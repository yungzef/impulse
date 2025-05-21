import 'package:flutter/material.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;

class HtmlRenderer extends StatelessWidget {
  final String html;

  const HtmlRenderer(this.html, {super.key});

  @override
  Widget build(BuildContext context) {
    final document = html_parser.parse(html);
    final bodyElements = document.body?.children ?? [];

    List<Widget> contentWidgets = [];

    for (var element in bodyElements) {
      contentWidgets.addAll(_parseElement(element));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: contentWidgets,
    );
  }

  List<Widget> _parseElement(dom.Element element) {
    List<Widget> widgets = [];

    if (element.localName == 'p') {
      final inlineWidgets = <InlineSpan>[];

      for (var node in element.nodes) {
        if (node is dom.Element && node.localName == 'strong') {
          inlineWidgets.add(
            TextSpan(
              text: node.text,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          );
        } else if (node is dom.Element && node.localName == 'a') {
          // Попытка извлечь картинку из <a><img/></a>
          final img = node.querySelector('img');
          if (img != null) {
            final src = img.attributes['src'];
            if (src != null) {
              widgets.add(
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Image.network(
                    'https://pdr.hsc.gov.ua$src',
                    height: 60,
                  ),
                ),
              );
            }
          }
        } else {
          inlineWidgets.add(TextSpan(text: node.text));
        }
      }

      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                height: 1.5,
              ),
              children: inlineWidgets,
            ),
          ),
        ),
      );
    }

    return widgets;
  }
}
