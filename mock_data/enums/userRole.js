/**
 * 用户角色枚举
 * @description 定义系统中所有用户的角色类型
 */
const UserRole = {
  /** 普通用户 - 具有基本的浏览和使用权限 */
  USER: 'user',

  /** 管理员 - 具有系统管理权限，可以管理用户和配置 */
  ADMIN: 'admin',

  /** 审核员 - 具有内容审核和管理权限 */
  MODERATOR: 'moderator'
};

/**
 * 获取所有角色值
 */
const getAllRoles = () => Object.values(UserRole);

/**
 * 验证角色是否有效
 */
const isValidRole = (role) => Object.values(UserRole).includes(role);

module.exports = {
  UserRole,
  getAllRoles,
  isValidRole
};
