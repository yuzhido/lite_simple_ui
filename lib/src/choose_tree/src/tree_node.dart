import '../../model/index.dart';

/// 树节点数据模型
class TreeNode {
  /// 节点唯一标识
  final String id;

  /// 显示文本
  final String label;

  /// 父节点引用（用于层级联动）
  TreeNode? parent;

  /// 子节点列表（可变，用于懒加载和层级联动）
  List<TreeNode>? children;

  /// 是否为叶子节点（用于懒加载）
  final bool? isLeaf;

  /// 是否被选中
  bool isSelected;

  /// 是否展开
  bool isExpanded;

  /// 是否正在加载
  bool isLoading;

  /// 保留原始后端数据
  final Map<String, dynamic> rawData;

  /// 字段映射配置
  final FieldMapping? fieldMapping;

  TreeNode({
    required this.id,
    required this.label,
    this.parent,
    this.children,
    this.isLeaf,
    this.isSelected = false,
    this.isExpanded = false,
    this.isLoading = false,
    this.rawData = const {},
    this.fieldMapping,
  });

  /// 从后端原始数据构建树节点
  factory TreeNode.fromData(Map<String, dynamic> data, {FieldMapping? mapping, TreeNode? parent}) {
    final fieldMap = mapping ?? FieldMapping();

    final node = TreeNode(
      id: data[fieldMap.idField].toString(),
      label: data[fieldMap.labelField].toString(),
      parent: parent,
      children: null, // 先设为 null，稍后设置
      isLeaf: data[fieldMap.leafField] as bool?,
      rawData: data,
      fieldMapping: mapping,
    );

    // 构建子节点并设置 parent 引用
    final childrenData = data[fieldMap.childrenField] as List?;
    if (childrenData != null) {
      node.children = childrenData.whereType<Map<String, dynamic>>().map((e) => TreeNode.fromData(e, mapping: mapping, parent: node)).toList();
    }

    return node;
  }

  /// 获取原始数据的任意字段
  dynamic getFieldValue(String key) => rawData[key];

  /// 复制节点并更新状态
  TreeNode copyWith({
    String? id,
    String? label,
    List<TreeNode>? children,
    bool? isLeaf,
    bool? isSelected,
    bool? isExpanded,
    bool? isLoading,
    Map<String, dynamic>? rawData,
    FieldMapping? fieldMapping,
  }) {
    return TreeNode(
      id: id ?? this.id,
      label: label ?? this.label,
      children: children ?? this.children,
      isLeaf: isLeaf ?? this.isLeaf,
      isSelected: isSelected ?? this.isSelected,
      isExpanded: isExpanded ?? this.isExpanded,
      isLoading: isLoading ?? this.isLoading,
      rawData: rawData ?? this.rawData,
      fieldMapping: fieldMapping ?? this.fieldMapping,
    );
  }

  @override
  String toString() => 'TreeNode(id: $id, label: $label, isSelected: $isSelected)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TreeNode && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  /// 更新节点状态
  void update({List<TreeNode>? children, bool? isSelected, bool? isExpanded, bool? isLoading}) {
    if (children != null) {
      // 通过反射修改 final 字段
      (this as dynamic).children = children;
    }
    if (isSelected != null) this.isSelected = isSelected;
    if (isExpanded != null) this.isExpanded = isExpanded;
    if (isLoading != null) this.isLoading = isLoading;
  }
}
