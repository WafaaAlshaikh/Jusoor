const Session = require('../model/Session');
const Child = require('../model/Child');
const Institution = require('../model/Institution');
const User = require('../model/User'); 
const { Op } = require('sequelize');


const getUpcomingSessions = async (req, res) => {
  try {
    const parentId = req.user.user_id;

    const children = await Child.findAll({ where: { parent_id: parentId } });
    const childIds = children.map(c => c.child_id);
    if (childIds.length === 0) return res.status(200).json({ sessions: [] });

    const sessions = await Session.findAll({
      where: { 
        child_id: { [Op.in]: childIds },
        status: { [Op.in]: ['Scheduled', 'Completed', 'Cancelled','Confirmed'] }
      },
      include: [
        { model: Child, attributes: ['full_name'], as: 'child' },
        { model: User, attributes: ['full_name'], as: 'specialist' },
        { model: Institution, attributes: ['name'], as: 'institution' },
      ],
      order: [['date', 'ASC'], ['time', 'ASC']]
    });

    const formatted = sessions.map(s => ({
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

    res.status(200).json({ sessions: formatted });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};


const getCompletedSessions = async (req, res) => {
  try {
    const parentId = req.user.user_id;
    const children = await Child.findAll({ where: { parent_id: parentId } });
    const childIds = children.map(c => c.child_id);
    if (!childIds.length) return res.json({ sessions: [] });

    const sessions = await Session.findAll({
      where: { child_id: childIds, status: 'Completed' },
      include: [
        { model: Child, attributes: ['full_name'], as: 'child' },
        { model: User, attributes: ['full_name'], as: 'specialist' },
        { model: Institution, attributes: ['name'], as: 'institution' },
      ],
      order: [['date', 'DESC'], ['time', 'DESC']]
    });

    const formatted = sessions.map(s => ({
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

    res.json({ sessions: formatted });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

const confirmSession = async (req, res) => {
  const { id } = req.params;
  try {
    const session = await Session.findByPk(id);
    if (!session) return res.status(404).json({ message: 'Session not found' });

    session.status = 'Confirmed';
    await session.save();
    res.json({ success: true, message: 'Session confirmed' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

const cancelSession = async (req, res) => {
  const { id } = req.params;
  try {
    const session = await Session.findByPk(id);
    if (!session) return res.status(404).json({ message: 'Session not found' });

    session.status = 'Cancelled';
    await session.save();
    res.json({ success: true, message: 'Session cancelled' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

const getChildSessions = async (req, res) => {
  try {
    const { childId } = req.params; // هنعطيه من الـ URL
    if (!childId) return res.status(400).json({ message: 'Child ID is required' });

    const sessions = await Session.findAll({
      where: { child_id: childId, status: ['Scheduled', 'Completed', 'Cancelled', 'Confirmed'] },
      include: [
        { model: Child, attributes: ['full_name'], as: 'child' },
        { model: User, attributes: ['full_name'], as: 'specialist' },
        { model: Institution, attributes: ['name'], as: 'institution' },
      ],
      order: [['date', 'ASC'], ['time', 'ASC']]
    });

    const formatted = sessions.map(s => ({
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

    res.status(200).json({ sessions: formatted });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

module.exports = {
  getUpcomingSessions,
  getCompletedSessions,
  confirmSession,
  cancelSession,
  getChildSessions, // ضيفنا الدالة الجديدة هنا
};

