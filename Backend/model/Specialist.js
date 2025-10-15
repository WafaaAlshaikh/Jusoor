const { DataTypes } = require('sequelize');
const sequelize = require('../config/db');
const User = require('./User');
const Institution = require('./Institution');

const Specialist = sequelize.define('Specialist', {
  specialist_id: {
    type: DataTypes.BIGINT.UNSIGNED,
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
    type: DataTypes.BIGINT.UNSIGNED,
    references: {
      model: Institution,
      key: 'institution_id'
    }
  }
});

module.exports = Specialist;