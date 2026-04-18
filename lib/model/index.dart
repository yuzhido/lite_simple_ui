/// 表单类型
enum FormItemType {
  /// 整数
  integer,

  /// 小数
  double,

  /// 下拉选
  dropdown,

  /// 树选择
  treeSelect,

  /// 日期选择
  date,

  /// 时间选择
  time,

  /// 日期时间选择
  dateTime,

  /// 上传
  upload,

  /// 选择
  select,

  /// 单选框
  radio,

  /// 复选框
  checkbox,
}

/// 文件类型
enum FileType {
  /// 文件
  file,

  /// 图片
  image,

  /// 视频
  video,

  /// 音频
  audio,
}

/// 数据源类型
enum DataSourceType {
  /// 数据源
  local,

  /// API数据源
  api,
}

/// 数据缓存方式
enum DataCacheType {
  /// 无缓存
  none,

  /// 缓存
  cache,
}

/// 备选数据模型
class ChooseDataModel<T, Id> {
  T data;
  String name;
  Id value;
  ChooseDataModel({required this.name, required this.value, required this.data});
}
