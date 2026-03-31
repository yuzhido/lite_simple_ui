import 'package:flutter/material.dart';
import 'package:lite_simple_ui/lite_simple_ui.dart';

/// ConfigForm 使用示例页面
class ConfigFormExample extends StatefulWidget {
  const ConfigFormExample({super.key});

  @override
  State<ConfigFormExample> createState() => _ConfigFormExampleState();
}

class _ConfigFormExampleState extends State<ConfigFormExample> {
  // 为纵向和横向布局分别使用不同的控制器
  final ConfigFormController _verticalController = ConfigFormController();
  final ConfigFormController _horizontalController = ConfigFormController();

  // 纵向布局示例
  List<FormItem> _verticalFormItems = [];

  // 横向布局示例
  List<FormItem> _horizontalFormItems = [];

  @override
  void initState() {
    super.initState();
    _initFormItems();
  }

  void _initFormItems() {
    // 纵向布局表单项
    _verticalFormItems = [
      // 示例 1：必填 + 手机号验证
      FormItem(
        property: 'phone',
        label: '手机号',
        formType: FormType.custom,
        required: true,
        valueType: ValidateType.phone,
        validateTriggers: {ValidateTrigger.onBlur, ValidateTrigger.onSubmit},
        customBuilder: () => TextField(
          decoration: const InputDecoration(hintText: '请输入手机号', border: OutlineInputBorder()),
        ),
      ),

      // 示例 2：必填 + 邮箱验证 + 实时验证
      FormItem(
        property: 'email',
        label: '邮箱',
        formType: FormType.custom,
        required: true,
        valueType: ValidateType.email,
        validateTriggers: {ValidateTrigger.onChanged, ValidateTrigger.onBlur, ValidateTrigger.onSubmit},
        customBuilder: () => TextField(
          decoration: const InputDecoration(hintText: '请输入邮箱', border: OutlineInputBorder()),
        ),
      ),

      // 示例 3：必填 + 整数验证
      FormItem(
        property: 'age',
        label: '年龄',
        formType: FormType.custom,
        required: true,
        valueType: ValidateType.int,
        validateTriggers: {ValidateTrigger.onBlur, ValidateTrigger.onSubmit},
        customBuilder: () => TextField(
          decoration: const InputDecoration(hintText: '请输入年龄', border: OutlineInputBorder()),
        ),
      ),

      // 示例 4：非必填 + URL 验证
      FormItem(
        property: 'website',
        label: '个人网站',
        formType: FormType.custom,
        required: false,
        valueType: ValidateType.url,
        validateTriggers: {ValidateTrigger.onBlur, ValidateTrigger.onSubmit},
        customBuilder: () => TextField(
          decoration: const InputDecoration(hintText: '请输入 URL', border: OutlineInputBorder()),
        ),
      ),

      // 示例 5：只验证非空（不指定 valueType）
      FormItem(
        property: 'username',
        label: '用户名',
        formType: FormType.custom,
        required: true,
        validateTriggers: {ValidateTrigger.onBlur, ValidateTrigger.onSubmit},
        customBuilder: () => TextField(
          decoration: const InputDecoration(hintText: '请输入用户名', border: OutlineInputBorder()),
        ),
      ),

      // 示例 6：整数输入框（FormType.int）- 基础用法
      FormItem(
        property: 'age',
        label: '年龄',
        formType: FormType.int,
        required: true,
        initialValue: 18,
        config: IntInputConfig(hintText: '请输入年龄'),
      ),

      // 示例 7：整数输入框 - 带范围限制
      FormItem(
        property: 'score',
        label: '分数',
        formType: FormType.int,
        required: true,
        initialValue: 75,
        config: IntInputConfig(hintText: '请输入分数 (0-100)', minValue: 0, maxValue: 100),
      ),

      // 示例 8：整数输入框 - 允许负数
      FormItem(
        property: 'temperature',
        label: '温度',
        formType: FormType.int,
        required: false,
        initialValue: -5,
        config: IntInputConfig(hintText: '请输入温度', allowNegative: true, minValue: -100, maxValue: 100),
      ),

      // 示例 9：下拉选择器（FormType.dropdownChoose）
      FormItem(
        property: 'city',
        label: '城市',
        formType: FormType.dropdownChoose,
        required: true,
        initialValue: {'id': 'beijing', 'label': '北京'},
        config: DropdownChooseConfig(
          options: [
            {'id': 'beijing', 'label': '北京'},
            {'id': 'shanghai', 'label': '上海'},
            {'id': 'guangzhou', 'label': '广州'},
            {'id': 'shenzhen', 'label': '深圳'},
          ],
        ),
      ),

      // 示例 10：树形选择器（FormType.chooseTree）
      FormItem(
        property: 'department',
        label: '部门',
        formType: FormType.chooseTree,
        required: true,
        initialValue: {'id': '1-1-1', 'label': '开发组'},
        config: ChooseTreeConfig(
          data: [
            {
              'id': '1',
              'label': '总公司',
              'children': [
                {
                  'id': '1-1',
                  'label': '技术部',
                  'children': [
                    {'id': '1-1-1', 'label': '开发组'},
                    {'id': '1-1-2', 'label': '测试组'},
                  ],
                },
                {
                  'id': '1-2',
                  'label': '市场部',
                  'children': [
                    {'id': '1-2-1', 'label': '销售组'},
                    {'id': '1-2-2', 'label': '运营组'},
                  ],
                },
              ],
            },
            {
              'id': '2',
              'label': '分公司',
              'children': [
                {'id': '2-1', 'label': '研发部'},
                {'id': '2-2', 'label': '人事部'},
              ],
            },
          ],
        ),
      ),

      // 示例 11：单行文本输入框（FormType.text）
      FormItem(
        property: 'username',
        label: '用户名',
        formType: FormType.text,
        required: true,
        initialValue: '',
        config: TextInputConfig(hintText: '请输入用户名', maxLength: 50),
      ),

      // 示例 12：多行文本输入框（FormType.textarea）
      FormItem(
        property: 'description',
        label: '描述',
        formType: FormType.textarea,
        required: false,
        initialValue: '',
        config: TextareaInputConfig(hintText: '请输入描述信息', minLines: 4, maxLines: 8, maxLength: 500),
      ),
    ];

    // 横向布局表单项
    _horizontalFormItems = [
      // 示例 1：自定义 Label 和清除按钮
      FormItem(
        property: 'icon',
        label: '图标',
        formType: FormType.custom,
        required: false,
        validateTriggers: {ValidateTrigger.onSubmit},
        labelBuilder: (context, {required hasError, required isRequired}) {
          return Row(
            children: [
              Icon(Icons.image, color: Colors.grey, size: 20),
              const SizedBox(width: 8),
              const Text('图标'),
            ],
          );
        },
        contentBuilder: (context, value, onChanged) {
          return TextField(
            onChanged: onChanged,
            decoration: const InputDecoration(hintText: '图标 URL', prefixIcon: Icon(Icons.link), border: OutlineInputBorder()),
          );
        },
        clearButtonBuilder: (onClear) {
          return IconButton(
            icon: const Icon(Icons.cancel, color: Colors.red),
            onPressed: onClear,
          );
        },
      ),

      // 示例 2：身份证验证
      FormItem(
        property: 'idCard',
        label: '身份证号',
        formType: FormType.custom,
        required: true,
        valueType: ValidateType.idCard,
        validateTriggers: {ValidateTrigger.onBlur, ValidateTrigger.onSubmit},
        customBuilder: () => TextField(
          decoration: const InputDecoration(hintText: '请输入身份证号', border: OutlineInputBorder()),
        ),
      ),

      // 示例 3：邮编验证
      FormItem(
        property: 'postalCode',
        label: '邮编',
        formType: FormType.custom,
        required: true,
        valueType: ValidateType.postalCode,
        validateTriggers: {ValidateTrigger.onBlur, ValidateTrigger.onSubmit},
        customBuilder: () => TextField(
          decoration: const InputDecoration(hintText: '请输入邮编', border: OutlineInputBorder()),
        ),
      ),

      // 示例 4：浮点数验证
      FormItem(
        property: 'price',
        label: '价格',
        formType: FormType.custom,
        required: true,
        valueType: ValidateType.double,
        validateTriggers: {ValidateTrigger.onBlur, ValidateTrigger.onSubmit},
        customBuilder: () => TextField(
          decoration: const InputDecoration(hintText: '请输入价格', border: OutlineInputBorder()),
        ),
      ),

      // 示例 5：整数输入框（FormType.int）- 横向布局
      FormItem(
        property: 'quantity',
        label: '数量',
        formType: FormType.int,
        required: true,
        initialValue: 10,
        config: IntInputConfig(hintText: '请输入数量', minValue: 1, maxValue: 999, showClearButton: true),
      ),

      // 示例 6：单行文本输入框（FormType.text）- 横向布局
      FormItem(
        property: 'nickname',
        label: '昵称',
        formType: FormType.text,
        required: true,
        initialValue: '',
        config: TextInputConfig(hintText: '请输入昵称', maxLength: 20, showClearButton: true),
      ),

      // 示例 7：多行文本输入框（FormType.textarea）- 横向布局
      FormItem(
        property: 'remark',
        label: '备注',
        formType: FormType.textarea,
        required: false,
        initialValue: '',
        config: TextareaInputConfig(hintText: '请输入备注信息', minLines: 3, maxLines: 6, maxLength: 200, showClearButton: true),
      ),
    ];
  }

