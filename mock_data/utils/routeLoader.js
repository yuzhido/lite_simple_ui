/**
 * 路由自动加载器
 * 自动加载 modules 目录下的所有路由
 */

const fs = require('fs');
const path = require('path');

/**
 * 自动加载路由
 * @param {Object} app - Express app 实例
 * @param {String} modulesDir - 模块目录路径
 * @param {String} apiPrefix - API 前缀
 */
const loadRoutes = (app, modulesDir, apiPrefix = '/api') => {
  try {
    // 读取模块目录
    const modules = fs.readdirSync(modulesDir, { withFileTypes: true });

    modules.forEach((module) => {
      if (module.isDirectory()) {
        const modulePath = path.join(modulesDir, module.name);
        const indexPath = path.join(modulePath, 'index.js');

        // 检查模块是否有 index.js
        if (fs.existsSync(indexPath)) {
          try {
            const moduleRouter = require(indexPath);

            // 注册路由
            app.use(`${apiPrefix}/${module.name}`, moduleRouter);
            console.log(`✅ Loaded module: /${module.name}`);
          } catch (error) {
            console.error(`❌ Failed to load module ${module.name}:`, error.message);
          }
        }
      }
    });
  } catch (error) {
    console.error('Failed to load routes:', error.message);
  }
};

module.exports = loadRoutes;
