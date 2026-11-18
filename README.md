# NetflixHapp (Flutter)

แอป Flutter รุ่นแรกที่ยึด flow จาก `NetflixHappIOS_Source.zip` และใช้ Android archive ที่ให้มาเป็นข้อมูลอ้างอิงแบบ static หน้าเว็บหลักเปิด `https://www.netflix.com/th/` ใน WebView

## Flow ของแอป

1. ตรวจสถานะ License กับ API ที่กำหนดไว้ใน source (`/status`) หากไม่มีคีย์จะเปิดหน้าใส่ License
2. เมื่อ License active จะเล่น `assets/LoadingVideo.mp4`
3. จากนั้นเปิด Netflix Thailand ใน WebView
4. WebView ตรวจ trigger `เปิดhapp` และข้อความ `Happy` ในช่องอีเมลตอน submit เพื่อเปิดหน้า HAPP
5. หน้า HAPP ใน IPA รุ่นแรกมีลิงก์ไปยังแอป Happ ทางการบน App Store

License key และ installation ID เก็บด้วย secure storage ของระบบ (Keychain บน iOS/Keystore บน Android) เมื่อเปิดแอปหรือกดตรวจคีย์ แอปจะส่ง `key`, `installationId` และ `appVersion` ไปยัง `https://keyadmin-4byc6bqo.manus.space/api/license/` ตาม logic ใน source ที่ส่งมา

## ข้อจำกัดของรุ่นแรก

IPA นี้ **ยังไม่มี HAPP/Xray engine หรือ iOS Network Extension จึงยังสร้าง system-wide VPN/proxy tunnel และยังไม่เทียบเท่าฟังก์ชัน HAPP บน Android** หน้า HAPP จะพาไปใช้แอป Happ ทางการแยกต่างหากเท่านั้น การเพิ่ม tunnel ในแอปนี้ต้องพัฒนา iOS Packet Tunnel/Network Extension และใช้ entitlement กับ provisioning ที่รองรับ

ไฟล์ `Netflix_source.zip` เป็น APK ที่ถอดโครงสร้างด้วย Apktool ไม่ใช่ Android Gradle source project และ source iOS ที่ให้มามี `HAPPView` เป็น placeholder จึงไม่ได้คัดลอก binary/native engine จาก APK มาใช้ใน iOS

การเล่นวิดีโอ Netflix ใน WebView อาจถูกจำกัดโดย Netflix หรือความสามารถของ WKWebView บนอุปกรณ์

## Third-party packages

- [`webview_flutter` ^4.14.1](https://pub.dev/packages/webview_flutter) — BSD-3-Clause
- [`video_player` ^2.14.1](https://pub.dev/packages/video_player) — BSD-3-Clause
- [`flutter_secure_storage` ^11.2.0](https://pub.dev/packages/flutter_secure_storage) — BSD-3-Clause
- [`url_launcher` ^6.3.3](https://pub.dev/packages/url_launcher) — BSD-3-Clause

## Build unsigned IPA บน GitHub

เปิด **Actions → Build unsigned iOS IPA → Run workflow**. Workflow ใช้ GitHub-hosted macOS runner สร้าง iOS runner, resolve dependencies, build แบบ `--no-codesign`, แพ็ก `Payload/Runner.app` เป็น `NetflixHapp-unsigned.ipa` และเก็บ artifact 14 วัน

IPA นี้ยังไม่เซ็น ต้องนำไปเซ็นด้วยวิธีที่รองรับก่อนติดตั้งบน iPhone ได้ การเซ็นอย่างเดียวไม่ได้เพิ่มความสามารถ Network Extension ให้แอป

## Build ในเครื่อง

```bash
flutter create --platforms=ios,android --org com.example --project-name netflixhapp .
flutter pub get
flutter build ios --release --no-codesign
flutter build apk --release
```
