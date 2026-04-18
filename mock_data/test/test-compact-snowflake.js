/**
 * 测试紧凑模式雪花算法
 */

const { snowflake } = require('../utils/snowflake');

console.log('========== 紧凑模式雪花算法测试 ==========\n');

console.log(`JavaScript 最大安全整数: ${Number.MAX_SAFE_INTEGER}\n`);

console.log('生成 10 个 ID：');
const ids = [];
for (let i = 0; i < 10; i++) {
  const id = snowflake.nextId();
  const numId = Number(id);
  const isSafe = numId <= Number.MAX_SAFE_INTEGER;

  ids.push(id);

  console.log(`${i + 1}. ID: ${id}`);
  console.log(`   数值: ${numId}`);
  console.log(`   是否安全: ${isSafe ? '✅ 是' : '❌ 否'}`);
  console.log(`   长度: ${id.length} 位`);
  console.log();
}

// 检查是否有重复
const uniqueIds = new Set(ids);
console.log(`唯一性检查: ${ids.length === uniqueIds.size ? '✅ 无重复' : '❌ 有重复'}`);

// 检查是否递增
let isIncreasing = true;
for (let i = 1; i < ids.length; i++) {
  if (Number(ids[i]) <= Number(ids[i - 1])) {
    isIncreasing = false;
    break;
  }
}
console.log(`递增性检查: ${isIncreasing ? '✅ 趋势递增' : '❌ 非递增'}\n`);

// 最大值和最小值
const minId = Math.min(...ids.map(Number));
const maxId = Math.max(...ids.map(Number));
console.log(`最小 ID: ${minId}`);
console.log(`最大 ID: ${maxId}`);
console.log(`距离安全上限: ${Number.MAX_SAFE_INTEGER - maxId}`);
console.log(`使用率: ${((maxId / Number.MAX_SAFE_INTEGER) * 100).toFixed(2)}%\n`);

// 解析测试
console.log('ID 解析测试：');
const testId = ids[0];
const timestamp = snowflake.constructor.parseTimestamp(testId, true);
const workerId = snowflake.constructor.parseWorkerId(testId);
const datacenterId = snowflake.constructor.parseDatacenterId(testId);

console.log(`ID: ${testId}`);
console.log(`生成时间: ${timestamp.toLocaleString('zh-CN')}`);
console.log(`机器 ID: ${workerId}`);
console.log(`数据中心 ID: ${datacenterId}\n`);

console.log('========== 测试完成 ==========');
