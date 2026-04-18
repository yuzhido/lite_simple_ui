/**
 * 区域位置数据模型 (Sequelize)
 * 支持树形结构（通过 parentId）
 */

const { DataTypes } = require('sequelize');
const { sequelize } = require('../../config/database');
const { snowflake } = require('../../utils/snowflake');

const Area = sequelize.define(
  'Area',
  {
    id: {
      type: DataTypes.STRING,
      primaryKey: true,
      allowNull: false,
      unique: true,
      defaultValue: () => snowflake.nextId(),
      comment: '雪花算法生成的唯一ID（字符串类型以避免精度丢失）'
    },
    name: {
      type: DataTypes.STRING(100),
      allowNull: false,
      validate: {
        notEmpty: { msg: '区域名称不能为空' },
        len: {
          args: [1, 100],
          msg: '区域名称不能超过 100 个字符'
        }
      },
      comment: '区域名称'
    },
    description: {
      type: DataTypes.TEXT,
      allowNull: true,
      defaultValue: '',
      comment: '区域描述'
    },
    parentId: {
      type: DataTypes.STRING,
      allowNull: true,
      defaultValue: null,
      comment: '父级区域ID（为空表示顶级区域）'
    },
    version: {
      type: DataTypes.INTEGER,
      allowNull: false,
      defaultValue: 0,
      comment: '版本号（乐观锁控制）'
    },
    createUser: {
      type: DataTypes.STRING(50),
      allowNull: true,
      defaultValue: '',
      comment: '创建人'
    },
    modifyUser: {
      type: DataTypes.STRING(50),
      allowNull: true,
      defaultValue: '',
      comment: '修改人'
    }
  },
  {
    tableName: 'areas',
    timestamps: true,
    underscored: true,
    createdAt: 'create_time',
    updatedAt: 'modify_time',
    hooks: {
      // 在创建前自动生成雪花算法 ID
      beforeCreate: (area) => {
        if (!area.id) {
          area.id = snowflake.nextId();
        }
        // 初始化版本号
        if (!area.version) {
          area.version = 0;
        }
      },
      // 在批量创建前生成 ID
      beforeBulkCreate: (areas) => {
        areas.forEach((area) => {
          if (!area.id) {
            area.id = snowflake.nextId();
          }
          if (!area.version) {
            area.version = 0;
          }
        });
      }
    }
  }
);

// 自关联：一个区域可以有多个子区域
Area.hasMany(Area, {
  foreignKey: 'parent_id',
  as: 'children'
});

// 自关联：一个区域属于一个父区域
Area.belongsTo(Area, {
  foreignKey: 'parent_id',
  as: 'parent'
});

module.exports = Area;
