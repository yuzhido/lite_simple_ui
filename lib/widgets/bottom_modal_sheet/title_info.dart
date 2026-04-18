import 'package:flutter/material.dart';

class TitleInfo extends StatefulWidget {
  final String? title;
  final List<dynamic>? options;
  const TitleInfo({super.key, this.title, this.options});
  @override
  State<TitleInfo> createState() => _TitleInfoState();
}

class _TitleInfoState extends State<TitleInfo> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 0),
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
          ],
        ),
        // 标题区域
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          spacing: 10,
          children: [
            Expanded(
              child: Text(
                '${widget.title}',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Text('共 ${widget.options?.length ?? 0} 项', style: TextStyle(fontSize: 16, color: Colors.grey)),
            Icon(Icons.close),
          ],
        ),
      ],
    );
  }
}
