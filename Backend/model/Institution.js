const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');
const User = require('./User');

const Institution = sequelize.define('Institution', {
  institution_id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    references: {
      model: User,
      key: 'user_id'
    }
  },
  name: {
    type: DataTypes.STRING(100),
    allowNull: false
  },
  description: DataTypes.TEXT,
  location: DataTypes.STRING(255),
  website: DataTypes.STRING(100),
  contact_info: DataTypes.STRING(100)
});

module.exports = Institution;
