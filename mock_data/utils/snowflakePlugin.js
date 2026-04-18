/**
 * Mongoose 雪花算法 ID 插件
 * 自动为 Mongoose Schema 生成雪花算法 ID
 */

const { snowflake } = require('./snowflake');

/**
 * 雪花算法 ID 插件
 * 使用方法：schema.plugin(snowflakeIdPlugin)
 */
const snowflakeIdPlugin = (schema, options = {}) => {
  const {
    fieldName = '_id', // ID 字段名
    fieldType = String, // 字段类型
    autoGenerate = true // 是否自动生成
  } = options;

  // 移除默认的 _id 字段（如果存在）
  if (fieldName === '_id' && schema.path('_id')) {
    schema.remove('_id');
  }

  // 添加自定义 ID 字段
  schema.add({
    [fieldName]: {
      type: fieldType,
      default: null,
      required: true,
      unique: true,
      index: true
    }
  });

  // 在保存前自动生成 ID
  if (autoGenerate) {
    schema.pre('save', function (next) {
      // 如果 ID 不存在，则自动生成
      if (!this[fieldName]) {
        this[fieldName] = snowflake.nextId();
      }
      next();
    });

    // 为批量插入也提供支持
    schema.pre('insertMany', function (next, docs) {
      docs.forEach((doc) => {
        if (!doc[fieldName]) {
          doc[fieldName] = snowflake.nextId();
        }
      });
      next();
    });
  }
};

module.exports = snowflakeIdPlugin;
