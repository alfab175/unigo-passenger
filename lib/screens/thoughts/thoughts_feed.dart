import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/thought.dart';
import '../../services/thought_service.dart';
import '../../utils/format.dart';

/// "Düşünceler" tab: public feed. Sharing APPENDS to the feed (everyone's
/// thoughts stay visible) and each user can like a thought only once
/// (tapping again un-likes).
class ThoughtsFeed extends StatefulWidget {
  const ThoughtsFeed({super.key, this.service});
  final ThoughtService? service;

  @override
  State<ThoughtsFeed> createState() => _ThoughtsFeedState();
}

class _ThoughtsFeedState extends State<ThoughtsFeed> {
  late final ThoughtService _thoughts = widget.service ?? ThoughtService();
  final _controller = TextEditingController();
  bool _sending = false;
  final _likingInFlight = <String>{};

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _share() async {
    if (_sending) return;
    setState(() => _sending = true);
    try {
      await _thoughts.share(_controller.text);
      _controller.clear();
    } catch (e) {
      if (mounted) _showError(e);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _toggleLike(Thought t) async {
    // Guard against rapid double-taps; the service transaction is the real
    // guarantee that one user can only ever add a single like.
    if (!_likingInFlight.add(t.id)) return;
    try {
      await _thoughts.toggleLike(t);
    } catch (e) {
      if (mounted) _showError(e);
    } finally {
      _likingInFlight.remove(t.id);
    }
  }

  void _confirmDelete(Thought t) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: const Icon(Icons.delete_outline_rounded, color: Colors.red),
            title: const Text('Düşünceyi sil', style: TextStyle(color: Colors.red)),
            onTap: () async {
              Navigator.pop(sheet);
              try {
                await _thoughts.delete(t);
              } catch (e) {
                if (mounted) _showError(e);
              }
            },
          ),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  void _report(Thought t) {
    const reasons = ['Spam', 'Hakaret veya taciz', 'Tartışma / kavga', 'Uygunsuz içerik'];
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
                await _thoughts.report(t, r);
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Şikayetin alındı, incelenecek.')));
              } catch (e) {
                if (mounted) _showError(e);
              }
            }),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  void _showError(Object e) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))));

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // Compose box.
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.12)),
        ),
        child: Row(children: [
          Expanded(child: TextField(
            controller: _controller,
            maxLength: 500,
            maxLines: 1,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => _share(),
            decoration: const InputDecoration(hintText: 'Düşünceni paylaş...', border: InputBorder.none, isDense: true, counterText: ''),
          )),
          _sending
              ? const Padding(padding: EdgeInsets.all(8), child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)))
              : IconButton(visualDensity: VisualDensity.compact, icon: Icon(Icons.arrow_upward_rounded, color: UnigoTheme.purple), onPressed: _share),
        ]),
      ),
      const SizedBox(height: 10),
      // Feed.
      Expanded(child: StreamBuilder<List<Thought>>(
        stream: _thoughts.watchThoughts(),
        builder: (_, snap) {
          final thoughts = snap.data ?? const <Thought>[];
          if (snap.connectionState == ConnectionState.waiting && thoughts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (thoughts.isEmpty) {
            return Center(child: Text('Henüz düşünce yok.\nİlk düşünceyi sen paylaş!', textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).hintColor, height: 1.5)));
          }
          return ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: thoughts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _ThoughtCard(
              thought: thoughts[i],
              isOwn: thoughts[i].userId == _uid,
              onLike: () => _toggleLike(thoughts[i]),
              onDelete: () => _confirmDelete(thoughts[i]),
              onReport: () => _report(thoughts[i]),
            ),
          );
        },
      )),
    ]);
  }
}

class _ThoughtCard extends StatelessWidget {
  const _ThoughtCard({required this.thought, required this.isOwn, required this.onLike, required this.onDelete, required this.onReport});
  final Thought thought;
  final bool isOwn;
  final VoidCallback onLike;
  final VoidCallback onDelete;
  final VoidCallback onReport;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final liked = thought.likedByUser(FirebaseAuth.instance.currentUser?.uid);
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 8),
      decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(
            radius: 15,
            backgroundColor: UnigoTheme.purple.withValues(alpha: 0.12),
            backgroundImage: thought.authorPhotoUrl != null ? NetworkImage(thought.authorPhotoUrl!) : null,
            child: thought.authorPhotoUrl == null ? Text(thought.authorName.isEmpty ? '?' : thought.authorName[0].toUpperCase(), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: UnigoTheme.purple)) : null,
          ),
          const SizedBox(width: 8),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(thought.authorName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
            Text('${formatTimeAgo(thought.createdAt)}${thought.edited ? ' • düzenlendi' : ''}', style: TextStyle(fontSize: 11, color: theme.hintColor)),
          ])),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: Icon(isOwn ? Icons.delete_outline_rounded : Icons.flag_outlined, size: 19, color: theme.hintColor),
            onPressed: isOwn ? onDelete : onReport,
          ),
        ]),
        const SizedBox(height: 8),
        Padding(padding: const EdgeInsets.only(right: 8), child: Text(thought.text, style: const TextStyle(fontSize: 14, height: 1.4))),
        Row(children: [
          TextButton.icon(
            style: TextButton.styleFrom(visualDensity: VisualDensity.compact, foregroundColor: liked ? Colors.red : theme.hintColor),
            onPressed: onLike,
            icon: Icon(liked ? Icons.favorite_rounded : Icons.favorite_border_rounded, size: 18),
            label: Text('${thought.likeCount}', style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
        ]),
      ]),
    );
  }
}
