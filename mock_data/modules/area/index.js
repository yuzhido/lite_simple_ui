/**
 * 区域位置模块路由
 */

const express = require('express');
const router = express.Router();
const { getAll, getTree, getById, create, update, remove, getChildren } = require('./controller');

// 基础 CRUD 路由
router.get('/', getAll); // 获取所有区域（支持分页和筛选）
router.get('/tree', getTree); // 获取区域树形结构
router.get('/:id/children', getChildren); // 获取指定区域的子区域
router.get('/:id', getById); // 获取单个区域
router.post('/', create); // 创建区域
router.put('/:id', update); // 更新区域
router.delete('/:id', remove); // 删除区域

module.exports = router;
