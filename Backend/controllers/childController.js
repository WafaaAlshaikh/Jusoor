// controllers/childController.js - الإصدار المكتمل
const Child = require('../model/Child');
const Diagnosis = require('../model/Diagnosis');
const Session = require('../model/Session');
const { Op } = require('sequelize');

// ================= GET CHILDREN =================
exports.getChildren = async (req, res) => {
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

    // معالجة البيانات لإضافة الحقول المطلوبة للفرونت
    const processedChildren = await Promise.all(children.map(async (child) => {
      const childData = child.get({ plain: true });
      
      // حساب العمر من تاريخ الميلاد
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

      // جلب آخر جلسة للطفل
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
        // الحقول الجديدة المطلوبة
        age: age,
        last_session_date: lastSession ? lastSession.date : null,
        status: 'Active'
      };
    }));

    res.status(200).json(processedChildren);

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
      medical_history 
    } = req.body;

    // التحقق من الحقول المطلوبة
    if (!full_name || !date_of_birth || !gender) {
      return res.status(400).json({ 
        message: 'Full name, date of birth, and gender are required' 
      });
    }

    const newChild = await Child.create({
      parent_id: parentId,
      full_name: full_name,
      date_of_birth: date_of_birth,
      gender: gender,
      diagnosis_id: diagnosis_id || null,
      photo: photo || '',
      medical_history: medical_history || ''
    });

    // جلب البيانات مع الـ Diagnosis
    const childWithDiagnosis = await Child.findByPk(newChild.child_id, {
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
    if (childWithDiagnosis.date_of_birth) {
      const birthDate = new Date(childWithDiagnosis.date_of_birth);
      const today = new Date();
      age = today.getFullYear() - birthDate.getFullYear();
      const monthDiff = today.getMonth() - birthDate.getMonth();
      if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthDate.getDate())) {
        age--;
      }
    }

    const childResponse = {
      id: childWithDiagnosis.child_id,
      full_name: childWithDiagnosis.full_name,
      date_of_birth: childWithDiagnosis.date_of_birth,
      gender: childWithDiagnosis.gender,
      diagnosis_id: childWithDiagnosis.diagnosis_id,
      photo: childWithDiagnosis.photo,
      medical_history: childWithDiagnosis.medical_history,
      condition: childWithDiagnosis.Diagnosis ? childWithDiagnosis.Diagnosis.name : null,
      age: age,
      last_session_date: null,
      status: 'Active'
    };

    res.status(201).json(childResponse);

  } catch (error) {
    console.error('Error adding child:', error);
    res.status(500).json({ 
      message: 'Failed to add child', 
      error: error.message 
    });
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