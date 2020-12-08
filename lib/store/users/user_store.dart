import 'package:mobx/mobx.dart';
part 'user_store.g.dart';

class UserStore = _UserStore with _$UserStore;

abstract class _UserStore with Store {
  @observable
  bool loading = false;

  @action
  void setLoading(bool value) => loading = value;
}
