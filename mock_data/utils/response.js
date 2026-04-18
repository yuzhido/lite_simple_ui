/**
 * 统一响应格式
 * 提供标准化的 API 响应
 */

/**
 * 成功响应
 * @param {Object} res - Express response 对象
 * @param {Number} statusCode - HTTP 状态码
 * @param {Object} data - 响应数据
 * @param {String} message - 成功消息
 */
const success = (res, statusCode = 200, data = null, message = 'Success') => {
  const response = {
    success: true,
    message
  };

  if (data !== null) {
    response.data = data;
  }

  return res.status(statusCode).json(response);
};

/**
 * 错误响应
 * @param {Object} res - Express response 对象
 * @param {Number} statusCode - HTTP 状态码
 * @param {String|Array} error - 错误信息
 * @param {String} message - 错误消息
 */
const error = (res, statusCode = 500, error = 'Internal Server Error', message = 'Error') => {
  const response = {
    success: false,
    message
  };

  if (Array.isArray(error)) {
    response.errors = error;
  } else {
    response.error = error;
  }

  return res.status(statusCode).json(response);
};

/**
 * 分页响应
 * @param {Object} res - Express response 对象
 * @param {Array} data - 数据列表
 * @param {Number} total - 总数
 * @param {Number} page - 当前页
 * @param {Number} limit - 每页数量
 * @param {String} message - 成功消息
 */
const paginated = (res, data, total, page = 1, limit = 10, message = 'Success') => {
  return success(
    res,
    200,
    {
      list: data,
      pagination: {
        total,
        page: parseInt(page),
        limit: parseInt(limit),
        pages: Math.ceil(total / limit)
      }
    },
    message
  );
};

module.exports = {
  success,
  error,
  paginated
};
