import 'package:get/get.dart';
import 'package:miru_app/models/index.dart';
import 'package:miru_app/data/services/database_service.dart';

import 'package:miru_app/data/services/syncdatabase_service.dart';

class HomePageController extends GetxController {
  final RxList<History> resents = <History>[].obs;
  final RxMap<ExtensionType, List<Favorite>> favorites =
      <ExtensionType, List<Favorite>>{}.obs;

  @override
  void onInit() {
    onRefresh();
    super.onInit();
  }

  refreshHistory() async {
    resents.clear();
    resents.addAll(
      await SyncDatabaseService.getHistorysByType(),
    );
  }

  onRefresh() async {
    favorites.clear();
    await refreshHistory();
    favorites.addAll({
      ExtensionType.bangumi: await SyncDatabaseService.getFavoritesByType(
        type: ExtensionType.bangumi,
        limit: 20,
      ),
      ExtensionType.manga: await SyncDatabaseService.getFavoritesByType(
        type: ExtensionType.manga,
        limit: 20,
      ),
      ExtensionType.fikushon: await SyncDatabaseService.getFavoritesByType(
        type: ExtensionType.fikushon,
        limit: 20,
      ),
    });
  }
}
