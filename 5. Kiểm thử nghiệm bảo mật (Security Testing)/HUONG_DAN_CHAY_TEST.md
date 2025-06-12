# Hướng Dẫn Chạy Bộ Test Bảo Mật Cho QuanLyVeTau

## 1. Điều Kiện Tiên Quyết

Trước khi chạy bộ test, cần đảm bảo:

- Đã cài đặt .NET 9.0 SDK hoặc cao hơn
- Đã cài đặt Chrome trình duyệt (phiên bản tương thích với ChromeDriver 137.0.7151.70)
- Đã cài đặt và cấu hình môi trường phát triển (Visual Studio hoặc Visual Studio Code)

## 2. Chuẩn Bị Ứng Dụng

1. **Khởi động ứng dụng QuanLyVeTau**:
   - Mở ứng dụng QuanLyVeTau trong Visual Studio
   - Chạy ứng dụng bằng cách nhấn F5 hoặc nút Start
   - Ghi lại URL ứng dụng (thường là http://localhost:[port])

2. **Cập nhật cấu hình test**:
   - Mở file `SecurityTests.cs` trong thư mục `seleniumTest`
   - Thay đổi biến `baseUrl` thành URL ứng dụng đang chạy:
     ```csharp
     private string baseUrl = "http://localhost:[port]"; // Thay [port] bằng cổng thật
     ```
   - Đảm bảo chuỗi kết nối database đúng:
     ```csharp
     string connectionString = "Data Source=.;Initial Catalog=QL_VETAU;Integrated Security=True";
     ```
     (Điều chỉnh tham số Data Source và tên database nếu cần)

## 3. Chạy Test

### Sử dụng Visual Studio:
1. Mở thư mục `seleniumTest` trong Visual Studio
2. Sử dụng Test Explorer để chạy các test

### Sử dụng Command Line:
1. Mở Command Prompt hoặc PowerShell
2. Di chuyển đến thư mục `seleniumTest`
3. Chạy lệnh:
   ```
   dotnet test
   ```

### Chạy test theo danh mục:
```
dotnet test --filter "Category=AccessControl"
dotnet test --filter "Category=DataSecurity"
dotnet test --filter "Category=InputValidation"
dotnet test --filter "Category=BruteForceProtection"
```

### Chạy một test cụ thể:
```
dotnet test --filter "Name=TC_SEC_001_CustomerAccessAdminPanel_ShouldShowAccessDenied"
```

### Sử dụng file batch:
```
run-tests.bat all    # Chạy tất cả test
run-tests.bat access # Chạy test kiểm soát truy cập
```

## 4. Hiểu và Điều Chỉnh Test

### Các test kiểm soát truy cập (AccessControl):
- Kiểm tra các quyền truy cập cho khách hàng, nhân viên và quản trị viên
- Yêu cầu tài khoản người dùng có trong hệ thống với các quyền phù hợp

### Các test bảo mật dữ liệu (DataSecurity):
- Kiểm tra việc mã hóa mật khẩu
- Kiểm tra xóa dữ liệu nhạy cảm khi xóa tài khoản

### Các test xác thực đầu vào (InputValidation):
- Kiểm tra khả năng chống SQL Injection

### Các test chống tấn công brute force (BruteForceProtection):
- Kiểm tra việc khóa tài khoản sau nhiều lần đăng nhập sai

## 5. Xử Lý Lỗi Thường Gặp

### Lỗi kết nối từ chối (Connection Refused):
```
OpenQA.Selenium.UnknownErrorException : unknown error: net::ERR_CONNECTION_REFUSED
```
- Nguyên nhân: Ứng dụng QuanLyVeTau không chạy hoặc URL không đúng
- Giải pháp: Chắc chắn ứng dụng đang chạy và cập nhật lại baseUrl

### Lỗi không tìm thấy phần tử (Element Not Found):
```
OpenQA.Selenium.NoSuchElementException : no such element: Unable to locate element
```
- Nguyên nhân: ID phần tử không đúng hoặc cấu trúc trang web đã thay đổi
- Giải pháp: Kiểm tra lại ID phần tử trong mã nguồn trang web và cập nhật test

### Lỗi cơ sở dữ liệu:
- Nguyên nhân: Chuỗi kết nối không đúng hoặc quyền truy cập không đủ
- Giải pháp: Kiểm tra và cập nhật lại chuỗi kết nối trong mã test

## 6. Liên Hệ Hỗ Trợ

Nếu gặp khó khăn trong việc chạy test, vui lòng liên hệ:
- Email: [địa chỉ email hỗ trợ]
- Nhóm phát triển: [tên nhóm/người hỗ trợ] 