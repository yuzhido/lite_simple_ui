/// DropdownChoose 组件的显示模式枚举
enum DropdownDisplayMode {
  /// 纯文本模式：单选显示名称，多选以逗号分隔
  text,

  /// 标签胶囊模式：每个选项显示为一个带背景的标签（默认样式）
  tags,

  /// 折叠模式：显示前 N 个标签，剩余的合并为 "+X 更多"
  compact,
}
