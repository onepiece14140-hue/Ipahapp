import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class NetflixWebPage extends StatefulWidget {
  const NetflixWebPage({required this.onOpenHapp, super.key});

  final VoidCallback onOpenHapp;

  @override
  State<NetflixWebPage> createState() => _NetflixWebPageState();
}

class _NetflixWebPageState extends State<NetflixWebPage> {
  static final Uri _homeUri = Uri.parse('https://www.netflix.com/th/');
  late final WebViewController _controller;
  int _progress = 0;
  bool _loadError = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController();
    _configureWebView();
  }

  Future<void> _configureWebView() async {
    await _controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    await _controller.setBackgroundColor(Colors.black);
    await _controller.addJavaScriptChannel(
      'happBridge',
      onMessageReceived: (message) {
        if (message.message == 'openHAPP' && mounted) {
          widget.onOpenHapp();
        }
      },
    );
    await _controller.setNavigationDelegate(
      NavigationDelegate(
        onProgress: (progress) {
          if (mounted) setState(() => _progress = progress);
        },
        onPageStarted: (_) {
          if (mounted) {
            setState(() {
              _progress = 0;
              _loadError = false;
            });
          }
        },
        onPageFinished: (_) async {
          if (mounted) setState(() => _progress = 100);
          try {
            await _controller.runJavaScript(_happTriggerScript);
          } catch (_) {
            // The page can navigate while the bridge script is being injected.
          }
        },
        onWebResourceError: (error) {
          if (error.isForMainFrame == true && mounted) {
            setState(() => _loadError = true);
          }
        },
      ),
    );
    await _controller.loadRequest(_homeUri);
  }

  Future<void> _reload() async {
    setState(() {
      _loadError = false;
      _progress = 0;
    });
    await _controller.loadRequest(_homeUri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(child: WebViewWidget(controller: _controller)),
            if (_progress < 100)
              Align(
                alignment: Alignment.topCenter,
                child: LinearProgressIndicator(
                  value: _progress == 0 ? null : _progress / 100,
                  color: Colors.red,
                  backgroundColor: Colors.white12,
                  minHeight: 2,
                ),
              ),
            if (_loadError)
              Align(
                alignment: Alignment.bottomCenter,
                child: SafeArea(
                  minimum: const EdgeInsets.all(16),
                  child: Material(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text('โหลด Netflix ไม่สำเร็จ ตรวจสอบอินเทอร์เน็ต'),
                          ),
                          TextButton.icon(
                            onPressed: _reload,
                            icon: const Icon(Icons.refresh),
                            label: const Text('ลองใหม่'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

const String _happTriggerScript = r'''(function(){
  if (window.__happBridgeInstalled) return;
  window.__happBridgeInstalled = true;
  function sendHapp(){
    try { happBridge.postMessage('openHAPP'); } catch(e) {}
  }
  function inspect(value){
    if (String(value || '').toLowerCase().indexOf('เปิดhapp') !== -1) sendHapp();
  }
  document.addEventListener('input', function(event){
    var target = event.target;
    inspect(target && (target.value || target.innerText || target.textContent));
  }, true);
  document.addEventListener('click', function(event){
    var target = event.target;
    inspect(target && (target.innerText || target.textContent));
  }, true);
  document.addEventListener('submit', function(event){
    var form = event.target;
    inspect(form && (form.innerText || form.textContent));
    try {
      var email = form && form.querySelector('input[type="email"]');
      if (email && String(email.value || '').toLowerCase().indexOf('happy') !== -1) sendHapp();
    } catch(e) {}
  }, true);
})();''';
