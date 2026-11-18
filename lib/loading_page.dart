import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({required this.onFinished, super.key});

  final VoidCallback onFinished;

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  late final VideoPlayerController _controller;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/LoadingVideo.mp4');
    _startVideo();
  }

  Future<void> _startVideo() async {
    try {
      await _controller.initialize();
      if (!mounted) return;
      _controller.addListener(_watchPlayback);
      await _controller.setLooping(false);
      await _controller.play();
      setState(() {});
    } catch (_) {
      _finish();
    }
  }

  void _watchPlayback() {
    final value = _controller.value;
    if (value.hasError ||
        (value.isInitialized &&
            value.duration > Duration.zero &&
            value.position >= value.duration)) {
      _finish();
    }
  }

  void _finish() {
    if (_finished) return;
    _finished = true;
    if (mounted) widget.onFinished();
  }

  @override
  void dispose() {
    _controller.removeListener(_watchPlayback);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const Scaffold(backgroundColor: Colors.black);
    }
    final videoSize = _controller.value.size;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: videoSize.width,
            height: videoSize.height,
            child: VideoPlayer(_controller),
          ),
        ),
      ),
    );
  }
}
