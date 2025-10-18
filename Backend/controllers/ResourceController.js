const Resource = require('../model/Resource');
const Diagnosis = require('../model/Diagnosis');
const Child = require('../model/Child');

exports.getParentResources = async (req, res) => {
  try {
    const parentId = req.user.user_id;

    // 1. جلب جميع تشخيصات أطفال الوالد
    const children = await Child.findAll({ where: { parent_id: parentId }});
    const diagnosisIds = children.map(c => c.diagnosis_id);

    // 2. جلب الموارد المرتبطة بهذه التشخيصات
    const resources = await Resource.findAll({
      include: [{
        model: Diagnosis,
        where: { diagnosis_id: diagnosisIds },
        attributes: ['diagnosis_id', 'name'],
        through: { attributes: [] }
      }]
    });

    res.json(resources);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Failed to fetch resources', error: error.message });
  }
};
