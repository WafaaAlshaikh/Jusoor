const express = require('express');
const router = express.Router();
const childController = require('../controllers/childController');
const authMiddleware = require('../middleware/authMiddleware');

router.get('/', authMiddleware, childController.getChildren);
router.post('/', authMiddleware, childController.addChild);
router.get('/stats', authMiddleware, childController.getChildStatistics);
router.get('/:id', authMiddleware, childController.getChild);
router.put('/:id', authMiddleware, childController.updateChild);
router.delete('/:id', authMiddleware, childController.deleteChild);

module.exports = router;