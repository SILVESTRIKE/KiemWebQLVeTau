# KiemWebQLVeTau

Hệ thống kiểm thử cho phần mềm Quản Lý Vé Tàu.

## Cấu trúc thư mục

- **1. Kiểm thử chức năng/**: Chứa các kịch bản kiểm thử chức năng (Selenium IDE `.side` files).
- **2. Kiểm thử cơ sở dữ liệu (Database Testing)/**: Chứa các script kiểm thử cơ sở dữ liệu, file tSQLt và các tài liệu liên quan.
- **3. Kiểm thử tính khả dụng/**: Các tài liệu kiểm thử usability.
- **4. Kiểm thử hiệu năng (Performance Testing)/**: Các tài liệu kiểm thử hiệu năng.
- **5. Kiểm thử nghiệm bảo mật (Security Testing)/**: Chứa mã nguồn kiểm thử bảo mật (C#, Selenium), hướng dẫn chạy test.
- **7. Kiểm thử Backup & Restore/**: Tài liệu kiểm thử backup và restore.

## Hướng dẫn sử dụng

### 1. Kiểm thử chức năng

- Mở các file `.side` trong [1. Kiểm thử chức năng/](1.%20Ki%E1%BB%83m%20th%E1%BB%AD%20ch%E1%BB%A9c%20n%C4%83ng/) bằng Selenium IDE để thực thi các kịch bản kiểm thử giao diện.

### 2. Kiểm thử cơ sở dữ liệu

- Sử dụng các script SQL và tSQLt trong [2. Kiểm thử cơ sở dữ liệu (Database Testing)/](2.%20Ki%E1%BB%83m%20th%E1%BB%AD%20c%C6%A1%20s%E1%BB%9F%20d%E1%BB%AF%20li%E1%BB%87u%20(Database%20Testing)/) để kiểm thử các chức năng liên quan đến cơ sở dữ liệu.

### 3. Kiểm thử bảo mật

- Làm theo hướng dẫn trong [5. Kiểm thử nghiệm bảo mật (Security Testing)/HUONG_DAN_CHAY_TEST.md](5.%20Ki%E1%BB%83m%20th%E1%BB%AD%20nghi%E1%BB%87m%20b%E1%BA%A3o%20m%E1%BA%ADt%20(Security%20Testing)/HUONG_DAN_CHAY_TEST.md) để chạy các bài kiểm thử bảo mật tự động bằng Selenium.

## Tham khảo

- Dự án gốc: [https://github.com/ngocnghia81/QuanLyVeTau](https://github.com/ngocnghia81/QuanLyVeTau)