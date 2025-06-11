-- File: Test_StoredProcedures.sql
-- Mục đích: Kiểm tra tự động các stored procedure trong cơ sở dữ liệu với PASS/FAIL và cleanup
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

-- 1. Kiểm tra TAOHOADON
PRINT 'Kiểm tra TAOHOADON:';
BEGIN TRY
    BEGIN TRANSACTION;
    INSERT INTO KhachHang (MaKhach, TenKhach, NamSinh, Email, SDT, CCCD, DiaChi)
    VALUES ('KH999', N'Test Khách', '1990-01-01', 'test@example.com', '0999999999', '123456789012', N'Test Address');
    INSERT INTO KhuyenMai (MaKhuyenMai, TenKhuyenMai, SoTienGiamToiDa, PhanTramGiam, NgayBatDau, NgayKetThuc, SoLuong, SoLuongConLai)
    VALUES ('KM999', N'Test KM', 50000, 10.0, '2025-06-01', '2025-06-30', 100, 100);
    DECLARE @MaHoaDon VARCHAR(100);
    EXEC @MaHoaDon = TAOHOADON @Email = 'test@example.com', @MaKhuyenMai = 'KM999', @ThanhTien = 100000.00, @ThoiGian = '2025-06-11';
    IF EXISTS (SELECT 1 FROM HoaDon WHERE MaHoaDon = @MaHoaDon AND MaKhach = 'KH999' AND ThanhTien = 100000.00)
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('TAOHOADON', 'PASS', 'Tạo hóa đơn thành công với thông tin chính xác.');
    ELSE
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('TAOHOADON', 'FAIL', 'Hóa đơn không được tạo đúng.');
    ROLLBACK;
END TRY
BEGIN CATCH
    INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('TAOHOADON', 'FAIL', 'Lỗi không mong đợi: ' + ERROR_MESSAGE());
    ROLLBACK;
END CATCH
GO

-- 2. Kiểm tra TAOVE
PRINT 'Kiểm tra TAOVE:';
BEGIN TRY
    BEGIN TRANSACTION;
    INSERT INTO LichTrinhTau (MaLichTrinh, TrangThai) VALUES ('LT999', N'Đang hoạt động');
    INSERT INTO NhatKyTau (MaNhatKy, MaTau, MaLichTrinh, NgayGio, TrangThai) 
    VALUES ('NK999', 'TA1', 'LT999', '2025-06-12', N'Chưa hoàn thành');
    INSERT INTO Ga (MaGa, TenGa) VALUES ('GA999', N'Ga A'), ('GB999', N'Ga B');
    INSERT INTO ChiTietLichTrinh (MaChiTiet, MaLichTrinh, MaGa, Stt_Ga) 
    VALUES ('CT999-1', 'LT999', 'GA999', 1), ('CT999-2', 'LT999', 'GB999', 2);
    INSERT INTO HoaDon (MaHoaDon, MaKhach, ThanhTien, ThoiGianLapHoaDon) 
    VALUES ('HD999', 'KH999', NULL, '2025-10-11');
    INSERT INTO Khoang (MaKhoang, MaToa, SoKhoang, SoChoNgoiToiDa) VALUES ('K999', 'TO1', 1, 20);
    EXEC TAOVE @MaNhatKy = 'NK999', @MaHoaDon = 'HD999', @GiaVe = 500000, @MaKhoang = 'K999', @stt = 5, @DiemDi = N'Ga A', @DiemDen = N'Ga B';
    IF EXISTS (SELECT 1 FROM Ve WHERE MaNhatKy = 'NK999' AND MaHoaDon = 'HD999' AND GiaVe = 500000 AND MaKhoang = 'K999' AND Stt_Ghe = 5 AND DiemDi = 'CT999-1' AND DiemDen = 'CT999-2')
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('TAOVE', 'PASS', 'Tạo vé thành công với thông tin chính xác.');
    ELSE
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('TAOVE', 'FAIL', 'Vé không được tạo đúng.');
    ROLLBACK;
END TRY
BEGIN CATCH
    INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('TAOVE', 'FAIL', 'Lỗi không mong đợi: ' + ERROR_MESSAGE());
    ROLLBACK;
