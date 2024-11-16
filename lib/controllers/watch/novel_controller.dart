import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:miru_app/models/index.dart';
import 'package:miru_app/controllers/watch/reader_controller.dart';
import 'package:miru_app/data/services/database_service.dart';
import 'package:miru_app/utils/miru_storage.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'package:miru_app/data/services/syncdatabase_service.dart';

import '../detail_controller.dart';
import '../home_controller.dart';

class NovelController extends ReaderController<ExtensionFikushonWatch> {
  NovelController({
    required super.title,
    required super.playList,
    required super.detailUrl,
    required super.playIndex,
    required super.episodeGroupId,
    required super.runtime,
    required super.cover,
    required super.anilistID,
  });
  ScrollController scrollController = ScrollController();
  // 字体大小
  final fontSize = (18.0).obs;
  final itemPositionsListener = ItemPositionsListener.create();
  final itemScrollController = ItemScrollController();
  final isRecover = false.obs;
  final positions = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fontSize.value = MiruStorage.getSetting(SettingKey.novelFontSize);

    itemPositionsListener.itemPositions.addListener(() {
      if (itemPositionsListener.itemPositions.value.isEmpty) {
        return;
      }
      final pos = itemPositionsListener.itemPositions.value.first;
      // putHistory(pos.index);
      positions.value = pos.index;
      SchedulerBinding.instance.addPostFrameCallback((_) async {
        putHistory(pos.index);
      });
    });
    ever(
      fontSize,
      (callback) => MiruStorage.setSetting(SettingKey.novelFontSize, callback),
    );

    // 切换章节时重置页码
    ever(index, (callback) => positions.value = 0);

    ever(super.watchData, (callback) async {
      if (isRecover.value || callback == null) {
        return;
      }
      isRecover.value = true;
      // 获取上次阅读的页码
      final history = await SyncDatabaseService.getHistoryByPackageAndUrl(
        super.runtime.extension.package,
        super.detailUrl,
      );
      if (history == null ||
          history.progress.isEmpty ||
          episodeGroupId != history.episodeGroupId ||
          history.episodeId != index.value) {
        return;
      }
      positions.value = int.parse(history.progress);
      itemScrollController.jumpTo(index: positions.value);
    });
  }

  putHistory(nowPositions) async{
    if (super.watchData.value != null) {
      final totalProgress = watchData.value!.content.length.toString();
      super.addHistory(
        nowPositions==null?positions.value.toString():nowPositions.toString(),
        totalProgress,
      );
    }
  }

  @override
  void onClose() async{
    await putHistory(null);
    await Get.find<DetailPageController>().onRefresh();
    await Get.find<HomePageController>().onRefresh();
    super.onClose();
  }

  onKey(KeyEvent event) {
    if (event is KeyUpEvent) {
      return;
    }
    // 上下
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if(positions.value-1<0){
        itemScrollController.jumpTo(index: 0);
        return;
      }
      positions.value = positions.value-1;
      itemScrollController.jumpTo(index: positions.value);
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      int totalProgress = watchData.value!.content.length;
      if(positions.value+1>totalProgress){
        itemScrollController.jumpTo(index: totalProgress);
        return;
      }
      positions.value = positions.value+1;
      itemScrollController.jumpTo(index: positions.value);
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      index.value--;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      index.value++;
    }
  }
}
