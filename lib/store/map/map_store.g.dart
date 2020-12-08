// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$MapStore on _MapStore, Store {
  final _$paddingBottomAtom = Atom(name: '_MapStore.paddingBottom');

  @override
  double get paddingBottom {
    _$paddingBottomAtom.reportRead();
    return super.paddingBottom;
  }

  @override
  set paddingBottom(double value) {
    _$paddingBottomAtom.reportWrite(value, super.paddingBottom, () {
      super.paddingBottom = value;
    });
  }

  final _$_MapStoreActionController = ActionController(name: '_MapStore');

  @override
  void setBottomPadding(double value) {
    final _$actionInfo = _$_MapStoreActionController.startAction(
        name: '_MapStore.setBottomPadding');
    try {
      return super.setBottomPadding(value);
    } finally {
      _$_MapStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
paddingBottom: ${paddingBottom}
    ''';
  }
}
