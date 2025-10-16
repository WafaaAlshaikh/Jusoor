// server.js
const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const sequelize = require('./config/db');

const authRoutes = require('./routes/authRoutes'); 
const testRoutes = require('./routes/testRoutes');
const forgotPasswordRoutes = require('./routes/forgotPasswordRoutes');
const parentRoutes = require('./routes/parentRoutes');
const specialistRoutes = require('./routes/specialistRoutes');
const sessionRoutes = require('./routes/sessionRoutes');
const childRoutes = require('./routes/childRoutes');
const diagnosisRoutes = require('./routes/diagnosisRoutes');


require('./model/index'); 


dotenv.config();

const app = express();

// Middlewares
app.use(cors());
app.use(express.json());

// Test route
app.get('/test', (req, res) => {
  res.send('Server is working!');
});

// Auth routes
app.use('/api/auth', authRoutes);
app.use('/api', testRoutes);
app.use('/api/password', forgotPasswordRoutes);
app.use('/api/parent', parentRoutes);
app.use('/api/parent', sessionRoutes);
app.use('/api/children', childRoutes);
app.use('/api/diagnoses', diagnosisRoutes);




app.use('/api/specialist', specialistRoutes);

// Start server
const startServer = async () => {
  try {
    await sequelize.authenticate();
    console.log('✅ Database connected');

    await sequelize.sync({ alter: true });
    console.log('✅ All models synced with DB');

    const PORT = process.env.PORT || 5000;
    app.listen(PORT, () => console.log(`🚀 Server running on http://localhost:${PORT}`));
  } catch (err) {
    console.log('❌ DB Error or Sync Error: ', err);
  }
};

startServer();
