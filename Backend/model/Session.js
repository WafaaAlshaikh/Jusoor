const { DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const Session = sequelize.define('Session', {
  session_id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
  child_id: { type: DataTypes.BIGINT.UNSIGNED, allowNull: false },
  specialist_id: { type: DataTypes.BIGINT.UNSIGNED, allowNull: false },
  institution_id: { type: DataTypes.BIGINT.UNSIGNED, allowNull: false },
  date: { type: DataTypes.DATEONLY, allowNull: false },
  time: { type: DataTypes.TIME, allowNull: false },
  duration: DataTypes.INTEGER,
  price: DataTypes.DECIMAL(10, 2),
  session_type: { type: DataTypes.ENUM('Online', 'Onsite'), defaultValue: 'Onsite' },
  status: { type: DataTypes.ENUM('Scheduled', 'Completed', 'Cancelled'), defaultValue: 'Scheduled' }
});

module.exports = Session;