  // 验证纵向布局的字段
  bool _validateVerticalForm() {
    bool isValid = true;
    final verticalProperties = ['phone', 'email', 'age', 'website', 'username', 'score', 'temperature', 'city', 'department', 'username', 'description'];

    for (final property in verticalProperties) {
      final error = _verticalController.validateField(property);
      if (error != null) {
        isValid = false;
      }
    }

    return isValid;
  }

  // 验证横向布局的字段
  bool _validateHorizontalForm() {
    bool isValid = true;
    final horizontalProperties = ['icon', 'idCard', 'postalCode', 'price', 'quantity', 'nickname', 'remark'];

    for (final property in horizontalProperties) {
      final error = _horizontalController.validateField(property);
      if (error != null) {
        isValid = false;
      }
    }

    return isValid;
  }

  // 验证所有字段（合并两个控制器的字段）
  bool _validateAllForms() {
    // 先验证纵向布局
    bool isValid = _validateVerticalForm();
    // 再验证横向布局
    if (!_validateHorizontalForm()) {
      isValid = false;
    }
    return isValid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ConfigForm 配置表单示例')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 纵向布局示例
              const Text('纵向布局（Vertical Layout）', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                child: ConfigForm(
                  items: _verticalFormItems,
                  controller: _verticalController,
                  config: const FormConfig(layout: LayoutStyle.vertical),
                ),
              ),
              // 纵向布局的提交按钮
              Padding(
                padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // 只验证纵向布局的字段
                          final isValid = _validateVerticalForm();
                          if (isValid) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('纵向布局验证通过')));
                            // 获取纵向布局字段的值
                            final values = {
                              'phone': _verticalController.getValue('phone'),
                              'email': _verticalController.getValue('email'),
                              'age': _verticalController.getValue('age'),
                              'website': _verticalController.getValue('website'),
                              'username': _verticalController.getValue('username'),
                              'score': _verticalController.getValue('score'),
                              'temperature': _verticalController.getValue('temperature'),
                              'city': _verticalController.getValue('city'),
                              'department': _verticalController.getValue('department'),
                              'username2': _verticalController.getValue('username'),
                              'description': _verticalController.getValue('description'),
                            };
                            debugPrint('纵向布局表单值：$values');
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('验证失败，请检查纵向布局表单'), backgroundColor: Colors.red));
                          }
                        },
                        child: const Text('验证纵向布局表单'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        // 重置纵向布局字段
                        _verticalController.resetField('phone');
                        _verticalController.resetField('email');
                        _verticalController.resetField('age');
                        _verticalController.resetField('website');
                        _verticalController.resetField('username');
                        _verticalController.resetField('score');
                        _verticalController.resetField('temperature');
                        _verticalController.resetField('city');
                        _verticalController.resetField('department');
                        _verticalController.resetField('username');
                        _verticalController.resetField('description');
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('纵向布局已重置')));
                      },
                      child: const Text('重置'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 横向布局示例
              const Text('横向布局（Horizontal Layout）', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                child: ConfigForm(
                  items: _horizontalFormItems,
                  controller: _horizontalController,
                  config: const FormConfig(layout: LayoutStyle.horizontal, labelWidth: 100, showDivider: true),
                ),
              ),
              // 横向布局的提交按钮
              Padding(
                padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // 只验证横向布局的字段
                          final isValid = _validateHorizontalForm();
                          if (isValid) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('横向布局验证通过')));
                            // 获取横向布局字段的值
                            final values = {
                              'icon': _horizontalController.getValue('icon'),
                              'idCard': _horizontalController.getValue('idCard'),
                              'postalCode': _horizontalController.getValue('postalCode'),
                              'price': _horizontalController.getValue('price'),
                              'quantity': _horizontalController.getValue('quantity'),
                              'nickname': _horizontalController.getValue('nickname'),
                              'remark': _horizontalController.getValue('remark'),
                            };
                            debugPrint('横向布局表单值：$values');
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('验证失败，请检查横向布局表单'), backgroundColor: Colors.red));
                          }
                        },
                        child: const Text('验证横向布局表单'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        // 重置横向布局字段
                        _horizontalController.resetField('icon');
                        _horizontalController.resetField('idCard');
                        _horizontalController.resetField('postalCode');
                        _horizontalController.resetField('price');
                        _horizontalController.resetField('quantity');
                        _horizontalController.resetField('nickname');
                        _horizontalController.resetField('remark');
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('横向布局已重置')));
                      },
                      child: const Text('重置'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 全局操作按钮（验证所有字段）
              const Text('全局验证（验证所有字段）', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // 验证所有字段（合并两个控制器）
                      final isValid = _validateAllForms();
                      if (isValid) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('所有表单验证通过')));
                        // 获取所有值
                        final values = {..._verticalController.getAllValues(), ..._horizontalController.getAllValues()};
                        debugPrint('所有表单值：$values');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('验证失败，请检查所有表单'), backgroundColor: Colors.red));
                      }
                    },
                    child: const Text('验证所有表单'),
                  ),
                  const SizedBox(width: 16),
                  TextButton(
                    onPressed: () {
                      // 重置所有表单
                      _verticalController.reset();
                      _horizontalController.reset();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('所有表单已重置')));
                    },
                    child: const Text('重置所有'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _verticalController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }
}
