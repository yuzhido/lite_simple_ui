import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// 数据库帮助类 - 管理 SQLite 数据库连接和基础操作
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  /// 获取数据库实例
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// 初始化数据库
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'tree_select.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  /// 创建数据库表
  Future<void> _onCreate(Database db, int version) async {
    // 地址节点表
    await db.execute('''
      CREATE TABLE address_nodes (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        parent_id TEXT,
        level INTEGER DEFAULT 0,
        children TEXT,
        data TEXT,
        created_at INTEGER,
        updated_at INTEGER
      )
    ''');

    // 创建索引以提高查询性能
    await db.execute('CREATE INDEX idx_parent_id ON address_nodes(parent_id)');
    await db.execute('CREATE INDEX idx_level ON address_nodes(level)');
  }

  // ==================== 基础 CRUD 操作 ====================

  /// 插入节点
  Future<int> insertNode(Map<String, dynamic> node) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    final data = Map<String, dynamic>.from(node);
    data['created_at'] = now;
    data['updated_at'] = now;
    return await db.insert('address_nodes', data);
  }

  /// 批量插入节点
  Future<void> insertNodes(List<Map<String, dynamic>> nodes) async {
    final db = await database;
    final batch = db.batch();
    final now = DateTime.now().millisecondsSinceEpoch;

    for (var node in nodes) {
      final data = Map<String, dynamic>.from(node);
      data['created_at'] = now;
      data['updated_at'] = now;
      batch.insert('address_nodes', data);
    }

    await batch.commit(noResult: true);
  }

  /// 更新节点
  Future<int> updateNode(String id, Map<String, dynamic> node) async {
    final db = await database;
    final data = Map<String, dynamic>.from(node);
    data['updated_at'] = DateTime.now().millisecondsSinceEpoch;
    return await db.update('address_nodes', data, where: 'id = ?', whereArgs: [id]);
  }

  /// 删除节点
  Future<int> deleteNode(String id) async {
    final db = await database;

    // 先删除所有子节点
    final children = await db.query('address_nodes', columns: ['id'], where: 'parent_id = ?', whereArgs: [id]);

    final batch = db.batch();
    for (var child in children) {
      batch.delete('address_nodes', where: 'id = ?', whereArgs: [child['id']]);
    }

    // 删除当前节点
    batch.delete('address_nodes', where: 'id = ?', whereArgs: [id]);

    final results = await batch.commit();
    return results.length;
  }

  /// 根据 ID 查询节点
  Future<Map<String, dynamic>?> getNodeById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('address_nodes', where: 'id = ?', whereArgs: [id]);
    return maps.isNotEmpty ? maps.first : null;
  }

  /// 查询所有根节点（level=0 或 parent_id IS NULL）
  Future<List<Map<String, dynamic>>> getRootNodes() async {
    final db = await database;
    return await db.query('address_nodes', where: 'parent_id IS NULL OR level = 0', orderBy: 'name ASC');
  }

  /// 查询指定父节点的子节点
  Future<List<Map<String, dynamic>>> getChildren(String parentId) async {
    final db = await database;
    return await db.query('address_nodes', where: 'parent_id = ?', whereArgs: [parentId], orderBy: 'name ASC');
  }

  /// 查询所有节点
  Future<List<Map<String, dynamic>>> getAllNodes() async {
    final db = await database;
    return await db.query('address_nodes', orderBy: 'level ASC, name ASC');
  }

  /// 清空所有节点数据
  Future<void> clearAllNodes() async {
    final db = await database;
    await db.delete('address_nodes');
  }

  /// 关闭数据库连接
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
