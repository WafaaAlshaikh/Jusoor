// routes/parentRoutes.js
const express = require('express');
const router = express.Router();
const { getUpcomingSessions } = require('../controllers/sessionController');
const authMiddleware = require('../middleware/authMiddleware'); // JWT middleware

router.get('/upcoming-sessions', authMiddleware, getUpcomingSessions);

module.exports = router;
