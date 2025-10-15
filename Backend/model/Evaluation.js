const { DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const Evaluation = sequelize.define('Evaluation', {
  evaluation_id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
  child_id: { type: DataTypes.INTEGER, allowNull: false },
  specialist_id: { type: DataTypes.INTEGER, allowNull: false },
  evaluation_type: { type: DataTypes.ENUM('Initial', 'Mid', 'Final'), defaultValue: 'Initial' },
  notes: DataTypes.TEXT,
  progress_score: DataTypes.DECIMAL(5, 2),
  created_at: { type: DataTypes.DATE, defaultValue: DataTypes.NOW }
});

module.exports = Evaluation;
