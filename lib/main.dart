import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'content/catalog.dart';

const _evergreen = Color(0xFF154C40);
const _gold = Color(0xFFD7B36D);
const _ivory = Color(0xFFF7F6F0);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  runApp(AwradApp(preferences: preferences));
}

class AwradApp extends StatefulWidget {
  final SharedPreferences preferences;
  const AwradApp({required this.preferences, super.key});

  @override
  State<AwradApp> createState() => _AwradAppState();
}

class _AwradAppState extends State<AwradApp> {
  bool dark = false;
  final Set<String> favorites = {};

  @override
  void initState() {
    super.initState();
    dark = widget.preferences.getBool('darkMode') ?? false;
    favorites.addAll(widget.preferences.getStringList('favoriteIds') ?? []);
  }

  void toggleDark() {
    setState(() => dark = !dark);
    widget.preferences.setBool('darkMode', dark);
  }

  void toggleFavorite(String id) {
    setState(() {
      if (!favorites.add(id)) favorites.remove(id);
    });
    widget.preferences.setStringList('favoriteIds', favorites.toList());
  }

  ThemeData theme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: _evergreen,
      brightness: brightness,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: isDark ? const Color(0xFF111E1B) : _ivory,
      cardColor: isDark ? const Color(0xFF1A302A) : Colors.white,
      appBarTheme: const AppBarTheme(centerTitle: false),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(fontWeight: FontWeight.w800, height: 1.3),
        titleLarge: TextStyle(fontWeight: FontWeight.w800, height: 1.4),
        bodyLarge: TextStyle(height: 1.8),
        bodyMedium: TextStyle(height: 1.65),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'أوراد | Awrad',
        debugShowCheckedModeBanner: false,
        locale: const Locale('ar'),
        theme: theme(Brightness.light),
        darkTheme: theme(Brightness.dark),
        themeMode: dark ? ThemeMode.dark : ThemeMode.light,
        builder: (context, child) => Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        ),
        home: AwradHome(
          isDark: dark,
          onToggleDark: toggleDark,
          favorites: favorites,
          onToggleFavorite: toggleFavorite,
        ),
      );
}

class AwradHome extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggleDark;
  final Set<String> favorites;
  final ValueChanged<String> onToggleFavorite;

  const AwradHome({
    required this.isDark,
    required this.onToggleDark,
    required this.favorites,
    required this.onToggleFavorite,
    super.key,
  });

  @override
  State<AwradHome> createState() => _AwradHomeState();
}

class _AwradHomeState extends State<AwradHome> {
  int tab = 0;
  String sourceId = 'all';
  String search = '';
  final searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void browse([String id = 'all']) {
    setState(() {
      tab = 1;
      sourceId = id;
    });
  }

