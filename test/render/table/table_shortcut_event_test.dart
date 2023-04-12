import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/render/table/util.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:appflowy_editor/src/render/table/table_node.dart';
import '../../infra/test_editor.dart';

void main() async {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('table_shortcut_event.dart', () {
    testWidgets('enter key on middle cells', (tester) async {
      final tableNode = TableNode.fromList([
        ['', ''],
        ['', '']
      ]);
      final editor = tester.editor..insert(tableNode.node);

      await editor.startTesting(customBuilders: {
        kTableType: TableNodeWidgetBuilder(),
        kTableCellType: TableCellNodeWidgetBuilder()
      }, shortcutEvents: [
        enterInTableCell
      ]);
      await tester.pumpAndSettle();

      var cell00 = getCellNode(tableNode.node, 0, 0)!;

      await editor.updateSelection(
          Selection.single(path: cell00.childAtIndex(0)!.path, startOffset: 0));
      await editor.pressLogicKey(key: LogicalKeyboardKey.enter);

      var selection = editor.documentSelection!;
      var cell01 = getCellNode(tableNode.node, 0, 1)!;

      expect(selection.isCollapsed, true);
      expect(selection.start.path, cell01.childAtIndex(0)!.path);
      expect(selection.start.offset, 0);
    });

    testWidgets('enter key on last cell', (tester) async {
      final tableNode = TableNode.fromList([
        ['', ''],
        ['', '']
      ]);
      final editor = tester.editor..insert(tableNode.node);

      await editor.startTesting(customBuilders: {
        kTableType: TableNodeWidgetBuilder(),
        kTableCellType: TableCellNodeWidgetBuilder()
      }, shortcutEvents: [
        enterInTableCell
      ]);
      await tester.pumpAndSettle();

      var cell11 = getCellNode(tableNode.node, 1, 1)!;

      await editor.updateSelection(
          Selection.single(path: cell11.childAtIndex(0)!.path, startOffset: 0));
      await editor.pressLogicKey(key: LogicalKeyboardKey.enter);

      var selection = editor.documentSelection!;

      expect(selection.isCollapsed, true);
      expect(selection.start.path, editor.nodeAtPath([1])!.path);
      expect(selection.start.offset, 0);
      expect(editor.documentLength, 2);
    });

    testWidgets('backspace on beginning of cell', (tester) async {
      final tableNode = TableNode.fromList([
        ['', ''],
        ['', '']
      ]);
      final editor = tester.editor..insert(tableNode.node);

      await editor.startTesting(customBuilders: {
        kTableType: TableNodeWidgetBuilder(),
        kTableCellType: TableCellNodeWidgetBuilder()
      }, shortcutEvents: [
        enterInTableCell
      ]);
      await tester.pumpAndSettle();

      var cell10 = getCellNode(tableNode.node, 1, 0)!;

      await editor.updateSelection(
          Selection.single(path: cell10.childAtIndex(0)!.path, startOffset: 0));
      await editor.pressLogicKey(key: LogicalKeyboardKey.backspace);

      var selection = editor.documentSelection!;

      expect(selection.isCollapsed, true);
      expect(selection.start.path, cell10.childAtIndex(0)!.path);
      expect(selection.start.offset, 0);
    });

    // TODO(zoli)
    //testWidgets('backspace on multiple cell selection', (tester) async {});

    //testWidgets(
    //    'backspace on cell and after table node selection', (tester) async {});

    testWidgets('up arrow key move to above row with same column',
        (tester) async {
      final tableNode = TableNode.fromList([
        ['ab', 'cde'],
        ['', '']
      ]);
      final editor = tester.editor..insert(tableNode.node);

      await editor.startTesting(customBuilders: {
        kTableType: TableNodeWidgetBuilder(),
        kTableCellType: TableCellNodeWidgetBuilder()
      }, shortcutEvents: [
        upInTableCell
      ]);
      await tester.pumpAndSettle();

      var cell01 = getCellNode(tableNode.node, 0, 1)!;
      var cell00 = getCellNode(tableNode.node, 0, 0)!;

      await editor.updateSelection(
          Selection.single(path: cell01.childAtIndex(0)!.path, startOffset: 1));
      await editor.pressLogicKey(key: LogicalKeyboardKey.arrowUp);

      var selection = editor.documentSelection!;

      expect(selection.isCollapsed, true);
      expect(selection.start.path, cell00.childAtIndex(0)!.path);
      expect(selection.start.offset, 1);

      await editor.updateSelection(
          Selection.single(path: cell01.childAtIndex(0)!.path, startOffset: 3));
      await editor.pressLogicKey(key: LogicalKeyboardKey.arrowUp);

      selection = editor.documentSelection!;

      expect(selection.isCollapsed, true);
      expect(selection.start.path, cell00.childAtIndex(0)!.path);
      expect(selection.start.offset, 2);
    });

    testWidgets('down arrow key move to down row with same column',
        (tester) async {
      final tableNode = TableNode.fromList([
        ['abc', 'de'],
        ['', '']
      ]);
      final editor = tester.editor..insert(tableNode.node);

      await editor.startTesting(customBuilders: {
        kTableType: TableNodeWidgetBuilder(),
        kTableCellType: TableCellNodeWidgetBuilder()
      }, shortcutEvents: [
        downInTableCell
      ]);
      await tester.pumpAndSettle();

      var cell01 = getCellNode(tableNode.node, 0, 1)!;
      var cell00 = getCellNode(tableNode.node, 0, 0)!;

      await editor.updateSelection(
          Selection.single(path: cell00.childAtIndex(0)!.path, startOffset: 1));
      await editor.pressLogicKey(key: LogicalKeyboardKey.arrowDown);

      var selection = editor.documentSelection!;

      expect(selection.isCollapsed, true);
      expect(selection.start.path, cell01.childAtIndex(0)!.path);
      expect(selection.start.offset, 1);

      await editor.updateSelection(
          Selection.single(path: cell00.childAtIndex(0)!.path, startOffset: 3));
      await editor.pressLogicKey(key: LogicalKeyboardKey.arrowDown);

      selection = editor.documentSelection!;

      expect(selection.isCollapsed, true);
      expect(selection.start.path, cell01.childAtIndex(0)!.path);
      expect(selection.start.offset, 2);
    });
  });
}
