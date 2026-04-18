/**
 * 用户模块路由
 * 演示新的模块化结构
 */

const express = require('express');
const router = express.Router();
const { getAll, getById, create, update, remove } = require('./controller');

// 基础 CRUD 路由
router.get('/', getAll); // 获取所有用户
router.get('/:id', getById); // 获取单个用户
router.post('/', create); // 创建用户
router.put('/:id', update); // 更新用户
router.delete('/:id', remove); // 删除用户

module.exports = router;
