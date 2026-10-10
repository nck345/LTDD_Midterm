# Ứng Dụng Danh Bạ Điện Thoại (Contact App)

Ứng dụng quản lý danh bạ thông minh được xây dựng bằng **Flutter & Dart**, áp dụng ngôn ngữ thiết kế **Material Design 3**, hỗ trợ lưu trữ cục bộ bền vững (**SharedPreferences**) và kiểm thử tự động toàn diện.

---

## 📋 ĐÁP ỨNG YÊU CẦU ĐỀ BÀI & THANG ĐIỂM

### 🎨 CÂU 1: GIAO DIỆN (3.5 ĐIỂM)

- **1.1 (2.0đ) Thiết kế theo yêu cầu:**
  - Giao diện chuẩn Material 3 hiện đại, trực quan.
  - Danh sách liên hệ chi tiết: Mỗi thẻ hiển thị Avatar tròn với màu sắc gradient và chữ cái viết tắt (**Initials**), Tên liên hệ rõ nét, Số điện thoại kèm icon, Tag phân loại nhóm màu sắc, biểu tượng sao Yêu thích (**Favorite badge**), cùng các nút gọi điện và gửi tin nhắn nhanh.
- **1.2 (1.0đ) Sử dụng Custom Layout:**
  - `ContactCard`: Thẻ danh bạ tùy biến bo tròn 16dp, đổ bóng mềm mại, bố cục chia cột khoa học kết hợp các nút thao tác nhanh.
  - `CategoryFilterChips`: Thanh cuộn ngang bộ lọc nhóm tùy biến dạng viên thuốc (Chip) hiển thị icon và số lượng liên hệ cho từng phân loại trong thời gian thực.
  - `ContactDetailScreen Header`: Giao diện chi tiết với Avatar lớn, bố cục bo tròn góc dưới và thanh tác vụ nhanh dạng tròn.
- **1.3 (0.5đ) Giao diện bổ sung khác:**
  - **Chế độ Sáng / Tối (Dark / Light Theme):** Nút chuyển đổi nhanh Dark Mode ngay trên AppBar với màu sắc tương phản cao, dịu mắt.
  - **Trạng thái rỗng (Empty State):** Minh họa trực quan khi chưa có liên hệ hoặc khi tìm kiếm không ra kết quả, đi kèm nút khôi phục hoặc xóa bộ lọc.
  - **Thống kê số lượng:** Thanh hiển thị tổng số danh bạ, số lượng yêu thích và số lượng đang lọc trong thời gian thực.

---

### ⚙️ CÂU 2: CHỨC NĂNG (6.5 ĐIỂM)

- **2.1 (1.5đ) Thêm danh bạ mới:**
  - Nút Floating Action Button `(+) Thêm liên hệ` mở form thêm mới tiện lợi.
  - Form kiểm tra tính hợp lệ (**Validation**):
    - *Họ và tên:* Bắt buộc nhập, tối thiểu 2 ký tự.
    - *Số điện thoại:* Bắt buộc nhập, kiểm tra định dạng số điện thoại hợp lệ (9 - 11 chữ số, hỗ trợ đầu số Việt Nam `0x...` hoặc quốc tế `+84...`).
    - *Email:* Kiểm tra định dạng regex email nếu người dùng nhập.
    - *Nhóm liên hệ:* Phân loại nhóm (Gia đình, Bạn bè, Công việc, VIP, Khác).
    - *Địa chỉ & Ghi chú:* Nhập thông tin bổ sung.
    - *Bảng màu Avatar (Color Palette):* Tùy chọn 10 màu sắc đại diện cho liên hệ.
    - *Đánh dấu yêu thích:* Tùy chọn sao ban đầu.
  - Thông báo SnackBar phản hồi khi thêm thành công.
- **2.2 (1.5đ) Chỉnh sửa thông tin liên hệ:**
  - Cho phép mở chỉnh sửa từ danh sách hoặc từ màn hình Chi tiết danh bạ.
  - Dữ liệu cũ được điền sẵn đầy đủ. Kiểm tra validation trước khi lưu.
  - Cập nhật tức thời (**Reactive State**) lên giao diện và lưu trữ cục bộ.
