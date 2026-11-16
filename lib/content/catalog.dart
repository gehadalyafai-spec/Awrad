/// عيّنة من نصوص جرت مقابلتها بصرياً على الملفات المرفقة.
/// ليست قاعدة الكتابين الكاملة، ولا تعتبر مراجعة شرعية نهائية.
enum ContentReview { draft, matchedToScan, approved }

class AwradSource {
  final String id;
  final String title;
  final String subtitle;
  final String note;

  const AwradSource({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.note,
  });
}

class DhikrRecord {
  final String id;
  final String title;
  final String text;
  final String category;
  final String sourceId;
  final int pdfPage;
  final int? printedPage;
  final int? itemNumber;
  final String attribution;
  final ContentReview review;
  final int? repetitionCount;

  const DhikrRecord({
    required this.id,
    required this.title,
    required this.text,
    required this.category,
    required this.sourceId,
    required this.pdfPage,
    this.printedPage,
    this.itemNumber,
    required this.attribution,
    this.review = ContentReview.draft,
    this.repetitionCount,
  });
  bool get approvedForPublication => review == ContentReview.approved;
}

const awradSources = <AwradSource>[
  AwradSource(
    id: 'hisn-1427',
    title: 'حصن المسلم',
    subtitle: 'من أذكار الكتاب والسنة',
    note: 'طبعة رجب 1427هـ، ملف مصور من 160 صفحة',
  ),
  AwradSource(
    id: 'dua-leaflet',
    title: 'الدعاء من الكتاب والسنة',
    subtitle: 'المطوية المختصرة',
    note: 'هذه مطوية مختصرة من الكتاب الأصلي وليست نسخته الكاملة',
  ),
];

/// النصوص القرآنية أصلها من القرآن الكريم. هذه عينة لا تمثل اكتمال المصدرين.
/// نص الاستيقاظ قوبل على صفحة PDF 12 من حصن المسلم؛ رقم الذكر 1.
/// الأدعية القرآنية قوبلت على صفحة PDF 3 من المطوية؛ أرقامها 2 و7 و8.
const awradExamples = <DhikrRecord>[
  DhikrRecord(
    id: 'hisn-1427-001',
    title: 'عند الاستيقاظ من النوم',
    text: 'الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا، وَإِلَيْهِ النُّشُورُ',
    category: 'أذكار الاستيقاظ',
    sourceId: 'hisn-1427',
    pdfPage: 12,
    printedPage: 12,
    itemNumber: 1,
    attribution: 'البخاري مع الفتح 11/113، ومسلم 4/2083؛ وفق حاشية النسخة',
    review: ContentReview.matchedToScan,
  ),
  DhikrRecord(
    id: 'dua-leaflet-002',
    title: 'دعاء قبول العمل',
    text: 'رَبَّنَا تَقَبَّلْ مِنَّا إِنَّكَ أَنْتَ السَّمِيعُ الْعَلِيمُ',
    category: 'أدعية قرآنية',
    sourceId: 'dua-leaflet',
    pdfPage: 3,
    itemNumber: 2,
    attribution: 'سورة البقرة، الآية 127',
    review: ContentReview.matchedToScan,
  ),
  DhikrRecord(
    id: 'dua-leaflet-007',
    title: 'دعاء الثبات على الهدى',
    text: 'رَبَّنَا لَا تُزِغْ قُلُوبَنَا بَعْدَ إِذْ هَدَيْتَنَا وَهَبْ لَنَا مِنْ لَدُنْكَ رَحْمَةً إِنَّكَ أَنْتَ الْوَهَّابُ',
    category: 'أدعية قرآنية',
    sourceId: 'dua-leaflet',
    pdfPage: 3,
    itemNumber: 7,
    attribution: 'سورة آل عمران، الآية 8',
    review: ContentReview.matchedToScan,
  ),
  DhikrRecord(
    id: 'dua-leaflet-008',
    title: 'طلب المغفرة',
    text: 'رَبَّنَا إِنَّنَا آمَنَّا فَاغْفِرْ لَنَا ذُنُوبَنَا وَقِنَا عَذَابَ النَّارِ',
    category: 'أدعية قرآنية',
    sourceId: 'dua-leaflet',
    pdfPage: 3,
    itemNumber: 8,
    attribution: 'سورة آل عمران، الآية 16',
    review: ContentReview.matchedToScan,
  ),
];

AwradSource? sourceFor(String id) {
  for (final source in awradSources) {
    if (source.id == id) return source;
  }
  return null;
}

String normalizeArabic(String value) => value
    .toLowerCase()
    .replaceAll(RegExp(r'[\u064B-\u065F\u0670\u0640]'), '')
    .replaceAll(RegExp(r'[إأآٱ]'), 'ا')
    .replaceAll('ى', 'ي')
    .replaceAll('ة', 'ه')
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();

List<DhikrRecord> searchAwrad(String search, {String? sourceId}) {
  final query = normalizeArabic(search);
  return awradExamples.where((record) {
    if (sourceId != null && record.sourceId != sourceId) return false;
    if (query.isEmpty) return true;
    final text = normalizeArabic(
      '${record.title} ${record.text} ${record.category} ${record.attribution}',
    );
    return text.contains(query);
  }).toList(growable: false);
}
