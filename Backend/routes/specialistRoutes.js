const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/authMiddleware');
const { 
  getUpcomingSessionsCount, 
  getChildrenCount, 
  addSession,
  getChildrenInInstitution
} = require('../controllers/specialistController');

// 🔒 كل الرُتب بس للأخصائيين (تحقق من الـ role)
const specialistOnly = (req, res, next) => {
  if (req.user.role !== 'Specialist') {
    return res.status(403).json({ message: 'Access denied' });
  }
  next();
};
const { getProfileInfo } = require('../controllers/specialistController');
// 🔹 احصائيات
router.get('/upcoming-sessions', authMiddleware, specialistOnly, getUpcomingSessionsCount);
router.get('/children-count', authMiddleware, specialistOnly, getChildrenCount);


// endpoint لجلب بيانات الملف الشخصي
router.get('/me', authMiddleware, (req, res) => {
  // إذا بدك تقتصر على الأخصائيين:
  if (req.user.role !== 'Specialist') {
    return res.status(403).json({ message: 'Access denied' });
  }
  getProfileInfo(req, res);
});

// 🔹 إضافة جلسة
router.post('/add-session', authMiddleware, specialistOnly, addSession);
router.get(
  '/institution-children',
  authMiddleware,
  specialistOnly,
  getChildrenInInstitution
);
module.exports = router;
