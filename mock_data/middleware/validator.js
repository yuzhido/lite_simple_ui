/**
 * 验证中间件
 * 使用 Joi 进行请求数据验证
 * 安装: npm install joi
 */

// 注意：需要先安装 joi: npm install joi
let Joi;
try {
  Joi = require('joi');
} catch (error) {
  Joi = null;
}

/**
 * 验证请求体
 * @param {Object} schema - Joi schema
 */
const validateBody = (schema) => {
  return (req, res, next) => {
    if (!Joi) {
      console.warn('Joi not installed. Validation skipped.');
      return next();
    }

    const { error } = schema.validate(req.body);

    if (error) {
      const errorMessage = error.details.map((detail) => detail.message).join(', ');
      return res.status(400).json({
        success: false,
        message: 'Validation Error',
        errors: [errorMessage]
      });
    }

    next();
  };
};

/**
 * 验证查询参数
 * @param {Object} schema - Joi schema
 */
const validateQuery = (schema) => {
  return (req, res, next) => {
    if (!Joi) {
      return next();
    }

    const { error } = schema.validate(req.query);

    if (error) {
      const errorMessage = error.details.map((detail) => detail.message).join(', ');
      return res.status(400).json({
        success: false,
        message: 'Validation Error',
        errors: [errorMessage]
      });
    }

    next();
  };
};

/**
 * 验证路径参数
 * @param {Object} schema - Joi schema
 */
const validateParams = (schema) => {
  return (req, res, next) => {
    if (!Joi) {
      return next();
    }

    const { error } = schema.validate(req.params);

    if (error) {
      const errorMessage = error.details.map((detail) => detail.message).join(', ');
      return res.status(400).json({
        success: false,
        message: 'Validation Error',
        errors: [errorMessage]
      });
    }

    next();
  };
};

module.exports = {
  validateBody,
  validateQuery,
  validateParams
};
