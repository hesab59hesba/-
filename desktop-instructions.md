
# دليل تحويل مشاريع الويب إلى Flutter Desktop  
## (منهجية الوكيل الذكي لتحويل React / Next.js إلى تطبيق ديسكتوب)

هذا الدليل مخصص لمساعدة وكلاء الذكاء الاصطناعي (AI Agents) في تحويل مشاريع الويب
(مثل React / Next.js) إلى تطبيقات **Flutter Desktop**
مع الحفاظ على نفس الشكل، الوظائف، ومنطق العمل، ولكن بتجربة استخدام مناسبة لتطبيقات سطح المكتب.

---

## 1. مرحلة التحليل والاستكشاف (Analysis Phase)
يجب على الوكيل فهم بنية مشروع الويب بالكامل قبل البدء في كتابة أي كود Flutter Desktop:

### تحليل الهيكل العام
- **تحليل المسارات (Routing):**
  - فحص `App.tsx`, `routes.ts`, أو مجلد `pages/`
  - تحديد الصفحات الأساسية والنوافذ المنطقية (Dashboards, Forms, Tables)
- **تحليل المكونات (Components):**
  - تحديد المكونات المتكررة (Sidebar, Navbar, Tables, Modals)
- **تحليل البيانات (Data Models):**
  - البحث عن `types` و `interfaces`
  - تحديد العلاقات بين الكيانات (One-to-Many, Lists, Status enums)

### تحليل المنطق
- **إدارة الحالة (State Management):**
  - Redux, Zustand, Context API, Hooks
  - تحديد مكان منطق الأعمال (Business Logic)
- **التعامل مع API:**
  - REST / GraphQL
  - Authorization / Tokens / Headers

### تحليل تجربة المستخدم (UX)
- تصميم يعتمد على:
  - شاشة عريضة (Wide layout)
  - Sidebars ثابتة
  - جداول بيانات (Tables)
  - نوافذ منبثقة (Dialogs / Modals)

---

## 2. إعداد بيئة Flutter Desktop (Setup Phase)

### إنشاء المشروع
```bash
flutter create my_desktop_app
cd my_desktop_app
flutter config --enable-windows-desktop
flutter config --enable-macos-desktop
flutter config --enable-linux-desktop
هيكل المجلدات داخل lib/
نسخ التعليمات البرمجية
Text
lib/
├── core/
│   ├── theme/
│   ├── constants/
│   ├── utils/
├── models/
├── providers/   (or controllers/)
├── services/    (API, storage)
├── layout/
│   ├── desktop_shell.dart
│   ├── sidebar.dart
│   ├── topbar.dart
├── screens/
├── widgets/
└── main.dart
التبعيات الأساسية (pubspec.yaml)
إدارة الحالة:
provider أو riverpod
HTTP:
dio أو http
Icons:
lucide_icons
font_awesome_flutter
Localization:
intl
Desktop utilities:
window_manager
bitsdojo_window
Routing:
go_router (مفضل لتطبيقات الديسكتوب)
3. بناء منطق التطبيق (Core Logic)
تحويل النماذج (Models)
تحويل TypeScript Interfaces إلى Dart Classes
دعم:
fromJson
toJson
copyWith
إدارة الحالة
كل Feature لها Provider / Controller مستقل
يحتوي على:
State (Lists, Selected Item, Loading)
CRUD Operations
Business Rules (filters, totals, permissions)
فصل المنطق
UI ≠ Logic
المنطق في:
providers/
services/
4. تنفيذ واجهة Flutter Desktop (UI Implementation)
Layout خاص بالديسكتوب
استخدام:
Row + Expanded
NavigationRail أو Sidebar مخصص
منع الاعتماد على Widgets مخصصة للموبايل فقط
Shell عام للتطبيق
DesktopShell يحتوي:
Sidebar ثابتة
Content Area ديناميكية
TopBar (Actions, User Menu)
الجداول والبيانات
استخدام:
DataTable أو Custom Table Widgets
دعم:
Sorting
Pagination
Row selection
النوافذ والحوارات
استبدال Modals في الويب بـ:
Dialog
AlertDialog
Forms تظهر كنوافذ وليس شاشات كاملة
5. دعم اللغة العربية (RTL & Localization)
تفعيل:
نسخ التعليمات البرمجية
Dart
localizationsDelegates
supportedLocales
locale: Locale('ar')
دعم RTL تلقائي
التأكد من:
محاذاة النصوص
اتجاه الأيقونات
الجداول تدعم RTL
6. الفروقات الجوهرية بين Web و Desktop
الإدخال
دعم:
Mouse hover
Keyboard shortcuts
Focus management
الأداء
تجنب:
SingleChildScrollView غير الضروري
استخدام:
Lazy loading
Efficient rebuilds
التخزين
استخدام:
shared_preferences
أو hive للبيانات المحلية
7. الربط والتحقق (Integration & Verification)
التأكد أن:
كل شاشة ويب لها Screen أو Dialog في Flutter
كل Action في الويب له Callback مكافئ
اختبار:
CRUD
Navigation
State sync
إضافة:
Loading indicators
Error dialogs
Confirmation dialogs
إرشادات مهمة للوكيل الذكي (AI Agent Guidelines)
لا تُحوّل تصميم الموبايل إلى ديسكتوب بشكل أعمى
فكّر كـ Desktop App:
مساحة
إنتاجية
سرعة وصول
حافظ على:
نفس أسماء المتغيرات
نفس منطق الأعمال
أي شيء كان Sidebar في الويب → Sidebar في Flutter Desktop
أي Modal في الويب → Dialog في Flutter
الهدف النهائي
إنتاج تطبيق Flutter Desktop:
مستقر
واضح
قابل للتوسع
مطابق لمنطق مشروع الويب الأصلي
بتجربة استخدام احترافية لتطبيقات سطح المكتب