import 'package:mobx/mobx.dart';
part 'map_store.g.dart';

class MapStore = _MapStore with _$MapStore;

abstract class _MapStore with Store {
  @observable
  double paddingBottom = 0;

  @action
  void setBottomPadding(double value) => paddingBottom = value;
}
