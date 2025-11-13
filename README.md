# Taskly-Assignment-Reminder-App
แอปพลิเคชันเตือนงานสำหรับนักเรียน–นักศึกษา ที่ออกแบบมาเพื่อช่วยจัดการงานบ้าน กิจกรรม และกำหนดส่งต่าง ๆ ได้อย่างเป็นระบบ พร้อมระบบแจ้งเตือนล่วงหน้า เพื่อไม่ให้พลาดงานสำคัญอีกต่อไป
📌 ฟีเจอร์หลัก (Main Features)

🏠 Home Page
แสดงรายการงานทั้งหมด
แสดงสถานะงาน เช่น ใกล้กำหนด วันนี้ หรือเลยกำหนด
โหลดข้อมูลแบบเรียลไทม์จาก Firebase

➕ Add / Edit Assignment
เพิ่ม แก้ไข และลบงาน
ใส่รายละเอียด เช่น วิชา หัวข้อ รายละเอียด วันกำหนดส่ง
บันทึกข้อมูลลง Firebase Firestore

🔔 Notification System
แจ้งเตือนล่วงหน้าตามเวลาที่ผู้ใช้เลือก
ทำงานแบบ background notification
เตือนก่อนกำหนดส่งเพื่อไม่ให้พลาดงานสำคัญ

📅 Calendar View
ดูงานทั้งหมดในรูปแบบปฏิทินรายเดือน
เห็นภาพรวมของงานในแต่ละวันอย่างชัดเจน

⚙️ Settings
ตั้งค่าการแจ้งเตือนล่วงหน้า (ชั่วโมง/วัน)
จัดเก็บการตั้งค่าของผู้ใช้ใน Firebase

🧑‍💻 Register & Login
ใช้ Firebase Authentication
รองรับ Email/Password Login

🧭 ฟีเจอร์เสริม (Optional Features)
🏷️ ระบบแท็ก / จัดประเภทงาน
🔍 ระบบค้นหา & กรองงาน
📊 ระบบติดตามความคืบหน้า (Progress / Subtasks)

🛠️ เทคโนโลยีที่ใช้ (Tech Stack)
Flutter (Dart) – Frontend + UI
Firebase Authentication – ระบบล็อกอิน
Firebase Firestore – จัดเก็บข้อมูลงาน
Firebase Cloud Messaging – ระบบแจ้งเตือน
Local Notifications – เตือนบนอุปกรณ์

🎯 จุดประสงค์ของโปรเจกต์
Taskly ถูกพัฒนาขึ้นเพื่อลดปัญหาการลืมงานของนักศึกษา และช่วยจัดการเวลาให้มีประสิทธิภาพมากขึ้น ด้วยอินเทอร์เฟซที่ใช้งานง่ายและระบบแจ้งเตือนที่แม่นยำ

📦 การติดตั้ง (Installation)
git clone https://github.com/your-repo/taskly-assignment-reminder.git
cd taskly-assignment-reminder
flutter pub get
flutter run
