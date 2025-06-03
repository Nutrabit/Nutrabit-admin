import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutrabit_admin/presentation/providers/interest_item_provider.dart';
import 'package:nutrabit_admin/presentation/screens/interest_list/interest_item_dialogs.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class InterestList extends ConsumerStatefulWidget {
  const InterestList({super.key});

  @override
  ConsumerState<InterestList> createState() => _InterestListState();
}

class _InterestListState extends ConsumerState<InterestList> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      final notifier = ref.read(interestItemsProvider.notifier);

      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          notifier.hasMore &&
          !notifier.isFetching) {
        notifier.fetchMoreItems();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(interestItemsProvider);
    final notifier = ref.watch(interestItemsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Recomendaciones'), centerTitle: true),
      body: itemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('No hay ítems aún.'));
          }

          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: items.length + 1,
            itemBuilder: (context, index) {
              if (index == items.length) {
                return notifier.hasMore
                    ? const Center(child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: CircularProgressIndicator(),
                      ))
                    : const SizedBox.shrink();
              }

              final item = items[index];
              final url = item.url.toLowerCase();

              if (url.contains('youtube')) {
                return YoutubeListItem(
                  itemId: item.id,
                  itemTitle: item.title,
                  youtubeUrl: item.url,
                  onDelete: () => showDeleteItemDialog(context, ref, item.id),
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddInterestDialog(context, ref),
        backgroundColor: const Color(0xFFD7F9DE),
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: const Icon(Icons.add),
      ),
    );
  }
}


// Youtube
class YoutubeListItem extends StatefulWidget {
  final String itemId;
  final String itemTitle;
  final String youtubeUrl;
  final VoidCallback onDelete;

  const YoutubeListItem({
    super.key,
    required this.itemId,
    required this.itemTitle,
    required this.youtubeUrl,
    required this.onDelete,
  });

  @override
  State<YoutubeListItem> createState() => _InterestListItemState();
}

class _InterestListItemState extends State<YoutubeListItem> {
  YoutubePlayerController? _controller;
  bool _isPlaying = false;

  String? extractYoutubeVideoId(String url) {
    final regExp = RegExp(r'(?:v=|\/)([0-9A-Za-z_-]{11})');
    final match = regExp.firstMatch(url);
    return match?.group(1);
  }

  @override
  void dispose() {
    _controller?.close();
    super.dispose();
  }

  void _startPlaying() {
    final videoId = extractYoutubeVideoId(widget.youtubeUrl);
    if (videoId == null) return;

    _controller = YoutubePlayerController(
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
      ),
    );

    _controller!.loadVideoById(videoId: videoId);
    setState(() => _isPlaying = true);
  }

  @override
  Widget build(BuildContext context) {
    final videoId = extractYoutubeVideoId(widget.youtubeUrl);
    final thumbnailUrl = videoId != null
        ? 'https://img.youtube.com/vi/$videoId/hqdefault.jpg'
        : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.itemTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: widget.onDelete,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_isPlaying && _controller != null)
              YoutubePlayer(controller: _controller!, aspectRatio: 16 / 9)
            else if (thumbnailUrl != null)
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(thumbnailUrl, fit: BoxFit.cover),
                  ),
                  Positioned.fill(
                    child: Material(
                      color: Colors.black38,
                      child: InkWell(
                        onTap: _startPlaying,
                        child: const Center(
                          child: Icon(
                            Icons.play_circle_fill,
                            color: Colors.white,
                            size: 64,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            else
              const SizedBox(
                height: 200,
                child: Center(child: Text('Video no válido')),
              ),
          ],
        ),
      ),
    );
  }
}

// Spotify