END CATCH
GO

-- 3. Kiểm tra TraVe
PRINT 'Kiểm tra TraVe:';
BEGIN TRY
    BEGIN TRANSACTION;
    INSERT INTO LichTrinhTau (MaLichTrinh, TrangThai) VALUES ('LT998', N'Đang hoạt động');
    INSERT INTO NhatKyTau (MaNhatKy, MaTau, MaLichTrinh, NgayGio, TrangThai) 
    VALUES ('NK998', 'TA1', 'LT998', DATEADD(DAY, 4, GETDATE()), N'Chưa hoàn thành');
    INSERT INTO HoaDon (MaHoaDon, MaKhach, ThanhTien, ThoiGianLapHoaDon) 
    VALUES ('HD998', 'KH999', NULL, '2025-06-11');
    INSERT INTO Ve (MaVe, MaNhatKy, MaHoaDon, GiaVe, MaKhoang, Stt_Ghe, DiemDi, DiemDen, DaThuHoi)
    VALUES ('VE998', 'NK998', 'HD998', 1000000, 'K1', 1, 'CT1', 'CT2', 0);
    EXEC TraVe @MaVe = 'VE998';
    IF EXISTS (SELECT 1 FROM LichSuDoiTraVe WHERE MaVe = 'VE998' AND EXISTS (SELECT 1 FROM Ve WHERE MaVe = 'VE998' AND DaThuHoi = 1))
        INSERT INTO #TestResults (TestName, Result, Result, Reason) VALUES ('TraVe', 'PASS', 'Trả vé thành công, cập nhật trạng thái và lịch sử đúng.');
    ELSE
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('TraVe', 'FAIL', 'Trả vé không được thực hiện đúng.');
    ROLLBACK;
END TRY
BEGIN CATCH
    INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('TraVe', 'FAIL', 'Lỗi không mong đợi: ' + ERROR_MESSAGE());
    ROLLBACK;
END CATCH
GO

-- 4. Kiểm tra ThemLichTrinh
PRINT 'Kiểm tra ThemLichTrinh:';
BEGIN TRY
    BEGIN TRANSACTION;
    EXEC ThemLichTrinh @TienTo = 'LT', @TenLichTrinh = N'Lịch trình Test';
    IF EXISTS (SELECT 1 FROM LichTrinhTau WHERE TenLichTrinh = N'Lịch trình Test' AND MaLichTrinh LIKE 'LT%')
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('ThemLichTrinh', 'PASS', 'Tạo lịch trình thành công với mã hợp lệ.');
    ELSE
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('ThemLichTrinh', 'FAIL', 'Lịch trình không được tạo đúng.');
    ROLLBACK;
END TRY
BEGIN CATCH
    INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('ThemLichTrinh', 'FAIL', 'Lỗi không mong đợi: ' + ERROR_MESSAGE());
    ROLLBACK;
END CATCH
GO

-- 5. Kiểm tra ThemNhanVien
PRINT 'Kiểm tra ThemNhanVien (tuổi hợp lệ):';
BEGIN TRY
    BEGIN TRANSACTION;
    INSERT INTO ChucVu (MaChucVu, TenChucVu) VALUES ('CV1', 'Nhân viên bán vé');
    EXEC ThemNhanVien @TenNhanVien = N'Test NV', @Email = 'nv@example.com', @SDT = '0999999999', @CCCD = '123456789012', @NamSinh = 1990, @VaiTro = 'BanHang', @ChucVu = 'Nhân viên bán vé', @MoTa = '', @Luong = 5.5, @DefaultPassword = 123456;
    IF EXISTS (SELECT 1 FROM NhanVien WHERE TenNhanVien = N'Test NV' AND Email = 'nv@example.com') 
 AND EXISTS (SELECT 1 FROM TaiKhoanNhanVien WHERE Email = 'nv@example.com')
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('ThemNhanVien', 'PASS', 'Thêm nhân viên thành công với thông tin hợp lệ.');
    ELSE
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('ThemNhanThemNhanvien', 'FAIL', 'Nhân viên hoặc tài khoản không được tạo đúng.');
    ROLLBACK;
