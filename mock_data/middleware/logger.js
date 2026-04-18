/**
 * 日志中间件
 * 记录请求信息
 */

const logger = (req, res, next) => {
  const start = Date.now();

  // 请求完成后记录日志
  res.on('finish', () => {
    const duration = Date.now() - start;
    const { method, originalUrl } = req;
    const statusCode = res.statusCode;

    const color = statusCode >= 400 ? '\x1b[31m' : '\x1b[32m';
    const reset = '\x1b[0m';

    console.log(`${color}${method} ${originalUrl} ${statusCode}${reset} - ${duration}ms`);
  });

  next();
};

module.exports = logger;
