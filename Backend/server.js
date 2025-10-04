// server.js
const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const sequelize = require('./config/db');
const index = require('./model/index');

dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());

const startServer = async () => {
  try {
    await sequelize.authenticate();
    console.log('✅ Database connected');

    // الآن Sequelize يعرف عن موديل User
    await sequelize.sync({ alter: true }); // alter: true → يحدث الجدول إذا تغير
    console.log('✅ All models synced with DB');

    const PORT = process.env.PORT || 5000;
    app.listen(PORT, () => console.log(`🚀 Server running on port ${PORT}`));
  } catch (err) {
    console.log('❌ DB Error or Sync Error: ', err);
  }
};

startServer();
