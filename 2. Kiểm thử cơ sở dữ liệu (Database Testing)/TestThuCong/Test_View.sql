-- File: Test_Views.sql
-- Mục đích: Kiểm tra tự động các view trong cơ sở dữ liệu với PASS/FAIL và cleanup
-- Ngày tạo: 2025-06-11
-- Lưu ý: Sử dụng transaction để đảm bảo không ảnh hưởng dữ liệu gốc

SET NOCOUNT ON;
GO

-- Tạo bảng tạm để lưu kết quả kiểm tra
IF OBJECT_ID('tempdb..#TestResults') IS NOT NULL DROP TABLE #TestResults;
CREATE TABLE #TestResults (
    TestID INT IDENTITY(1,1),
    TestName NVARCHAR(100),
    Result NVARCHAR(10),
    Reason NVARCHAR(500)
);
GO

-- 1. Kiểm tra Vw_NhatKyTauChuaHoanThanhs
PRINT 'Kiểm tra Vw_NhatKyTauChuaHoanThanhs:';
BEGIN TRY
    BEGIN TRANSACTION;
    INSERT INTO LichTrinhTau (MaLichTrinh, TrangThai) VALUES ('LT999', N'Đang hoạt động');
    INSERT INTO NhatKyTau (MaNhatKy, MaTau, MaLichTrinh, NgayGio, TrangThai) 
    VALUES ('NK999', 'TA1', 'LT999', '2025-06-12', N'Chưa hoàn thành');
    DECLARE @Result TABLE (MaNhatKy VARCHAR(11), MaTau VARCHAR(10), MaLichTrinh VARCHAR(10), NgayGio DATETIME, TrangThai NVARCHAR(50));
    INSERT INTO @Result
    SELECT * FROM Vw_NhatKyTauChuaHoanThanhs;
    IF EXISTS (SELECT 1 FROM @Result WHERE MaNhatKy = 'NK999' AND TrangThai = N'Chưa hoàn thành')
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('Vw_NhatKyTauChuaHoanThanhs', 'PASS', 'View trả về danh sách nhật ký chưa hoàn thành đúng.');
    ELSE
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('Vw_NhatKyTauChuaHoanThanhs', 'FAIL', 'View không trả về danh sách nhật ký đúng.');
    ROLLBACK;
END TRY
BEGIN CATCH
    INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('Vw_NhatKyTauChuaHoanThanhs', 'FAIL', 'Lỗi không mong đợi: ' + ERROR_MESSAGE());
    ROLLBACK;
END CATCH
GO

-- 2. Kiểm tra Vw_TongNguoiDung
PRINT 'Kiểm tra Vw_TongNguoiDung:';
BEGIN TRY
    BEGIN TRANSACTION;
    INSERT INTO TaiKhoan (MaTaiKhoan, Email, MatKhau, DaXoa) VALUES ('TK999', 'test@example.com', 'pass123', 0);
    DECLARE @Result TABLE (TongNguoiDung INT);
    INSERT INTO @Result
    SELECT * FROM Vw_TongNguoiDung;
    IF EXISTS (SELECT 1 FROM @Result WHERE TongNguoiDung = 1)
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('Vw_TongNguoiDung', 'PASS', 'View trả về tổng số người dùng đúng.');
    ELSE
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('Vw_TongNguoiDung', 'FAIL', 'View không trả về tổng số người dùng đúng.');
    ROLLBACK;
END TRY
BEGIN CATCH
    INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('Vw_TongNguoiDung', 'FAIL', 'Lỗi không mong đợi: ' + ERROR_MESSAGE());
    ROLLBACK;
END CATCH
GO