  void openDhikr(DhikrRecord record) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => DhikrReader(
          record: record,
          favorites: widget.favorites,
          onToggleFavorite: widget.onToggleFavorite,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final texts = [
      _dashboard(),
      _library(),
      _favorites(),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('أوراد', style: TextStyle(fontWeight: FontWeight.w900)),
        actions: [
          IconButton(
            tooltip: widget.isDark ? 'الوضع الفاتح' : 'الوضع الليلي',
            onPressed: widget.onToggleDark,
            icon: Icon(widget.isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: texts[tab],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (value) => setState(() => tab = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'الرئيسية'),
          NavigationDestination(icon: Icon(Icons.auto_stories_outlined), selectedIcon: Icon(Icons.auto_stories), label: 'المكتبة'),
          NavigationDestination(icon: Icon(Icons.bookmark_outline), selectedIcon: Icon(Icons.bookmark), label: 'المحفوظات'),
        ],
      ),
    );
  }

  Widget _dashboard() => ListView(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(26),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_evergreen, Color(0xFF276E5B)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(27),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.auto_awesome, color: _gold, size: 28),
                SizedBox(height: 20),
                Text('أوراد', style: TextStyle(color: Colors.white, fontSize: 43, fontWeight: FontWeight.w900)),
                SizedBox(height: 4),
                Text('الأذكار والأدعية من الكتاب والسنة',
                    style: TextStyle(color: Color(0xFFF1EEDB), fontSize: 17)),
                SizedBox(height: 23),
                Text('اقرأ بخشوع، وتعرّف على مصدر كل ذكر.',
                    style: TextStyle(color: Color(0xFFE1EEDD), fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const _ReviewNotice(),
          const SizedBox(height: 24),
          const Text('المصادر', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          ...awradSources.map((source) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Card(
                  elevation: 0,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    leading: const Icon(Icons.menu_book_outlined, color: _evergreen, size: 32),
                    title: Text(source.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${source.subtitle}\n${source.note}'),
                    isThreeLine: true,
                    trailing: const Icon(Icons.chevron_left),
                    onTap: () => browse(source.id),
                  ),
                ),
              )),
          const SizedBox(height: 10),
          FilledButton.tonalIcon(
            onPressed: () => browse(),
            icon: const Icon(Icons.search),
            label: const Text('تصفح العينة مع مراجعها'),
          ),
        ],
      );

  Widget _library() {
    final found = searchAwrad(search, sourceId: sourceId == 'all' ? null : sourceId);
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 25),
      children: [
        const Text('مكتبة الأذكار', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 24)),
        const SizedBox(height: 4),
        Text('العينة الأولية: ${awradExamples.length} أدعية وأذكار',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        const SizedBox(height: 14),
        TextField(
          controller: searchController,
          onChanged: (value) => setState(() => search = value),
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: 'ابحث بكلمة من الذكر أو الدعاء',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            filled: true,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(label: const Text('الكل'), selected: sourceId == 'all', onSelected: (_) => setState(() => sourceId = 'all')),
            ...awradSources.map((source) => ChoiceChip(
              label: Text(source.title),
              selected: sourceId == source.id,
              onSelected: (_) => setState(() => sourceId = source.id),
            )),
          ],
        ),
        const SizedBox(height: 10),
        if (found.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 60),
            child: Center(child: Text('لا توجد نتيجة في العينة الحالية')),
          ),
        ...found.map((entry) => _dhikrTile(entry)),
      ],
    );
  }

  Widget _favorites() {
    final saved = awradExamples.where((entry) => widget.favorites.contains(entry.id)).toList();
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text('المحفوظات', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        if (saved.isEmpty)
          Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                children: [
                  const Icon(Icons.bookmark_border, size: 45, color: _evergreen),
                  const SizedBox(height: 12),
                  const Text('لم تحفظ أي ذكر بعد'),
                  const SizedBox(height: 10),
                  OutlinedButton(onPressed: () => browse(), child: const Text('استعرض الأذكار')),
                ],
              ),
            ),
          ),
        ...saved.map(_dhikrTile),
      ],
    );
  }

  Widget _dhikrTile(DhikrRecord record) => Card(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 10),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => openDhikr(record),
          child: Padding(
            padding: const EdgeInsets.all(19),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(record.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(record.text, maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 19, height: 1.85)),
                const SizedBox(height: 11),
                Text('${sourceFor(record.sourceId)?.title ?? ''} · صفحة PDF ${record.pdfPage}',
                    style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
        ),
      );
}

class _ReviewNotice extends StatelessWidget {
  const _ReviewNotice();

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(17),
        ),
        child: const Padding(
          padding: EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(Icons.fact_check_outlined, size: 24),
              SizedBox(width: 12),
              Expanded(child: Text(
                'إصدار تجريبي: النصوص المعروضة قوبلت على الملفات المصورة، وتنتظر المراجعة العلمية النهائية.',
                style: TextStyle(fontSize: 12, height: 1.6),
              )),
            ],
          ),
        ),
      );
}

class DhikrReader extends StatefulWidget {
  final DhikrRecord record;
  final Set<String> favorites;
  final ValueChanged<String> onToggleFavorite;

  const DhikrReader({
    required this.record,
    required this.favorites,
    required this.onToggleFavorite,
    super.key,
  });

  @override
  State<DhikrReader> createState() => _DhikrReaderState();
}

class _DhikrReaderState extends State<DhikrReader> {
  double textSize = 25;

  @override
  Widget build(BuildContext context) {
    final record = widget.record;
    final saved = widget.favorites.contains(record.id);
    final source = sourceFor(record.sourceId);
    return Scaffold(
      appBar: AppBar(
        title: const Text('قراءة الذكر'),
        actions: [
          IconButton(
            tooltip: saved ? 'إزالة من المحفوظات' : 'حفظ الذكر',
            onPressed: () {
              widget.onToggleFavorite(record.id);
              setState(() {});
            },
            icon: Icon(saved ? Icons.bookmark : Icons.bookmark_outline),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(record.title, textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w800)),
              const SizedBox(height: 14),
              Card(
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 34, horizontal: 23),
                  child: SelectableText(
                    record.text,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: textSize, height: 2.1),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.format_size_outlined),
                  Expanded(
                    child: Slider(
                      min: 21,
                      max: 37,
                      divisions: 8,
                      value: textSize,
                      label: '${textSize.round()}',
                      onChanged: (value) => setState(() => textSize = value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('توثيق المصدر', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
                      const SizedBox(height: 8),
                      Text(source?.title ?? record.sourceId),
                      Text('رقم الصفحة في PDF: ${record.pdfPage}'),
                      if (record.printedPage != null) Text('الصفحة المطبوعة: ${record.printedPage}'),
                      if (record.itemNumber != null) Text('رقم الذكر في المصدر: ${record.itemNumber}'),
                      const SizedBox(height: 8),
                      Text(record.attribution),
                      const Divider(height: 28),
                      const Text(
                        'حالة المراجعة: مقابل على صورة المصدر، غير معتمد للنشر النهائي بعد.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
