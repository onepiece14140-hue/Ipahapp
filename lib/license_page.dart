import 'package:flutter/material.dart';

class AppLicensePage extends StatefulWidget {
  const AppLicensePage({
    required this.onSubmit,
    required this.isSubmitting,
    required this.hasOfflineSavedKey,
    this.message,
    super.key,
  });

  final Future<void> Function(String key) onSubmit;
  final bool isSubmitting;
  final bool hasOfflineSavedKey;
  final String? message;

  @override
  State<AppLicensePage> createState() => _AppLicensePageState();
}

class _AppLicensePageState extends State<AppLicensePage> {
  final TextEditingController _keyController = TextEditingController();

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.key, color: Colors.red, size: 48),
                  const SizedBox(height: 20),
                  Text(
                    'ยืนยันสิทธิ์การใช้งาน',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'คีย์จะผูกกับการติดตั้งนี้หนึ่งชุด และตรวจวันหมดอายุกับเซิร์ฟเวอร์',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _keyController,
                    enabled: !widget.isSubmitting,
                    textCapitalization: TextCapitalization.characters,
                    autocorrect: false,
                    textInputAction: TextInputAction.done,
                    onSubmitted: widget.isSubmitting
                        ? null
                        : (_) => widget.onSubmit(_keyController.text),
                    decoration: InputDecoration(
                      labelText: 'License key',
                      hintText: 'เช่น KICK-XXXXXX-XXXXXX',
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: widget.isSubmitting
                          ? null
                          : () => widget.onSubmit(_keyController.text),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: widget.isSubmitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('ตรวจสอบคีย์'),
                    ),
                  ),
                  if (widget.hasOfflineSavedKey) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'ไม่สามารถตรวจสอบคีย์ที่บันทึกไว้ได้ในขณะนี้',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.orangeAccent),
                    ),
                  ],
                  if (widget.message != null) ...[
                    const SizedBox(height: 14),
                    Text(
                      widget.message!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