-- 3. Kiểm tra Vw_TongVeDaBan
PRINT 'Kiểm tra Vw_TongVeDaBan:';
BEGIN TRY
    BEGIN TRANSACTION;
    INSERT INTO KhachHang (MaKhach, TenKhach, NamSinh, Email, SDT, CCCD, DiaChi) 
    VALUES ('KH999', N'Test', '1990-01-01', 'test@example.com', '0999999999', '123456789012', N'Test');
    INSERT INTO HoaDon (MaHoaDon, MaKhach, ThanhTien, ThoiGianLapHoaDon) 
    VALUES ('HD999', 'KH999', 100000, '2025-06-11');
    INSERT INTO LichTrinhTau (MaLichTrinh, TrangThai) VALUES ('LT998', N'Đang hoạt động');
    INSERT INTO NhatKyTau (MaNhatKy, MaTau, MaLichTrinh, NgayGio, TrangThai) 
    VALUES ('NK998', 'TA1', 'LT998', '2025-06-12', N'Chưa hoàn thành');
    INSERT INTO Ve (MaVe, MaNhatKy, MaHoaDon, GiaVe, MaKhoang, Stt_Ghe, DiemDi, DiemDen, DaThuHoi) 
    VALUES ('VE999', 'NK998', 'HD999', 100000, 'K1', 1, 'CT1', 'CT2', 0);
    DECLARE @Result TABLE (TongVeDaBan INT);
    INSERT INTO @Result
    SELECT * FROM Vw_TongVeDaBan;
    IF EXISTS (SELECT 1 FROM @Result WHERE TongVeDaBan = 1)
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('Vw_TongVeDaBan', 'PASS', 'View trả về tổng số vé đã bán đúng.');
    ELSE
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('Vw_TongVeDaBan', 'FAIL', 'View không trả về tổng số vé đã bán đúng.');
    ROLLBACK;
END TRY
BEGIN CATCH
    INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('Vw_TongVeDaBan', 'FAIL', 'Lỗi không mong đợi: ' + ERROR_MESSAGE());
    ROLLBACK;
END CATCH
GO

-- 4. Kiểm tra Vw_TongDoanhThu
PRINT 'Kiểm tra Vw_TongDoanhThu:';
BEGIN TRY
    BEGIN TRANSACTION;
    INSERT INTO KhachHang (MaKhach, TenKhach, NamSinh, Email, SDT, CCCD, DiaChi) 
    VALUES ('KH998', N'Test', '1990-01-01', NULL, '0999999998', NULL, NULL);
    INSERT INTO HoaDon (MaHoaDon, MaKhach, ThanhTien, ThoiGianLapHoaDon) 
    VALUES ('HD998', 'KH998', 200000, '2025-06-11');
    INSERT INTO LichSuDoiTraVe (MaVe, HanhDong, ThoiGian, LePhi) 
    VALUES ('VE998', 'Trả', '2025-06-11', 50000);
    DECLARE @Result TABLE (TongDoanhThu DECIMAL(19,2));
    INSERT INTO @Result
    SELECT * FROM Vw_TongDoanhThu;
    IF EXISTS (SELECT 1 FROM @Result WHERE TongDoanhThu = 250000)
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('Vw_TongDoanhThu', 'PASS', 'View trả về tổng doanh thu đúng.');
    ELSE
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('Vw_TongDoanhThu', 'FAIL', 'View không trả về tổng doanh thu đúng.');
    ROLLBACK;
END TRY
BEGIN CATCH
    INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('Vw_TongDoanhThu', 'FAIL', 'Lỗi không mong đợi: ' + ERROR_MESSAGE());
    ROLLBACK;
END CATCH
GO

