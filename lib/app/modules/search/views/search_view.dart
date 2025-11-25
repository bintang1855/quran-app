import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quranapp/app/contants/colors.dart';
import 'package:quranapp/app/data/models/surah.dart';
import 'package:quranapp/app/data/models/juz.dart' as juz;
import 'package:quranapp/app/routes/app_pages.dart';
import '../controllers/search_controller.dart';

class SearchView extends GetView<SearchControllerApp> {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cari Surah & Juz'), centerTitle: true),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                onChanged: (value) {
                  // Panggil fungsi search sesuai tab yang aktif
                  if (controller.currentTab.value == 0) {
                    controller.searchSurah(value);
                  } else {
                    controller.searchJuz(value);
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Cari surah atau juz...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  filled: true,
                  fillColor: Get.isDarkMode
                      ? Colors.grey[800]
                      : Colors.grey[200],
                ),
              ),
            ),
            // Tab Bar
            Obx(
              () => TabBar(
                onTap: (index) {
                  controller.changeTab(index);
                },
                tabs: [
                  Tab(
                    child: Text(
                      'Surah (${controller.searchSurahResults.length})',
                    ),
                  ),
                  Tab(
                    child: Text('Juz (${controller.searchJuzResults.length})'),
                  ),
                ],
              ),
            ),
            // Tab Bar View
            Expanded(
              child: Obx(() {
                // Tampilkan loading jika sedang load data
                if (controller.isLoading.value) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Memuat data...'),
                      ],
                    ),
                  );
                }

                return TabBarView(
                  children: [
                    // Tab Surah
                    _buildSurahList(),
                    // Tab Juz
                    _buildJuzList(),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk menampilkan list surah
  Widget _buildSurahList() {
    return Obx(() {
      if (controller.searchSurahResults.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 80, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Surah tidak ditemukan',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        itemCount: controller.searchSurahResults.length,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemBuilder: (context, index) {
          Surah surah = controller.searchSurahResults[index];
          return Card(
            elevation: 2,
            margin: EdgeInsets.only(bottom: 12),
            color: Get.isDarkMode
                ? appPurpleLight2.withValues(alpha: 0.2)
                : appPurpleLight1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: InkWell(
              onTap: () {
                Get.toNamed(
                  Routes.DETAIL_SURAH,
                  arguments: {
                    "name": surah.name?.transliteration?.id ?? "",
                    "number": surah.number,
                  },
                );
              },
              borderRadius: BorderRadius.circular(15),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Nomor Surah dalam lingkaran
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/images/bintang_putih.png"),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          "${surah.number}",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    // Informasi Surah
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${surah.name?.transliteration?.id}",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "${surah.name?.translation?.id}",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "${surah.numberOfVerses} Ayat • ${surah.revelation?.id}",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white60,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Nama Arab
                    Text(
                      "${surah.name?.short}",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
  }

  // Widget untuk menampilkan list juz
  Widget _buildJuzList() {
    return Obx(() {
      if (controller.searchJuzResults.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 80, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Juz tidak ditemukan',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        itemCount: controller.searchJuzResults.length,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemBuilder: (context, index) {
          juz.Juz juzItem = controller.searchJuzResults[index];

          // Parse info start dan end untuk mendapatkan nama surah
          String startSurah = juzItem.juzStartInfo?.split(" - ").first ?? "";
          String endSurah = juzItem.juzEndInfo?.split(" - ").first ?? "";

          return Card(
            elevation: 2,
            margin: EdgeInsets.only(bottom: 12),
            color: Get.isDarkMode
                ? appPurpleLight2.withValues(alpha: 0.2)
                : appPurpleLight1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: InkWell(
              onTap: () {
                // Bangun list surah dalam juz ini
                List<Surah> surahListForJuz = [];
                List<Surah> rawAll = [];

                for (var s in controller.allSurahList) {
                  rawAll.add(s);
                  if (s.name?.transliteration?.id == endSurah) break;
                }

                for (var s in rawAll.reversed) {
                  surahListForJuz.add(s);
                  if (s.name?.transliteration?.id == startSurah) break;
                }

                List<Surah> finalList = surahListForJuz.reversed.toList();

                Get.toNamed(
                  Routes.DETAIL_JUZ,
                  arguments: {"juz": juzItem, "surah": finalList},
                );
              },
              borderRadius: BorderRadius.circular(15),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Nomor Juz
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/images/bintang_putih.png"),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          "${juzItem.juz}",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    // Informasi Juz
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Juz ${juzItem.juz}",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Mulai: $startSurah",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "Akhir: $endSurah",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "${juzItem.totalVerses} Ayat",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white60,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Icon
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
  }
}
