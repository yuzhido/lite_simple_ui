/// 数据缓存管理器 - 组件级别的缓存
///
/// 缓存策略：
/// - 每个 MainContent 实例有自己的缓存
/// - 首次加载后缓存，组件销毁时清除
/// - 只有无关键字的初始加载才缓存
/// - 搜索结果不缓存
class DataCacheManager<T> {
  List<T>? _cachedData;
  bool _isLoaded = false;

  /// 获取缓存数据
  List<T>? get cachedData => _cachedData;

  /// 是否已加载
  bool get isLoaded => _isLoaded;

  /// 设置缓存数据
  void setCache(List<T> data) {
    _cachedData = data;
    _isLoaded = true;
  }

  /// 清除缓存
  void clearCache() {
    _cachedData = null;
    _isLoaded = false;
  }

  /// 是否需要重新加载
  bool shouldReload(bool forceRefresh) {
    return forceRefresh || !_isLoaded;
  }
}
