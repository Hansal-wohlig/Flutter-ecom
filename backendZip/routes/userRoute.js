const express = require('express');
const router = express.Router();
const { registerUser, loginUser, getUserProfile, googleLogin } = require('../controller/userController');
const { protect } = require('../middleware/authMiddleware');

router.post('/register', registerUser);
router.post('/login', loginUser);
router.post('/google-login', googleLogin);
router.get('/profile', protect, getUserProfile);

module.exports = router;
