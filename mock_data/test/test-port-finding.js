/**
 * 测试自动端口查找功能
 */

const http = require('http');

// 占用 3000 端口
const server1 = http.createServer((req, res) => {
  res.end('Port 3000 occupied');
});

server1.listen(3000, () => {
  console.log('✅ Port 3000 is now occupied by test server');
  console.log('🧪 Now start the main server with: npm run dev');
  console.log('💡 It should automatically use port 3001\n');
});

// 保持进程运行
process.on('SIGINT', () => {
  server1.close();
  console.log('\nTest server stopped');
  process.exit(0);
});
