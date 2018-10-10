// Copyright 2016 Google Inc.
// Licensed under the Apache License, Version 2.0 (the "License")
// You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0

import 'exceptions.dart';
import 'row.dart';

class RowMetadata {
  final List<String> columns;
  final Map<String, int> columnToIndex = {};

  RowMetadata(this.columns) {
    for (int i = 0; i < columns.length; i++) {
      columnToIndex[columns[i]] = i;
    }
  }
}

class Row implements IRow {
  final RowMetadata _metadata;
  final List _data;

  @override
  final int index;

  Row(this.index, this._metadata, this._data);

  @override
  dynamic operator [](dynamic i) {
    if (i is int) {
      return _data[i];
    } else {
      var index = _metadata.columnToIndex[i];
      if (index == null) {
        throw SqliteException("No such column $i");
      }
      return _data[index];
    }
  }

  @override
  List<Object> toList() => List<Object>.from(_data);

  @override
  Map<String, Object> toMap() {
    var result = Map<String, Object>();
    for (int i = 0; i < _data.length; i++) {
      result[_metadata.columns[i]] = _data[i];
    }
    return result;
  }

  @override
  String toString() => _data.toString();
}
