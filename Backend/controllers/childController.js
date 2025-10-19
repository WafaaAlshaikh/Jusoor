// controllers/childController.js 
const Child = require('../model/Child');
const Diagnosis = require('../model/Diagnosis');
const Session = require('../model/Session');
const Institution = require('../model/Institution');
const ChildRegistrationRequest = require('../model/ChildRegistrationRequest');
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

    const where = { parent_id: parentId, deleted_at: null };

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

   let include = [
  {
    model: Diagnosis,
    attributes: ['name'],
    as: 'Diagnosis',
    required: false
  }
];

if (diagnosis && diagnosis !== 'All') {
  if (isNaN(parseInt(diagnosis, 10))) {
    include = [
      {
        model: Diagnosis,
        attributes: ['name'],
        as: 'Diagnosis',
        required: true,
        where: { name: diagnosis }
      }
    ];
  } else {
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
        status: 'Active',
        registration_status: childData.registration_status || 'Not Registered'
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
        parent_id: parentId,
        deleted_at: null 
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
      status: 'Active',
      registration_status: child.registration_status || 'Not Registered',
      current_institution_id: child.current_institution_id
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
      institution_id
    } = req.body;

    if (!full_name || !date_of_birth || !gender) {
      return res.status(400).json({ 
        message: 'Full name, date of birth, and gender are required' 
      });
    }

    // إنشاء الطفل الأساسي
    const newChild = await Child.create({
      parent_id: parentId,
      full_name,
      date_of_birth,
      gender,
      diagnosis_id: diagnosis_id || null,
      photo: photo || '',
      medical_history: medical_history || '',
      registration_status: 'Not Registered',
      current_institution_id: null
    });

    let registrationRequested = false;

    // إذا أرسل institution_id، ننشئ طلب انضمام
    if (institution_id) {
      try {
        await ChildRegistrationRequest.create({
          child_id: newChild.child_id,
          institution_id: institution_id,
          requested_by_parent_id: parentId,
          status: 'Pending'
        });

        await newChild.update({ registration_status: 'Pending' });
        registrationRequested = true;
        
      } catch (importError) {
        console.log('Note: ChildRegistrationRequest creation failed, but child was created');
        // نكمل بدون طلب الانضمام
      }
    }

    res.status(201).json({ 
      message: 'Child added successfully', 
      child_id: newChild.child_id,
      ...(registrationRequested && { registration_requested: true })
    });

  } catch (error) {
    console.error('Error adding child:', error);
    res.status(500).json({ 
      message: 'Failed to add child', 
      error: error.message 
    });
  }
};

// ================= REQUEST INSTITUTION REGISTRATION =================
exports.requestInstitutionRegistration = async (req, res) => {
  try {
    const parentId = req.user.user_id;
    const { child_id, institution_id } = req.body;

    const child = await Child.findOne({
      where: { child_id, parent_id: parentId }
    });

    if (!child) {
      return res.status(404).json({ message: 'Child not found' });
    }

    const existingRequest = await ChildRegistrationRequest.findOne({
      where: { 
        child_id, 
        status: 'Pending' 
      }
    });

    if (existingRequest) {
      return res.status(400).json({ 
        message: 'Child already has a pending registration request' 
      });
    }

    await ChildRegistrationRequest.create({
      child_id,
      institution_id,
      requested_by_parent_id: parentId,
      status: 'Pending'
    });

    await child.update({ registration_status: 'Pending' });

    res.status(201).json({ 
      message: 'Registration request submitted successfully',
      status: 'Pending'
    });

  } catch (error) {
    console.error('Error requesting registration:', error);
    res.status(500).json({ 
      message: 'Failed to submit registration request', 
      error: error.message 
    });
  }
};

