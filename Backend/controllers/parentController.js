const Parent = require('../model/Parent');
const Child = require('../model/Child');
const Diagnosis = require('../model/Diagnosis');
const User = require('../model/User');

const getParentDashboard = async (req, res) => {
  try {
    const parentId = req.user.user_id; 
    const parent = await Parent.findOne({
      where: { parent_id: parentId },
      include: [
        { model: User, attributes: ['full_name', 'email', 'phone', 'profile_picture'] },
      ]
    });

    if (!parent) return res.status(404).json({ message: 'Parent not found' });

    const children = await Child.findAll({
      where: { parent_id: parentId },
      include: [{ model: Diagnosis, attributes: ['name'] }],
    });

    res.status(200).json({
      parent: {
        name: parent.User.full_name,
        phone: parent.User.phone,
        address: parent.address,
        email: parent.User.email,
        profile_picture: parent.User.profile_picture,
      },
      children: children.map(c => ({
        name: c.full_name,
        condition: c.Diagnosis ? c.Diagnosis.name : 'Not diagnosed',
        image: c.photo,
      })),
      summaries: {
        upcomingSessions: 3,
        newAIAdviceCount: 5,
        notifications: [
          { icon: 'payment', title: 'Payment due for October sessions.' },
          { icon: 'check_circle', title: 'Evaluation report for Ali is ready.' },
          { icon: 'campaign', title: 'New donation campaign launched.' },
        ]
      }
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
};

module.exports = { getParentDashboard };
