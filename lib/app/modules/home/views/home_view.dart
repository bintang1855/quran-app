import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:quranapp/app/contants/colors.dart';
import 'package:quranapp/app/data/models/juz.dart' as juz;
import 'package:quranapp/app/data/models/surah.dart';
import 'package:quranapp/app/routes/app_pages.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    if (Get.isDarkMode) {
      controller.isDark.value = true;
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Al Quran Apps',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              // Langsung kirim data yang sudah ada di controller
              // Data akan diload saat pertama kali buka tab Surah/Juz
              Get.toNamed(
                Routes.SEARCH,
                arguments: {
                  'surah': controller.allSurah,
                  'juz': controller.allJuz,
                },
              );
            },
            icon: Icon(Icons.search),
          ),
        ],
      ),
      body: DefaultTabController(
        length: 3,
        child: Padding(
          padding: const EdgeInsets.only(top: 20, right: 20, left: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Assalamualikum",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              GetBuilder<HomeController>(
                builder: (c) => FutureBuilder<Map<String, dynamic>?>(
                  future: c.getLastRead(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [appPurpleLight1, appPurpleDark],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                bottom: -30,
                                right: 0,
                                child: Opacity(
                                  opacity: 0.7,
                                  child: SizedBox(
                                    width: 160,
                                    height: 160,
                                    child: Image.asset(
                                      "assets/images/alquran.png",
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.menu_book_rounded,
                                          color: appWhite,
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          "Terakhir dibaca",
                                          style: TextStyle(color: appWhite),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 30),
                                    Text(
                                      "Loading...",
                                      style: TextStyle(color: appWhite),
                                    ),
                                    Text("", style: TextStyle(color: appWhite)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    Map<String, dynamic>? lastRead = snapshot.data;
                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [appPurpleLight1, appPurpleDark],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        child: InkWell(
                          onLongPress: () {
                            if (lastRead != null) {
                              Get.defaultDialog(
                                title: "Delete Last Read",
                                middleText:
                                    "Are you sure to delete this last read?",
                                actions: [
                                  OutlinedButton(
                                    onPressed: () => Get.back(),
                                    child: Text("Cancel"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      c.deleteBookmark(lastRead['id']);
                                    },
                                    child: Text("Delete"),
                                  ),
                                ],
                              );
                            }
                          },
                          borderRadius: BorderRadius.circular(20),
                          onTap: () async {
                            if (lastRead == null) return;

                            final via = (lastRead['via'] ?? '')
                                .toString()
                                .toLowerCase();

                            switch (via) {
                              case 'juz':
                                // Ambil nomor juz dari lastRead
                                final int juzNumber =
                                    int.tryParse('${lastRead["juz"]}') ?? -1;

                                // Ambil semua Juz dari HomeController
                                final List<juz.Juz> allJuz = await controller
                                    .getAllJuz();

                                // Fallback aman kalau data nggak valid
                                if (allJuz.isEmpty || juzNumber <= 0) {
                                  Get.toNamed(
                                    Routes.DETAIL_SURAH,
                                    arguments: {
                                      "name": lastRead["surah"]
                                          .toString()
                                          .replaceAll("+", ""),
                                      "number": lastRead["number_surah"],
                                      "bookmark":
                                          lastRead, // biar auto-scroll di DetailSurah (kalau ada)
                                    },
                                  );
                                  return;
                                }

                                // DAPATKAN OBJEK JUZ (harus return non-null)
                                final juz.Juz detailJuz = allJuz.firstWhere(
                                  (j) => j.juz == juzNumber,
                                  orElse: () => allJuz.first,
                                );

                                // BANGUN LIST SURAH DALAM JUZ (sesuai logika tab Juz kamu)
                                final String nameStart = detailJuz.juzStartInfo!
                                    .split(" - ")
                                    .first;
                                final String nameEnd = detailJuz.juzEndInfo!
                                    .split(" - ")
                                    .first;

                                final List<Surah> rawAll = [];
                                final List<Surah> allSurahInJuz = [];

                                for (final s in controller.allSurah) {
                                  rawAll.add(s);
                                  if (s.name?.transliteration?.id == nameEnd)
                                    break;
                                }
                                for (final s in rawAll.reversed) {
                                  allSurahInJuz.add(s);
                                  if (s.name?.transliteration?.id == nameStart)
                                    break;
                                }
                                final List<Surah> surahListForJuz =
                                    allSurahInJuz.reversed.toList();
                                // MASUK KE DETAIL_JUZ — DetailJuzView kamu sudah auto-scroll dari "bookmark"
                                Get.toNamed(
                                  Routes.DETAIL_JUZ,
                                  arguments: {
                                    "juz": detailJuz,
                                    "surah": surahListForJuz,
                                    "bookmark":
                                        lastRead, // harus punya "index_ayat"
                                  },
                                );
                                break;
                              default:
                                // via "surah" (atau yang lain) → Detail Surah
                                Get.toNamed(
                                  Routes.DETAIL_SURAH,
                                  arguments: {
                                    "name": lastRead["surah"]
                                        .toString()
                                        .replaceAll("+", ""),
                                    "number": lastRead["number_surah"],
                                    "bookmark":
                                        lastRead, // kalau kamu juga auto-scroll di DetailSurah
                                  },
                                );
                            }
                          },
                          child: Container(
                            child: Stack(
                              children: [
                                Positioned(
                                  bottom: -30,
                                  right: 0,
                                  child: Opacity(
                                    opacity: 0.7,
                                    child: SizedBox(
                                      width: 160,
                                      height: 160,
                                      child: Image.asset(
                                        "assets/images/alquran.png",
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.menu_book_rounded,
                                            color: appWhite,
                                          ),
                                          SizedBox(width: 10),
                                          Text(
                                            "Terakhir dibaca",
                                            style: TextStyle(color: appWhite),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 30),
                                      Text(
                                        lastRead == null
                                            ? ""
                                            : "${lastRead['surah']}",
                                        style: TextStyle(
                                          color: appWhite,
                                          fontSize: 17,
                                        ),
                                      ),
                                      Text(
                                        lastRead == null
                                            ? "Belum ada data"
                                            : "Juz Ke-${lastRead['juz']} | Ayat Ke-${lastRead['ayat']}",
                                        style: TextStyle(color: appWhite),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              TabBar(
                tabs: [
                  Tab(
                    child: Text(
                      "Surah",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Tab(
                    child: Text(
                      "Juz",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Tab(
                    child: Text(
                      "Bookmark",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    //Detail surah
                    FutureBuilder<List<Surah>>(
                      future: controller.getAllSurah(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData) {
                          return Center(child: Text("Tidak ada data."));
                        }
                        return ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            Surah surah = snapshot.data![index];
                            return ListTile(
                              onTap: () {
                                Get.toNamed(
                                  Routes.DETAIL_SURAH,
                                  arguments: {
                                    "name": surah.name!.transliteration!.id,
                                    "number": surah.number!,
                                  },
                                );
                              },
                              leading: Obx(
                                () => Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage(
                                        controller.isDark.isTrue
                                            ? "assets/images/bintang_putih.png"
                                            : "assets/images/bintang.png",
                                      ),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "${surah.number}",
                                      style: TextStyle(),
                                    ),
                                  ),
                                ),
                              ),
                              title: Text(
                                surah.name?.transliteration?.id ??
                                    'Data tidak ditemukan.',
                                style: TextStyle(),
                              ),
                              subtitle: Text(
                                "${surah.numberOfVerses} Ayat | ${surah.revelation?.id ?? 'Data tidak ditemukan.'} ",
                                style: TextStyle(color: Colors.grey[500]),
                              ),
                              trailing: Text(
                                "${surah.name?.short ?? 'Data tidak ditemukan.'} ",
                                style: TextStyle(fontSize: 20),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    //Detail Juz
                    FutureBuilder<List<juz.Juz>>(
                      future: controller.getAllJuz(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData) {
                          return Center(child: Text("Tidak ada data."));
                        }
                        return ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            juz.Juz detailJuz = snapshot.data![index];
                            String nameStart = detailJuz.juzStartInfo!
                                .split(" - ")
                                .first;
                            String nameEnd = detailJuz.juzEndInfo!
                                .split(" - ")
                                .first;
                            List<Surah> rawAllSurahInJuz = [];
                            List<Surah> allSurahInJuz = [];
                            for (Surah item in controller.allSurah) {
                              rawAllSurahInJuz.add(item);
                              if (item.name!.transliteration!.id == nameEnd) {
                                break;
                              }
                            }
                            for (Surah item
                                in rawAllSurahInJuz.reversed.toList()) {
                              allSurahInJuz.add(item);
                              if (item.name!.transliteration!.id == nameStart) {
                                break;
                              }
                            }
                            return ListTile(
                              onTap: () {
                                Get.toNamed(
                                  Routes.DETAIL_JUZ,
                                  arguments: {
                                    "juz": detailJuz,
                                    "surah": allSurahInJuz.reversed.toList(),
                                  },
                                );
                              },
                              leading: Obx(
                                () => Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage(
                                        controller.isDark.isTrue
                                            ? "assets/images/bintang_putih.png"
                                            : "assets/images/bintang.png",
                                      ),
                                    ),
                                  ),
                                  child: Center(child: Text("${index + 1}")),
                                ),
                              ),
                              title: Text("Juz ${index + 1}"),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Mulai dari ${detailJuz.juzStartInfo}",
                                    style: TextStyle(color: Colors.grey[500]),
                                  ),
                                  Text(
                                    "Sampai ${detailJuz.juzEndInfo}",
                                    style: TextStyle(color: Colors.grey[500]),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                    //Bookmark
                    GetBuilder<HomeController>(
                      builder: (c) {
                        return FutureBuilder<List<Map<String, dynamic>>>(
                          future: c.getBookmark(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }
                            if (snapshot.data?.length == 0) {
                              return Center(
                                child: Text("Bookmark tidak tersedia"),
                              );
                            }
                            return ListView.builder(
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                Map<String, dynamic> data =
                                    snapshot.data![index];
                                return ListTile(
                                  onTap: () async {
                                    final via = (data['via'] ?? '')
                                        .toString()
                                        .toLowerCase();

                                    if (via == 'juz') {
                                      final int juzNumber =
                                          int.tryParse('${data["juz"]}') ?? -1;

                                      // Ambil semua Juz
                                      final List<juz.Juz> allJuz =
                                          await controller.getAllJuz();

                                      // Kalau kosong → fallback buka ke Detail Surah
                                      if (allJuz.isEmpty || juzNumber <= 0) {
                                        Get.toNamed(
                                          Routes.DETAIL_SURAH,
                                          arguments: {
                                            "name": data["surah"].toString(),
                                            "number": data["number_surah"],
                                            "bookmark": data,
                                          },
                                        );
                                        return;
                                      }

                                      // Wajib return Juz pada orElse (tidak boleh null)
                                      final juz.Juz detailJuz = allJuz
                                          .firstWhere(
                                            (j) => j.juz == juzNumber,
                                            orElse: () => allJuz.first,
                                          );

                                      // Bangun daftar Surah dalam Juz (sesuai logic tab Juz kamu)
                                      final String nameStart = detailJuz
                                          .juzStartInfo!
                                          .split(" - ")
                                          .first;
                                      final String nameEnd = detailJuz
                                          .juzEndInfo!
                                          .split(" - ")
                                          .first;

                                      final List<Surah> rawAll = [];
                                      final List<Surah> allSurahInJuz = [];
                                      for (final s in controller.allSurah) {
                                        rawAll.add(s);
                                        if (s.name?.transliteration?.id ==
                                            nameEnd)
                                          break;
                                      }
                                      for (final s in rawAll.reversed) {
                                        allSurahInJuz.add(s);
                                        if (s.name?.transliteration?.id ==
                                            nameStart)
                                          break;
                                      }
                                      final List<Surah> surahListForJuz =
                                          allSurahInJuz.reversed.toList();

                                      Get.toNamed(
                                        Routes.DETAIL_JUZ,
                                        arguments: {
                                          "juz": detailJuz,
                                          "surah": surahListForJuz,
                                          "bookmark":
                                              data, // penting: ada index_ayat
                                        },
                                      );
                                      return;
                                    }

                                    // Default (via Surah)
                                    Get.toNamed(
                                      Routes.DETAIL_SURAH,
                                      arguments: {
                                        "name": data["surah"].toString(),
                                        "number": data["number_surah"],
                                        "bookmark": data,
                                      },
                                    );
                                  },

                                  leading: Obx(
                                    () => Container(
                                      height: 50,
                                      width: 50,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: AssetImage(
                                            controller.isDark.isTrue
                                                ? "assets/images/bintang_putih.png"
                                                : "assets/images/bintang.png",
                                          ),
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "${index + 1}",
                                          style: TextStyle(),
                                        ),
                                      ),
                                    ),
                                  ),
                                  title: Text("${data['surah']}"),
                                  subtitle: Text(
                                    "Ayat ${data['ayat']} - via ${data['via']}",
                                  ),
                                  trailing: IconButton(
                                    onPressed: () {
                                      c.deleteBookmark(data['id']);
                                    },
                                    icon: Icon(Icons.delete_outline),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => controller.chageThemeMode(),
        child: Icon(Icons.color_lens_outlined),
      ),
    );
  }
}
