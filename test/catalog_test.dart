import 'package:flutter_test/flutter_test.dart';
import 'package:awrad/content/catalog.dart';

void main() {
  test('every entry has a unique id and a traceable source page', () {
    final ids = <String>{};
    final sources = awradSources.map((s) => s.id).toSet();
    for (final record in awradExamples) {
      expect(ids.add(record.id), isTrue, reason: 'Duplicated ID: ${record.id}');
      expect(sources.contains(record.sourceId), isTrue);
      expect(record.pdfPage, greaterThan(0));
      expect(record.text.trim(), isNotEmpty);
      expect(record.attribution.trim(), isNotEmpty);
      expect(record.review, isNot(ContentReview.approved));
    }
  });

  test('all examples are disclosed as scan-matched, not fully approved', () {
    expect(awradExamples, isNotEmpty);
    expect(awradExamples.every((e) => e.review == ContentReview.matchedToScan), isTrue);
    expect(awradExamples.every((e) => !e.approvedForPublication), isTrue);
  });

  test('Arabic search ignores diacritics and alif differences', () {
    expect(normalizeArabic('إِنَّ'), 'ان');
    expect(searchAwrad('ربنا'), isNotEmpty);
    expect(searchAwrad('الذي احيانا').length, 1);
    expect(searchAwrad('not-in-sources'), isEmpty);
  });

  test('source filter is strict', () {
    final records = searchAwrad('', sourceId: 'hisn-1427');
    expect(records, hasLength(1));
    expect(records.every((e) => e.sourceId == 'hisn-1427'), isTrue);
  });

  test('no unverified repetition counts', () {
    expect(awradExamples.every((e) => e.repetitionCount == null), isTrue);
  });
}
