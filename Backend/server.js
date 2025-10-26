  // server.js
  const express = require('express');
  const cors = require('cors');
  const dotenv = require('dotenv');
  const sequelize = require('./config/db');
  const authRoutes = require('./routes/authRoutes'); 
  require('./model/index'); 
  const testRoutes = require('./routes/testRoutes');
  const forgotPasswordRoutes = require('./routes/forgotPasswordRoutes');
  const parentRoutes = require('./routes/parentRoutes');
  const specialistRoutes = require('./routes/specialistRoutes');
  const sessionRoutes = require('./routes/sessionRoutes');
  const childRoutes = require('./routes/childRoutes');
  const resourceRoutes = require('./routes/resourceRoutes');
  const institutionRoutes = require('./routes/institutionRoutes');
const specialistChildrenRoutes = require('./routes/specialistChildrenRoutes');
const communityRoutes = require('./routes/communityRoutes');

  const path = require('path');

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
  app.use('/api', resourceRoutes);
  app.use('/api', institutionRoutes);
  app.use('/api/community', communityRoutes);
 app.use('/api/specialist', require('./routes/specialistSessionRoutes'));

app.use('/api/specialist', specialistChildrenRoutes);




  app.use('/api/specialist', specialistRoutes);
  app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

  // Routes
  app.use('/api/evaluations', require('./routes/evaluations'));
  // باقي ال routes...
  app.use('/api/vacations', require('./routes/vacationRoutes'));

  // أنشئ مجلد uploads إذا لم يكن موجود
  const fs = require('fs');
  const uploadsDir = path.join(__dirname, 'uploads/evaluations');
  if (!fs.existsSync(uploadsDir)) {
    fs.mkdirSync(uploadsDir, { recursive: true });
  }
  // Start server
  const startServer = async () => {
    try {
      await sequelize.authenticate();
      console.log('✅ Database connected');

      await sequelize.sync( );

      console.log('✅ All models synced with DB');

      const PORT = process.env.PORT || 5000;
      app.listen(PORT, () => console.log(`🚀 Server running on http://localhost:${PORT}`));
    } catch (err) {
      console.log('❌ DB Error or Sync Error: ', err);
    }
  };

  startServer();
