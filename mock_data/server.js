/**
 * 服务器启动入口
 * 负责启动 HTTP 服务器
 */

require('dotenv').config();
const http = require('http');
const path = require('path');
const os = require('os');
const app = require('./app');
const config = require('./config/config');
const { testConnection } = require('./config/database');

/**
 * 获取局域网 IP 地址
 */
function getLocalIP() {
  const networkInterfaces = os.networkInterfaces();

  for (const interfaceName in networkInterfaces) {
    const interfaces = networkInterfaces[interfaceName];
    for (const iface of interfaces) {
      if (iface.family === 'IPv4' && !iface.internal) {
        return iface.address;
      }
    }
  }

  return 'localhost';
}

/**
 * 打印启动信息
 * @param {number} actualPort - 实际使用的端口号
 */
function printStartupInfo(actualPort) {
  const port = actualPort;
  const localIP = getLocalIP();
  const projectPath = path.resolve(__dirname);
  const baseUrl = `http://localhost:${port}`;

  console.log('\n' + '='.repeat(60));
  console.log('🚀 Mock Data Server Started Successfully!');
  console.log('='.repeat(60));
  console.log(`\n📁 Project Path: ${projectPath}`);
  console.log(`\n🌐 Server URLs:`);
  console.log(`   • Local:   ${baseUrl}`);
  console.log(`   • Network: http://${localIP}:${port}`);
  console.log(`\n📚 API Documentation:`);
  console.log(`   • Swagger UI: ${baseUrl}${config.swagger.path}`);
  console.log(`   • Swagger JSON: ${baseUrl}${config.swagger.path}/swagger.json`);
  console.log(`\n🔗 API Endpoints:`);
  console.log(`   • Base URL: ${baseUrl}${config.api.prefix}/[module]`);
  console.log(`   • Example: ${baseUrl}${config.api.prefix}/users`);
  console.log(`\n📊 Available Modules:`);

  // 动态显示已加载的模块
  try {
    const fs = require('fs');
    const modulesDir = path.join(__dirname, 'modules');
    const modules = fs.readdirSync(modulesDir, { withFileTypes: true });

    modules.forEach((module) => {
      if (module.isDirectory()) {
        console.log(`   • /${config.api.prefix}/${module.name}`);
      }
    });
  } catch (error) {
    console.log('   • No modules loaded');
  }

  console.log('\n' + '='.repeat(60));
  console.log('💡 Tip: Open Swagger UI in your browser to test APIs!');
  console.log('='.repeat(60) + '\n');
}

/**
 * 查找可用端口
 * @param {number} startPort - 起始端口
 * @returns {Promise<number>} 可用端口号
 */
function findAvailablePort(startPort) {
  return new Promise((resolve, reject) => {
    const net = require('net');

    const server = net.createServer();

    server.listen(startPort, () => {
      const { port } = server.address();
      server.close(() => {
        resolve(port);
      });
    });

    server.on('error', (err) => {
      if (err.code === 'EADDRINUSE') {
        // 端口被占用，尝试下一个端口
        console.log(`⚠️  Port ${Number(startPort)} is already in use. Trying port ${Number(startPort) + 1}...`);
        findAvailablePort(Number(startPort) + 1)
          .then(resolve)
          .catch(reject);
      } else {
        reject(err);
      }
    });
  });
}

// 创建 HTTP 服务器
const server = http.createServer(app);

// 启动服务器 - 自动查找可用端口
const PREFERRED_PORT = config.server.port;

findAvailablePort(PREFERRED_PORT)
  .then(async (PORT) => {
    // 如果找到的端口不是首选端口，提示用户
    if (PORT !== PREFERRED_PORT) {
      console.log(`\n✅ Found available port: ${PORT}\n`);
    }

    server.listen(PORT, async () => {
      // 先连接数据库
      try {
        await testConnection();
      } catch (error) {
        console.error('❌ Failed to connect to database. Server will not start.');
        process.exit(1);
      }

      // 打印启动信息（传入实际端口号）
      printStartupInfo(PORT);
    });
  })
  .catch((error) => {
    console.error('❌ Failed to find an available port:', error);
    process.exit(1);
  });

// 优雅关闭
process.on('SIGTERM', () => {
  console.log('\n⚠️  SIGTERM signal received: closing HTTP server');
  server.close(() => {
    console.log('✅ HTTP server closed');
    process.exit(0);
  });
});

process.on('SIGINT', () => {
  console.log('\n⚠️  SIGINT signal received: closing HTTP server');
  server.close(() => {
    console.log('✅ HTTP server closed');
    process.exit(0);
  });
});

// 未捕获的异常处理
process.on('uncaughtException', (error) => {
  console.error('❌ Uncaught Exception:', error);
  process.exit(1);
});

process.on('unhandledRejection', (reason, promise) => {
  console.error('❌ Unhandled Rejection at:', promise, 'reason:', reason);
  process.exit(1);
});

module.exports = server;
