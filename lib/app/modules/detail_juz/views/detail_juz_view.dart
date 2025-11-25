import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quranapp/app/contants/colors.dart';
import 'package:quranapp/app/data/models/juz.dart' as juz;
import 'package:quranapp/app/data/models/surah.dart';
import 'package:quranapp/app/modules/home/controllers/home_controller.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../controllers/detail_juz_controller.dart';

class DetailJuzView extends GetView<DetailJuzController> {
  DetailJuzView({super.key});
  final juz.Juz detailJuz = Get.arguments["juz"];
  final List<Surah> allSurahInThisJuz = Get.arguments["surah"];
  final homeC = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    // AUTO-SCROLL dari bookmark (Detail Juz)
    // AUTO-SCROLL dari bookmark (Detail Juz) — robust untuk String/int
    final bm = Get.arguments?["bookmark"];
    if (bm != null && (detailJuz.verses?.isNotEmpty ?? false)) {
      // Helper parse int aman jika String
      int? _asInt(dynamic v) {
        if (v == null) return null;
        if (v is int) return v;
        if (v is String) return int.tryParse(v);
        return null;
      }

      final via = bm["via"]?.toString();
      final int? idxFromJuz = (via == "juz") ? _asInt(bm["index_ayat"]) : null;
      int? targetIndex;

      // 1) Jika bookmark asalnya dari Juz & index valid → pakai langsung
      if (idxFromJuz != null &&
          idxFromJuz >= 0 &&
          idxFromJuz < (detailJuz.verses!.length)) {
        targetIndex = idxFromJuz;
      } else {
        // 2) Fallback: hitung dari (number_surah, ayat(inSurah)) — aman parsing
        final int? targetNumberSurah = _asInt(bm["number_surah"]);
        final int? targetInSurah = _asInt(bm["ayat"]);

        if (targetNumberSurah != null && targetInSurah != null) {
          int currentSurahIdx = 0;
          for (int i = 0; i < detailJuz.verses!.length; i++) {
            final v = detailJuz.verses![i];

            // Samakan dengan logic di itemBuilder:
            if (i != 0 && (v.number?.inSurah ?? 0) == 1) {
              if (currentSurahIdx < allSurahInThisJuz.length - 1) {
                currentSurahIdx++;
              }
            }

            final surahAktif = allSurahInThisJuz[currentSurahIdx];
            final int? inSurahNow = v.number?.inSurah;

            if (surahAktif.number == targetNumberSurah &&
                inSurahNow == targetInSurah) {
              targetIndex = i;
              break;
            }
          }
        }
      }

      if (targetIndex != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          controller.scrollC.scrollToIndex(
            targetIndex!,
            preferPosition: AutoScrollPosition.begin,
          );
        });
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text("Juz ${detailJuz.juz}"), centerTitle: true),
      body: ListView.builder(
        controller: controller.scrollC,
        padding: const EdgeInsets.all(20),
        itemCount: detailJuz.verses?.length ?? 0,
        itemBuilder: (context, index) {
          if (detailJuz.verses?.isEmpty == true) {
            return const Center(child: Text("Tidak ada data."));
          }

          final juz.Verses ayat = detailJuz.verses![index];

          // Saat ketemu ayat pertama surah baru (kecuali item pertama), geser index surah aktif
          if (index != 0 && ayat.number?.inSurah == 1) {
            if (controller.index < allSurahInThisJuz.length - 1) {
              controller.index++;
            }
          }

          // Surah aktif berdasarkan penanda index controller
          final Surah surahAktif = allSurahInThisJuz[controller.index];

          return AutoScrollTag(
            key: ValueKey(index),
            index: index,
            controller: controller.scrollC,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Tampilkan KARTU HEADER saat masuk ayat pertama surah (inSurah == 1)
                if (ayat.number?.inSurah == 1)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () => Get.dialog(
                          Dialog(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(27),
                                color: Get.isDarkMode
                                    ? appPurpleLight2.withValues(alpha: 0.3)
                                    : appWhite,
                              ),
                              padding: const EdgeInsets.all(25),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Tafsir ${surahAktif.name?.transliteration?.id ?? 'Data tidak ditemukan.'}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    surahAktif.tafsir?.id ??
                                        'Tidak ada tafsir di surah ini.',
                                    textAlign: TextAlign.justify,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        child: Container(
                          width: Get.width,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [appPurpleLight1, appPurpleDark],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                // Nama Surah (latin)
                                Text(
                                  surahAktif.name?.transliteration?.id ??
                                      'Data tidak ditemukan.',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                    color: appWhite,
                                  ),
                                ),
                                // Nama terjemahan (Indonesia)
                                Text(
                                  "(${surahAktif.name?.translation?.id ?? 'Data tidak ditemukan.'})",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: appWhite,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                // Info jumlah ayat & tempat turun
                                Text(
                                  "${surahAktif.numberOfVerses ?? '-'} Ayat | ${surahAktif.revelation?.id ?? '-'}",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: appWhite,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                Container(
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
                        // nomor ayat + nama surah aktif
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(right: 10),
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
                              child: Center(
                                child: Text("${ayat.number?.inSurah}"),
                              ),
                            ),
                            Text(
                              surahAktif.name?.transliteration?.id ?? '',
                              style: const TextStyle(
                                fontStyle: FontStyle.italic,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        // aksi
                        // aksi
                        Obx(() {
                          final s = controller.stateFor(
                            ayat,
                          ); // 'stop' | 'playing' | 'pause'
                          return Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  Get.defaultDialog(
                                    title: "BOOKMARK",
                                    middleText: "Pilih jenis bookmark",
                                    actions: [
                                      ElevatedButton(
                                        onPressed: () async {
                                          await controller.addBookmark(
                                            true,
                                            detailJuz,
                                            ayat,
                                            index,
                                            surahAktif.name?.transliteration?.id
                                                    ?.replaceAll("'", "") ??
                                                '-',
                                            surahAktif.number!,
                                          );
                                          homeC.update();
                                        },
                                        child: Text("LAST READ"),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          controller.addBookmark(
                                            false,
                                            detailJuz,
                                            ayat,
                                            index,
                                            surahAktif.name?.transliteration?.id
                                                    ?.replaceAll("'", "") ??
                                                '-',
                                            surahAktif.number!,
                                          );
                                        },
                                        child: Text("BOOKMARK"),
                                      ),
                                    ],
                                  );
                                },
                                icon: Icon(Icons.bookmark_add_outlined),
                              ),
                              if (s == 'stop') ...[
                                IconButton(
                                  onPressed: () => controller.playAudio(ayat),
                                  icon: const Icon(Icons.play_arrow),
                                ),
                              ] else ...[
                                if (s == 'playing')
                                  IconButton(
                                    onPressed: () =>
                                        controller.pauseAudio(ayat),
                                    icon: const Icon(Icons.pause),
                                  )
                                else
                                  IconButton(
                                    onPressed: () =>
                                        controller.resumeAudio(ayat),
                                    icon: const Icon(Icons.play_arrow),
                                  ),
                                IconButton(
                                  onPressed: () => controller.stopAudio(ayat),
                                  icon: const Icon(Icons.stop),
                                ),
                              ],
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Ayat Arab
                const Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: SizedBox.shrink(),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Text(
                    "${ayat.text?.arab}",
                    textAlign: TextAlign.end,
                    style: const TextStyle(fontSize: 30),
                  ),
                ),
                const SizedBox(height: 20),
                // Transliterasi (latin)
                Text(
                  "${ayat.text?.transliteration?.en}",
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    fontSize: 20,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                // Terjemahan Indonesia
                Text(
                  "${ayat.translation?.id}",
                  textAlign: TextAlign.justify,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          );
        },
      ),
    );
  }
}
