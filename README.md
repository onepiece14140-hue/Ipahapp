# Proxy Utility Starter (Flutter)

โปรเจกต์ Flutter เริ่มต้นสำหรับต่อยอดแอปข้ามแพลตฟอร์ม Android/iOS โดยออกแบบหน้าจอใหม่จากการตรวจโครงสร้าง Android แบบ static ใน `Netflix_source.zip` เท่านั้น **ไม่ได้แปลงหรือคัดลอก Smali, binary, รูป/วิดีโอ, credentials หรือโค้ด proprietary**

## มีอะไรใน starter

- Dashboard พร้อมปุ่ม Connect/Disconnect ที่เป็นเพียง demo state
- รายการโปรไฟล์จำลอง และฟอร์มเพิ่มโปรไฟล์ในหน่วยความจำ
- หน้า Statistics ที่แสดง placeholder ไม่ได้อ่านปริมาณ traffic จริง
- Settings พร้อมสวิตช์ตัวอย่างและทางลัดไปหน้าสถิติ/ข้อความ log ตัวอย่าง
- โครงสร้างเป็น Flutter/Dart ใช้ Material 3 และไม่มี plugin ภายนอก

## ยังไม่ได้ทำ

ไม่มี VPN tunnel, XRay/proxy engine, routing, subscription fetch/update, QR/deep link import, real ping, network statistics, background services, Firebase, Android Quick Settings tile หรือ iOS Network Extension ระบบปุ่มเชื่อมต่อเป็น UI จำลองเท่านั้น ข้อมูล endpoint ที่เพิ่มจะไม่ถูกส่งไปที่ใดและหายเมื่อปิดแอป

ฟีเจอร์เครือข่ายจริงต้องออกแบบและพัฒนาใหม่โดยใช้ library/API ที่ได้รับอนุญาต พร้อมตรวจใบอนุญาต, ความปลอดภัยของ config/credentials และข้อกำหนดของแต่ละแพลตฟอร์ม สำหรับ VPN บน iOS ต้องมี Network Extension entitlement และการตั้งค่า/การลงนามที่เหมาะสม ส่วน Android ต้องใช้ Android VpnService และ permission flow ที่ถูกต้อง

## โครงสร้าง

```text
lib/main.dart       แอปตัวอย่างและหน้าจอทั้งหมด
pubspec.yaml        Flutter package configuration
```

## สร้าง unsigned IPA บน GitHub

เปิด **Actions → Build unsigned iOS IPA → Run workflow**. Workflow ใช้ macOS GitHub-hosted runner สร้าง iOS Runner project, compile ด้วย `flutter build ios --release --no-codesign`, แพ็กเป็น `ProxyUtilityStarter-unsigned.ipa` และอัปโหลด artifact ชื่อ `ProxyUtilityStarter-unsigned-ipa` ไว้ 14 วัน. ขั้น compile จะตรวจความถูกต้องของ Dart/iOS build โดยตรง.

ไฟล์ IPA นี้ยังไม่เซ็น จึงติดตั้งบน iPhone โดยตรงไม่ได้ ต้องนำไปเซ็นด้วย certificate/profile ที่ถูกต้องหรือวิธีที่ GBox และ iOS เวอร์ชันของอุปกรณ์รองรับก่อน GBox ช่วยเซ็น/ติดตั้ง IPA ที่มีอยู่ ไม่ได้ build Flutter project จาก source. การมีหรือใช้ certificate ขึ้นกับผู้ให้บริการ signing และข้อกำหนดของ Apple.

## วิธีรัน/build ในเครื่อง

ติดตั้ง Flutter SDK; สำหรับ iOS ต้องใช้ macOS และ Xcode. จาก root ของ repository:

```bash
flutter create --platforms=ios --org com.example --project-name proxyutility .
flutter pub get
flutter build ios --release --no-codesign
```

สร้าง Android APK ได้ด้วย `flutter build apk --release`. IPA ที่เซ็นเพื่อแจกจ่ายต้องตั้งค่า Apple code-signing และ provisioning; workflow นี้ไม่ขอหรือเก็บ signing credentials.
