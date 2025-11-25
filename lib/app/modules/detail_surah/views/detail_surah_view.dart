import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:quranapp/app/contants/colors.dart';
import 'package:quranapp/app/data/models/detailsurah.dart' as detail;

import 'package:quranapp/app/modules/home/controllers/home_controller.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../controllers/detail_surah_controller.dart';

class DetailSurahView extends GetView<DetailSurahController> {
  final homeC = Get.find<HomeController>();
  Map<String, dynamic>? bookmark;
  DetailSurahView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Surah ${Get.arguments["name"]}',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),

      body: FutureBuilder(
        future: controller.getDetailSurah(Get.arguments["number"].toString()),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return Center(child: Text("Tidak ada data."));
          }
          if (Get.arguments["bookmark"] != null) {
            bookmark = Get.arguments["bookmark"];
            if (bookmark!["index_ayat"] > -1) {
              controller.scrollC.scrollToIndex(
                bookmark!["index_ayat"] + 2,
                preferPosition: AutoScrollPosition.begin,
              );
            }
          }
          detail.Detailsurah surah = snapshot.data!;
          List<Widget>
          allAyat = List.generate(snapshot.data?.verses?.length ?? 0, (index) {
            detail.Verse? ayat = snapshot.data?.verses?[index];
            return AutoScrollTag(
              key: ValueKey(index + 2),
              index: index + 2,
              controller: controller.scrollC,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: appPurpleLight2.withValues(alpha: 0.2),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 7,
                        horizontal: 10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(
                                  Get.isDarkMode
                                      ? "assets/images/bintang_putih.png"
                                      : "assets/images/bintang.png",
                                ),
                                fit: BoxFit.contain,
                              ),
                            ),
                            child: Center(child: Text("${index + 1}")),
                          ),
                          GetBuilder<DetailSurahController>(
                            builder: (c) => Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    Get.defaultDialog(
                                      title: "BOOKMARK",
                                      middleText: "Pilih jenis bookmark",
                                      actions: [
                                        ElevatedButton(
                                          onPressed: () async {
                                            await c.addBookmark(
                                              true,
                                              snapshot.data!,
                                              ayat!,
                                              index,
                                            );
                                            homeC.update();
                                          },
                                          child: Text("LAST READ"),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            c.addBookmark(
                                              false,
                                              snapshot.data!,
                                              ayat!,
                                              index,
                                            );
                                          },
                                          child: Text("BOOKMARK"),
                                        ),
                                      ],
                                    );
                                  },
                                  icon: Icon(Icons.bookmark_add_outlined),
                                ),
                                (ayat?.kondisiAudio == "stop")
                                    ? IconButton(
                                        onPressed: () {
                                          c.playAudio(ayat);
                                        },
                                        icon: Icon(Icons.play_arrow),
                                      )
                                    : Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          (ayat?.kondisiAudio == "playing")
                                              ? IconButton(
                                                  onPressed: () {
                                                    c.pauseAudio(ayat!);
                                                  },
                                                  icon: Icon(Icons.pause),
                                                )
                                              : IconButton(
                                                  onPressed: () {
                                                    c.resumeAudio(ayat!);
                                                  },
                                                  icon: Icon(Icons.play_arrow),
                                                ),
                                          IconButton(
                                            onPressed: () {
                                              c.stopAudio(ayat!);
                                            },
                                            icon: Icon(Icons.stop),
                                          ),
                                        ],
                                      ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Text(
                      "${ayat!.text?.arab}",
                      textAlign: TextAlign.end,
                      style: TextStyle(fontSize: 30),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "${ayat.text?.transliteration?.en}",
                    textAlign: TextAlign.end,
                    style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic),
                  ),
                  Text(
                    "${ayat.translation?.id}",
                    textAlign: TextAlign.justify,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300),
                  ),
                  SizedBox(height: 50),
                ],
              ),
            );
          });

          return ListView(
            controller: controller.scrollC,
            padding: EdgeInsets.all(20),
            children: [
              AutoScrollTag(
                key: ValueKey(0),
                index: 0,
                controller: controller.scrollC,
                child: GestureDetector(
                  onTap: () => Get.dialog(
                    Dialog(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(27),
                          color: Get.isDarkMode
                              ? appPurpleLight2.withValues(alpha: 0.3)
                              : appWhite,
                        ),
                        padding: EdgeInsets.all(25),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Tafsir ${surah.name?.transliteration?.id ?? 'Data tidak ditemukan.'}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            SizedBox(height: 20),
                            Text(
                              surah.tafsir?.id ??
                                  'Tidak ada tafsir disurah ini.',
                              textAlign: TextAlign.justify,
                              //style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [appPurpleLight1, appPurpleDark],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text(
                            surah.name?.transliteration?.id ??
                                'Data tidak ditemukan.',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: appWhite,
                            ),
                          ),
                          Text(
                            "(${surah.name?.translation?.id ?? 'Data tidak ditemukan.'})",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: appWhite,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "${surah.numberOfVerses ?? 'Data tidak ditemukan.'} Ayat | ${surah.revelation?.id ?? 'Data tidak ditemukan.'}",
                            style: TextStyle(fontSize: 16, color: appWhite),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              AutoScrollTag(
                key: ValueKey(1),
                index: 1,
                controller: controller.scrollC,
                child: SizedBox(height: 20),
              ),
              ...allAyat,
            ],
          );
        },
      ),
    );
  }
}