// ================= GET REGISTRATION STATUS =================
exports.getRegistrationStatus = async (req, res) => {
  try {
    const parentId = req.user.user_id;
    const { id } = req.params; // ⬅️ استخدم id من الـ URL

    console.log('Fetching registration status for child:', id);

    // الحل البديل: جلب البيانات بشكل منفصل
    const child = await Child.findOne({
      where: { 
        child_id: id, 
        parent_id: parentId,
        deleted_at: null 
      },
      attributes: ['child_id', 'full_name', 'registration_status', 'current_institution_id']
    });

    if (!child) {
      return res.status(404).json({ message: 'Child not found' });
    }

    // جلب طلبات الانضمام بشكل منفصل
    const registrationRequests = await ChildRegistrationRequest.findAll({
      where: { child_id: id },
      include: [
        {
          model: Institution,
          attributes: ['name', 'institution_id']
        },
        {
          model: require('../model/User'),
          as: 'assignedManager',
          attributes: ['full_name']
        }
      ],
      order: [['requested_at', 'DESC']]
    });

    const response = {
      child_id: child.child_id,
      child_name: child.full_name,
      registration_status: child.registration_status,
      current_institution: child.current_institution_id ? {
        institution_id: child.current_institution_id,
      } : null,
      registration_requests: registrationRequests.map(req => ({
        request_id: req.request_id,
        institution_id: req.institution_id,
        institution_name: req.Institution ? req.Institution.name : 'Unknown',
        status: req.status,
        requested_at: req.requested_at,
        reviewed_at: req.reviewed_at,
        notes: req.notes,
        assigned_manager: req.assignedManager ? req.assignedManager.full_name : null
      }))
    };

    res.status(200).json(response);

  } catch (error) {
    console.error('Error fetching registration status:', error);
    res.status(500).json({ 
      message: 'Failed to fetch registration status', 
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

    const child = await Child.findOne({
      where: { 
        child_id: childId,
        parent_id: parentId 
      }
    });

    if (!child) {
      return res.status(404).json({ message: 'Child not found' });
    }

    await child.update({
      full_name: full_name,
      date_of_birth: date_of_birth,
      gender: gender,
      diagnosis_id: diagnosis_id,
      photo: photo || child.photo,
      medical_history: medical_history || child.medical_history
    });

    const updatedChild = await Child.findByPk(childId, {
      include: [
        {
          model: Diagnosis,
          attributes: ['name'],
          as: 'Diagnosis'
        }
      ]
    });

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
      status: 'Active',
      registration_status: updatedChild.registration_status || 'Not Registered'
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
// ================= SOFT DELETE CHILD =================
exports.deleteChild = async (req, res) => {
  try {
    const childId = req.params.id;
    const parentId = req.user.user_id;

    const child = await Child.findOne({
      where: { 
        child_id: childId,
        parent_id: parentId,
        deleted_at: null // ⬅️ تأكد إنه مش محذوف already
      }
    });

    if (!child) {
      return res.status(404).json({ message: 'Child not found or already deleted' });
    }

    // Soft Delete - تحديث حقل deleted_at
    await child.update({
      deleted_at: new Date(),
      registration_status: 'Archived' // ⬅️ غير الحالة
    });

    res.status(200).json({ 
      message: 'Child archived successfully',
      child_id: childId
    });

  } catch (error) {
    console.error('Error archiving child:', error);
    res.status(500).json({ 
      message: 'Failed to archive child', 
      error: error.message 
    });
  }
};

// ================= GET CHILD STATISTICS =================
exports.getChildStatistics = async (req, res) => {
  try {
    const parentId = req.user.user_id;

    const children = await Child.findAll({
      where: { parent_id: parentId, deleted_at: null },
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
      byRegistrationStatus: {
        'Not Registered': 0,
        'Pending': 0,
        'Approved': 0
      },
      activeChildren: children.length
    };

    children.forEach(child => {
      const condition = child.Diagnosis ? child.Diagnosis.name : 'Not Diagnosed';
      statistics.byCondition[condition] = (statistics.byCondition[condition] || 0) + 1;

      if (child.gender) {
        statistics.byGender[child.gender] = (statistics.byGender[child.gender] || 0) + 1;
      }

      const regStatus = child.registration_status || 'Not Registered';
      statistics.byRegistrationStatus[regStatus] = (statistics.byRegistrationStatus[regStatus] || 0) + 1;
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