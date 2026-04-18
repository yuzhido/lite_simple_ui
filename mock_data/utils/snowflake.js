/**
 * 雪花算法（Snowflake）ID 生成器
 * 生成唯一的分布式 ID
 *
 * 标准模式结构：时间戳(41位) + 机器ID(10位) + 序列号(12位) = 63位
 * 紧凑模式结构：时间戳(31位) + 机器ID(5位) + 序列号(10位) = 46位 (推荐)
 *
 * 优势：
 * - 全局唯一
 * - 趋势递增
 * - 高性能
 * - 不依赖数据库
 * - 紧凑模式保证 ID 在 JavaScript 安全整数范围内
 */

class SnowflakeIdGenerator {
  /**
   * @param {Number} workerId - 机器ID (0-31)
   * @param {Number} datacenterId - 数据中心ID (0-31)
   * @param {Boolean} compactMode - 是否使用紧凑模式（默认true，保证ID在JS安全范围内）
   */
  constructor(workerId = 1, datacenterId = 1, compactMode = true) {
    this.compactMode = compactMode;

    if (compactMode) {
      // ========== 紧凑模式（推荐）==========
      // 目标：生成 15位、7开头的 ID
      // 策略：使用较小的时间戳位数，让ID保持在15位范围内

      // 起始时间戳：2020-06-01 00:00:00（微调以控制ID以7开头）
      this.twepoch = 1590969600000n;

      // 机器 ID 所占位数（3位 = 8台机器）
      this.workerIdBits = 3n;
      // 数据中心 ID 所占位数（3位 = 8个数据中心）
      this.datacenterIdBits = 3n;
      // 序列号所占位数（6位 = 64/毫秒）
      this.sequenceBits = 6n;

      // 总位数：41 + 3 + 3 + 6 = 53位（等于JS安全上限）
      // 可以使用约 69 年（2020-2089）
      // 当前时间（2026-04）生成的 ID 约为 7,xxx,xxx,xxx,xxx (16位，7开头)
    } else {
      // ========== 标准模式 ==========
      // 起始时间戳 (2026-01-01 00:00:00)
      this.twepoch = 1767225600000n;

      // 机器 ID 所占位数
      this.workerIdBits = 5n;
      // 数据中心 ID 所占位数
      this.datacenterIdBits = 5n;
      // 序列号所占位数
      this.sequenceBits = 12n;

      // 总位数：41 + 5 + 5 + 12 = 63位 (> 53位，超出JS安全范围)
    }

    // 最大值计算
    this.maxWorkerId = -1n ^ (-1n << this.workerIdBits); // 31
    this.maxDatacenterId = -1n ^ (-1n << this.datacenterIdBits); // 31

    // 位移计算
    this.workerIdShift = this.sequenceBits;
    this.datacenterIdShift = this.sequenceBits + this.workerIdBits;
    this.timestampLeftShift = this.sequenceBits + this.workerIdBits + this.datacenterIdBits;

    // 序列号掩码
    this.sequenceMask = -1n ^ (-1n << this.sequenceBits); // 4095

    this.workerId = BigInt(workerId);
    this.datacenterId = BigInt(datacenterId);
    this.sequence = 0n;
    this.lastTimestamp = -1n;

    // 验证参数
    if (this.workerId > this.maxWorkerId || this.workerId < 0n) {
      throw new Error(`Worker ID 必须在 0 到 ${this.maxWorkerId} 之间`);
    }
    if (this.datacenterId > this.maxDatacenterId || this.datacenterId < 0n) {
      throw new Error(`Datacenter ID 必须在 0 到 ${this.maxDatacenterId} 之间`);
    }
  }

  /**
   * 获取当前时间戳（毫秒）
   */
  _tilNextMillis(lastTimestamp) {
    let timestamp = BigInt(Date.now());
    while (timestamp <= lastTimestamp) {
      timestamp = BigInt(Date.now());
    }
    return timestamp;
  }

  /**
   * 生成下一个 ID
   * @returns {String} 生成的 ID（字符串格式）
   */
  nextId() {
    let timestamp = BigInt(Date.now());

    // 如果当前时间小于上次生成 ID 的时间戳，说明系统时钟回拨
    if (timestamp < this.lastTimestamp) {
      throw new Error(`时钟回拨，拒绝生成 ID，等待 ${this.lastTimestamp - timestamp} 毫秒`);
    }

    // 如果是同一毫秒内生成的
    if (timestamp === this.lastTimestamp) {
      this.sequence = (this.sequence + 1n) & this.sequenceMask;

      // 序列号溢出，等待下一毫秒
      if (this.sequence === 0n) {
        timestamp = this._tilNextMillis(this.lastTimestamp);
      }
    } else {
      this.sequence = 0n;
    }

    this.lastTimestamp = timestamp;

    // 组合 ID
    const id = ((timestamp - this.twepoch) << this.timestampLeftShift) | (this.datacenterId << this.datacenterIdShift) | (this.workerId << this.workerIdShift) | this.sequence;

    const idStr = id.toString();

    // 验证 ID 是否在安全范围内
    if (this.compactMode) {
      const idNum = Number(idStr);
      if (idNum > Number.MAX_SAFE_INTEGER) {
        console.warn(`⚠️  警告：生成的 ID (${idStr}) 超出了 JavaScript 安全整数范围！`);
      }
    }

    return idStr;
  }

  /**
   * 批量生成 ID
   * @param {Number} count - 生成数量
   * @returns {Array<String>} ID 数组
   */
  nextIds(count = 1) {
    const ids = [];
    for (let i = 0; i < count; i++) {
      ids.push(this.nextId());
    }
    return ids;
  }

  /**
   * 从 ID 中解析时间戳
   * @param {String} id - Snowflake ID
   * @returns {Date} 生成时间
   */
  static parseTimestamp(id, compactMode = true) {
    const idBigInt = BigInt(id);
    const twepoch = compactMode ? 1590969600000n : 1767225600000n;
    const timestampLeftShift = compactMode ? 12n : 22n;

    const timestamp = (idBigInt >> timestampLeftShift) + twepoch;
    return new Date(Number(timestamp));
  }

  /**
   * 从 ID 中解析机器 ID
   * @param {String} id - Snowflake ID
   * @returns {Number} 机器 ID
   */
  static parseWorkerId(id) {
    const idBigInt = BigInt(id);
    const workerIdShift = 12n;
    const workerIdBits = 5n;
    const mask = -1n ^ (-1n << workerIdBits);

    return Number((idBigInt >> workerIdShift) & mask);
  }

  /**
   * 从 ID 中解析数据中心 ID
   * @param {String} id - Snowflake ID
   * @returns {Number} 数据中心 ID
   */
  static parseDatacenterId(id) {
    const idBigInt = BigInt(id);
    const datacenterIdShift = 17n;
    const datacenterIdBits = 5n;
    const mask = -1n ^ (-1n << datacenterIdBits);

    return Number((idBigInt >> datacenterIdShift) & mask);
  }
}

// 创建单例（默认使用紧凑模式，保证 ID 在 JS 安全范围内）
const snowflake = new SnowflakeIdGenerator(1, 1, true);

module.exports = {
  SnowflakeIdGenerator,
  snowflake
};
