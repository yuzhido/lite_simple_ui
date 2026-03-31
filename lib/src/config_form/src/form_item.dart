import 'package:flutter/material.dart';
import 'enums.dart';
import 'form_item_config.dart';

/// 表单字段验证器函数类型
typedef FormFieldValidator = String? Function(dynamic value);

/// 表单项数据模型
class FormItem {
  /// 字段名
  final String property;

  /// 标签文本
  final String label;

  /// 表单类型
  final FormType formType;

  /// 是否必填
  final bool required;

  /// 初始值
  final dynamic initialValue;

  /// 值类型（用于智能验证）
  final ValidateType? valueType;

  /// 自定义验证器
  final FormFieldValidator? validator;

  /// 验证触发时机（支持多个）
  final Set<ValidateTrigger> validateTriggers;

  /// 额外配置参数（类型安全）
  final FormItemConfig? config;

  /// 自定义构建函数（当 formType 为 custom 时使用）
  final Widget Function()? customBuilder;

  /// 自定义 Label 构建器
  final Widget Function(BuildContext context, {required bool hasError, required bool isRequired})? labelBuilder;

  /// 自定义内容构建器
  final Widget Function(BuildContext context, dynamic value, Function(dynamic) onChanged)? contentBuilder;

  /// 自定义清除按钮构建器
  final Widget Function(VoidCallback onClear)? clearButtonBuilder;

  /// 右侧状态构建器（用于显示提示文字、状态等）
  final Widget Function(BuildContext, dynamic value)? statusBuilder;

  FormItem({
    required this.property,
    required this.label,
    required this.formType,
    this.required = false,
    this.initialValue,
    this.valueType,
    this.validator,
    this.validateTriggers = const {ValidateTrigger.onBlur},
    this.config,
    this.customBuilder,
    this.labelBuilder,
    this.contentBuilder,
    this.clearButtonBuilder,
    this.statusBuilder,
  });

  /// 获取实际的验证器（优先级：自定义 > valueType > required）
  FormFieldValidator? get actualValidator {
    // 1. 优先使用自定义 validator
    if (validator != null) {
      return validator;
    }

    // 2. 使用 valueType 对应的验证器
    if (valueType != null) {
      return _getTypeValidator(valueType!);
    }

    // 3. 使用 required 的默认非空验证
    if (required) {
      return _defaultRequiredValidator(label);
    }

    return null;
  }

  /// 根据类型获取验证器
  FormFieldValidator _getTypeValidator(ValidateType type) {
    switch (type) {
      case ValidateType.int:
        return _intValidator(label, required);
      case ValidateType.double:
        return _doubleValidator(label, required);
      case ValidateType.email:
        return _emailValidator(label, required);
      case ValidateType.phone:
        return _phoneValidator(label, required);
      case ValidateType.url:
        return _urlValidator(label, required);
      case ValidateType.idCard:
        return _idCardValidator(label, required);
      case ValidateType.postalCode:
        return _postalCodeValidator(label, required);
      case ValidateType.string:
        return _stringValidator(label, required);
    }
  }

  /// 整数验证器
  FormFieldValidator _intValidator(String label, bool required) => (value) {
    if (value == null || value.toString().isEmpty) {
      if (required) {
        return '$label 不能为空';
      }
      return null; // 非必填，空值通过
    }

    final intRegex = RegExp(r'^-?\d+$');
    if (!intRegex.hasMatch(value.toString())) {
      return '$label 必须是整数';
    }
    return null;
  };

  /// 浮点数验证器
  FormFieldValidator _doubleValidator(String label, bool required) => (value) {
    if (value == null || value.toString().isEmpty) {
      if (required) {
        return '$label 不能为空';
      }
      return null;
    }

    final doubleRegex = RegExp(r'^-?\d+(\.\d+)?$');
    if (!doubleRegex.hasMatch(value.toString())) {
      return '$label 必须是数字';
    }
    return null;
  };

  /// 邮箱验证器
  FormFieldValidator _emailValidator(String label, bool required) => (value) {
    if (value == null || value.toString().isEmpty) {
      if (required) {
        return '$label 不能为空';
      }
      return null;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.toString())) {
      return '请输入有效的邮箱地址';
    }
    return null;
  };

  /// 手机号验证器
  FormFieldValidator _phoneValidator(String label, bool required) => (value) {
    if (value == null || value.toString().isEmpty) {
      if (required) {
        return '$label 不能为空';
      }
      return null;
    }

    final phoneRegex = RegExp(r'^1[3-9]\d{9}$');
    if (!phoneRegex.hasMatch(value.toString())) {
      return '请输入正确的手机号';
    }
    return null;
  };

  /// URL 验证器
  FormFieldValidator _urlValidator(String label, bool required) => (value) {
    if (value == null || value.toString().isEmpty) {
      if (required) {
        return '$label 不能为空';
      }
      return null;
    }

    final urlRegex = RegExp(r'^https?://[^\s/$.?#].[^\s]*$');
    if (!urlRegex.hasMatch(value.toString())) {
      return '请输入有效的 URL';
    }
    return null;
  };

  /// 身份证验证器
  FormFieldValidator _idCardValidator(String label, bool required) => (value) {
    if (value == null || value.toString().isEmpty) {
      if (required) {
        return '$label 不能为空';
      }
      return null;
    }

    final idCardRegex = RegExp(r'^\d{17}[\dXx]$');
    if (!idCardRegex.hasMatch(value.toString())) {
      return '请输入正确的身份证号';
    }
    return null;
  };

  /// 邮编验证器
  FormFieldValidator _postalCodeValidator(String label, bool required) => (value) {
    if (value == null || value.toString().isEmpty) {
      if (required) {
        return '$label 不能为空';
      }
      return null;
    }

    final postalCodeRegex = RegExp(r'^\d{6}$');
    if (!postalCodeRegex.hasMatch(value.toString())) {
      return '请输入正确的邮编（6 位数字）';
    }
    return null;
  };

  /// 字符串验证器（默认）
  FormFieldValidator _stringValidator(String label, bool required) => (value) {
    if (value == null || value.toString().isEmpty) {
      if (required) {
        return '$label 不能为空';
      }
      return null;
    }
    return null;
  };

  /// 默认必填验证器（用于没有 valueType 的情况）
  FormFieldValidator _defaultRequiredValidator(String label) => (value) {
    if (value == null) {
      return '$label 不能为空';
    }

    if (value is List) {
      if (value.isEmpty) {
        return '$label 不能为空';
      }
      return null;
    }

    if (value is String) {
      if (value.trim().isEmpty) {
        return '$label 不能为空';
      }
      return null;
    }

    return null;
  };
}
