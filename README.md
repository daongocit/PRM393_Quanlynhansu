# HỆ THỐNG QUẢN LÝ NHÂN SỰ CÔNG TY (ASOFT-HRM) - DART & FLUTTER

> **Môn học**: PRM / Mobile Application Development  
> **Đề tài**: Quản lý Nhân sự Công ty & Phê duyệt Doanh nghiệp (ASOFT-HRM)  
> **Nhóm thực hiện**: 2 thành viên (**Duy Ngọc**, **Uyên**)  
> *(Ghi chú: Toàn bộ 15 màn hình nghiệp vụ liên thông đã được cân đối và chia đều giữa 2 thành viên: Duy Ngọc phụ trách 7 màn + Core; Uyên phụ trách 8 màn + Core)*  
> **Quy mô đáp ứng**: Vượt chuẩn yêu cầu của môn học PRM (trung bình 7-8 màn hình nghiệp vụ liên thông / thành viên).

---

## I. BẢNG PHÂN CÔNG 15 MÀN HÌNH THEO TỪNG THÀNH VIÊN (NHÓM 2 NGƯỜI)

| STT | Thành viên | Màn hình (File Path) | Luồng nghiệp vụ & Tính năng nổi bật |
|:---:|:---|:---|:---|
| **1** | **Duy Ngọc** | `lib/features/attendance_approval/screens/attendance_checkin_screen.dart` | **Màn 1: Check-in Điểm danh GPS**: Đồng hồ số thời gian thực, vị trí ca, đếm giờ làm việc, cảnh báo Business Rule đi trễ sau 8:15 và phím tắt tạo đơn giải trình. |
| **2** | **Duy Ngọc** | `lib/features/attendance_approval/screens/attendance_history_screen.dart` | **Màn 2: Bảng Chấm công Cá nhân**: Thống kê công tháng, xem Calendar dạng `TableCalendar` và danh sách quẹt thẻ chi tiết từng ngày. |
| **3** | **Duy Ngọc** | `lib/features/attendance_approval/screens/manager_approval_list_screen.dart` | **Màn 3: Danh sách Đơn Chờ duyệt**: Tabs Chờ duyệt / Đã xử lý, hỗ trợ **Duyệt đơn hàng loạt (Batch approval)** với Checkbox. |
| **4** | **Duy Ngọc** | `lib/features/attendance_approval/screens/manager_approval_detail_screen.dart` | **Màn 4: Thẩm định & Phê duyệt Đơn**: Xem lý do, hồ sơ nộp, quota phép còn lại của nhân viên, form nhập ý kiến Từ chối / Duyệt đơn. |
| **5** | **Duy Ngọc** | `lib/features/attendance_approval/screens/department_attendance_report_screen.dart` | **Màn 5: Báo cáo Chấm công Phòng ban**: Biểu đồ chuyên cần, theo dõi nhân sự có mặt, đi trễ, vắng mặt trong bộ phận. |
| **6** | **Duy Ngọc** | `lib/features/department_tasks/screens/department_task_board_screen.dart` | **Màn 11: Bảng Kanban Công việc**: Lọc To Do, In Progress, Done, cờ Deadline khẩn cấp, tiến độ % thanh trượt. |
| **7** | **Duy Ngọc** | `lib/features/department_tasks/screens/create_or_edit_task_screen.dart` | **Màn 12: Giao việc & Phân công**: Chọn Assignee cùng phòng ban, chọn Deadline ngày/giờ, mức độ ưu tiên (High/Med/Low). |
| **8** | **Uyên** | `lib/features/leave_requests/screens/leave_quota_dashboard_screen.dart` | **Màn 6: Quỹ phép thông minh (Business Rule Cốt lõi)**: Thẻ thông số phép năm theo thâm niên: *Làm 3 tháng $\rightarrow$ tối đa 3 ngày phép, đã nghỉ 2 ngày, còn lại 1 ngày khả dụng*. |
| **9** | **Uyên** | `lib/features/leave_requests/screens/create_leave_request_screen.dart` | **Màn 7: Lập đơn xin nghỉ / Giải trình / Đổi ca**: Tự tính số ngày, kiểm tra quota phép và chặn nộp nếu bị trùng lịch. |
| **10** | **Uyên** | `lib/features/leave_requests/screens/my_leave_requests_screen.dart` | **Màn 8: Danh sách Đơn từ Cá nhân**: Lọc trạng thái (Chờ duyệt, Đã duyệt, Từ chối), theo dõi tiến độ giải quyết. |
| **11** | **Uyên** | `lib/features/leave_requests/screens/leave_request_detail_screen.dart` | **Màn 9: Chi tiết Đơn từ & Timeline**: Hiển thị tiến trình duyệt đa cấp, chức năng Hủy đơn khi đang chờ duyệt. |
| **12** | **Uyên** | `lib/features/leave_requests/screens/shift_schedule_screen.dart` | **Màn 10: Lịch Ca Làm việc**: Xem lịch phân ca tuần (CA01 hành chính, CA02 chiều/tối) và nút tắt nộp đơn xin đổi ca. |
| **13** | **Uyên** | `lib/features/department_tasks/screens/task_detail_screen.dart` | **Màn 13: Chi tiết Nhiệm vụ**: Kéo Slider tiến độ (0% - 100%), đổi trạng thái công việc, nút liên thông sang Trao đổi & Nhắc nhở. |
| **14** | **Uyên** | `lib/features/department_tasks/screens/task_comments_screen.dart` | **Màn 14: Thảo luận & Bình luận nội bộ**: Các nhân sự trong cùng phòng ban IT xem và gửi comment trao đổi realtime. |
| **15** | **Uyên** | `lib/features/department_tasks/screens/task_reminder_screen.dart` | **Màn 15: Mốc Nhắc nhở & Notification**: Chọn mốc trước 1h, trước 1 ngày hoặc tự chọn, kích hoạt Local Notification trên máy. |

