import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:html/dom.dart' as dom;

class HtmlBulletedListNodeParser extends HTMLNodeParser {
  const HtmlBulletedListNodeParser();

  @override
  String get id => BulletedListBlockKeys.type;

  @override
  String transformNodeToHTMLString(
    Node node, {
    required List<HTMLNodeParser> encodeParsers,
  }) {
    assert(node.type == BulletedListBlockKeys.type);

    return toHTMLString(
      transformNodeToDomNodes(node, encodeParsers: encodeParsers),
    );
  }

  @override
  List<dom.Node> transformNodeToDomNodes(
    Node node, {
    required List<HTMLNodeParser> encodeParsers,
  }) {
    final delta = node.delta ?? Delta();
    final domNodes = deltaHTMLEncoder.convert(delta);
    domNodes.addAll(
      childrenNodes(
        node.children,
        encodeParsers: encodeParsers,
      ),
    );

    final element = insertText(HTMLTags.list, childNodes: domNodes);
    return [
      dom.Element.tag(HTMLTags.unorderedList)..append(element),
    ];
  }
}
