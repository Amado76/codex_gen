import 'package:flutter/material.dart';

class HtmlTextWidget extends StatelessWidget {
  final String html;
  final TextStyle baseStyle;

  const HtmlTextWidget({super.key, required this.html, required this.baseStyle});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(style: baseStyle, children: _parse(html, baseStyle)),
    );
  }

  List<TextSpan> _parse(String html, TextStyle base) {
    final spans = <TextSpan>[];
    final text = html
        .replaceAll('<br/>', '\n')
        .replaceAll('<br />', '\n')
        .replaceAll('<br>', '\n')
        .replaceAll('<p>', '')
        .replaceAll('</p>', '\n');

    final regex = RegExp(
      r'<b>(.*?)</b>|<i>(.*?)</i>|<bi>(.*?)</bi>|<ib>(.*?)</ib>|([^<]+)',
      caseSensitive: false,
      dotAll: true,
    );

    for (final m in regex.allMatches(text)) {
      if (m.group(1) != null) {
        spans.add(TextSpan(text: m.group(1), style: base.copyWith(fontWeight: FontWeight.w700)));
      } else if (m.group(2) != null) {
        spans.add(TextSpan(text: m.group(2), style: base.copyWith(fontStyle: FontStyle.italic)));
      } else if (m.group(3) != null || m.group(4) != null) {
        spans.add(TextSpan(
          text: m.group(3) ?? m.group(4),
          style: base.copyWith(fontWeight: FontWeight.w700, fontStyle: FontStyle.italic),
        ));
      } else if (m.group(5) != null) {
        spans.add(TextSpan(text: m.group(5)));
      }
    }
    return spans;
  }
}
