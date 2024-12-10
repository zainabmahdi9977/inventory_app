import 'package:get_it/get_it.dart';
import 'package:inventory_app/serviecs/reposiory.services.dart';


class MainBloc {
  // Function(bool) completeLoading;

  MainBloc();

  loadData() async {
    if (!GetIt.instance.isRegistered<Repository>()) {
      Repository repository = Repository();
      GetIt.instance.registerSingleton<Repository>(repository);
      await repository.load();
    }

    return true;
  }
}