- **2.3 (1.5đ) Xóa danh bạ:**
  - **Vuốt để xóa (Dismissible Swipe-to-delete):** Vuốt thẻ danh bạ sang trái để xóa với hiệu ứng nền đỏ và icon thùng rác.
  - **Hộp thoại xác nhận (Confirm Dialog):** Ngăn ngừa việc vô tình chạm xóa nhầm.
  - **Tính năng Hoàn tác (Undo):** SnackBar hỗ trợ nút `HOÀN TÁC` cho phép khôi phục lại liên hệ vừa xóa trong vòng vài giây.
- **2.4 (0.5đ) Tìm kiếm Real-time:**
  - Thanh tìm kiếm lọc tức thì khi gõ phím.
  - Tìm kiếm linh hoạt theo **Tên**, **Số điện thoại** hoặc **Email**.
  - **Hỗ trợ tiếng Việt không dấu (Accent-insensitive):** Tìm từ khóa `"khiem"` hoặc `"nguyen"` vẫn tìm ra `"Nguyễn Chánh Khiêm"`.
  - Nút `(X)` xóa nhanh từ khóa tìm kiếm.
- **2.5 (0.5đ) Bộ lọc & Sắp xếp:**
  - **Lọc theo nhóm:** Tất cả, Gia đình, Bạn bè, Công việc, VIP, Khác.
  - **Lọc theo trạng thái Yêu thích:** Xem nhanh danh sách liên hệ quan trọng.
  - **Sắp xếp danh bạ:** Sắp xếp theo Tên từ A đến Z, Tên từ Z đến A, hoặc Mới thêm gần nhất.
- **2.6 (1.0đ) Tính năng bổ sung khác:**
  - **Giả lập Cuộc gọi thoại (Call Simulation):** Màn hình cuộc gọi chân thực với hiệu ứng Avatar phát sóng xung kích, bộ đếm thời gian cuộc gọi đếm giây tự động, các nút Mute mic, Loa ngoài, và nút đỏ gác máy.
  - **Giả lập Nhắn tin (SMS Dialog):** Giao diện gửi SMS với các mẫu tin nhắn nhanh tiện lợi hoặc tự soạn nội dung tin nhắn.
  - **Sao chép SĐT vào Clipboard:** Bấm 1 chạm để sao chép số điện thoại vào bộ nhớ tạm.
  - **Bật/tắt Yêu thích nhanh:** 1 chạm vào biểu tượng ngôi sao ngay trên thẻ danh bạ.

---

## 🚀 HƯỚNG DẪN CÀI ĐẶT VÀ CHẠY DỰ ÁN

### 1. Yêu cầu môi trường
* Đã cài đặt **Flutter SDK** (Khuyên dùng Flutter 3.13 trở lên, hỗ trợ tốt Flutter 3.24+ / 3.47+).
* Đã cài đặt **Dart SDK** (tự động kèm theo Flutter).
* Thiết bị/môi trường chạy:
  * Máy ảo **Android Emulator** hoặc Thiết bị thật cắm cáp USB (bật USB Debugging).
  * Trình duyệt **Google Chrome** hoặc **Microsoft Edge** (chạy web).
  * Môi trường **Windows Desktop**.

---

### 2. Các bước khởi chạy dự án

#### Bước 1: Cài đặt các gói thư viện phụ thuộc
```bash
flutter pub get
```

#### Bước 2: Khởi chạy ứng dụng

* **Chạy trên Thiết bị Android (Máy ảo hoặc thiết bị thật):**
  ```bash
  flutter run
  ```
  *(Hoặc chỉ định rõ: `flutter run -d android`)*

* **Chạy trên Trình duyệt Web (Google Chrome / Edge):**
  ```bash
  flutter run -d chrome
  ```

* **Chạy trên Windows Desktop:**
  ```bash
  flutter run -d windows
  ```
