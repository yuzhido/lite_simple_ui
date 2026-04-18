/**
 * Sequelize 快速测试
 * 验证数据库连接和基本操作
 */

const { sequelize, testConnection } = require('../config/database');
const User = require('../modules/users/model');

async function test() {
  console.log('🧪 Sequelize 测试开始...\n');

  try {
    // 1. 测试数据库连接
    console.log('1️⃣ 测试数据库连接...');
    await testConnection();
    console.log('✅ 数据库连接成功\n');

    // 2. 创建测试用户
    console.log('2️⃣ 创建测试用户...');
    const timestamp = Date.now();
    const user = await User.create({
      username: `test_user_${timestamp}`,
      email: `test${timestamp}@example.com`,
      password: '123456',
      role: 'user'
    });
    console.log('✅ 用户创建成功');
    console.log(`   ID: ${user.id}`);
    console.log(`   用户名: ${user.username}`);
    console.log(`   邮箱: ${user.email}\n`);

    // 3. 查询用户
    console.log('3️⃣ 查询用户...');
    const foundUser = await User.findByPk(user.id);
    console.log('✅ 用户查询成功');
    console.log(`   找到用户: ${foundUser.username}\n`);

    // 4. 更新用户
    console.log('4️⃣ 更新用户...');
    await foundUser.update({ username: 'updated_user' });
    console.log('✅ 用户更新成功');
    console.log(`   新用户名: ${foundUser.username}\n`);

    // 5. 统计用户数量
    console.log('5️⃣ 统计用户数量...');
    const count = await User.count();
    console.log(`✅ 当前用户总数: ${count}\n`);

    // 6. 删除用户
    console.log('6️⃣ 删除测试用户...');
    await foundUser.destroy();
    console.log('✅ 用户删除成功\n');

    console.log('🎉 所有测试通过！Sequelize 集成成功！');

    // 关闭连接
    await sequelize.close();
    process.exit(0);
  } catch (error) {
    console.error('❌ 测试失败:', error.message);
    console.error(error);
    process.exit(1);
  }
}

test();
