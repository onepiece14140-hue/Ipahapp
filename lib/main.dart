import 'package:flutter/material.dart';

import 'happ_page.dart';
import 'license_page.dart';
import 'license_service.dart';
import 'loading_page.dart';
import 'netflix_web_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NetflixHappApp());
}

enum _AppStage { checkingLicense, license, loading, netflix, happ }

class NetflixHappApp extends StatelessWidget {
  const NetflixHappApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NetflixHapp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(backgroundColor: Colors.black),
      ),
      home: const _AppFlow(),
    );
  }
}

class _AppFlow extends StatefulWidget {
  const _AppFlow();

  @override
  State<_AppFlow> createState() => _AppFlowState();
}

class _AppFlowState extends State<_AppFlow> {
  final LicenseService _licenseService = LicenseService();
  _AppStage _stage = _AppStage.checkingLicense;
  String? _licenseMessage;
  bool _offlineSavedKey = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _checkSavedLicense();
  }

  Future<void> _checkSavedLicense() async {
    String? savedKey;
    try {
      savedKey = await _licenseService.readSavedKey();
      if (savedKey == null || savedKey.trim().isEmpty) {
        if (mounted) setState(() => _stage = _AppStage.license);
        return;
      }

      final result = await _licenseService.checkStatus(savedKey);
      if (!mounted) return;
      setState(() {
        _stage = result.isActive ? _AppStage.loading : _AppStage.license;
        _licenseMessage = result.isActive
            ? null
            : (result.message ?? 'คีย์ไม่สามารถใช้งานได้');
        _offlineSavedKey = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _stage = _AppStage.license;
        _offlineSavedKey = savedKey != null && savedKey.trim().isNotEmpty;
        _licenseMessage = _offlineSavedKey
            ? 'ตรวจสอบคีย์ที่บันทึกไว้ไม่ได้ กรุณาลองใหม่เมื่อต่ออินเทอร์เน็ต'
            : null;
      });
    }
  }

  Future<void> _activateLicense(String input) async {
    final key = input.trim();
    if (key.isEmpty) {
      setState(() {
        _licenseMessage = 'กรุณากรอกคีย์ก่อน';
        _offlineSavedKey = false;
      });
      return;
    }

    setState(() {
      _submitting = true;
      _licenseMessage = null;
      _offlineSavedKey = false;
    });

    try {
      final result = await _licenseService.activate(key);
      if (result.isActive) {
        await _licenseService.saveKey(key);
        if (mounted) setState(() => _stage = _AppStage.loading);
      } else if (mounted) {
        setState(() {
          _licenseMessage = result.message ?? 'คีย์ไม่สามารถใช้งานได้';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _licenseMessage = 'เชื่อมต่อเซิร์ฟเวอร์ไม่ได้ กรุณาลองใหม่อีกครั้ง';
        });
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _goTo(_AppStage stage) {
    if (mounted) setState(() => _stage = stage);
  }

  @override
  Widget build(BuildContext context) {
    return switch (_stage) {
      _AppStage.checkingLicense => const _CheckingLicensePage(),
      _AppStage.license => AppLicensePage(
          message: _licenseMessage,
          hasOfflineSavedKey: _offlineSavedKey,
          isSubmitting: _submitting,
          onSubmit: _activateLicense,
        ),
      _AppStage.loading => LoadingPage(
          onFinished: () => _goTo(_AppStage.netflix),
        ),
      _AppStage.netflix => NetflixWebPage(
          onOpenHapp: () => _goTo(_AppStage.happ),
        ),
      _AppStage.happ => HappPage(
          onBackToNetflix: () => _goTo(_AppStage.netflix),
        ),
    };
  }
}

class _CheckingLicensePage extends StatelessWidget {
  const _CheckingLicensePage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.red),
            SizedBox(height: 16),
            Text('กำลังตรวจสอบสิทธิ์การใช้งาน…'),
          ],
        ),
      ),
    );
  }
}
