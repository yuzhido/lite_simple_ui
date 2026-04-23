/// 数据助手类 - 处理选项数据的提取和查找
class DropdownDataHelper<R, T> {
  final List<T> options;
  final R Function(T)? valueExtractor;
  final String Function(T)? displayText;

  DropdownDataHelper({required this.options, this.valueExtractor, this.displayText});

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

  /// 通过 ID 在 options 中查找对象
  T? findOptionById(R id) {
    for (var item in options) {
      if (extractValue(item) == id) return item;
    }
    return null;
  }
}
