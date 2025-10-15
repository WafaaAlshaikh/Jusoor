const { DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const Post = sequelize.define('Post', {
  post_id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
  institution_id: { type: DataTypes.INTEGER, allowNull: false },
  title: { type: DataTypes.STRING(255), allowNull: false },
  content: { type: DataTypes.TEXT, allowNull: false },
  type: { type: DataTypes.ENUM('Post', 'Campaign'), defaultValue: 'Post' },
  target_amount: DataTypes.DECIMAL(10, 2),
  created_at: { type: DataTypes.DATE, defaultValue: DataTypes.NOW }
});

module.exports = Post;