@echo off
echo Kiểm tra kết nối với ứng dụng Quản Lý Vé Tàu
echo ============================================

dotnet test --filter "Name=VerifyHomePageLoads" --logger:"console;verbosity=detailed"

echo ============================================
echo Nếu test thành công, ứng dụng đang chạy và có thể tiếp tục với các bài test khác
echo Nếu test thất bại, hãy đảm bảo ứng dụng đang chạy ở địa chỉ đúng (hiện tại là http://localhost:53258) 