-- 5. Kiểm tra Vw_TongPhanHoi
PRINT 'Kiểm tra Vw_TongPhanHoi:';
BEGIN TRY
    BEGIN TRANSACTION;
    INSERT INTO KhachHang (MaKhach, TenKhach, NamSinh, Email, SDT, CCCD, DiaChi) 
    VALUES ('KH997', N'Test', '1990-01-01', NULL, '0999999997', NULL, NULL);
    INSERT INTO HoaDon (MaHoaDon, MaKhach, ThanhTien, ThoiGianLapHoaDon) 
    VALUES ('HD997', 'KH997', 100000, '2025-06-11');
    INSERT INTO PhanHoi (MaHoaDon, NoiDung, NgayPhanHoi, SoSao) 
    VALUES ('HD997', N'Test phản hồi', '2025-06-11', 5);
    DECLARE @Result TABLE (TongPhanHoi INT);
    INSERT INTO @Result
    SELECT * FROM Vw_TongPhanHoi;
    IF EXISTS (SELECT 1 FROM @Result WHERE TongPhanHoi = 1)
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('Vw_TongPhanHoi', 'PASS', 'View trả về tổng số phản hồi đúng.');
    ELSE
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('Vw_TongPhanHoi', 'FAIL', 'View không trả về tổng số phản hồi đúng.');
    ROLLBACK;
END TRY
BEGIN CATCH
    INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('Vw_TongPhanHoi', 'FAIL', 'Lỗi không mong đợi: ' + ERROR_MESSAGE());
    ROLLBACK;
END CATCH
GO

-- 6. Kiểm tra Vw_DoanhThuTheoThang
PRINT 'Kiểm tra Vw_DoanhThuTheoThang:';
BEGIN TRY
    BEGIN TRANSACTION;
    INSERT INTO KhachHang (MaKhach, TenKhach, NamSinh, Email, SDT, CCCD, DiaChi) 
    VALUES ('KH996', N'Test', '1990-01-01', NULL, '0999999996', NULL, NULL);
    INSERT INTO HoaDon (MaHoaDon, MaKhach, ThanhTien, ThoiGianLapHoaDon) 
    VALUES ('HD996', 'KH996', 300000, '2025-06-01');
    DECLARE @Result TABLE (Nam INT, Thang INT, TongDoanhThu DECIMAL(19,2));
    INSERT INTO @Result
    SELECT * FROM Vw_DoanhThuTheoThang;
    IF EXISTS (SELECT 1 FROM @Result WHERE Nam = 2025 AND Thang = 6 AND TongDoanhThu = 300000)
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('Vw_DoanhThuTheoThang', 'PASS', 'View trả về doanh thu theo tháng đúng.');
    ELSE
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('Vw_DoanhThuTheoThang', 'FAIL', 'View không trả về doanh thu theo tháng đúng.');
    ROLLBACK;
END TRY
BEGIN CATCH
    INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('Vw_DoanhThuTheoThang', 'FAIL', 'Lỗi không mong đợi: ' + ERROR_MESSAGE());
    ROLLBACK;
END CATCH
GO

-- 7. Kiểm tra Vw_SoKhachHang
PRINT 'Kiểm tra Vw_SoKhachHang:';
BEGIN TRY
    BEGIN TRANSACTION;
    INSERT INTO KhachHang (MaKhach, TenKhach, NamSinh, Email, SDT, CCCD, DiaChi) 
    VALUES ('KH995', N'Test', '1990-01-01', NULL, '0999999995', NULL, NULL);
    DECLARE @Result TABLE (SoKhachHang INT);
    INSERT INTO @Result
    SELECT * FROM Vw_SoKhachHang;
    IF EXISTS (SELECT 1 FROM @Result WHERE SoKhachHang = 1)
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('Vw_SoKhachHang', 'PASS', 'View trả về số khách hàng đúng.');
    ELSE
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('Vw_SoKhachHang', 'FAIL', 'View không trả về số khách hàng đúng.');
    ROLLBACK;
END TRY
BEGIN CATCH
    INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('Vw_SoKhachHang', 'FAIL', 'Lỗi không mong đợi: ' + ERROR_MESSAGE());
    ROLLBACK;
END CATCH
GO

