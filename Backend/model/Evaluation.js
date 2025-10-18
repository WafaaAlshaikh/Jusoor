const { DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const Evaluation = sequelize.define('Evaluation', {
  evaluation_id: { 
    type: DataTypes.INTEGER, 
    primaryKey: true, 
    autoIncrement: true 
  },
  child_id: { 
    type: DataTypes.BIGINT.UNSIGNED, 
    allowNull: false,
    references: {
      model: 'Children', // غير لـ Children (بالجمع)
      key: 'child_id'
    },
    onUpdate: 'CASCADE',
    onDelete: 'RESTRICT'
  },
  specialist_id: { 
    type: DataTypes.BIGINT.UNSIGNED, 
    allowNull: false,
    references: {
      model: 'Specialists', // غير لـ Specialists (بالجمع)
      key: 'specialist_id'
    },
    onUpdate: 'CASCADE',
    onDelete: 'RESTRICT'
  },
  evaluation_type: { 
    type: DataTypes.ENUM('Initial', 'Mid', 'Final', 'Follow-up'), 
    defaultValue: 'Initial' 
  },
  notes: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  progress_score: {
    type: DataTypes.DECIMAL(5, 2),
    allowNull: true
  },
  attachment: {
    type: DataTypes.STRING(500),
    allowNull: true
  },
  created_at: { 
    type: DataTypes.DATE, 
    defaultValue: DataTypes.NOW 
  }
}, {
  tableName: 'Evaluations',
  timestamps: false
});

// أو أزل العلاقات من التعريف وخلها في associate فقط
Evaluation.associate = function(models) {
  Evaluation.belongsTo(models.Child, { 
    foreignKey: 'child_id',
    targetKey: 'child_id'
  });
  Evaluation.belongsTo(models.Specialist, { 
    foreignKey: 'specialist_id',
    targetKey: 'specialist_id'
  });
};

module.exports = Evaluation;