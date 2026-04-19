import 'package:flutter/material.dart';
import 'package:lite_simple_ui/widgets/bottom_modal_sheet/index.dart';
import 'package:lite_simple_ui/widgets/container_wrapper/index.dart';

class DropdownChoose<R, T> extends StatefulWidget {
  final List<T> options;
  final bool isMultiSelect;
  const DropdownChoose({required this.options, this.isMultiSelect = false, super.key});
  @override
  State<DropdownChoose> createState() => _DropdownChooseState();
}

class _DropdownChooseState<R, T> extends State<DropdownChoose<R, T>> {
  R? _selectedId; // 维护选中的 ID (单选)
  List<R>? _selectedIds; // 维护选中的 ID 列表 (多选)
  String selectedValue = '';
  List<String> selectedValues = [];

  void _updateDisplay() {
    if (widget.isMultiSelect) {
      if (_selectedIds != null && _selectedIds!.isNotEmpty) {
        selectedValue = '已选择 ${_selectedIds!.length} 项';
        selectedValues = _selectedIds!.map((e) => e.toString()).toList();
      } else {
        selectedValue = '';
        selectedValues = [];
      }
    } else {
      selectedValue = _selectedId != null ? _selectedId.toString() : '';
      selectedValues = selectedValue.isNotEmpty ? [selectedValue] : [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return ContainerWrapper(
      selectedValue: selectedValue,
      selectedValues: selectedValues,
      onClear: () {
        setState(() {
          if (widget.isMultiSelect) {
            _selectedIds = [];
          } else {
            _selectedId = null;
          }
          _updateDisplay();
        });
      },
      onTap: () async {
        final res = await BottomModalSheet.show<R, T>(
          context,
          title: '请选择用户',
          options: widget.options,
          defaultValue: widget.isMultiSelect ? _selectedIds : _selectedId,
          isMultiSelect: widget.isMultiSelect,
        );

        if (res != null) {
          setState(() {
            if (widget.isMultiSelect) {
              _selectedIds = res as List<R>?;
            } else {
              _selectedId = res as R?;
            }
            _updateDisplay();
          });
          print('选中结果: $res');
        }
      },
    );
  }
}