-- 8. Kiểm tra Vw_SoKhuyenMai
PRINT 'Kiểm tra Vw_SoKhuyenMai:';
BEGIN TRY
    BEGIN TRANSACTION;
    INSERT INTO KhuyenMai (MaKhuyenMai, TenKhuyenMai, SoTienGiamToiDa, PhanTramGiam, NgayBatDau, NgayKetThuc, SoLuong, SoLuongConLai)
    VALUES ('KM999', N'Test KM', 50000, 10.0, '2025-06-01', '2025-06-30', 100, 100);
    DECLARE @Result TABLE (SoKhuyenMai INT);
    INSERT INTO @Result
    SELECT * FROM Vw_SoKhuyenMai;
    IF EXISTS (SELECT 1 FROM @Result WHERE SoKhuyenMai = 1)
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('Vw_SoKhuyenMai', 'PASS', 'View trả về số khuyến mãi đúng.');
    ELSE
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('Vw_SoKhuyenMai', 'FAIL', 'View không trả về số khuyến mãi đúng.');
    ROLLBACK;
END TRY
BEGIN CATCH
    INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('Vw_SoKhuyenMai', 'FAIL', 'Lỗi không mong đợi: ' + ERROR_MESSAGE());
    ROLLBACK;
END CATCH
GO

-- 9. Kiểm tra Vw_SoVeTheoThang
PRINT 'Kiểm tra Vw_SoVeTheoThang:';
BEGIN TRY
    BEGIN TRANSACTION;
    INSERT INTO KhachHang (MaKhach, TenKhach, NamSinh, Email, SDT, CCCD, DiaChi) 
    VALUES ('KH994', N'Test', '1990-01-01', NULL, '0999999994', NULL, NULL);
    INSERT INTO HoaDon (MaHoaDon, MaKhach, ThanhTien, ThoiGianLapHoaDon) 
    VALUES ('HD994', 'KH994', 150000, '2025-06-01');
    INSERT INTO LichTrinhTau (MaLichTrinh, TrangThai) VALUES ('LT994', N'Đang hoạt động');
    INSERT INTO NhatKyTau (MaNhatKy, MaTau, MaLichTrinh, NgayGio, TrangThai) 
    VALUES ('NK994', 'TA1', 'LT994', '2025-06-12', N'Chưa hoàn thành');
    INSERT INTO Ve (MaVe, MaNhatKy, MaHoaDon, GiaVe, MaKhoang, Stt_Ghe, DiemDi, DiemDen, DaThuHoi) 
    VALUES ('VE994', 'NK994', 'HD994', 150000, 'K1', 1, 'CT1', 'CT2', 0);
    DECLARE @Result TABLE (Nam INT, Thang INT, SoVeBan INT);
    INSERT INTO @Result
    SELECT * FROM Vw_SoVeTheoThang;
    IF EXISTS (SELECT 1 FROM @Result WHERE Nam = 2025 AND Thang = 6 AND SoVeBan = 1)
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('Vw_SoVeTheoThang', 'PASS', 'View trả về số vé theo tháng đúng.');
    ELSE
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('Vw_SoVeTheoThang', 'FAIL', 'View không trả về số vé theo tháng đúng.');
    ROLLBACK;
END TRY
BEGIN CATCH
    INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('Vw_SoVeTheoThang', 'FAIL', 'Lỗi không mong đợi: ' + ERROR_MESSAGE());
    ROLLBACK;
END CATCH
GO

