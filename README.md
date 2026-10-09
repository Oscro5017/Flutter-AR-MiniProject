# 🛋️ AR Furniture - Mobile AR & E-Commerce Application

**AR Furniture** คือแอปพลิเคชันเลือกซื้อและจำลองวางเฟอร์นิเจอร์ 3D ในห้องจริงผ่านเทคโนโลยี **Augmented Reality (AR)** บนสมาร์ทโฟน พัฒนาด้วย **Flutter** และ **Jetpack/Android Native Tools** ครอบคลุมลูปการทำงานตั้งแต่นำเสนอสินค้า หมุนชมโมเดล 3D แบบ 360 องศา ลองวางในกล้อง AR ด้วยสเกล 1:1 สมจริง คำนวณงบประมาณ สั่งซื้อสินค้า ออกใบเสร็จรับเงินจำลอง ไปจนถึงระบบหลังบ้านสำหรับ **Admin** ในการจัดการและเพิ่มโมเดล 3D เข้าสู่ระบบ

---

## 🌟 ฟีเจอร์หลักของแอปพลิเคชัน (Key Features)

### 1. 🪑 3D & Augmented Reality (AR) Placement
- **3D Interactive Model Viewer:** หมุน ซูม และพิจารณาพื้นผิว/มุมมองของเฟอร์นิเจอร์แบบ 360 องศา
- **Real-World AR Placement:** ใช้กล้องตรวจจับพื้นผิวห้องเพื่อจำลองการวางเฟอร์นิเจอร์ ด้วยสเกลขนาดสัดส่วน 1:1 สมจริง
- **Capture & Share:** ถ่ายภาพมุมห้องที่มีโมเดล AR วางอยู่ และส่งแชร์ไปยังแอปพลิเคชันอื่นได้ทันที

### 2. 🏠 E-Commerce & Catalog Experience
- **Catalog & Multi-Category Filter:** ค้นหาและกรองสินค้าตามหมวดหมู่ (เช่น Living Room, Bedroom, Kitchen, Bathroom, Lighting, Decoration)
- **Multi-Category Tagging:** สินค้า 1 ชิ้น สามารถระบุได้หลายหมวดหมู่พร้อมกัน
- **Product Comparison:** เปรียบเทียบสเปก ราคา ขนาด และวัสดุของเฟอร์นิเจอร์เคียงข้างกัน
- **Favorites System:** บันทึกรายการสินค้าโปรดไว้ดูย้อนหลัง

### 3. 🛒 Smart Cart, Budget Tracker & Mock Checkout
- **Selective Item Cart:** ติ๊กเลือกเฉพาะรายการสินค้าที่ต้องการสั่งซื้อในรอบนั้นๆ พร้อมปุ่ม "เลือกทั้งหมด (Select All)"
- **Dynamic Budget Tracker:** ตั้งงบประมาณการตกแต่งบ้าน พร้อมระบบแจ้งเตือนอัตโนมัติเมื่อราคาสินค้าเกินงบ
- **Mock Checkout & PromptPay QR Code:** ฟอร์มที่อยู่จัดส่ง (พร้อมปุ่มกรอกตัวอย่าง) และสร้าง **PromptPay Vector QR Code** ระบุยอดชำระจริง
- **Order Receipt Summary:** ออกใบเสร็จรับเงินจำลองระบุ Order ID, วันเวลา, รายการสินค้า, และยอดชำระสุทธิ พร้อมตัดสต็อกสินค้าในตะกร้าอัตโนมัติ

### 4. 🛡️ User & Admin Role System
- **Role Switch at Login:** สลับโหมดการใช้งานระหว่าง **General User** และ **System Admin** ได้จากหน้าล็อกอิน
- **Admin Dashboard (`/admin`):** ค้นหารายการสินค้าในระบบ, ลบสินค้า, และจัดการเพิ่ม/แก้ไข/ลบหมวดหมู่สินค้าแบบเรียลไทม์
- **Add/Edit Product Form (`/admin/add-edit`):** เพิ่มสินค้าใหม่โดยสามารถกดเลือกไฟล์โมเดล 3D (`.glb`) และไฟล์รูปภาพพรีวิว (`.png`) จากหน่วยความจำเครื่องมือถือได้โดยตรงผ่าน **File Picker**

