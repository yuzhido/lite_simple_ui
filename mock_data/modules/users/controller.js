/**
 * 用户模块控制器 (Sequelize)
 * 处理用户相关的业务逻辑
 */

const asyncHandler = require('../../utils/asyncHandler');
const { success, error, paginated } = require('../../utils/response');
const { parsePagination } = require('../../utils/helpers');
const User = require('./model');
const { Op } = require('sequelize');

const getAll = asyncHandler(async (req, res) => {
  const { page, limit, offset } = parsePagination(req.query);
  const { keyword, role, isActive } = req.query;

  const where = {};

  // 关键字搜索（用户名或邮箱模糊匹配）
  if (keyword) {
    where[Op.or] = [{ username: { [Op.like]: `%${keyword}%` } }, { email: { [Op.like]: `%${keyword}%` } }];
  }

  // 按角色筛选
  if (role) {
    where.role = role;
  }

  // 按激活状态筛选
  if (isActive !== undefined) {
    where.isActive = isActive === 'true';
  }

  const { count, rows: users } = await User.findAndCountAll({
    where,
    offset,
    limit,
    order: [['created_at', 'DESC']]
  });

  paginated(res, users, count, page, limit, '获取用户列表成功');
});

const getById = asyncHandler(async (req, res) => {
  const user = await User.findByPk(req.params.id);

  if (!user) {
    return error(res, 404, '用户不存在', '获取失败');
  }

  success(res, 200, user, '获取用户成功');
});

/**
 * 创建用户
 * POST /api/users
 */
const create = asyncHandler(async (req, res) => {
  const user = await User.create(req.body);

  success(res, 201, user, '创建用户成功');
});

/**
 * 更新用户
 * PUT /api/users/:id
 */
const update = asyncHandler(async (req, res) => {
  const user = await User.findByPk(req.params.id);

  if (!user) {
    return error(res, 404, '用户不存在', '更新失败');
  }

  await user.update(req.body);

  // 重新获取更新后的数据
  const updatedUser = await User.findByPk(req.params.id);

  success(res, 200, updatedUser, '更新用户成功');
});

/**
 * 删除用户
 * DELETE /api/users/:id
 */
const remove = asyncHandler(async (req, res) => {
  const user = await User.findByPk(req.params.id);

  if (!user) {
    return error(res, 404, '用户不存在', '删除失败');
  }

  await user.destroy();

  success(res, 200, null, '删除用户成功');
});

module.exports = {
  getAll,
  getById,
  create,
  update,
  remove
};
