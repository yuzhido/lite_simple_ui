/// 树形选择器模式枚举
enum TreeSelectMode {
  /// 下拉模式
  dropdown,

  /// 弹窗模式
  popup,

  /// 列表模式
  list,
}

/// 选择类型枚举
enum SelectType {
  /// 单选
  single,

  /// 多选
  multiple,
}

/// 节点可选择性模式
enum SelectableMode {
  /// 所有节点可选（默认）
  all,

  /// 层级联动选择
  hierarchical,
}

/// 显示模式枚举
enum DisplayMode {
  /// 文本模式（逗号拼接）
  text,

  /// 标签模式（独立圆形框）
  tags,
}

/// 缓存策略枚举
enum CacheStrategy {
  /// 总是缓存：首次加载后始终使用缓存，不再请求
  always,

  /// 从不缓存：每次都重新请求接口
  never,

  /// 会话期间缓存：弹窗会话期间使用缓存，关闭后清除
  session,
}

/// 搜索触发模式枚举
enum SearchTriggerMode {
  /// 实时搜索：输入即搜索，不显示搜索按钮
  realTime,

  /// 点击搜索：需要点击搜索按钮才触发搜索
  click,
}

/// 空状态类型枚举
enum EmptyType {
  /// 初始加载无数据
  initial,

  /// 搜索无结果
  searchEmpty,

  /// 搜索结果不匹配
  searchMismatch,
}

/// 字段映射配置 - 用于适配后端不同的数据结构
class FieldMapping {
  /// ID 字段名，默认 'id'
  final String idField;

  /// 文本字段名，默认 'label'
  final String labelField;

  /// 子节点字段名，默认 'children'
  final String childrenField;

  /// 叶子节点字段名，默认 'isLeaf'
  final String leafField;

  const FieldMapping({this.idField = 'id', this.labelField = 'label', this.childrenField = 'children', this.leafField = 'isLeaf'});

  /// 从 JSON 创建 FieldMapping 对象
  factory FieldMapping.fromJson(Map<String, dynamic> json) {
    return FieldMapping(
      idField: json['idField'] as String? ?? 'id',
      labelField: json['labelField'] as String? ?? 'label',
      childrenField: json['childrenField'] as String? ?? 'children',
      leafField: json['leafField'] as String? ?? 'isLeaf',
    );
  }

  /// 转换为 JSON 对象
  Map<String, dynamic> toJson() {
    return {'idField': idField, 'labelField': labelField, 'childrenField': childrenField, 'leafField': leafField};
  }

  /// 复制并修改字段映射
  FieldMapping copyWith({String? idField, String? labelField, String? childrenField, String? leafField}) {
    return FieldMapping(
      idField: idField ?? this.idField,
      labelField: labelField ?? this.labelField,
      childrenField: childrenField ?? this.childrenField,
      leafField: leafField ?? this.leafField,
    );
  }

  @override
  String toString() {
    return 'FieldMapping(id: $idField, label: $labelField, children: $childrenField, leaf: $leafField)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FieldMapping && other.idField == idField && other.labelField == labelField && other.childrenField == childrenField && other.leafField == leafField;
  }

  @override
  int get hashCode => Object.hash(idField, labelField, childrenField, leafField);
}
