/**
 * 服务器配置
 * 集中管理所有服务器相关配置
 */

const path = require('path');

// 基础配置
const config = {
  // 服务器配置
  server: {
    port: process.env.PORT || 3000,
    env: process.env.NODE_ENV || 'development'
  },

  // 数据库配置 (Sequelize)
  database: {
    type: process.env.DB_TYPE || 'sqlite',
    sqlite: {
      storage: process.env.SQLITE_STORAGE || './database.sqlite'
    },
    mysql: {
      host: process.env.MYSQL_HOST || 'localhost',
      port: process.env.MYSQL_PORT || 3306,
      database: process.env.MYSQL_DATABASE || 'mock_data_db',
      user: process.env.MYSQL_USER || 'root',
      password: process.env.MYSQL_PASSWORD || ''
    },
    postgres: {
      host: process.env.POSTGRES_HOST || 'localhost',
      port: process.env.POSTGRES_PORT || 5432,
      database: process.env.POSTGRES_DATABASE || 'mock_data_db',
      user: process.env.POSTGRES_USER || 'postgres',
      password: process.env.POSTGRES_PASSWORD || ''
    }
  },

  // CORS 配置
  cors: {
    origin: process.env.CORS_ORIGIN || '*',
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
    allowedHeaders: ['Content-Type', 'Authorization'],
    credentials: true
  },

  // Swagger 配置
  swagger: {
    path: '/api-docs',
    title: '模拟数据服务器 API',
    version: '1.0.0',
    description: '基于 Express 和 Sequelize 的模拟数据服务器 API 文档'
  },

  // API 配置
  api: {
    prefix: '/api',
    version: 'v1'
  },

  // 路径配置
  paths: {
    root: path.resolve(__dirname, '..'),
    config: path.resolve(__dirname),
    src: path.resolve(__dirname, '..')
  }
};

module.exports = config;
