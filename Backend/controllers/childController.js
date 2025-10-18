// controllers/childController.js 
const Child = require('../model/Child');
const Diagnosis = require('../model/Diagnosis');
const Session = require('../model/Session');
const { ChildInstitution } = require('../model/ChildInstitution');
const Institution = require('../model/Institution');
const { Op } = require('sequelize');

// ================= GET CHILDREN =================
exports.getChildren = async (req, res) => {
  try {
    const parentId = req.user.user_id;

    const {
      search = '',
      gender,
      diagnosis, 
      sort = 'name', 
      order = 'asc',
      page = '1',
      limit = '50',
    } = req.query;

    const pageNum = Math.max(1, parseInt(page, 10) || 1);
    const pageLimit = Math.max(1, parseInt(limit, 10) || 50);
    const offset = (pageNum - 1) * pageLimit;

    const where = { parent_id: parentId };

    if (search && search.trim() !== '') {
      where.full_name = { [Op.like]: `%${search.trim()}%` };
    }

    if (gender && (gender === 'Male' || gender === 'Female')) {
      where.gender = gender;
    }

    if (diagnosis && diagnosis !== 'All') {
      if (!isNaN(parseInt(diagnosis, 10))) {
        where.diagnosis_id = parseInt(diagnosis, 10);
      } else {
        where['$Diagnosis.name$'] = { [Op.eq]: diagnosis };
      }
    }

   // تعديل جزء الفلترة
let include = [
  {
    model: Diagnosis,
    attributes: ['name'],
    as: 'Diagnosis',
    required: false // false يعني رح يظهر حتى لو ما عنده diagnosis
  }
];

if (diagnosis && diagnosis !== 'All') {
  // إذا diagnosis اسم وليس رقم
  if (isNaN(parseInt(diagnosis, 10))) {
    include = [
      {
        model: Diagnosis,
        attributes: ['name'],
        as: 'Diagnosis',
        required: true, // مهم لتطبيق فلتر على الاسم
        where: { name: diagnosis } // هنا فلترة الاسم
      }
    ];
  } else {
    // فلترة بالـ diagnosis_id موجودة عندك
    where.diagnosis_id = parseInt(diagnosis, 10);
  }
}


    let orderArray = [];
    if (sort === 'age') {
      orderArray.push(['date_of_birth', order === 'asc' ? 'ASC' : 'DESC']);
    } else if (sort === 'lastSession') {
       orderArray.push(['date_of_birth', 'ASC']);
    } else {
      orderArray.push(['full_name', order === 'asc' ? 'ASC' : 'DESC']);
    }

    const children = await Child.findAll({
      where,
      include,
      offset,
      limit: pageLimit,
      order: orderArray
    });

    const processedChildren = await Promise.all(children.map(async (child) => {
      const childData = child.get({ plain: true });

      let age = 0;
      if (childData.date_of_birth) {
        const birthDate = new Date(childData.date_of_birth);
        const today = new Date();
        age = today.getFullYear() - birthDate.getFullYear();
        const monthDiff = today.getMonth() - birthDate.getMonth();
        if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthDate.getDate())) {
          age--;
        }
      }

      const lastSession = await Session.findOne({
        where: { child_id: childData.child_id },
        order: [['date', 'DESC']],
        limit: 1
      });

      return {
        id: childData.child_id,
        full_name: childData.full_name,
        date_of_birth: childData.date_of_birth,
        gender: childData.gender,
        diagnosis_id: childData.diagnosis_id,
        photo: childData.photo || '',
        medical_history: childData.medical_history || '',
        condition: childData.Diagnosis ? childData.Diagnosis.name : null,
        age: age,
        last_session_date: lastSession ? lastSession.date : null,
        status: 'Active'
      };
    }));

    res.status(200).json({
      data: processedChildren,
      meta: {
        page: pageNum,
        limit: pageLimit,
        returned: processedChildren.length
      }
    });

  } catch (error) {
    console.error('Error fetching children:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};


// ================= GET SINGLE CHILD =================
exports.getChild = async (req, res) => {
  try {
    const childId = req.params.id;
    const parentId = req.user.user_id;

    const child = await Child.findOne({
      where: { 
        child_id: childId,
        parent_id: parentId 
      },
      include: [
        {
          model: Diagnosis,
          attributes: ['name'],
          as: 'Diagnosis'
        }
      ]
    });

    if (!child) {
      return res.status(404).json({ message: 'Child not found' });
    }

    // حساب العمر
    let age = 0;
    if (child.date_of_birth) {
      const birthDate = new Date(child.date_of_birth);
      const today = new Date();
      age = today.getFullYear() - birthDate.getFullYear();
      const monthDiff = today.getMonth() - birthDate.getMonth();
      if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthDate.getDate())) {
        age--;
      }
    }

    // جلب آخر جلسة
    const lastSession = await Session.findOne({
      where: { child_id: childId },
      order: [['date', 'DESC']],
      limit: 1
    });

    const childData = {
      id: child.child_id,
      full_name: child.full_name,
      date_of_birth: child.date_of_birth,
      gender: child.gender,
      diagnosis_id: child.diagnosis_id,
      photo: child.photo || '',
      medical_history: child.medical_history || '',
      condition: child.Diagnosis ? child.Diagnosis.name : null,
      age: age,
      last_session_date: lastSession ? lastSession.date : null,
      status: 'Active'
    };

    res.status(200).json(childData);

  } catch (error) {
    console.error('Error fetching child:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};


// ================= ADD CHILD =================
exports.addChild = async (req, res) => {
  try {
    const parentId = req.user.user_id;
    const { 
      full_name, 
      date_of_birth, 
      gender, 
      diagnosis_id, 
      photo, 
      medical_history,
      institution_id  // <- جديد
    } = req.body;

    if (!full_name || !date_of_birth || !gender || !institution_id) {
      return res.status(400).json({ 
        message: 'Full name, date of birth, gender, and institution are required' 
      });
    }

    // إنشاء الطفل
    const newChild = await Child.create({
      parent_id: parentId,
      full_name,
      date_of_birth,
      gender,
      diagnosis_id: diagnosis_id || null,
      photo: photo || '',
      medical_history: medical_history || ''
    });

    // ربط الطفل بالمؤسسة
    const institution = await Institution.findByPk(institution_id);
    if (!institution) {
      return res.status(404).json({ message: 'Institution not found' });
    }

    await ChildInstitution.create({
      child_id: newChild.child_id,
      institution_id: institution.institution_id
    });

    res.status(201).json({ 
      message: 'Child added successfully', 
      child_id: newChild.child_id,
      institution_id: institution.institution_id
    });

  } catch (error) {
    console.error('Error adding child:', error);
    res.status(500).json({ message: 'Failed to add child', error: error.message });
  }
};


// ================= UPDATE CHILD =================
exports.updateChild = async (req, res) => {
  try {
    const childId = req.params.id;
    const parentId = req.user.user_id;
    const { 
      full_name, 
      date_of_birth, 
      gender, 
      diagnosis_id, 
      photo, 
      medical_history 
    } = req.body;

    // التحقق من ملكية الطفل
    const child = await Child.findOne({
      where: { 
        child_id: childId,
        parent_id: parentId 
      }
    });

    if (!child) {
      return res.status(404).json({ message: 'Child not found' });
    }

    // تحديث البيانات
    await child.update({
      full_name: full_name,
      date_of_birth: date_of_birth,
      gender: gender,
      diagnosis_id: diagnosis_id,
      photo: photo || child.photo,
      medical_history: medical_history || child.medical_history
    });

    // جلب البيانات المحدثة مع الـ Diagnosis
    const updatedChild = await Child.findByPk(childId, {
      include: [
        {
          model: Diagnosis,
          attributes: ['name'],
          as: 'Diagnosis'
        }
      ]
    });

    // حساب العمر
    let age = 0;
    if (updatedChild.date_of_birth) {
      const birthDate = new Date(updatedChild.date_of_birth);
      const today = new Date();
      age = today.getFullYear() - birthDate.getFullYear();
      const monthDiff = today.getMonth() - birthDate.getMonth();
      if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthDate.getDate())) {
        age--;
      }
    }

    const childResponse = {
      id: updatedChild.child_id,
      full_name: updatedChild.full_name,
      date_of_birth: updatedChild.date_of_birth,
      gender: updatedChild.gender,
      diagnosis_id: updatedChild.diagnosis_id,
      photo: updatedChild.photo,
      medical_history: updatedChild.medical_history,
      condition: updatedChild.Diagnosis ? updatedChild.Diagnosis.name : null,
      age: age,
      last_session_date: null,
      status: 'Active'
    };

    res.status(200).json(childResponse);

  } catch (error) {
    console.error('Error updating child:', error);
    res.status(500).json({ 
      message: 'Failed to update child', 
      error: error.message 
    });
  }
};

// ================= DELETE CHILD =================
exports.deleteChild = async (req, res) => {
  try {
    const childId = req.params.id;
    const parentId = req.user.user_id;

    const child = await Child.findOne({
      where: { 
        child_id: childId,
        parent_id: parentId 
      }
    });

    if (!child) {
      return res.status(404).json({ message: 'Child not found' });
    }

    await child.destroy();
    
    res.status(200).json({ 
      message: 'Child deleted successfully',
      deletedChildId: childId
    });

  } catch (error) {
    console.error('Error deleting child:', error);
    res.status(500).json({ 
      message: 'Failed to delete child', 
      error: error.message 
    });
  }
};

// ================= GET CHILD STATISTICS =================
exports.getChildStatistics = async (req, res) => {
  try {
    const parentId = req.user.user_id;

    const children = await Child.findAll({
      where: { parent_id: parentId },
      include: [
        {
          model: Diagnosis,
          attributes: ['name'],
          as: 'Diagnosis'
        }
      ]
    });

    const statistics = {
      totalChildren: children.length,
      byCondition: {},
      byGender: {
        Male: 0,
        Female: 0
      },
      activeChildren: children.length
    };

    children.forEach(child => {
      // إحصائيات حسب الحالة
      const condition = child.Diagnosis ? child.Diagnosis.name : 'Not Diagnosed';
      statistics.byCondition[condition] = (statistics.byCondition[condition] || 0) + 1;

      // إحصائيات حسب الجنس
      if (child.gender) {
        statistics.byGender[child.gender] = (statistics.byGender[child.gender] || 0) + 1;
      }
    });

    res.status(200).json(statistics);

  } catch (error) {
    console.error('Error fetching child statistics:', error);
    res.status(500).json({ 
      message: 'Failed to fetch statistics', 
      error: error.message 
    });
  }
};