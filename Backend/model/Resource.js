// models/Resource.js
const { DataTypes } = require('sequelize');
const sequelize = require('../config/db');
const Diagnosis = require('./Diagnosis');

const Resource = sequelize.define('Resource', {
  resource_id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
  title: { type: DataTypes.STRING, allowNull: false },
  description: { type: DataTypes.TEXT },
  link: { type: DataTypes.STRING },
  type: { type: DataTypes.STRING }, // مثال: 'article', 'video', 'pdf'
  created_at: { type: DataTypes.DATE, defaultValue: DataTypes.NOW }
}, {
  tableName: 'resources',
  timestamps: false
});

// العلاقة مع التشخيص
Resource.belongsToMany(Diagnosis, {
  through: 'resource_diagnosis',
  foreignKey: 'resource_id',
  otherKey: 'diagnosis_id'
});

module.exports = Resource;
