/**
 * 用户数据模型 (Sequelize)
 * 使用雪花算法自动生成 ID
 */

const { DataTypes } = require('sequelize');
const { sequelize } = require('../../config/database');
const { snowflake } = require('../../utils/snowflake');
const { UserRole } = require('../../enums/userRole');

const User = sequelize.define(
  'User',
  {
    id: {
      type: DataTypes.STRING,
      primaryKey: true,
      allowNull: false,
      unique: true,
      defaultValue: () => snowflake.nextId(), // 使用默认值函数
      comment: '雪花算法生成的唯一ID（字符串类型以避免精度丢失）'
    },
    username: {
      type: DataTypes.STRING(50),
      allowNull: false,
      unique: true,
      validate: {
        notEmpty: { msg: '用户名不能为空' },
        len: {
          args: [1, 50],
          msg: '用户名不能超过 50 个字符'
        }
      },
      comment: '用户名'
    },
    email: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true,
      validate: {
        notEmpty: { msg: '邮箱不能为空' },
        isEmail: { msg: '请输入有效的邮箱地址' }
      },
      comment: '邮箱地址'
    },
    password: {
      type: DataTypes.STRING,
      allowNull: false,
      validate: {
        notEmpty: { msg: '密码不能为空' },
        len: {
          args: [6],
          msg: '密码至少需要 6 个字符'
        }
      },
      comment: '密码（加密存储）'
    },
    role: {
      type: DataTypes.ENUM(...Object.values(UserRole)),
      defaultValue: UserRole.USER,
      comment: '用户角色'
    },
    avatar: {
      type: DataTypes.STRING,
      defaultValue: '',
      comment: '头像 URL'
    },
    isActive: {
      type: DataTypes.BOOLEAN,
      defaultValue: true,
      comment: '是否激活'
    }
  },
  {
    tableName: 'users',
    timestamps: true,
    underscored: true,
    createdAt: 'created_at',
    updatedAt: 'updated_at',
    hooks: {
      // 在创建前自动生成雪花算法 ID
      beforeCreate: (user) => {
        if (!user.id) {
          user.id = snowflake.nextId();
        }
      },
      // 在批量创建前生成 ID
      beforeBulkCreate: (users) => {
        users.forEach((user) => {
          if (!user.id) {
            user.id = snowflake.nextId();
          }
        });
      }
    }
  }
);

module.exports = User;
