@echo off
echo Chạy các bài test bảo mật cho hệ thống Quản Lý Vé Tàu
echo =======================================================

rem Tạo thư mục cho báo cáo
if not exist "test-reports" mkdir test-reports

rem Build dự án
dotnet build

rem Chạy tests và tạo báo cáo XML
dotnet test --logger:"console;verbosity=detailed" --results-directory:"test-reports" --configuration:Release

echo =======================================================
echo Hoàn thành! Xem báo cáo chi tiết tại thư mục test-reports 