### 5. 🌓 Theme & UI/UX Design
- **Soft Light / Dark Mode:** รองรับการสลับธีมสว่างและธีมมืด พร้อมบันทึกสถานะการตั้งค่าถาวรด้วย `SharedPreferences`
- **Responsive Layout:** รองรับการแสดงผลทั้งแนวตั้ง (Portrait) และแนวนอน (Landscape)

---

## 🛠️ เทคโนโลยีและไลบรารีที่ใช้ (Tech Stack)

- **Framework:** Flutter SDK 3.47+ / Dart 3.12+
- **Architecture & State Management:** Provider (`provider: ^6.1.5`)
- **Navigation & Routing:** GoRouter (`go_router: ^16.0.0`)
- **3D & AR Engine:** ModelViewer Plus (`model_viewer_plus: ^1.7.0`) / Google `<model-viewer>`
- **File & Device Picker:** FilePicker (`file_picker: ^8.1.7`)
- **Screenshot & Media:** Screenshot (`screenshot: ^3.0.0`), Share Plus (`share_plus: ^10.0.0`), Path Provider (`path_provider: ^2.1.0`)
- **Storage & Identity:** SharedPreferences (`shared_preferences: ^2.2.0`), UUID (`uuid: ^4.5.1`)
- **Android Environment:** AGP 8.11.1, Kotlin 2.2.20, Gradle 8.14.0, JDK 21

---

## 📂 โครงสร้างโฟลเดอร์โปรเจกต์ (Project Structure)

```text
ar_furniture/
├── android/                   # ไฟล์ตั้งค่าสำหรับระบบปฏิบัติการ Android
├── assets/
│   ├── furniture_models/      # คลังไฟล์โมเดล 3D (.glb) ทั้งหมด 120+ ชิ้น
│   └── images/
│       └── furniture/         # คลังไฟล์รูปภาพพรีวิวสินค้า (.png / .webp)
├── lib/
│   ├── core/
│   │   ├── constants/         # ค่าสี และธีมระบบ (AppColors)
│   │   └── providers/         # State Management Providers (Cart, User, Furniture, Budget, ฯลฯ)
│   ├── data/
│   │   └── dummy_furniture.dart # คลังข้อมูลสินค้าคัดสรร 50 ชิ้นพร้อมสเปกจริง
│   ├── models/                # Data Models (Furniture, UserRole, ฯลฯ)
│   ├── routes/
│   │   └── app_router.dart    # เส้นทางการนำทางในแอป (GoRouter)
│   ├── screens/               # หน้าจอการทำงานหลักของแอป
│   │   ├── admin/             # Admin Dashboard & Add/Edit Form
│   │   ├── ar/                # AR Placement Screen
│   │   ├── cart/              # Cart & Budget Tracker
│   │   ├── catalog/           # Catalog & Filter
│   │   ├── checkout/          # Checkout Form & PromptPay QR
│   │   ├── detail/            # 3D Furniture Detail View
│   │   ├── home/              # Home Screen
│   │   ├── login/             # Login & Role Switcher
│   │   ├── profile/           # User Profile & Role Badge
│   │   ├── receipt/           # Order Receipt Screen
│   │   └── scan/              # AR Scan Room Carousel
│   ├── widgets/               # Reusable UI Components (FurnitureCard, SoftButton, ฯลฯ)
│   └── main.dart              # จุดเริ่มต้นการทำงานของแอป
├── MODEL_INVENTORY.md         # ตารางอ้างอิงรายชื่อสินค้า โมเดล 3D และภาพพรีวิว
├── pubspec.yaml               # ไฟล์การตั้งค่า Dependencies & Assets
└── README.md                  # เอกสารอธิบายโปรเจกต์
```

---

## 🚀 วิธีการติดตั้งและตั้งค่าโปรเจกต์ (Setup Instructions)

