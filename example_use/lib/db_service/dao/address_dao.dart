import 'database_helper.dart';
import '../model/address_node.dart';

/// 地址数据访问对象 - 封装对 AddressNode 的数据库操作
class AddressDao {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// 插入地址节点
  Future<int> insert(AddressNode node) async {
    return await _dbHelper.insertNode(node.toMap());
  }

  /// 批量插入地址节点
  Future<void> insertAll(List<AddressNode> nodes) async {
    final maps = nodes.map((node) => node.toMap()).toList();
    await _dbHelper.insertNodes(maps);
  }

  /// 更新地址节点
  Future<int> update(String id, AddressNode node) async {
    return await _dbHelper.updateNode(id, node.toMap());
  }

  /// 删除地址节点（包括子节点）
  Future<int> delete(String id) async {
    return await _dbHelper.deleteNode(id);
  }

  /// 根据 ID 获取地址节点
  Future<AddressNode?> getById(String id) async {
    final map = await _dbHelper.getNodeById(id);
    return map != null ? AddressNode.fromMap(map) : null;
  }

  /// 获取所有根节点
  Future<List<AddressNode>> getRootNodes() async {
    final maps = await _dbHelper.getRootNodes();
    return maps.map((map) => AddressNode.fromMap(map)).toList();
  }

  /// 获取指定父节点的子节点
  Future<List<AddressNode>> getChildren(String parentId) async {
    final maps = await _dbHelper.getChildren(parentId);
    return maps.map((map) => AddressNode.fromMap(map)).toList();
  }

  /// 获取完整的树形结构
  Future<List<AddressNode>> getTreeStructure() async {
    final rootNodes = await getRootNodes();

    // 递归加载子节点
    final result = <AddressNode>[];
    for (var root in rootNodes) {
      final rootNodeWithChildren = await _loadChildren(root);
      result.add(rootNodeWithChildren);
    }

    return result;
  }

  /// 递归加载子节点
  Future<AddressNode> _loadChildren(AddressNode node) async {
    final children = await getChildren(node.id);

    if (children.isNotEmpty) {
      // 递归加载每个子节点
      final loadedChildren = <Map<String, dynamic>>[];
      for (var child in children) {
        final childWithGrandChildren = await _loadChildren(child);
        loadedChildren.add(childWithGrandChildren.toMap());
      }

      // 返回包含子节点信息的新节点
      return AddressNode(id: node.id, name: node.name, parentId: node.parentId, level: node.level, children: {'items': loadedChildren}, rawData: node.rawData);
    }

    return node;
  }

  /// 清空所有地址数据
  Future<void> clearAll() async {
    await _dbHelper.clearAllNodes();
  }

  /// 获取所有节点（扁平化）
  Future<List<AddressNode>> getAll() async {
    final maps = await _dbHelper.getAllNodes();
    return maps.map((map) => AddressNode.fromMap(map)).toList();
  }
}
