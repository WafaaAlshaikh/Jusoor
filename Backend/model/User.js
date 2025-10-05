const { DataTypes } = require('sequelize');
const sequelize = require('../config/db'); 

const User = sequelize.define('User', {
    user_id: {
        type: DataTypes.BIGINT.UNSIGNED, 
        autoIncrement: true,
        primaryKey: true
    },
    full_name: {
        type: DataTypes.STRING(100),
        allowNull: false
    },
    email: {
        type: DataTypes.STRING(100),
        allowNull: false,
        unique: true
    },
    password: {
        type: DataTypes.STRING(255),
        allowNull: false
    },
    phone: {
        type: DataTypes.STRING(20),
        allowNull: true
    },
    role: {
        type: DataTypes.ENUM('Admin','Parent','Specialist','Donor','Institution'),
        allowNull: false,
        defaultValue: 'Parent'
    },
    profile_picture: {
        type: DataTypes.STRING(255),
        allowNull: true
    },
    status: {
        type: DataTypes.ENUM('Pending', 'Approved', 'Canceled'),
        defaultValue: 'Pending'
    },
    created_at: {
        type: DataTypes.DATE,
        defaultValue: DataTypes.NOW
    },
    updated_at: {
        type: DataTypes.DATE,
        defaultValue: DataTypes.NOW
    }
}, {
    tableName: 'Users',
    timestamps: false, 
});

module.exports = User;
