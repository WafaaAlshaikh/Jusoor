const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/authMiddleware');
const { getParentDashboard } = require('../controllers/parentController');

router.get('/dashboard', authMiddleware, getParentDashboard);


module.exports = router;
