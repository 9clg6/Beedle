import 'dart:io';

import 'package:beedle/domain/entities/screenshot.entity.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

/// Viewer full-screen avec swipe horizontal entre captures + pinch-to-zoom.
class ScreenshotFullScreenViewer extends StatefulWidget {
  const ScreenshotFullScreenViewer({
    required this.screenshots,
    required this.initialIndex,
    required this.workerBaseUrl,
    required this.userId,
    super.key,
  });

  final List<ScreenshotEntity> screenshots;
  final int initialIndex;
  final String workerBaseUrl;
  final String? userId;

  @override
  State<ScreenshotFullScreenViewer> createState() =>
      _ScreenshotFullScreenViewerState();
}

class _ScreenshotFullScreenViewerState
    extends State<ScreenshotFullScreenViewer> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  ImageProvider? _providerFor(ScreenshotEntity s) {
    if (s.remoteUrl != null && widget.userId != null) {
      return CachedNetworkImageProvider(
        '${widget.workerBaseUrl}${s.remoteUrl}',
        headers: <String, String>{'X-User-Id': widget.userId!},
      );
    }
    final File f = File(s.filePath);
    if (f.existsSync()) return FileImage(f);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: <Widget>[
          PhotoViewGallery.builder(
            scrollPhysics: const BouncingScrollPhysics(),
            pageController: _pageController,
            itemCount: widget.screenshots.length,
            onPageChanged: (int i) => setState(() => _currentIndex = i),
            backgroundDecoration: const BoxDecoration(color: Colors.black),
            builder: (BuildContext _, int index) {
              final ScreenshotEntity s = widget.screenshots[index];
              final ImageProvider? provider = _providerFor(s);
              if (provider == null) {
                return PhotoViewGalleryPageOptions.customChild(
                  child: const Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: Colors.white54,
                      size: 64,
                    ),
                  ),
                );
              }
              return PhotoViewGalleryPageOptions(
                imageProvider: provider,
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 4,
                heroAttributes: PhotoViewHeroAttributes(tag: s.uuid),
              );
            },
            loadingBuilder: (_, __) => const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          if (widget.screenshots.length > 1)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 16,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  '${_currentIndex + 1} / ${widget.screenshots.length}',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
