import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/news_article.dart';
import '../../services/news_service.dart';
import '../../utils/format.dart';
import '../../widgets/ad_card.dart';
import 'news_detail_screen.dart';

/// "Haberler" tab: article list with an inline ad every 3 items, an
/// occasional interstitial ad while browsing, and a ⋮ menu per article
/// (Kaydet / Şikayet et).
class NewsFeed extends StatefulWidget {
  const NewsFeed({super.key, this.service});
  final NewsService? service;

  @override
  State<NewsFeed> createState() => _NewsFeedState();
}

class _NewsFeedState extends State<NewsFeed> {
  late final NewsService _news = widget.service ?? NewsService();
  Set<String> _saved = {};
  int _opens = 0;

  @override
  void initState() {
    super.initState();
    _news.loadSavedIds().then((s) => mounted ? setState(() => _saved = s) : null);
  }

  Future<void> _openArticle(NewsArticle a) async {
    _opens++;
    // Every 3rd article open: a quick, dismissible interstitial ad.
    if (_opens % 3 == 0 && mounted) await _showInterstitial();
    if (!mounted) return;
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => NewsDetailScreen(article: a)));
  }

  Future<void> _showInterstitial() {
    final creative = defaultAdCreatives[_opens ~/ 3 % defaultAdCreatives.length];
    return showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            AdCard(creative: creative),
            const SizedBox(height: 12),
            SizedBox(width: double.infinity, child: FilledButton.tonal(onPressed: () => Navigator.pop(sheet), child: const Text('Habere devam et'))),
          ]),
        ),
      ),
    );
  }

  void _showActions(NewsArticle a) {
    final isSaved = _saved.contains(a.id);
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: Icon(isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded),
            title: Text(isSaved ? 'Kaydedildi' : 'Kaydet'),
            onTap: () async {
              Navigator.pop(sheet);
              final ids = await _news.toggleSaved(a.id);
              if (mounted) setState(() => _saved = ids);
            },
          ),
          ListTile(
            leading: const Icon(Icons.flag_outlined, color: Colors.red),
            title: const Text('Şikayet et', style: TextStyle(color: Colors.red)),
            onTap: () { Navigator.pop(sheet); _showReportReasons(a); },
          ),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  void _showReportReasons(NewsArticle a) {
    const reasons = ['Uygunsuz içerik', 'Yanıltıcı bilgi', 'Spam veya reklam'];
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Padding(padding: EdgeInsets.all(12), child: Text('Şikayet nedeni', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16))),
          for (final r in reasons)
            ListTile(title: Text(r), onTap: () async {
              Navigator.pop(sheet);
              try {
                await _news.report(a, r);
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Şikayetin alındı, incelenecek.')));
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))));
              }
            }),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<NewsArticle>>(
      stream: _news.watchNews(),
      builder: (_, snap) {
        final remote = snap.data ?? const <NewsArticle>[];
        final articles = remote.isEmpty ? NewsService.fallback() : remote;
        // Inline ad card after every 3rd article.
        final itemCount = articles.length + articles.length ~/ 3;
        return ListView.separated(
          padding: EdgeInsets.zero,
          itemCount: itemCount,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) {
            if ((i + 1) % 4 == 0) {
              return AdCard(creative: defaultAdCreatives[(i ~/ 4) % defaultAdCreatives.length]);
            }
            final a = articles[i - i ~/ 4];
            final isSaved = _saved.contains(a.id);
            return Material(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _openArticle(a),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(a.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, height: 1.3), maxLines: 2, overflow: TextOverflow.ellipsis),
                      if (a.summary.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(a.summary, style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor, height: 1.35), maxLines: 2, overflow: TextOverflow.ellipsis),
                      ],
                      const SizedBox(height: 6),
                      Row(children: [
                        Text('${a.source} • ${formatTimeAgo(a.publishedAt)}', style: TextStyle(fontSize: 11, color: Theme.of(context).hintColor)),
                        if (isSaved) ...[const SizedBox(width: 6), Icon(Icons.bookmark_rounded, size: 13, color: UnigoTheme.purple)],
                      ]),
                    ])),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.more_horiz_rounded),
                      onPressed: () => _showActions(a),
                    ),
                  ]),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
