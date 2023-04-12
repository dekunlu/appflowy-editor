import 'package:flutter_test/flutter_test.dart';
import 'package:appflowy_editor/src/render/table/table_node_widget.dart';
import 'package:appflowy_editor/src/render/table/table_cell_node_widget.dart';
import 'package:appflowy_editor/src/render/table/table_node.dart';
import 'package:appflowy_editor/src/render/table/table_const.dart';
import 'package:appflowy_editor/src/render/table/table_action.dart';
import 'package:appflowy_editor/src/render/table/util.dart';
import '../../infra/test_editor.dart';

void main() async {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('table_action.dart', () {
    testWidgets('remove column', (tester) async {
      var tableNode = TableNode.fromList([
        ['1', '2'],
        ['3', '4']
      ]);
      final editor = tester.editor..insert(tableNode.node);

      await editor.startTesting(customBuilders: {
        kTableType: TableNodeWidgetBuilder(),
        kTableCellType: TableCellNodeWidgetBuilder()
      });
      await tester.pumpAndSettle();

      final transaction = editor.editorState.transaction;
      removeCol(tableNode.node, 0, transaction);
      editor.editorState.apply(transaction);
      await tester.pump(const Duration(milliseconds: 100));
      tableNode = TableNode(node: tableNode.node);

      expect(tableNode.colsLen, 1);
      expect(
        tableNode.getCell(0, 0).children.first.toJson(),
        {
          "type": "text",
          "delta": [
            {
              "insert": "3",
            }
          ]
        },
      );
    });

    testWidgets('remove row', (tester) async {
      var tableNode = TableNode.fromList([
        ['1', '2'],
        ['3', '4']
      ]);
      final editor = tester.editor..insert(tableNode.node);

      await editor.startTesting(customBuilders: {
        kTableType: TableNodeWidgetBuilder(),
        kTableCellType: TableCellNodeWidgetBuilder()
      });
      await tester.pumpAndSettle();

      final transaction = editor.editorState.transaction;
      removeRow(tableNode.node, 0, transaction);
      editor.editorState.apply(transaction);
      await tester.pump(const Duration(milliseconds: 100));
      tableNode = TableNode(node: tableNode.node);

      expect(tableNode.rowsLen, 1);
      expect(
        tableNode.getCell(0, 0).children.first.toJson(),
        {
          "type": "text",
          "delta": [
            {
              "insert": "2",
            }
          ]
        },
      );
    });

    testWidgets('duplicate column', (tester) async {
      var tableNode = TableNode.fromList([
        ['1', '2'],
        ['3', '4']
      ]);
      final editor = tester.editor..insert(tableNode.node);

      await editor.startTesting(customBuilders: {
        kTableType: TableNodeWidgetBuilder(),
        kTableCellType: TableCellNodeWidgetBuilder()
      });
      await tester.pumpAndSettle();

      final transaction = editor.editorState.transaction;
      duplicateCol(tableNode.node, 0, transaction);
      editor.editorState.apply(transaction);
      await tester.pump(const Duration(milliseconds: 100));
      tableNode = TableNode(node: tableNode.node);

      expect(tableNode.colsLen, 3);
      for (var i = 0; i < tableNode.rowsLen; i++) {
        expect(getCellNode(tableNode.node, 0, i)!.children.first.toJson(),
            getCellNode(tableNode.node, 1, i)!.children.first.toJson());
      }
    });

    testWidgets('duplicate row', (tester) async {
      var tableNode = TableNode.fromList([
        ['1', '2'],
        ['3', '4']
      ]);
      final editor = tester.editor..insert(tableNode.node);

      await editor.startTesting(customBuilders: {
        kTableType: TableNodeWidgetBuilder(),
        kTableCellType: TableCellNodeWidgetBuilder()
      });
      await tester.pumpAndSettle();

      final transaction = editor.editorState.transaction;
      duplicateRow(tableNode.node, 0, transaction);
      editor.editorState.apply(transaction);
      await tester.pump(const Duration(milliseconds: 100));
      tableNode = TableNode(node: tableNode.node);

      expect(tableNode.rowsLen, 3);
      for (var i = 0; i < tableNode.colsLen; i++) {
        expect(getCellNode(tableNode.node, i, 0)!.children.first.toJson(),
            getCellNode(tableNode.node, i, 1)!.children.first.toJson());
      }
    });
  });
}
