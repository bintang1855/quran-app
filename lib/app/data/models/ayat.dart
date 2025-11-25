import 'dart:convert';

Ayat ayatFromJson(String str) => Ayat.fromJson(json.decode(str));

String ayatToJson(Ayat data) => json.encode(data.toJson());

class Ayat {
  Number? number;
  Meta? meta;
  Text? text;
  Translation? translation;
  Audio? audio;
  Tafsir? tafsir;

  Ayat({
    this.number,
    this.meta,
    this.text,
    this.translation,
    this.audio,
    this.tafsir,
  });

  factory Ayat.fromJson(Map<String, dynamic>? json) => Ayat(
    number: Number.fromJson(json?["number"]),
    meta: Meta.fromJson(json?["meta"]),
    text: Text.fromJson(json?["text"]),
    translation: Translation.fromJson(json?["translation"]),
    audio: Audio.fromJson(json?["audio"]),
    tafsir: Tafsir.fromJson(json?["tafsir"]),
  );

  Map<String, dynamic> toJson() => {
    "number": number?.toJson(),
    "meta": meta?.toJson(),
    "text": text?.toJson(),
    "translation": translation?.toJson(),
    "audio": audio?.toJson(),
    "tafsir": tafsir?.toJson(),
  };
}

class Audio {
  String? primary;
  List<String>? secondary;

  Audio({this.primary, this.secondary});

  factory Audio.fromJson(Map<String, dynamic>? json) => Audio(
    primary: json?["primary"],
    secondary: json?["secondary"] == null
        ? null
        : List<String>.from(json!["secondary"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "primary": primary,
    "secondary": secondary == null
        ? null
        : List<dynamic>.from(secondary!.map((x) => x)),
  };
}

class Meta {
  int? juz;
  int? page;
  int? manzil;
  int? ruku;
  int? hizbQuarter;
  Sajda? sajda;

  Meta({
    this.juz,
    this.page,
    this.manzil,
    this.ruku,
    this.hizbQuarter,
    this.sajda,
  });

  factory Meta.fromJson(Map<String, dynamic>? json) => Meta(
    juz: json?["juz"],
    page: json?["page"],
    manzil: json?["manzil"],
    ruku: json?["ruku"],
    hizbQuarter: json?["hizbQuarter"],
    sajda: Sajda.fromJson(json?["sajda"]),
  );

  Map<String, dynamic> toJson() => {
    "juz": juz,
    "page": page,
    "manzil": manzil,
    "ruku": ruku,
    "hizbQuarter": hizbQuarter,
    "sajda": sajda?.toJson(),
  };
}

class Sajda {
  bool? recommended;
  bool? obligatory;

  Sajda({this.recommended, this.obligatory});

  factory Sajda.fromJson(Map<String, dynamic>? json) =>
      Sajda(recommended: json?["recommended"], obligatory: json?["obligatory"]);

  Map<String, dynamic> toJson() => {
    "recommended": recommended,
    "obligatory": obligatory,
  };
}

class Number {
  int? inQuran;
  int? inSurah;

  Number({this.inQuran, this.inSurah});

  factory Number.fromJson(Map<String, dynamic>? json) =>
      Number(inQuran: json?["inQuran"], inSurah: json?["inSurah"]);

  Map<String, dynamic> toJson() => {"inQuran": inQuran, "inSurah": inSurah};
}

class Tafsir {
  Id? id;

  Tafsir({this.id});

  factory Tafsir.fromJson(Map<String, dynamic>? json) =>
      Tafsir(id: Id.fromJson(json?["id"]));

  Map<String, dynamic> toJson() => {"id": id?.toJson()};
}

class Id {
  String? short;
  String? long;

  Id({this.short, this.long});

  factory Id.fromJson(Map<String, dynamic>? json) =>
      Id(short: json?["short"], long: json?["long"]);

  Map<String, dynamic> toJson() => {"short": short, "long": long};
}

class Text {
  String? arab;
  Transliteration? transliteration;

  Text({this.arab, this.transliteration});

  factory Text.fromJson(Map<String, dynamic>? json) => Text(
    arab: json?["arab"],
    transliteration: Transliteration.fromJson(json?["transliteration"]),
  );

  Map<String, dynamic> toJson() => {
    "arab": arab,
    "transliteration": transliteration?.toJson(),
  };
}

class Transliteration {
  String? en;

  Transliteration({this.en});

  factory Transliteration.fromJson(Map<String, dynamic>? json) =>
      Transliteration(en: json?["en"]);

  Map<String, dynamic> toJson() => {"en": en};
}

class Translation {
  String? en;
  String? id;

  Translation({this.en, this.id});

  factory Translation.fromJson(Map<String, dynamic>? json) =>
      Translation(en: json?["en"], id: json?["id"]);

  Map<String, dynamic> toJson() => {"en": en, "id": id};
}
