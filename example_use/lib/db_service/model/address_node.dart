/// 地址节点数据模型
class AddressNode {
  final String id;
  final String name;
  final String? parentId;
  final int level;
  final Map<String, dynamic>? children; // 存储子节点 JSON 数据
  final Map<String, dynamic> rawData; // 原始数据

  AddressNode({required this.id, required this.name, this.parentId, required this.level, this.children, required this.rawData});

  /// 从 Map 创建 AddressNode
  factory AddressNode.fromMap(Map<String, dynamic> map) {
    return AddressNode(
      id: map['id'] as String,
      name: map['name'] as String,
      parentId: map['parent_id'] as String?,
      level: map['level'] as int? ?? 0,
      children: map['children'] != null ? Map<String, dynamic>.from(map['children']) : null,
      rawData: map,
    );
  }

  /// 转换为 Map
  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'parent_id': parentId, 'level': level, 'children': children};
  }

  /// 从树形结构创建 AddressNode（用于 UI 展示）
  factory AddressNode.fromTreeData(Map<String, dynamic> data, {String? parentId, int level = 0}) {
    return AddressNode(
      id: data['id'] as String,
      name: data['name'] as String,
      parentId: parentId ?? data['parent_id'] as String?,
      level: level,
      children: data['children'] != null ? {'items': (data['children'] as List).map((e) => e is Map<String, dynamic> ? e : {}).toList()} : null,
      rawData: data,
    );
  }

  @override
  String toString() {
    return 'AddressNode(id: $id, name: $name, parentId: $parentId, level: $level)';
  }
}
