# Kiểm thử bảo mật cho Hệ thống Quản lý Vé Tàu

Bộ kiểm thử này sử dụng Selenium WebDriver để thực hiện các kiểm thử bảo mật tự động cho hệ thống Quản lý Vé Tàu.

## Các kiểm thử bảo mật được triển khai

### Kiểm soát truy cập (Access Control)
- **TC_SEC_001**: Kiểm tra khách hàng không thể truy cập trang quản trị
- **TC_SEC_002**: Kiểm tra nhân viên không thể chỉnh sửa dữ liệu tàu
- **TC_SEC_003**: Kiểm tra giám đốc có thể xem danh sách nhân viên
- **TC_SEC_004**: Kiểm tra khách hàng không thể xem lịch sử của khách hàng khác
- **TC_SEC_005**: Kiểm tra nhân viên không thể xem báo cáo doanh thu

### Bảo mật dữ liệu (Data Security)
- **TC_SEC_006**: Kiểm tra mật khẩu được mã hóa khi lưu vào database
- **TC_SEC_008**: Kiểm tra kết nối HTTPS hoặc bảo mật hình thức đăng nhập
- **TC_SEC_010**: Kiểm tra dữ liệu nhạy cảm bị xóa khi xóa tài khoản

### Kiểm tra đầu vào (Input Validation)
- **TC_SEC_007**: Kiểm tra hệ thống phòng chống SQL Injection

### Phòng chống tấn công Brute Force
- **TC_SEC_009**: Kiểm tra giới hạn số lần đăng nhập sai

### Kiểm tra cơ bản
- **VerifyHomePageLoads**: Kiểm tra ứng dụng có đang chạy và trang chủ có tải thành công

## Cách chạy kiểm thử

### Yêu cầu
- .NET SDK 9.0 hoặc cao hơn
- Google Chrome đã được cài đặt
- Ứng dụng Quản lý Vé Tàu đang chạy ở địa chỉ http://localhost:53258 (có thể thay đổi trong file SecurityTests.cs)

### Kiểm tra ứng dụng có đang chạy
```
.\verify-app.bat
```

### Chạy tất cả các kiểm thử
```
dotnet test
```

### Chạy một kiểm thử cụ thể
```
dotnet test --filter "Name=TC_SEC_007_SQLInjection_ShouldNotAllowInjection"
```

### Chạy các kiểm thử theo danh mục
```
dotnet test --filter "Category=AccessControl"
dotnet test --filter "Category=DataSecurity"
dotnet test --filter "Category=InputValidation"
dotnet test --filter "Category=BruteForceProtection"
```

## Cách giải thích kết quả
- **Passed**: Kiểm thử thành công, hệ thống đã triển khai biện pháp bảo mật
- **Passed conditionally**: Kiểm thử thành công có điều kiện, hệ thống có thể không triển khai tính năng nhưng không ảnh hưởng đến bảo mật
- **Warning**: Cảnh báo, có thể có rủi ro bảo mật cần được xem xét
- **Failed**: Kiểm thử thất bại, hệ thống có lỗ hổng bảo mật cần được khắc phục

## Lưu ý
- Các kiểm thử có thể cần được điều chỉnh theo cấu trúc thực tế của ứng dụng
- Đảm bảo ứng dụng đang chạy trước khi thực hiện kiểm thử
- Một số kiểm thử yêu cầu quyền truy cập vào cơ sở dữ liệu, có thể cần điều chỉnh chuỗi kết nối trong mã nguồn

## Cách điều chỉnh kiểm thử

1. Đảm bảo đường dẫn ứng dụng được cập nhật (thay đổi biến `baseUrl` trong `SecurityTests.cs`)
2. Cập nhật chuỗi kết nối database (thay đổi biến `connectionString` trong các phương thức test)
3. Kiểm tra và cập nhật các ID của phần tử trong trang web (ví dụ: "pUsername", "pPassword") nếu cần
4. Kiểm tra và cập nhật thông điệp hiển thị trong các kiểm tra để phù hợp với ứng dụng

## Testing Strategy

Các bài test được thiết kế để kiểm tra các điểm bảo mật của ứng dụng QuanLyVeTau theo danh sách OWASP Top 10:

1. **Kiểm tra kiểm soát truy cập**: Xác minh người dùng chỉ có thể truy cập vào các tài nguyên mà họ được phép
2. **Bảo vệ dữ liệu**: Đảm bảo dữ liệu nhạy cảm được bảo vệ khi lưu trữ và truyền tải
3. **Xác thực đầu vào**: Kiểm tra khả năng chống lại các cuộc tấn công injection
4. **Kiểm tra xác thực**: Xác minh cơ chế xác thực hoạt động đúng
5. **Quản lý phiên**: Kiểm tra phiên được xử lý an toàn 