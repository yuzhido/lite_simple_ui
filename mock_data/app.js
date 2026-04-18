/**
 * Express 应用配置
 * 集中管理所有中间件和路由
 */

const express = require('express');
const cors = require('cors');
const path = require('path');
const swaggerUi = require('swagger-ui-express');
const swaggerSpecs = require('./config/swagger');
const config = require('./config/config');
const loadRoutes = require('./utils/routeLoader');
const errorHandler = require('./middleware/errorHandler');
const logger = require('./middleware/logger');

// 创建 Express 应用
const app = express();

// ==================== 中间件配置 ====================

// 日志中间件（记录所有请求）
app.use(logger);

// CORS 跨域配置
app.use(cors(config.cors));

// Body parser 中间件
app.use(express.json());
app.use(express.urlencoded({ extended: false }));

// ==================== Swagger 配置 ====================

// 自定义 Swagger UI 样式
const swaggerCustomCss = `
  .swagger-ui .topbar { display: none; }
  .swagger-ui .info { margin: 20px 0; }
  .swagger-ui .info .description { line-height: 1.6; }
  .swagger-ui section.models { display: none !important; }
`;

const swaggerCustomHtml = `
  <div style="background: #f8f9fa; border-left: 4px solid #667eea; padding: 15px; margin: 15px 0; border-radius: 4px;">
    <p style="margin: 0 0 10px 0; color: #495057; font-size: 14px;">
      <strong>💡 提示：</strong>点击下方链接查看或下载 Swagger JSON 原始数据
    </p>
    <div style="display: flex; gap: 10px; flex-wrap: wrap;">
      <a href="/api-docs/swagger.json" target="_blank" style="
        display: inline-block;
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white;
        padding: 10px 20px;
        border-radius: 6px;
        text-decoration: none;
        font-weight: bold;
        font-size: 14px;
        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
      ">
        📄 查看 JSON（新标签页）
      </a>
      <a href="/api-docs/swagger.json" download="swagger.json" style="
        display: inline-block;
        background: linear-gradient(135deg, #11998e 0%, #38ef7d 100%);
        color: white;
        padding: 10px 20px;
        border-radius: 6px;
        text-decoration: none;
        font-weight: bold;
        font-size: 14px;
        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
      ">
        💾 下载 JSON 文件
      </a>
    </div>
  </div>
`;

// Swagger JSON 路由（必须在 swaggerUi.serve 之前）
app.get('/api-docs/swagger.json', (req, res) => {
  res.setHeader('Content-Type', 'application/json');
  res.setHeader('Content-Disposition', 'inline');
  res.json(swaggerSpecs);
});

// Swagger UI
app.use(
  config.swagger.path,
  swaggerUi.serve,
  swaggerUi.setup(swaggerSpecs, {
    explorer: true,
    customCss: swaggerCustomCss,
    customSiteTitle: config.swagger.title,
    customfavIcon: false,
    customHtml: swaggerCustomHtml
  })
);

// ==================== 路由配置 ====================

// 主页路由
app.get('/', (req, res) => {
  res.json({
    message: 'Mock Data Server is running',
    version: config.swagger.version,
    environment: config.server.env,
    documentation: `${req.protocol}://${req.get('host')}${config.swagger.path}`,
    apiPrefix: config.api.prefix
  });
});

// 健康检查
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

// 自动加载所有业务模块
const modulesDir = path.join(__dirname, 'modules');
loadRoutes(app, modulesDir, config.api.prefix);

// ==================== 错误处理 ====================

// 404 处理
app.use((req, res, next) => {
  res.status(404).json({
    success: false,
    message: `Route ${req.originalUrl} not found`
  });
});

// 全局错误处理（必须放在最后）
app.use(errorHandler);

module.exports = app;
