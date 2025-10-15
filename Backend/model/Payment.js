const { DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const Payment = sequelize.define('Payment', {
  payment_id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
  session_id: { type: DataTypes.INTEGER, allowNull: false },
  parent_id: { type: DataTypes.INTEGER, allowNull: false },
  amount: { type: DataTypes.DECIMAL(10, 2), allowNull: false },
  method: { type: DataTypes.ENUM('Cash', 'Card', 'Online'), allowNull: false },
  status: { type: DataTypes.ENUM('Pending', 'Paid', 'Failed'), defaultValue: 'Pending' },
  transaction_id: DataTypes.STRING(100),
  date: { type: DataTypes.DATE, defaultValue: DataTypes.NOW }
});

module.exports = Payment;
