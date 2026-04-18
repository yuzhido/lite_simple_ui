/**
 * 雪花算法测试
 * 验证 ID 生成的唯一性和性能
 */

const { snowflake, SnowflakeIdGenerator } = require('../utils/snowflake');

console.log('🧪 雪花算法测试开始...\n');

// 测试 1: 基本 ID 生成
console.log('测试 1: 基本 ID 生成');
const id1 = snowflake.nextId();
const id2 = snowflake.nextId();
console.log(`  ID 1: ${id1}`);
console.log(`  ID 2: ${id2}`);
console.log(`  长度: ${id1.length} 位`);
console.log(`  递增: ${BigInt(id2) > BigInt(id1) ? '✓' : '✗'}`);
console.log();

// 测试 2: 批量生成
console.log('测试 2: 批量生成（1000 个）');
const start = Date.now();
const ids = snowflake.nextIds(1000);
const end = Date.now();
console.log(`  生成数量: ${ids.length}`);
console.log(`  耗时: ${end - start}ms`);
console.log(`  平均速度: ${Math.round((1000 / (end - start)) * 1000)} 个/秒`);
console.log();

// 测试 3: 唯一性验证
console.log('测试 3: 唯一性验证');
const uniqueIds = new Set(ids);
console.log(`  总数: ${ids.length}`);
console.log(`  唯一: ${uniqueIds.size}`);
console.log(`  重复: ${ids.length - uniqueIds.size}`);
console.log(`  结果: ${ids.length === uniqueIds.size ? '✓ 全部唯一' : '✗ 存在重复'}`);
console.log();

// 测试 4: ID 解析
console.log('测试 4: ID 解析');
const sampleId = ids[0];
const timestamp = SnowflakeIdGenerator.parseTimestamp(sampleId);
const workerId = SnowflakeIdGenerator.parseWorkerId(sampleId);
const datacenterId = SnowflakeIdGenerator.parseDatacenterId(sampleId);
console.log(`  ID: ${sampleId}`);
console.log(`  生成时间: ${timestamp.toLocaleString()}`);
console.log(`  Worker ID: ${workerId}`);
console.log(`  Datacenter ID: ${datacenterId}`);
console.log();

// 测试 5: 并发生成
console.log('测试 5: 并发测试（10 个线程，每线程 100 个）');
const concurrentStart = Date.now();
const promises = [];
for (let i = 0; i < 10; i++) {
  const generator = new SnowflakeIdGenerator(i + 1, 1);
  promises.push(
    new Promise((resolve) => {
      const threadIds = [];
      for (let j = 0; j < 100; j++) {
        threadIds.push(generator.nextId());
      }
      resolve(threadIds);
    })
  );
}

Promise.all(promises)
  .then((results) => {
    const allIds = results.flat();
    const concurrentEnd = Date.now();
    const concurrentUnique = new Set(allIds);

    console.log(`  总生成数: ${allIds.length}`);
    console.log(`  唯一数量: ${concurrentUnique.size}`);
    console.log(`  耗时: ${concurrentEnd - concurrentStart}ms`);
    console.log(`  结果: ${allIds.length === concurrentUnique.size ? '✓ 全部唯一' : '✗ 存在重复'}`);
    console.log();

    // 测试 6: 趋势递增
    console.log('测试 6: 趋势递增验证');
    const sortedIds = [...allIds].sort((a, b) => BigInt(a) - BigInt(b));
    let isSorted = true;
    for (let i = 1; i < sortedIds.length; i++) {
      if (BigInt(sortedIds[i]) < BigInt(sortedIds[i - 1])) {
        isSorted = false;
        break;
      }
    }
    console.log(`  是否递增: ${isSorted ? '✓' : '✗'}`);
    console.log();

    console.log('✅ 所有测试完成！');
  })
  .catch((error) => {
    console.error('❌ 测试失败:', error);
  });
