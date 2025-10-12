const { DataTypes } = require('sequelize');
const sequelize = require('../config/db');
const Parent = require('./Parent');
const Diagnosis = require('./Diagnosis');

const Child = sequelize.define('Child', {
  child_id: { type: DataTypes.BIGINT.UNSIGNED, autoIncrement: true, primaryKey: true },
  parent_id: { type: DataTypes.BIGINT.UNSIGNED, allowNull: false },
  full_name: { type: DataTypes.STRING(100), allowNull: false },
  date_of_birth: { type: DataTypes.DATE },
  gender: { type: DataTypes.ENUM('Male', 'Female', 'Other') },
  diagnosis_id: { type: DataTypes.BIGINT.UNSIGNED },
  photo: { type: DataTypes.STRING(255) },
  medical_history: { type: DataTypes.TEXT },
}, { tableName: 'Children', timestamps: false });

Child.belongsTo(Parent, { foreignKey: 'parent_id' });
Child.belongsTo(Diagnosis, { foreignKey: 'diagnosis_id' });

module.exports = Child;
