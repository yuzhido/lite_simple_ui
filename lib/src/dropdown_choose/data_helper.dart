/// 数据助手类 - 处理选项数据的提取和查找
class DropdownDataHelper<R, T> {
  final List<T> options;
  final R Function(T)? valueExtractor;
  final String Function(T)? displayText;
  late final Map<R, T> _cacheMap;

  DropdownDataHelper({required this.options, this.valueExtractor, this.displayText}) {
    // 初始化时构建缓存 Map，提高查找效率
    _cacheMap = {};
    for (var item in options) {
      final id = extractValue(item);
      _cacheMap[id] = item;
    }
  }

  /// 从对象中提取 ID
  R extractValue(T item) {
    if (valueExtractor != null) return valueExtractor!(item);
    final dynamicObj = item as dynamic;
    return dynamicObj.id as R;
  }

  /// 从对象中提取显示文本
  String extractDisplayText(T item) {
    if (displayText != null) return displayText!(item);
    final dynamicObj = item as dynamic;
    return dynamicObj.name?.toString() ?? item.toString();
  }

  /// 通过 ID 在 options 中查找对象 (O(1) 复杂度)
  T? findOptionById(R id) {
    return _cacheMap[id];
  }
}