-- 10. Kiểm tra Vw_DoanhThuThucNhan
PRINT 'Kiểm tra Vw_DoanhThuThucNhan:';
BEGIN TRY
    BEGIN TRANSACTION;
    INSERT INTO KhachHang (MaKhach, TenKhach, NamSinh, Email, SDT, CCCD, DiaChi) 
    VALUES ('KH993', N'Test', '1990-01-01', NULL, '0999999993', NULL, NULL);
    INSERT INTO HoaDon (MaHoaDon, MaKhach, ThanhTien, ThoiGianLapHoaDon) 
    VALUES ('HD993', 'KH993', 400000, '2025-06-11');
    INSERT INTO LichTrinhTau (MaLichTrinh, TrangThai) VALUES ('LT993', N'Đang hoạt động');
    INSERT INTO NhatKyTau (MaNhatKy, MaTau, MaLichTrinh, NgayGio, TrangThai) 
    VALUES ('NK993', 'TA1', 'LT993', '2025-06-11', N'Hoàn thành');
    INSERT INTO Ve (MaVe, MaNhatKy, MaHoaDon, GiaVe, MaKhoang, Stt_Ghe, DiemDi, DiemDen, DaThuHoi) 
    VALUES ('VE993', 'NK993', 'HD993', 400000, 'K1', 1, 'CT1', 'CT2', 0);
    INSERT INTO LichSuDoiTraVe (MaVe, HanhDong, ThoiGian, LePhi) 
    VALUES ('VE993', 'Trả', '2025-06-11', 10000);
    DECLARE @Result TABLE (DoanhThuThucNhan DECIMAL(19,2));
    INSERT INTO @Result
    SELECT * FROM Vw_DoanhThuThucNhan;
    IF EXISTS (SELECT 1 FROM @Result WHERE DoanhThuThucNhan = 410000)
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('Vw_DoanhThuThucNhan', 'PASS', 'View trả về doanh thu thực nhận đúng.');
    ELSE
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('Vw_DoanhThuThucNhan', 'FAIL', 'View không trả về doanh thu thực nhận đúng.');
    ROLLBACK;
END TRY
BEGIN CATCH
    INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('Vw_DoanhThuThucNhan', 'FAIL', 'Lỗi không mong đợi: ' + ERROR_MESSAGE());
    ROLLBACK;
END CATCH
GO

-- 11. Kiểm tra Vw_LichPhanCong
PRINT 'Kiểm tra Vw_LichPhanCong:';
BEGIN TRY
    BEGIN TRANSACTION;
    INSERT INTO NhanVien (MaNhanVien, TenNhanVien, Email, SDT) VALUES ('NV999', N'Test NV', 'nv@example.com', '0999999999');
    INSERT INTO LichTrinhTau (MaLichTrinh, TrangThai) VALUES ('LT992', N'Đang hoạt động');
    INSERT INTO NhatKyTau (MaNhatKy, MaTau, MaLichTrinh, NgayGio, TrangThai) 
    VALUES ('NK992', 'TA1', 'LT992', '2025-06-12', N'Chưa hoàn thành');
    INSERT INTO PhanCong (MaPhanCong, MaNhanVien, MaNhatKy) VALUES ('PC999', 'NV999', 'NK992');
    DECLARE @Result TABLE (MaPhanCong VARCHAR(15), TenNhanVien NVARCHAR(100), MaNhatKy VARCHAR(11), MaLichTrinh VARCHAR(10), NgayGio DATETIME, TrangThai NVARCHAR(50), Email VARCHAR(255), SDT VARCHAR(15));
    INSERT INTO @Result
    SELECT * FROM Vw_LichPhanCong;
    IF EXISTS (SELECT 1 FROM @Result WHERE MaPhanCong = 'PC999' AND TenNhanVien = N'Test NV' AND MaNhatKy = 'NK992')
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('Vw_LichPhanCong', 'PASS', 'View trả về lịch phân công đúng.');
    ELSE
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('Vw_LichPhanCong', 'FAIL', 'View không trả về lịch phân công đúng.');
    ROLLBACK;
END TRY
BEGIN CATCH
    INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('Vw_LichPhanCong', 'FAIL', 'Lỗi không mong đợi: ' + ERROR_MESSAGE());
    ROLLBACK;
END CATCH
GO

