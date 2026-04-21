import 'package:flutter/material.dart';

class InputKeyword extends StatefulWidget {
  const InputKeyword({super.key});
  @override
  State<InputKeyword> createState() => _InputKeywordState();
}

class _InputKeywordState extends State<InputKeyword> {
  final searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            spacing: 10,
            children: [
              Expanded(
                child: TextFormField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: '请输入内容',
                    prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              searchController.clear();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: Icon(Icons.search),
                label: Text('搜索'),
                style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))),
              ),
            ],
          ),
          SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xfff5f5f5)),
        ],
      ),
    );
  }
}