*Màn hình Dùng chung (Core)*:
- `lib/features/auth/screens/login_screen.dart`: Đăng nhập Google / Gmail + Demo Account Switcher linh hoạt.
- `lib/features/auth/screens/profile_screen.dart`: Hồ sơ nhân sự cá nhân, thâm niên, hợp đồng, đăng xuất.
- `lib/features/home/screens/main_navigation_shell.dart`: Bottom Navigation Bar 4 tabs + Drawer bên cạnh truy cập nhanh toàn bộ 15 màn hình.

---

## II. ĐẶC TẢ BUSINESS RULES (QUY TẮC NGHIỆP VỤ PHỨC TẠP)

### 1. Quy tắc tính Quỹ phép năm theo Thâm niên & Thưởng thâm niên lâu năm
- Nằm trong file: [leave_calculator.dart](file:///lib/features/leave_requests/services/leave_calculator.dart)
- **Công thức tính toán**: 
  - Số tháng thâm niên = `(Ngày hiện tại - Ngày bắt đầu làm việc) / 30 ngày`.
  - **Nhân sự mới (< 12 tháng)**: Hạn mức tích lũy = `Số tháng thâm niên` (1 ngày/tháng).
  - **Nhân sự từ 1 năm đến dưới 2 năm**: Hạn mức cơ sở = `12 ngày phép/năm`.
  - **Nhân sự thâm niên lâu năm ($\ge 2$ năm)**: Được thưởng thêm ngày phép theo số năm cống hiến:
    - *Làm 2 năm (24 - 35 tháng)*: Thưởng **+2 ngày phép** $\rightarrow$ Hạn mức **14 ngày/năm**.
    - *Làm 3 năm (36 - 47 tháng)*: Thưởng **+3 ngày phép** $\rightarrow$ Hạn mức **15 ngày/năm**.
    - *Mỗi năm thâm niên tiếp theo*: Cộng thêm 1 ngày phép (tối đa +5 ngày = 17 ngày/năm).
  - Phép còn lại = `(Hạn mức tích lũy + Thưởng thâm niên) - Tổng số ngày nghỉ phép năm đã APPROVED`.
- **Ví dụ thực tế trong DB**:
  - *Nhân sự mới (Uyên)*: Vào làm `12/07/2026` đến `12/10/2026` tròn 3 tháng $\rightarrow$ Hạn mức **3 ngày**, đã nghỉ **2 ngày** $\rightarrow$ Còn lại **1 ngày khả dụng**.
  - *Nhân sự lâu năm (Duy Ngọc)*: Vào làm `15/01/2024` đến `10/2026` là 33 tháng (> 2 năm) $\rightarrow$ Thưởng **+2 ngày phép thâm niên** $\rightarrow$ Hạn mức **14 ngày phép/năm** (nhiều hơn nhân viên mới).
- **Validation**: Nếu xin nghỉ vượt quá hạn mức khả dụng hoặc trùng lịch với đơn đang chờ, hệ thống chặn gửi đơn và thông báo lỗi rõ ràng.

### 2. Quy tắc Phê duyệt Đa cấp (Approval Workflow)
- Đơn $\le 2$ ngày: Trưởng phòng (`MANAGER`) duyệt 1 bước hoàn tất.
- Đơn $> 2$ ngày: Hệ thống phân quyền duyệt 2 cấp (Trưởng phòng duyệt trước, Giám đốc nhân sự duyệt bước 2).

### 3. Quy tắc Đi trễ Chấm công (Late Geofence Check)
- Ca CA01 bắt đầu lúc `08:00`. Nếu Check-in sau `08:15`, hệ thống tự động gán cờ `LATE (Đi trễ)` và hiển thị cảnh báo đỏ yêu cầu nộp đơn giải trình.

---

## III. THIẾT KẾ CƠ SỞ DỮ LIỆU CỤC BỘ (SQLite)

Hệ thống sử dụng SQLite thông qua [database_helper.dart](file:///lib/core/database/database_helper.dart) với 7 bảng quan hệ:
1. `departments`: Phòng ban (`IT_DEPT`, `HR_DEPT`, `SALES_DEPT`).
2. `users`: Nhân sự (Duy Ngọc - Manager, Uyên - Employee, v.v.), lưu ngày vào làm để tính thâm niên.
3. `shifts`: Danh mục ca làm việc (CA01, CA02, CA03).
4. `user_shift_assignments`: Phân ca làm việc theo tuần cho nhân sự.
5. `attendance`: Bảng chấm công quẹt thẻ (giờ vào, giờ ra, số giờ làm, trạng thái ON_TIME/LATE).
6. `leave_requests`: Đơn từ (nghỉ phép, đổi ca, giải trình đi trễ, trạng thái PENDING/APPROVED/REJECTED/CANCELLED).
7. `tasks`, `task_comments`, `task_reminders`: Quản lý công việc phòng ban, bình luận trao đổi nội bộ, và mốc nhắc nhở.

---

## IV. HƯỚNG DẪN CHẠY VÀ DEMO DỰ ÁN

```bash
# 1. Cài đặt dependencies
flutter pub get

# 2. Chạy kiểm tra tĩnh
flutter analyze

# 3. Chạy toàn bộ Unit & Business Rules Test
flutter test

# 4. Chạy ứng dụng (trên Android Studio, Android Emulator, Windows hoặc Chrome)
flutter run
```

### Các bước demo với Giảng viên:
1. **Tại màn hình Login**: Bấm chọn tài khoản **Uyên (Nhân viên)**.
2. **Xem Quỹ phép & Đơn từ (Uyên - Phần việc Thành viên 2)**:
   - Vào tab "Đơn từ & Phép": Xem thẻ quota phép hiển thị chuẩn: *3 tháng $\rightarrow$ tối đa 3 ngày, đã nghỉ 2 ngày, còn 1 ngày*.
   - Bấm "Lập đơn xin nghỉ mới": Thử xin 2 ngày phép năm $\rightarrow$ Hệ thống cảnh báo đỏ vượt hạn mức.
   - Thử xin 1 ngày hợp lệ $\rightarrow$ Nộp thành công, trạng thái chuyển sang "Chờ phê duyệt".
3. **Chuyển sang Quản lý (Duy Ngọc - Phần việc Thành viên 1)**:
   - Bấm nút hoán đổi Role trên thanh Header hoặc Drawer: Chọn **Duy Ngọc (Quản lý)**.
   - Vào tab "Duyệt đơn": Thấy ngay đơn của Uyên vừa nộp.
   - Trải nghiệm tính năng: Duyệt đơn lẻ hoặc Chọn checkbox để **Duyệt hàng loạt**.
   - Vào tab "Báo cáo": Xem báo cáo chấm công chuyên cần của toàn phòng ban IT.
4. **Quản lý & Tương tác Công việc (Kanban, Slider tiến độ, Thảo luận & Nhắc nhở)**:
   - Vào tab "Công việc": Xem bảng Kanban, cờ Deadline khẩn cấp.
   - Bấm vào task: Kéo Slider cập nhật tiến độ (0% - 100%).
   - Bấm "Thảo luận Task": Xem và gửi bình luận nội bộ realtime.
   - Bấm "Đặt mốc nhắc": Hẹn giờ và nhận thông báo Notification trên máy.