---- 12. Kiểm tra Vw_NhanVienDangHoatDong
--PRINT 'Kiểm tra Vw_NhanVienDangHoatDong:';
--BEGIN TRY
--    BEGIN TRANSACTION;
--    INSERT INTO NhanVien (MaNhanVien, TenNhanVien, Email, SDT, NamSinh, HeSoLuong) 
--    VALUES ('NV998', N'Test NV', 'nv2@example.com', '0999999998', 1990, 5.5);
--    INSERT INTO TaiKhoanNhanVien (MaTaiKhoan, Email, MatKhau, DaXoa) 
--    VALUES ('TKNV998', 'nv2@example.com', 'pass123', 0);
--    DECLARE @Result TABLE (MaNhanVien VARCHAR(10), TenNhanVien NVARCHAR(100), Email VARCHAR(255), SDT VARCHAR(15), NamSinh INT, HeSoLuong DECIMAL(10,2));
--    INSERT INTO @Result
--    SELECT * FROM Vw_NhanVienDangHoatDong;
--    IF EXISTS (SELECT 1 FROM @Result WHERE MaNhanVien = 'NV998' AND Email = 'nv2@example.com' AND DaXoa = 0)
--        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('Vw_NhanVienDangHoatDong', 'PASS', 'View trả về danh sách nhân viên đang hoạt động đúng.');
--    ELSE
--        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('Vw_NhanVienDangHoatDong', 'FAIL', 'View không trả về danh sách nhân viên đúng.');
--    ROLLBACK;
--END TRY
--BEGIN CATCH
--    INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('Vw_NhanVienDangHoatDong', 'FAIL', 'Lỗi không mong đợi: ' + ERROR_MESSAGE());
--    ROLLBACK;
--END CATCH
--GO

-- 13. Kiểm tra Vw_DoanhThuTheoNgay
PRINT 'Kiểm tra Vw_DoanhThuTheoNgay:';
BEGIN TRY
    BEGIN TRANSACTION;
    INSERT INTO KhachHang (MaKhach, TenKhach, NamSinh, Email, SDT, CCCD, DiaChi) 
    VALUES ('KH992', N'Test', '1990-01-01', NULL, '0999999992', NULL, NULL);
    INSERT INTO HoaDon (MaHoaDon, MaKhach, ThanhTien, ThoiGianLapHoaDon) 
    VALUES ('HD992', 'KH992', 500000, '2025-06-11 10:00:00');
    DECLARE @Result TABLE (Ngay DATE, DoanhThu DECIMAL(19,2));
    INSERT INTO @Result
    SELECT * FROM Vw_DoanhThuTheoNgay;
    IF EXISTS (SELECT 1 FROM @Result WHERE Ngay = '2025-06-11' AND DoanhThu = 500000)
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('Vw_DoanhThuTheoNgay', 'PASS', 'View trả về doanh thu theo ngày đúng.');
    ELSE
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('Vw_DoanhThuTheoNgay', 'FAIL', 'View không trả về doanh thu theo ngày đúng.');
    ROLLBACK;
END TRY
BEGIN CATCH
    INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('Vw_DoanhThuTheoNgay', 'FAIL', 'Lỗi không mong đợi: ' + ERROR_MESSAGE());
    ROLLBACK;
END CATCH
GO