### 1. ความต้องการของระบบ (Prerequisites)
- [Flutter SDK](https://docs.flutter.dev/get-started/install) เวอร์ชั่น 3.22.0 ขึ้นไป
- [Android Studio](https://developer.android.com/studio) หรือ VS Code
- [JDK 17 หรือ JDK 21](https://www.oracle.com/java/technologies/downloads/)
- อุปกรณ์ Android จริง (แนะนำสำหรับการทดสอบ AR ผ่านกล้อง) หรือ Android Emulator

### ไฟล์โมเดลและรูปภาพจาก Google Drive

เพื่อให้ repository บน GitHub มีขนาดเหมาะสม ไฟล์โมเดล `.glb` และรูปภาพสินค้าใน `assets/furniture_models/` และ `assets/images/furniture/` จะไม่ถูกเก็บใน GitHub

ดาวน์โหลด assets ได้ที่ [Google Drive](https://drive.google.com/file/d/1iYVf4g0utEQWfR9GPdB-db0NneXSyMI1/view?usp=sharing)

ก่อนรันแอป ให้ดาวน์โหลดไฟล์จาก Google Drive แล้ววางไฟล์ทั้งหมดในโฟลเดอร์เดิม โดยคงชื่อไฟล์และโครงสร้างโฟลเดอร์ไว้:
- โมเดล `.glb` ใน `assets/furniture_models/`
- รูปภาพสินค้า `.png` ใน `assets/images/furniture/`

หากไม่มีไฟล์เหล่านี้ แอปอาจ build ได้ แต่หน้าสินค้าและตัวแสดงโมเดล 3D จะไม่มีสื่อประกอบ

### 2. ขั้นตอนการ Clone และ Run โปรเจกต์

```bash
# 1. Clone โปรเจกต์มาจาก GitHub
git clone https://github.com/your-username/ar_furniture.git

# 2. เข้าสู่โฟลเดอร์โปรเจกต์
cd ar_furniture

# 3. ดาวน์โหลด Packages & Dependencies
flutter pub get

# 4. ตรวจสอบความพร้อมของระบบ
flutter analyze

# 5. สั่งรันแอปพลิเคชันลงบนอุปกรณ์ทดสอบ
flutter run
```

### 3. วิธีการ Build APK สำหรับ Android

```bash
# บิวด์ไฟล์ APK ในโหมด Debug
flutter build apk --debug

# หรือบิวด์ไฟล์ APK ในโหมด Release
flutter build apk --release
```
*ไฟล์ APK จะถูกสร้างไว้ที่ตำแหน่ง:* `build/app/outputs/flutter-apk/app-release.apk`

---

## 📱 คู่มือการทดสอบฟีเจอร์สำหรับการนำเสนอ (Presentation Walkthrough)

1. **เข้าสู่ระบบ & เลือกสิทธิ์ (Login Screen):**
   * เลือกแท็บ **General User** หรือ **System Admin** เพื่อเข้าสู่แอปพลิเคชัน
2. **เลือกชมสินค้า & หมุนโมเดล 3D (Home & Detail Screen):**
   * เลือกดูสินค้าในหน้า Home/Catalog ใช้ชิปกรองหมวดหมู่หลายหมวดหมู่
   * แตะเข้าหน้ารายละเอียดเพื่อหมุนดูโมเดล 3D แบบ 360 องศา
3. **ทดสอบโหมด AR (AR Placement):**
   * แตะปุ่ม **"AR Mode"** เพื่อเปิดกล้อง สแกนพื้นผิว และวางเฟอร์นิเจอร์ในสเกล 1:1 จริง
   * กดถ่ายรูปหน้าจอ (Capture) หรือกดแชร์รูปภาพ
4. **ทดสอบตะกร้าสินค้า & การสั่งซื้อ (Cart & Checkout):**
   * ติ๊กเลือกสินค้าเฉพาะชิ้นที่ต้องการในตะกร้า สังเกตราคารวมและแถบ Budget Tracker
   * กด **Checkout** กรอกที่อยู่จัดส่ง (หรือกดปุ่ม *"⚡ กรอกตัวอย่าง"*)
   * เลือกชำระเงินด้วย **PromptPay QR Code** ➔ กดสั่งซื้อเพื่อรับใบเสร็จรับเงินจำลอง
5. **ทดสอบระบบหลังบ้าน Admin (Admin Dashboard):**
   * สลับสิทธิ์เป็น Admin ➔ เข้าสู่ **Admin Dashboard**
   * ทดสอบ **จัดการหมวดหมู่สินค้า** (เพิ่ม/แก้ไข/ลบหมวดหมู่)
   * กด **"+ เพิ่มสินค้าใหม่"** ➔ ทดสอบเลือกไฟล์ `.glb` หรือภาพถ่ายจากเครื่องเพื่อเพิ่มสินค้าใหม่แบบเรียลไทม์

---

## 📄 License & Credits
- **Developer:** AR Furniture Project Team
- **3D Asset Models:** Optimized Low-Poly GLB Asset Collections (CC0 / Open Source)
- **Framework:** Developed with [Flutter Framework](https://flutter.dev)
