/**
 * 异步错误包装器
 * 自动捕获异步路由中的错误
 */

const asyncHandler = (fn) => {
  return (req, res, next) => {
    Promise.resolve(fn(req, res, next)).catch(next);
  };
};

module.exports = asyncHandler;