-- 14. Kiểm tra vw_ThongTinVeDaBan
PRINT 'Kiểm tra vw_ThongTinVeDaBan:';
BEGIN TRY
    BEGIN TRANSACTION;
    INSERT INTO Tau (MaTau, TenTau, DaXoa) VALUES ('TA999', N'Tàu Test', 0);
    INSERT INTO LichTrinhTau (MaLichTrinh, TenLichTrinh, TrangThai) VALUES ('LT991', N'Lịch trình Test', N'Đang hoạt động');
    INSERT INTO NhatKyTau (MaNhatKy, MaTau, MaLichTrinh, NgayGio, TrangThai) 
    VALUES ('NK991', 'TA999', 'LT991', '2025-06-12', N'Chưa hoàn thành');
    INSERT INTO Ga (MaGa, TenGa) VALUES ('GA991', N'Ga A'), ('GB991', N'Ga B');
    INSERT INTO ChiTietLichTrinh (MaChiTiet, MaLichTrinh, MaGa, Stt_Ga) 
    VALUES ('CT991-1', 'LT991', 'GA991', 1), ('CT991-2', 'LT991', 'GB991', 2);
    INSERT INTO KhachHang (MaKhach, TenKhach, NamSinh, Email, SDT, CCCD, DiaChi) 
    VALUES ('KH991', N'Test', '1990-01-01', NULL, '0999999991', NULL, NULL);
    INSERT INTO HoaDon (MaHoaDon, MaKhach, ThanhTien, ThoiGianLapHoaDon) 
    VALUES ('HD991', 'KH991', 200000, '2025-06-11');
    INSERT INTO Ve (MaVe, MaNhatKy, MaHoaDon, GiaVe, MaKhoang, Stt_Ghe, DiemDi, DiemDen, DaThuHoi) 
    VALUES ('VE991', 'NK991', 'HD991', 200000, 'K1', 1, 'CT991-1', 'CT991-2', 0);
    DECLARE @Result TABLE (MaVe VARCHAR(15), MaNhatKy VARCHAR(11), TenTau NVARCHAR(100), TenLichTrinh NVARCHAR(100), GiaVe DECIMAL(19,2), DiemDi VARCHAR(10), DiemDen VARCHAR(10), DaThuHoi BIT);
    INSERT INTO @Result
    SELECT * FROM vw_ThongTinVeDaBan;
    IF EXISTS (SELECT 1 FROM @Result WHERE MaVe = 'VE991' AND TenTau = N'Tàu Test' AND DiemDi = 'GA991' AND DiemDen = 'GB991')
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('vw_ThongTinVeDaBan', 'PASS', 'View trả về thông tin vé đã bán đúng.');
    ELSE
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('vw_ThongTinVeDaBan', 'FAIL', 'View không trả về thông tin vé đã bán đúng.');
    ROLLBACK;
END TRY
BEGIN CATCH
    INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('vw_ThongTinVeDaBan', 'FAIL', 'Lỗi không mong đợi: ' + ERROR_MESSAGE());
    ROLLBACK;
END CATCH
GO

-- 15. Kiểm tra Top3KhachHang
PRINT 'Kiểm tra Top3KhachHang:';
BEGIN TRY
    BEGIN TRANSACTION;
    INSERT INTO KhachHang (MaKhach, TenKhach, NamSinh, Email, SDT, CCCD, DiaChi) 
    VALUES ('KH990', N'Test Khách', '1990-01-01', NULL, '0999999990', NULL, NULL);
    INSERT INTO HoaDon (MaHoaDon, MaKhach, ThanhTien, ThoiGianLapHoaDon) 
    VALUES ('HD990', 'KH990', 300000, '2025-06-01');
    INSERT INTO LichTrinhTau (MaLichTrinh, TrangThai) VALUES ('LT990', N'Đang hoạt động');
    INSERT INTO NhatKyTau (MaNhatKy, MaTau, MaLichTrinh, NgayGio, TrangThai) 
    VALUES ('NK990', 'TA1', 'LT990', '2025-06-01', N'Hoàn thành');
    INSERT INTO Ve (MaVe, MaNhatKy, MaHoaDon, GiaVe, MaKhoang, Stt_Ghe, DiemDi, DiemDen, DaThuHoi) 
    VALUES ('VE990', 'NK990', 'HD990', 300000, 'K1', 1, 'CT1', 'CT2', 0);
    DECLARE @Result TABLE (MaKhach VARCHAR(10), TenKhach NVARCHAR(100), SoChuyenDi INT, TongTienMua DECIMAL(19,2));
    INSERT INTO @Result
    SELECT * FROM Top3KhachHang;
    IF EXISTS (SELECT 1 FROM @Result WHERE MaKhach = 'KH990' AND SoChuyenDi = 1 AND TongTienMua = 300000)
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('Top3KhachHang', 'PASS', 'View trả về danh sách khách hàng đúng.');
    ELSE
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('Top3KhachHang', 'FAIL', 'View không trả về danh sách khách hàng đúng.');
    ROLLBACK;
