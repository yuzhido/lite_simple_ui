/**
 * Sequelize 数据库配置
 * 支持 MySQL、PostgreSQL、SQLite 等多种数据库
 */

// 确保环境变量已加载
if (!process.env.DB_TYPE) {
  require('dotenv').config();
}

const { Sequelize } = require('sequelize');
const config = require('./config');

// 根据环境变量选择数据库类型
const dbType = process.env.DB_TYPE || 'mysql'; // mysql, postgres, sqlite

let sequelize;

if (dbType === 'sqlite') {
  // SQLite 配置（适合开发环境）
  sequelize = new Sequelize({
    dialect: 'sqlite',
    storage: process.env.SQLITE_STORAGE || './database.sqlite',
    logging: false, // 关闭 SQL 日志，避免乱码
    define: {
      timestamps: true,
      underscored: true, // 使用下划线命名（created_at, updated_at）
      freezeTableName: true // 不自动复数化表名
    }
  });
} else if (dbType === 'mysql') {
  // MySQL 配置（适合生产环境）
  sequelize = new Sequelize(process.env.MYSQL_DATABASE || 'mock_data_db', process.env.MYSQL_USER || 'root', process.env.MYSQL_PASSWORD || '', {
    host: process.env.MYSQL_HOST || 'localhost',
    port: process.env.MYSQL_PORT || 3306,
    dialect: 'mysql',
    logging: config.server.env === 'development' ? console.log : false,
    pool: {
      max: 5,
      min: 0,
      acquire: 30000,
      idle: 10000
    },
    define: {
      timestamps: true,
      underscored: true,
      freezeTableName: true,
      charset: 'utf8mb4',
      collate: 'utf8mb4_unicode_ci'
    }
  });
} else if (dbType === 'postgres') {
  // PostgreSQL 配置
  sequelize = new Sequelize(process.env.POSTGRES_DATABASE || 'mock_data_db', process.env.POSTGRES_USER || 'postgres', process.env.POSTGRES_PASSWORD || '', {
    host: process.env.POSTGRES_HOST || 'localhost',
    port: process.env.POSTGRES_PORT || 5432,
    dialect: 'postgres',
    logging: config.server.env === 'development' ? console.log : false,
    pool: {
      max: 5,
      min: 0,
      acquire: 30000,
      idle: 10000
    },
    define: {
      timestamps: true,
      underscored: true,
      freezeTableName: true
    }
  });
} else {
  throw new Error(`Unsupported database type: ${dbType}`);
}

// 测试数据库连接
const testConnection = async () => {
  try {
    await sequelize.authenticate();
    console.log('✅ Database connection established successfully.');

    // 同步模型（开发环境自动创建表）
    if (config.server.env === 'development') {
      await sequelize.sync({ alter: true });
      console.log('✅ Database models synchronized.');
    }
  } catch (error) {
    console.error('❌ Unable to connect to the database:', error);
    throw error;
  }
};

module.exports = {
  sequelize,
  Sequelize,
  testConnection
};
