/**
 * 通用工具函数
 */

/**
 * 分页参数解析
 * @param {Object} query - 查询参数
 * @returns {Object} { page, limit, skip (MongoDB), offset (Sequelize) }
 */
const parsePagination = (query) => {
  const page = Math.max(1, parseInt(query.page) || 1);
  const limit = Math.max(1, Math.min(100, parseInt(query.limit) || 10));
  const skip = (page - 1) * limit;
  const offset = skip; // Sequelize 使用 offset

  return { page, limit, skip, offset };
};

/**
 * 过滤参数解析
 * @param {Object} query - 查询参数
 * @param {Array} allowedFields - 允许过滤的字段
 * @returns {Object} 过滤条件
 */
const parseFilters = (query, allowedFields = []) => {
  const filters = {};

  Object.keys(query).forEach((key) => {
    if (allowedFields.includes(key) && query[key]) {
      filters[key] = query[key];
    }
  });

  return filters;
};

/**
 * 排序参数解析
 * @param {Object} query - 查询参数
 * @param {Array} allowedFields - 允许排序的字段
 * @returns {Object} 排序条件
 */
const parseSorting = (query, allowedFields = []) => {
  if (!query.sort) {
    return { createdAt: -1 }; // 默认按创建时间降序
  }

  const sortBy = query.sort.replace(/-/g, '');
  const order = query.sort.startsWith('-') ? -1 : 1;

  if (!allowedFields.includes(sortBy)) {
    return { createdAt: -1 };
  }

  return { [sortBy]: order };
};

/**
 * 生成 API URL
 * @param {String} path - 路径
 * @param {Object} params - 查询参数
 * @returns {String} 完整 URL
 */
const generateUrl = (path, params = {}) => {
  const queryString = Object.keys(params)
    .filter((key) => params[key] !== undefined && params[key] !== null)
    .map((key) => `${encodeURIComponent(key)}=${encodeURIComponent(params[key])}`)
    .join('&');

  return queryString ? `${path}?${queryString}` : path;
};

/**
 * 深度合并对象
 * @param {Object} target - 目标对象
 * @param {Object} source - 源对象
 * @returns {Object} 合并后的对象
 */
const deepMerge = (target, source) => {
  const output = { ...target };

  Object.keys(source).forEach((key) => {
    if (source[key] && typeof source[key] === 'object' && !Array.isArray(source[key])) {
      output[key] = deepMerge(output[key] || {}, source[key]);
    } else {
      output[key] = source[key];
    }
  });

  return output;
};

module.exports = {
  parsePagination,
  parseFilters,
  parseSorting,
  generateUrl,
  deepMerge
};