END TRY
BEGIN CATCH
    INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('Top3KhachHang', 'FAIL', 'Lỗi không mong đợi: ' + ERROR_MESSAGE());
    ROLLBACK;
END CATCH
GO

-- 16. Kiểm tra Vw_BaoCaoDoanhThuTheoNgay
PRINT 'Kiểm tra Vw_BaoCaoDoanhThuTheoNgay:';
BEGIN TRY
    BEGIN TRANSACTION;
    INSERT INTO ChucVu (MaChucVu, TenChucVu) VALUES ('CV1', 'Nhân viên bán vé');
    INSERT INTO NhanVien (MaNhanVien, TenNhanVien, MaChucVu, Email, SDT) 
    VALUES ('NV990', N'Test NV', 'CV1', 'nv4@example.com', '0999999997');
    INSERT INTO KhachHang (MaKhach, TenKhach, NamSinh, Email, SDT, CCCD, DiaChi) 
    VALUES ('KH989', N'Test Khách', '1990-01-01', NULL, '0999999989', NULL, NULL);
    INSERT INTO HoaDon (MaHoaDon, MaKhach, ThanhTien, ThoiGianLapHoaDon) 
    VALUES ('HD989', 'KH989', 600000, '2025-07-11');
    INSERT INTO LichTrinhTau (MaLichTrinh, TrangThai) VALUES ('LT989', N'Đang hoạt động');
    INSERT INTO NhatKyTau (MaNhatKy, MaTau, MaLichTrinh, NgayGio, TrangThai) 
    VALUES ('NK989', 'TA999', 'LT989', '2025-07-11', N'Chưa hoàn thành');
    INSERT INTO PhanCong (MaPhanCong, MaNhanVien, MaNhatKy) VALUES ('PC989', 'NV990', 'NK989');
    INSERT INTO Ve (MaVe, MaNhatKy, MaHoaDon, GiaVe, MaKhoang, Stt_Ghe, DiemDi, DiemDen, DaThuHoi) 
    VALUES ('VE989', 'NK989', 'HD989', 600000, 'K1', 1, 'CT1', 'CT2', 0);
    INSERT INTO LichSuDoiTraVe (MaVe, HanhDong, ThoiGian, LePhi) 
    VALUES ('VE989', 'Trả', '2025-07-11', 5000);
    DECLARE @Result TABLE (NgayLapHoaDon DATE, SoLuongVeBanRa INT, DoanhThu DECIMAL(19,2), MaHoaDon VARCHAR(10), MaNhatKy VARCHAR(11), NgayGio DATETIME, MaNhanVien VARCHAR(10), TenNhanVien NVARCHAR(100), TenChucVu NVARCHAR(100));
    INSERT INTO @Result
    SELECT * FROM Vw_BaoCaoDoanhThuTheoNgay;
    IF EXISTS (SELECT 1 FROM @Result WHERE NgayLapHoaDon = '2025-07-11' AND SoLuongVeBanRa = 1 AND DoanhThu = 605000 AND MaNhanVien = 'NV990')
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('Vw_BaoCaoDoanhThuTheoNgay', 'PASS', 'View trả về báo cáo doanh thu theo ngày đúng.');
    ELSE
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('Vw_BaoCaoDoanhThuTheoNgay', 'FAIL', 'View không trả về báo cáo doanh thu theo ngày đúng.');
    ROLLBACK;
END TRY
BEGIN CATCH
    INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('Vw_BaoCaoDoanhThuTheoNgay', 'FAIL', 'Lỗi không mong đợi: ' + ERROR_MESSAGE());
    ROLLBACK;
END CATCH
GO

-- In kết quả kiểm tra
PRINT '===== KẾT QUẢ KIỂM TRA VIEW =====';
SELECT 
    TestID,
    TestName,
    Result,
    Reason
FROM #TestResults
ORDER BY TestID;

-- Dọn dẹp bảng tạm
DROP TABLE #TestResults;
GO