END TRY
BEGIN CATCH
    INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('ThemNhanVien', 'FAIL', 'Lỗi không mong đợi: ' + ERROR_MESSAGE());
    ROLLBACK;
END CATCH
GO

-- 6. Kiểm tra ThemNhanVienChuaPhanCong
PRINT 'Kiểm tra LayNhanVienChuaPhanCong:';
BEGIN TRY
    BEGIN TRANSACTION;
    INSERT INTO NhanVien (MaNhanVien, TenNhanVien) VALUES ('NV999', N'Test NV');
    INSERT INTO LichTrinhTau (MaLichTrinh, TrangThai) VALUES ('LT997', N'Đang hoạt động');
    INSERT INTO NhatKyTau (MaNhatKy, MaTau, MaLichTrinh, NgayGio, TrangThai) 
    VALUES ('NK997', 'TA1', 'LT997', DATEADD(DAY, 2, GETDATE()), N'Chưa hoàn thành');
    INSERT INTO Ga (MaGa, TenGa) VALUES ('G1', 'Ga1'), ('G2', 'Ga2');
    INSERT INTO ChiTietLichTrinh (MaChiTiet, MaLichTrinh, MaGa, Stt_Ga) 
    VALUES ('CT997-1', 'LT997', 'G1', 1), ('CT997-2', 'LT997', 'G2', 2);
    
 DECLARE @Output TABLE (MaNhanVien VARCHAR(10));
    INSERT INTO @Output
    EXEC LayNhanVienChuaPhanCong @MaNhatKyChon = 'NK997';
    IF EXISTS (SELECT 1 FROM @Output WHERE MaNhanVien = 'NV999')
        INSERT INTO #TestResults (TestName, Result, Result, Reason) VALUES ('LayNhanVienChuaPhanCong', 'PASS', 'Lấy danh sách nhân viên chưa phân công thành công.');
    ELSE
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('LayNhanVienChuaPhanCong', 'FAIL', 'Không tìm thấy nhân viên chưa phân công.');
    ROLLBACK;
END TRY
BEGIN CATCH
    INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('LayNhanVienChuaPhanCong', 'FAIL', 'Lỗi không mong đợi: ' + ERROR_MESSAGE());
    ROLLBACK;
END CATCH
GO

-- 7. Kiểm tra spDoanhThuTheoTau
PRINT 'Kiểm tra spDoanhThuTheoTau:';
BEGIN TRY
    BEGIN TRANSACTION;
    INSERT INTO Tau (MaTau, TenTau, DaXoa) VALUES ('TA999', N'Tàu Test', 0);
    INSERT INTO LichTrinhTau (MaLichTrinh, TrangThai) VALUES ('LT996', N'Đang hoạt động');
    INSERT INTO NhatKyTau (MaNhatKy, MaTau, MaLichTrinh, NgayGio, TrangThai) 
    VALUES ('NK996', 'TA999', 'LT996', '2025-06-12', N'Chưa hoàn thành');
    INSERT INTO HoaDon (MaHoaDon, MaKhach, ThanhTien, ThoiGianLapHoaDon) 
    VALUES ('HD996', 'KH999', NULL, '2025-06-11');
    INSERT INTO Ve (MaVe, MaNhatKy, MaHoaDon, GiaVe, MaKhoang, Stt_Ghe, DiemDi, DiemDen, DaThuHoi)
    VALUES ('VE996', 'NK996', 'HD996', 500000, 'K1', 1, 'CT1', 'CT2', 0);
    DECLARE @DoanhThu TABLE (TenTau NVARCHAR(100), SoLuongVeBan INT, DoanhThu DECIMAL(19,2));
    INSERT INTO @DoanhThu
    EXEC spDoanhThuTheoTau;
    IF EXISTS (SELECT 1 FROM @DoanhThu WHERE TenTau = N'Tàu Test' AND SoLuongVeBan = 1 AND DoanhThu = 500000)
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('spDoanhThuTheoTau', 'PASS', 'Tính doanh thu theo tàu chính xác.');
    ELSE
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('spDoanhThuTheoTau', 'FAIL', 'Doanh thu theo tàu không chính xác.');
    ROLLBACK;
