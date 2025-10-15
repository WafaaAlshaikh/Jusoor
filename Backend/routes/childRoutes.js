const express = require('express');
const router = express.Router();
const childController = require('../controllers/childController');
const authMiddleware = require('../middleware/authMiddleware');

router.get('/', authMiddleware, childController.getChildren);
router.post('/', authMiddleware, childController.addChild);
router.put('/:id', authMiddleware, childController.updateChild);
router.delete('/:id', authMiddleware, childController.deleteChild);

module.exports = router;
