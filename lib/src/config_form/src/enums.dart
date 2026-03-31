/// ConfigForm 配置表单枚举定义

/// 验证类型枚举
enum ValidateType {
  /// 字符串（默认）
  string,

  /// 整数
  int,

  /// 浮点数
  double,

  /// 邮箱
  email,

  /// 手机号
  phone,

  /// URL
  url,

  /// 身份证
  idCard,

  /// 邮编
  postalCode,
}

/// 验证触发时机枚举
enum ValidateTrigger {
  /// 失焦验证
  onBlur,

  /// 实时验证（输入内容变化时）
  onChanged,

  /// 提交验证
  onSubmit,
}

/// 表单类型枚举
enum FormType {
  /// 字符串-单行文本输入框
  text,

  /// 文本输入框-多行文本输入
  textarea,

  /// 整数-数字输入框
  int,

  /// 浮点数-数字输入框
  double,

  /// 下拉选择器
  dropdownChoose,

  /// 树形选择器
  chooseTree,

  /// 自定义组件
  custom,
}

/// 布局风格枚举
enum LayoutStyle {
  /// 纵向布局：label 在上，输入在下
  vertical,

  /// 横向布局：label 和输入在同一行
  horizontal,
}
