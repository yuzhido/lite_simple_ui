/**
 * SQLite 数据库查看工具
 * 快速查看表结构和数据
 */

const { sequelize } = require('./config/database');

async function viewDatabase() {
  console.log('🔍 SQLite 数据库查看工具\n');
  console.log('='.repeat(60));

  try {
    // 1. 显示所有表
    console.log('\n📋 所有表:');
    console.log('-'.repeat(60));
    const tables = await sequelize.getQueryInterface().showAllTables();
    tables.forEach((table, index) => {
      console.log(`  ${index + 1}. ${table}`);
    });

    // 2. 查看每个表的结构和数据
    for (const tableName of tables) {
      console.log(`\n\n📊 表: ${tableName}`);
      console.log('='.repeat(60));

      // 表结构
      console.log('\n📝 表结构:');
      const columns = await sequelize.getQueryInterface().describeTable(tableName);
      Object.entries(columns).forEach(([colName, colInfo]) => {
        console.log(`  • ${colName.padEnd(20)} | ${colInfo.type.padEnd(15)} | ${colInfo.allowNull ? 'NULL' : 'NOT NULL'}`);
      });

      // 数据统计
      const countResult = await sequelize.query(`SELECT COUNT(*) as count FROM \`${tableName}\``);
      const count = countResult[0][0].count;
      console.log(`\n📈 记录数: ${count}`);

      // 显示前 5 条数据
      if (count > 0) {
        console.log('\n📄 前 5 条数据:');
        const rows = await sequelize.query(`SELECT * FROM \`${tableName}\` LIMIT 5`);
        const data = rows[0];

        if (data.length > 0) {
          // 显示列名
          const headers = Object.keys(data[0]);
          console.log('  ' + headers.map((h) => h.padEnd(20)).join(' | '));
          console.log('  ' + '-'.repeat(headers.length * 22));

          // 显示数据
          data.forEach((row) => {
            const values = headers.map((h) => {
              let val = row[h];
              if (val === null) val = 'NULL';
              else if (typeof val === 'string' && val.length > 18) val = val.substring(0, 15) + '...';
              return String(val).padEnd(20);
            });
            console.log('  ' + values.join(' | '));
          });
        }
      }
    }

    console.log('\n\n' + '='.repeat(60));
    console.log('✅ 查看完成！\n');

    await sequelize.close();
    process.exit(0);
  } catch (error) {
    console.error('❌ 错误:', error.message);
    process.exit(1);
  }
}

viewDatabase();
