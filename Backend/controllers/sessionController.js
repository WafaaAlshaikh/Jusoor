// controllers/upcomingSessionsController.js
const Session = require('../model/Session');
const Child = require('../model/Child');
const Institution = require('../model/Institution');
const User = require('../model/User'); // Specialist info

const getUpcomingSessions = async (req, res) => {
  try {
    const parentId = req.user.user_id; // مفروض middleware يحط req.user من التوكن

    // جلب جميع الأطفال التابعين للوالد
    const children = await Child.findAll({ where: { parent_id: parentId } });
    const childIds = children.map(c => c.child_id);
    if (childIds.length === 0) return res.status(200).json({ sessions: [] });

    // جلب الجلسات القادمة لكل الأطفال
    const sessions = await Session.findAll({
      where: {
        child_id: childIds,
        status: 'Scheduled'
      },
      include: [
        { model: Child, attributes: ['full_name'], as: 'child' },
        { model: User, attributes: ['full_name'], as: 'specialist' },
        { model: Institution, attributes: ['name'], as: 'institution' },
      ],
      order: [['date', 'ASC'], ['time', 'ASC']]
    });

    // تحويل البيانات للشكل المطلوب للفلاتر
    const formattedSessions = sessions.map(s => ({
      sessionId: s.session_id,
      childName: s.child.full_name,
      specialistName: s.specialist.full_name,
      institutionName: s.institution.name,
      date: s.date,
      time: s.time,
      duration: s.duration,
      price: s.price,
      sessionType: s.session_type,
      status: s.status,
    }));

    res.status(200).json({ sessions: formattedSessions });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
};

module.exports = { getUpcomingSessions };
