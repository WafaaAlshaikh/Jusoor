const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');
const User = require('./User');
const Institution = require('./Institution');

const Specialist = sequelize.define('Specialist', {
  specialist_id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    references: {
      model: User,
      key: 'user_id'
    }
  },
  specialization: {
    type: DataTypes.STRING(100)
  },
  years_experience: {
    type: DataTypes.INTEGER
  },
  institution_id: {
    type: DataTypes.INTEGER,
    references: {
      model: Institution,
      key: 'institution_id'
    }
  }
});

module.exports = Specialist;
