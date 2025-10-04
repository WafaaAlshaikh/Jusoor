const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const User = require('../model/User');
const Parent = require('../model/Parent');
require('dotenv').config();

const signup = async (req, res) => {
  const { full_name, email, password, phone, profile_picture, address, occupation } = req.body;

  // تحقق من الحقول الإلزامية
  if (!full_name || !email || !password) {
    return res.status(400).json({ message: 'Full name, email, and password are required' });
  }

  try {
    // تحقق إذا الإيميل موجود مسبقًا
    const existingUser = await User.findOne({ where: { email } });
    if (existingUser) {
      return res.status(400).json({ message: 'Email already registered' });
    }

    // تشفير الباسورد
    const hashedPassword = await bcrypt.hash(password, 10);

    // إنشاء User
    const user = await User.create({
      full_name,
      email,
      password: hashedPassword,
      phone: phone || null,
      profile_picture: profile_picture || null,
      role: 'Parent' // افتراضي
    });

    // إنشاء Parent record
    await Parent.create({
      parent_id: user.user_id,
      address: address || null,
      occupation: occupation || null
    });

    // إنشاء JWT
    const token = jwt.sign(
      { user_id: user.user_id, role: user.role },
      process.env.JWT_SECRET,
      { expiresIn: '7d' }
    );

    res.status(201).json({ message: 'User registered', token, user });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
};

module.exports = { signup };
