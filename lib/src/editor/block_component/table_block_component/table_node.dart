import 'dart:math';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/block_component/table_block_component/table_config.dart';

class TableNode {
  final TableConfig _config;

  final Node node;
  final EditorState? editorState;
  final List<List<Node>> _cells = [];

  TableNode({
    required this.node,
    this.editorState,
  }) : _config = TableConfig.fromJson(node.attributes) {
    assert(node.type == TableBlockKeys.type);
    assert(node.attributes.containsKey(TableBlockKeys.colsLen));
    assert(node.attributes[TableBlockKeys.colsLen] is int);
    assert(node.attributes.containsKey(TableBlockKeys.rowsLen));
    assert(node.attributes[TableBlockKeys.rowsLen] is int);

    assert(node.attributes[TableBlockKeys.rowDefaultHeight] != null);
    assert(node.attributes[TableBlockKeys.colMinimumWidth] != null);
    assert(node.attributes[TableBlockKeys.colDefaultWidth] != null);

    final int colsCount = node.attributes[TableBlockKeys.colsLen];
    final int rowsCount = node.attributes[TableBlockKeys.rowsLen];
    assert(node.children.length == colsCount * rowsCount);
    assert(
      node.children.every(
        (n) =>
            n.attributes.containsKey(TableBlockKeys.rowPosition) &&
            n.attributes.containsKey(TableBlockKeys.colPosition),
      ),
    );
    assert(
      node.children.every(
        (n) =>
            n.attributes.containsKey(TableBlockKeys.rowPosition) &&
            n.attributes.containsKey(TableBlockKeys.colPosition),
      ),
    );

    for (var i = 0; i < colsCount; i++) {
      _cells.add([]);
      for (var j = 0; j < rowsCount; j++) {
        final cell = node.children.where(
          (n) =>
              n.attributes[TableBlockKeys.colPosition] == i &&
              n.attributes[TableBlockKeys.rowPosition] == j,
        );
        assert(cell.length == 1);
        _cells[i].add(newCellNode(node, cell.first));
      }
    }
  }

  factory TableNode.fromJson(Map<String, Object> json) {
    return TableNode(node: Node.fromJson(json));
  }

  static TableNode fromList<T>(List<List<T>> cols, {TableConfig? config}) {
    assert(
      T == String ||
          (T == Node &&
              cols.every(
                (col) => col.every((n) => (n as Node).delta != null),
              )),
    );
    assert(cols.isNotEmpty);
    assert(cols[0].isNotEmpty);
    assert(cols.every((col) => col.length == cols[0].length));

    config = config ?? const TableConfig();

    Node node = Node(
      type: TableBlockKeys.type,
      attributes: {}
        ..addAll({
          TableBlockKeys.colsLen: cols.length,
          TableBlockKeys.rowsLen: cols[0].length,
        })
        ..addAll(config.toJson()),
    );
    for (var i = 0; i < cols.length; i++) {
      for (var j = 0; j < cols[0].length; j++) {
        final cell = Node(
          type: TableCellBlockKeys.type,
          attributes: {
            TableBlockKeys.colPosition: i,
            TableBlockKeys.rowPosition: j
          },
        );

        late Node cellChild;
        if (T == String) {
          cellChild = paragraphNode(
            delta: Delta()..insert(cols[i][j] as String),
          );
        } else {
          cellChild = cols[i][j] as Node;
        }
        cell.insert(cellChild);

        node.insert(cell);
      }
    }

    return TableNode(node: node);
  }

  Node getCell(int col, row) => _cells[col][row];

  TableConfig get config => _config;

  int get colsLen => _cells.length;

  int get rowsLen => _cells.isNotEmpty ? _cells[0].length : 0;

  double getRowHeight(int row) =>
      double.tryParse(
        _cells[0][row].attributes[TableBlockKeys.height].toString(),
      ) ??
      _config.rowDefaultHeight;

  double get colsHeight =>
      List.generate(rowsLen, (idx) => idx).fold<double>(
        0,
        (prev, cur) => prev + getRowHeight(cur) + _config.borderWidth,
      ) +
      _config.borderWidth;

  double getColWidth(int col) =>
      double.tryParse(
        _cells[col][0].attributes[TableBlockKeys.width].toString(),
      ) ??
      _config.colDefaultWidth;

  double get tableWidth =>
      List.generate(colsLen, (idx) => idx).fold<double>(
        0,
        (prev, cur) => prev + getColWidth(cur) + _config.borderWidth,
      ) +
      _config.borderWidth;

  // void setColWidth(int col, double w) {
  //   w = w < _config.colMinimumWidth ? _config.colMinimumWidth : w;
  //   if (getColWidth(col) != w) {
  //     for (var i = 0; i < rowsLen; i++) {
  //       _cells[col][i].updateAttributes({TableBlockKeys.width: w});
  //     }
  //     for (var i = 0; i < rowsLen; i++) {
  //       updateRowHeight(i);
  //     }

  //   }
  // }

  Future<void> setColWidth(
    int col,
    double w, {
    EditorState? editorState,
  }) async {
    editorState ??= this.editorState;
    if (editorState == null) {
      return;
    }
    final transaction = editorState.transaction;
    w = w < _config.colMinimumWidth ? _config.colMinimumWidth : w;
    if (getColWidth(col) != w) {
      for (var i = 0; i < rowsLen; i++) {
        transaction.updateNode(_cells[col][i], {TableBlockKeys.width: w});
      }
      for (var i = 0; i < rowsLen; i++) {
        await updateRowHeight(i);
      }
      transaction.updateNode(node, node.attributes);
    }
    transaction.afterSelection = transaction.beforeSelection;
    await editorState.apply(transaction);
  }

  Future<void> updateRowHeight(int row) async {
    if (editorState == null) {
      return;
    }
    final transaction = editorState!.transaction;

    // The extra 8 is because of paragraph padding
    double maxHeight = _cells
        .map<double>((c) => c[row].children.first.rect.height + 8)
        .reduce(max);

    if (_cells[0][row].attributes[TableBlockKeys.height] != maxHeight) {
      for (var i = 0; i < colsLen; i++) {
        transaction.updateNode(
          _cells[i][row],
          {TableBlockKeys.height: maxHeight},
        );
      }
    }

    if (node.attributes[TableBlockKeys.colsHeight] != colsHeight) {
      transaction.updateNode(node, {TableBlockKeys.colsHeight: colsHeight});
    }

    transaction.afterSelection = transaction.beforeSelection;
    await editorState!.apply(transaction);
  }
}
