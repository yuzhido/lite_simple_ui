/**
 * 区域位置模块控制器 (Sequelize)
 * 处理区域位置相关的业务逻辑
 */

const asyncHandler = require('../../utils/asyncHandler');
const { success, error, paginated } = require('../../utils/response');
const { parsePagination } = require('../../utils/helpers');
const Area = require('./model');
const { Op } = require('sequelize');

const getAll = asyncHandler(async (req, res) => {
  const { page, limit, offset } = parsePagination(req.query);
  const { parentId, name } = req.query;

  const where = {};

  // 按父级ID筛选
  if (parentId !== undefined) {
    where.parent_id = parentId === 'null' || parentId === '' ? null : parentId;
  }

  // 按名称模糊搜索
  if (name) {
    where.name = { [Op.like]: `%${name}%` };
  }

  const { count, rows: areas } = await Area.findAndCountAll({
    where,
    offset,
    limit,
    order: [['create_time', 'DESC']]
  });

  paginated(res, areas, count, page, limit, '获取区域列表成功');
});

const getTree = asyncHandler(async (req, res) => {
  const { parentId } = req.query;

  // 获取顶级区域（parentId为null）或指定父级的子区域
  const where = {};
  if (parentId) {
    where.parent_id = parentId;
  } else {
    where.parent_id = null;
  }

  const areas = await Area.findAll({
    where,
    include: [
      {
        model: Area,
        as: 'children',
        include: [
          {
            model: Area,
            as: 'children'
          }
        ]
      }
    ],
    order: [['create_time', 'ASC']]
  });

  success(res, 200, areas, '获取区域树成功');
});

/**
 * 获取单个区域
 * GET /api/areas/:id
 */
const getById = asyncHandler(async (req, res) => {
  const area = await Area.findByPk(req.params.id, {
    include: [
      {
        model: Area,
        as: 'parent'
      },
      {
        model: Area,
        as: 'children'
      }
    ]
  });

  if (!area) {
    return error(res, 404, '区域不存在', '获取失败');
  }

  success(res, 200, area, '获取区域成功');
});

const create = asyncHandler(async (req, res) => {
  // 如果提供了parentId，验证父区域是否存在
  if (req.body.parentId) {
    const parentArea = await Area.findByPk(req.body.parentId);
    if (!parentArea) {
      return error(res, 404, '父级区域不存在', '创建失败');
    }
  }

  const area = await Area.create({
    ...req.body,
    version: 0
  });

  success(res, 201, area, '创建区域成功');
});

const update = asyncHandler(async (req, res) => {
  const area = await Area.findByPk(req.params.id);

  if (!area) {
    return error(res, 404, '区域不存在', '更新失败');
  }

  // 如果提供了parentId，验证父区域是否存在（不能是自身）
  if (req.body.parentId && req.body.parentId !== area.parent_id) {
    if (req.body.parentId === req.params.id) {
      return error(res, 400, '父级区域不能是自身', '更新失败');
    }
    const parentArea = await Area.findByPk(req.body.parentId);
    if (!parentArea) {
      return error(res, 404, '父级区域不存在', '更新失败');
    }
  }

  await area.update(req.body);

  // 重新获取更新后的数据
  const updatedArea = await Area.findByPk(req.params.id, {
    include: [
      {
        model: Area,
        as: 'parent'
      },
      {
        model: Area,
        as: 'children'
      }
    ]
  });

  success(res, 200, updatedArea, '更新区域成功');
});

const remove = asyncHandler(async (req, res) => {
  const area = await Area.findByPk(req.params.id);

  if (!area) {
    return error(res, 404, '区域不存在', '删除失败');
  }

  // 检查是否有子区域
  const childrenCount = await Area.count({
    where: { parent_id: req.params.id }
  });

  if (childrenCount > 0) {
    return error(res, 400, '该区域下存在子区域，无法删除', '删除失败');
  }

  await area.destroy();

  success(res, 200, null, '删除区域成功');
});

const getChildren = asyncHandler(async (req, res) => {
  const { page, limit, offset } = parsePagination(req.query);

  const parentArea = await Area.findByPk(req.params.id);
  if (!parentArea) {
    return error(res, 404, '父级区域不存在', '获取失败');
  }

  const { count, rows: children } = await Area.findAndCountAll({
    where: { parent_id: req.params.id },
    offset,
    limit,
    order: [['create_time', 'DESC']]
  });

  paginated(res, children, count, page, limit, '获取子区域列表成功');
});

module.exports = {
  getAll,
  getTree,
  getById,
  create,
  update,
  remove,
  getChildren
};