END TRY
BEGIN CATCH
    INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('spDoanhThuTheoTau', 'FAIL', 'Lỗi không mong đợi: ' + ERROR_MESSAGE());
    ROLLBACK;
END CATCH
GO

-- 8. Kiểm tra BaoCaoTheoNgay
PRINT 'Kiểm tra BaoCaoTheoNgay:';
BEGIN TRY
    BEGIN TRANSACTION;
    INSERT INTO NhanVien (MaNhanVien, TenNhanVien) VALUES ('NV998', N'Test NV');
    INSERT INTO LichTrinhTau (MaLichTrinh, TrangThai) VALUES ('LT995', N'Đang hoạt động');
    INSERT INTO NhatKyTau (MaNhatKy, MaTau, MaLichTrinh, NgayGio, TrangThai) 
    VALUES ('NK995', 'TA1', 'LT995', '2025-06-11', N'Chưa hoàn thành');
    INSERT INTO PhanCong (MaPhanCong, MaNhanVien, MaNhatKy) VALUES ('PC995', 'NV998', 'NK995');
    INSERT INTO HoaDon (MaHoaDon, MaKhach, ThanhTien, ThoiGianLapHoaDon) 
    VALUES ('HD995', 'KH999', NULL, '2025-06-11');
    INSERT INTO Ve (MaVe, MaNhatKy, MaHoaDon, GiaVe, MaKhoang, Stt_Ghe, DiemDi, DiemDen, DaThuHoi)
    VALUES ('VE995', 'NK995', 'HD995', 300000, 'K1', 1, 'CT1', 'CT2', 0);
    DECLARE @BaoCao TABLE (TenNhanVien NVARCHAR(100), MaPhanCong VARCHAR(15), MaNhatKy VARCHAR(11), NgayGio DATETIME, SoVeBanDuoc INT, TongDoanhThu DECIMAL(19,2));
    INSERT INTO @BaoCao
    EXEC BaoCaoTheoNgay @Ngay = '2025-06-11';
    IF EXISTS (SELECT 1 FROM @BaoCao WHERE TenNhanVien = N'Test NV' AND SoVeBanDuoc = 1 AND TongDoanhThu = 300000)
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('BaoCaoTheoNgay', 'PASS', 'Báo cáo theo ngày chính xác.');
    ELSE
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('BaoCaoTheoNgay', 'FAIL', 'Báo cáo theo ngày không chính xác.');
    ROLLBACK;
END TRY
BEGIN CATCH
    INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('BaoCaoTheoNgay', 'FAIL', 'Lỗi không mong đợi: ' + ERROR_MESSAGE());
    ROLLBACK;
END CATCH
GO

-- 9. Kiểm tra DangKy
PRINT 'Kiểm tra DangKy:';
BEGIN TRY
    BEGIN TRANSACTION;
    EXEC DangKy @TenKhach = N'Test Khách', @NamSinh = '1990-01-01', @Email = 'new@example.com', @SDT = '0999999998', @CCCD = '123456789013', @DiaChi = N'Test Address', @MatKhau = 'pass123';
    IF EXISTS (SELECT 1 FROM KhachHang WHERE Email = 'new@example.com' AND TenKhach = N'Test Khách') 
        AND EXISTS (SELECT 1 FROM TaiKhoan WHERE Email = 'new@example.com' AND MatKhau = 'pass123')
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('DangKy', 'PASS', 'Đăng ký khách hàng và tài khoản thành công.');
    ELSE
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('DangKy', 'FAIL', 'Khách hàng hoặc tài khoản không được tạo đúng.');
    ROLLBACK;
END TRY
BEGIN CATCH
    INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('DangKy', 'FAIL', 'Lỗi không mong đợi: ' + ERROR_MESSAGE());
    ROLLBACK;
END CATCH
GO

-- In kết quả kiểm tra
PRINT '===== KẾT QUẢ KIỂM TRA STORED PROCEDURE =====';
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