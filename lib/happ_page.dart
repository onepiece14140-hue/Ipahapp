import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HappPage extends StatefulWidget {
  const HappPage({required this.onBackToNetflix, super.key});

  final VoidCallback onBackToNetflix;

  @override
  State<HappPage> createState() => _HappPageState();
}

class _HappPageState extends State<HappPage> {
  static final Uri _officialHapp = Uri.parse(
    'https://apps.apple.com/us/app/happ-proxy-utility/id6504287215',
  );
  bool _openingStore = false;

  Future<void> _openOfficialHapp() async {
    setState(() => _openingStore = true);
    try {
      final opened = await launchUrl(
        _officialHapp,
        mode: LaunchMode.externalApplication,
      );
      if (!opened && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('เปิด App Store ไม่สำเร็จ')),
        );
      }
    } finally {
      if (mounted) setState(() => _openingStore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HAPP'),
        leading: IconButton(
          onPressed: widget.onBackToNetflix,
          icon: const Icon(Icons.arrow_back),
          tooltip: 'กลับไป Netflix',
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.network_check, color: Colors.red, size: 54),
                const SizedBox(height: 18),
                Text(
                  'HAPP',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'IPA รุ่นแรกนี้ยังไม่ได้ฝัง HAPP/Xray tunnel จึงยังสร้างการเชื่อมต่อ VPN ของระบบไม่ได้',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 10),
                const Text(
                  'หากต้องการใช้ proxy จริง สามารถเปิดแอป Happ ทางการแยกต่างหากได้',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _openingStore ? null : _openOfficialHapp,
                    icon: _openingStore
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.open_in_new),
                    label: const Text('เปิด Happ ทางการใน App Store'),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: widget.onBackToNetflix,
                  child: const Text('กลับไป Netflix Thailand'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
