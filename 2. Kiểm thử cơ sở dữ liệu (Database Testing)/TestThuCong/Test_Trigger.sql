-- File: Test_Triggers.sql
-- Mục đích: Kiểm tra tự động các trigger trong cơ sở dữ liệu với PASS/FAIL và cleanup
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

-- 1. Kiểm tra Trigger_Insert_TRAVE_VE
PRINT 'Kiểm tra Trigger_Insert_TRAVE_VE:';
BEGIN TRY
    BEGIN TRANSACTION;
    INSERT INTO LICHSUDOITRAVE (MaVe, HanhDong, Thoigian, LePhi)
    VALUES ('VE0111241', N'Trả', '2025-06-11', 100000);
    IF EXISTS (SELECT 1 FROM VE WHERE MaVe = 'VE0111241' AND DaThuHoi = 1)
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('Trigger_Insert_TRAVE_VE', 'PASS', 'Trigger cập nhật DaThuHoi = 1 đúng.');
    ELSE
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('Trigger_Insert_TRAVE_VE', 'FAIL', 'Trigger không cập nhật DaThuHoi = 1.');
    ROLLBACK;
END TRY
BEGIN CATCH
    INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('Trigger_Insert_TRAVE_VE', 'FAIL', 'Lỗi không mong đợi: ' + ERROR_MESSAGE());
    ROLLBACK;
END CATCH
GO

-- 2. Kiểm tra trg_ThemTau
PRINT 'Kiểm tra trg_ThemTau:';
BEGIN TRY
    BEGIN TRANSACTION;
    INSERT INTO Tau (TenTau, DaXoa) VALUES (N'Tàu Test', 0);
    DECLARE @NewMaTau VARCHAR(10);
    SELECT @NewMaTau = MaTau FROM Tau WHERE TenTau = N'Tàu Test';
    IF @NewMaTau LIKE 'TA[0-9][0-9]'
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('trg_ThemTau', 'PASS', 'Trigger tạo MaTau đúng định dạng TAxx.');
    ELSE
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('trg_ThemTau', 'FAIL', 'Trigger không tạo MaTau đúng định dạng: ' + @NewMaTau);
    ROLLBACK;
END TRY
BEGIN CATCH
    INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('trg_ThemTau', 'FAIL', 'Lỗi không mong đợi: ' + ERROR_MESSAGE());
    ROLLBACK;
END CATCH
GO

-- 3. Kiểm tra trg_SetDaXoa_Tau
PRINT 'Kiểm tra trg_SetDaXoa_Tau (có lịch trình tương lai):';
BEGIN TRY
    BEGIN TRANSACTION;
    INSERT INTO Tau (MaTau, TenTau, DaXoa) VALUES ('TA99', N'Tàu Test', 0);
    INSERT INTO LichTrinhTau (MaLichTrinh, TrangThai) VALUES ('LT99', N'Đang hoạt động');
    INSERT INTO NhatKyTau (MaNhatKy, MaTau, MaLichTrinh, NgayGio, TrangThai) 
    VALUES ('NK99', 'TA99', 'LT99', DATEADD(DAY, 1, GETDATE()), N'Chưa hoàn thành');
    DELETE FROM Tau WHERE MaTau = 'TA99';
    INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('trg_SetDaXoa_Tau', 'FAIL', 'Trigger cho phép xóa tàu có lịch trình tương lai (không mong muốn).');
    ROLLBACK;
END TRY
BEGIN CATCH
    INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('trg_SetDaXoa_Tau', 'PASS', 'Trigger chặn xóa đúng: ' + ERROR_MESSAGE());
    ROLLBACK;
END CATCH
GO

-- 4. Kiểm tra trg_ThemToa
PRINT 'Kiểm tra trg_ThemToa:';
BEGIN TRY
    BEGIN TRANSACTION;
    INSERT INTO Tau (MaTau, TenTau, DaXoa) VALUES ('TA98', N'Tàu Test', 0);
    INSERT INTO Toa (MaTau, SoToa, MaLoaiToa) VALUES ('TA98', 1, 'LT1');
    DECLARE @NewMaToa VARCHAR(10);
    SELECT @NewMaToa = MaToa FROM Toa WHERE MaTau = 'TA98';
    IF @NewMaToa LIKE 'TO[0-9]%'
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('trg_ThemToa', 'PASS', 'Trigger tạo MaToa đúng định dạng TOx.');
    ELSE
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('trg_ThemToa', 'FAIL', 'Trigger không tạo MaToa đúng định dạng: ' + @NewMaToa);
    ROLLBACK;
END TRY
BEGIN CATCH
    INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('trg_ThemToa', 'FAIL', 'Lỗi không mong đợi: ' + ERROR_MESSAGE());
    ROLLBACK;
END CATCH
GO

-- 5. Kiểm tra trg_CheckLength_SDT_CCCD
PRINT 'Kiểm tra trg_CheckLength_SDT_CCCD (SDT sai độ dài):';
BEGIN TRY
    BEGIN TRANSACTION;
    INSERT INTO KhachHang (MaKhach, TenKhach, NamSinh, Email, SDT, CCCD, DiaChi)
    VALUES ('KH999', N'Test', '1990-01-01', 'test@example.com', '12345', '123456789012', N'Test Address');
    INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('trg_CheckLength_SDT_CCCD', 'FAIL', 'Trigger cho phép thêm SDT sai độ dài (không mong muốn).');
    ROLLBACK;
END TRY
BEGIN CATCH
    INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('trg_CheckLength_SDT_CCCD', 'PASS', 'Trigger chặn SDT sai độ dài đúng: ' + ERROR_MESSAGE());
    ROLLBACK;
END CATCH
GO

-- 6. Kiểm tra trg_KiemTraXoaToa
PRINT 'Kiểm tra trg_KiemTraXoaToa (có vé chưa sử dụng):';
BEGIN TRY
    BEGIN TRANSACTION;
    INSERT INTO Tau (MaTau, TenTau, DaXoa) VALUES ('TA97', N'Tàu Test', 0);
    INSERT INTO Toa (MaToa, MaTau, SoToa, MaLoaiToa) VALUES ('TO97', 'TA97', 1, 'LT1');
    INSERT INTO LichTrinhTau (MaLichTrinh, TrangThai) VALUES ('LT97', N'Đang hoạt động');
    INSERT INTO NhatKyTau (MaNhatKy, MaTau, MaLichTrinh, NgayGio, TrangThai) 
    VALUES ('NK97', 'TA97', 'LT97', DATEADD(DAY, 1, GETDATE()), N'Chưa hoàn thành');
    INSERT INTO Ve (MaVe, MaNhatKy, MaHoaDon, GiaVe, MaKhoang, Stt_Ghe, DiemDi, DiemDen, DaThuHoi)
    VALUES ('VE97', 'NK97', 'HD97', 100000, 'K1', 1, 'GA1', 'GA2', 0);
    DELETE FROM Toa WHERE MaToa = 'TO97';
    INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('trg_KiemTraXoaToa', 'FAIL', 'Trigger cho phép xóa toa có vé chưa sử dụng (không mong muốn).');
    ROLLBACK;
END TRY
BEGIN CATCH
    INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('trg_KiemTraXoaToa', 'PASS', 'Trigger chặn xóa toa đúng: ' + ERROR_MESSAGE());
    ROLLBACK;
END CATCH
GO

-- 7. Kiểm tra trg_ThemKhoang
PRINT 'Kiểm tra trg_ThemKhoang:';
BEGIN TRY
    BEGIN TRANSACTION;
    INSERT INTO Tau (MaTau, TenTau, DaXoa) VALUES ('TA96', N'Tàu Test', 0);
    INSERT INTO Toa (MaToa, MaTau, SoToa, MaLoaiToa) VALUES ('TO96', 'TA96', 1, 'LT1');
    INSERT INTO Khoang (MaToa, SoKhoang, SoChoNgoiToiDa) VALUES ('TO96', 1, 20);
    DECLARE @NewMaKhoang VARCHAR(10);
    SELECT @NewMaKhoang = MaKhoang FROM Khoang WHERE MaToa = 'TO96';
    IF @NewMaKhoang LIKE 'K[0-9]%'
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('trg_ThemKhoang', 'PASS', 'Trigger tạo MaKhoang đúng định dạng Kx.');
    ELSE
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('trg_ThemKhoang', 'FAIL', 'Trigger không tạo MaKhoang đúng định dạng: ' + @NewMaKhoang);
    ROLLBACK;
END TRY
BEGIN CATCH
    INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('trg_ThemKhoang', 'FAIL', 'Lỗi không mong đợi: ' + ERROR_MESSAGE());
    ROLLBACK;
END CATCH
GO

-- 8. Kiểm tra trg_KiemTraXoaKhoang
PRINT 'Kiểm tra trg_KiemTraXoaKhoang (có vé chưa sử dụng):';
BEGIN TRY
    BEGIN TRANSACTION;
    INSERT INTO Tau (MaTau, TenTau, DaXoa) VALUES ('TA95', N'Tàu Test', 0);
    INSERT INTO Toa (MaToa, MaTau, SoToa, MaLoaiToa) VALUES ('TO95', 'TA95', 1, 'LT1');
    INSERT INTO Khoang (MaKhoang, MaToa, SoKhoang, SoChoNgoiToiDa) VALUES ('K95', 'TO95', 1, 20);
    INSERT INTO LichTrinhTau (MaLichTrinh, TrangThai) VALUES ('LT95', N'Đang hoạt động');
    INSERT INTO NhatKyTau (MaNhatKy, MaTau, MaLichTrinh, NgayGio, TrangThai) 
    VALUES ('NK95', 'TA95', 'LT95', DATEADD(DAY, 1, GETDATE()), N'Chưa hoàn thành');
    INSERT INTO Ve (MaVe, MaNhatKy, MaHoaDon, GiaVe, MaKhoang, Stt_Ghe, DiemDi, DiemDen, DaThuHoi)
    VALUES ('VE95', 'NK95', 'HD95', 100000, 'K95', 1, 'GA1', 'GA2', 0);
    DELETE FROM Khoang WHERE MaKhoang = 'K95';
    INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('trg_KiemTraXoaKhoang', 'FAIL', 'Trigger cho phép xóa khoang có vé chưa sử dụng (không mong muốn).');
    ROLLBACK;
END TRY
BEGIN CATCH
    INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('trg_KiemTraXoaKhoang', 'PASS', 'Trigger chặn xóa khoang đúng: ' + ERROR_MESSAGE());
    ROLLBACK;
END CATCH
GO

-- 9. Kiểm tra trg_CapNhatTrangThaiLichTrinh
PRINT 'Kiểm tra trg_CapNhatTrangThaiLichTrinh (cập nhật trạng thái không hợp lệ):';
BEGIN TRY
    BEGIN TRANSACTION;
    INSERT INTO LichTrinhTau (MaLichTrinh, TrangThai) VALUES ('LT94', N'Đang hoạt động');
    INSERT INTO NhatKyTau (MaNhatKy, MaTau, MaLichTrinh, NgayGio, TrangThai) 
    VALUES ('NK94', 'TA1', 'LT94', DATEADD(DAY, 1, GETDATE()), N'Chưa hoàn thành');
    UPDATE LichTrinhTau SET TrangThai = N'Hủy' WHERE MaLichTrinh = 'LT94';
    INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('trg_CapNhatTrangThaiLichTrinh', 'FAIL', 'Trigger cho phép cập nhật trạng thái khi có nhật ký tương lai (không mong muốn).');
    ROLLBACK;
END TRY
BEGIN CATCH
    INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('trg_CapNhatTrangThaiLichTrinh', 'PASS', 'Trigger chặn cập nhật trạng thái đúng: ' + ERROR_MESSAGE());
    ROLLBACK;
END CATCH
GO

-- 10. Kiểm tra trg_ThemChiTietLichTrinh
PRINT 'Kiểm tra trg_ThemChiTietLichTrinh (Stt_Ga trùng lặp):';
BEGIN TRY
    BEGIN TRANSACTION;
    INSERT INTO LichTrinhTau (MaLichTrinh, TrangThai) VALUES ('LT93', N'Đang hoạt động');
    INSERT INTO NhatKyTau (MaNhatKy, MaTau, MaLichTrinh, NgayGio, TrangThai) 
    VALUES ('NK93', 'TA1', 'LT93', DATEADD(DAY, 1, GETDATE()), N'Chưa hoàn thành');
    INSERT INTO ChiTietLichTrinh (MaLichTrinh, MaGa, Stt_Ga, ThoiGianDiChuyenTuTramTruoc, KhoangCachTuTramTruoc)
    VALUES ('LT93', 'GA1', 1, '00:30:00', 50);
    INSERT INTO ChiTietLichTrinh (MaLichTrinh, MaGa, Stt_Ga, ThoiGianDiChuyenTuTramTruoc, KhoangCachTuTramTruoc)
    VALUES ('LT93', 'GA2', 1, '00:30:00', 50);
    INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('trg_ThemChiTietLichTrinh', 'FAIL', 'Trigger cho phép thêm Stt_Ga trùng lặp (không mong muốn).');
    ROLLBACK;
END TRY
BEGIN CATCH
    INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('trg_ThemChiTietLichTrinh', 'PASS', 'Trigger chặn Stt_Ga trùng lặp đúng: ' + ERROR_MESSAGE());
    ROLLBACK;
END CATCH
GO

-- 11. Kiểm tra trg_CheckTimeAndFutureDate
PRINT 'Kiểm tra trg_CheckTimeAndFutureDate (thời gian dưới 20 phút):';
BEGIN TRY
    BEGIN TRANSACTION;
    INSERT INTO LichTrinhTau (MaLichTrinh, TrangThai) VALUES ('LT92', N'Đang hoạt động');
    INSERT INTO NhatKyTau (MaNhatKy, MaTau, MaLichTrinh, NgayGio, TrangThai) 
    VALUES ('NK92', 'TA1', 'LT92', DATEADD(MINUTE, 10, GETDATE()), N'Chưa hoàn thành');
    INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('trg_CheckTimeAndFutureDate', 'FAIL', 'Trigger cho phép thêm nhật ký với thời gian không hợp lệ (không mong muốn).');
    ROLLBACK;
END TRY
BEGIN CATCH
    INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('trg_CheckTimeAndFutureDate', 'PASS', 'Trigger chặn thời gian không hợp lệ đúng: ' + ERROR_MESSAGE());
    ROLLBACK;
END CATCH
GO

-- 12. Kiểm tra trg_InsertPhanCong
PRINT 'Kiểm tra trg_InsertPhanCong:';
BEGIN TRY
    BEGIN TRANSACTION;
    INSERT INTO NhanVien (MaNhanVien, TenNhanVien) VALUES ('NV1', N'Test NV');
    INSERT INTO LichTrinhTau (MaLichTrinh, TrangThai) VALUES ('LT91', N'Đang hoạt động');
    INSERT INTO NhatKyTau (MaNhatKy, MaTau, MaLichTrinh, NgayGio, TrangThai) 
    VALUES ('NK91', 'TA1', 'LT91', DATEADD(DAY, 1, GETDATE()), N'Chưa hoàn thành');
    INSERT INTO PhanCong (MaNhanVien, MaNhatKy) VALUES ('NV1', 'NK91');
    DECLARE @NewMaPhanCong VARCHAR(15);
    SELECT @NewMaPhanCong = MaPhanCong FROM PhanCong WHERE MaNhanVien = 'NV1' AND MaNhatKy = 'NK91';
    IF @NewMaPhanCong LIKE 'PC[0-9]%'
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('trg_InsertPhanCong', 'PASS', 'Trigger tạo MaPhanCong đúng định dạng PCx.');
    ELSE
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('trg_InsertPhanCong', 'FAIL', 'Trigger không tạo MaPhanCong đúng định dạng: ' + @NewMaPhanCong);
    ROLLBACK;
END TRY
BEGIN CATCH
    INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('trg_InsertPhanCong', 'FAIL', 'Lỗi không mong đợi: ' + ERROR_MESSAGE());
    ROLLBACK;
END CATCH
GO

-- 13. Kiểm tra trg_KiemTraTruocKhiXoaPhanCong
PRINT 'Kiểm tra trg_KiemTraTruocKhiXoaPhanCong (phân công gần giờ khởi hành):';
BEGIN TRY
    BEGIN TRANSACTION;
    INSERT INTO NhanVien (MaNhanVien, TenNhanVien) VALUES ('NV2', N'Test NV');
    INSERT INTO LichTrinhTau (MaLichTrinh, TrangThai) VALUES ('LT90', N'Đang hoạt động');
    INSERT INTO NhatKyTau (MaNhatKy, MaTau, MaLichTrinh, NgayGio, TrangThai) 
    VALUES ('NK90', 'TA1', 'LT90', DATEADD(MINUTE, 5, GETDATE()), N'Chưa hoàn thành');
    INSERT INTO PhanCong (MaPhanCong, MaNhanVien, MaNhatKy) VALUES ('PC90', 'NV2', 'NK90');
    DELETE FROM PhanCong WHERE MaPhanCong = 'PC90';
    INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('trg_KiemTraTruocKhiXoaPhanCong', 'FAIL', 'Trigger cho phép xóa phân công gần giờ khởi hành (không mong muốn).');
    ROLLBACK;
END TRY
BEGIN CATCH
    INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('trg_KiemTraTruocKhiXoaPhanCong', 'PASS', 'Trigger chặn xóa phân công đúng: ' + ERROR_MESSAGE());
    ROLLBACK;
END CATCH
GO

-- 14. Kiểm tra trg_KiemTraCapNhatNhatKy
PRINT 'Kiểm tra trg_KiemTraCapNhatNhatKy (cập nhật trạng thái Hủy khi có vé):';
BEGIN TRY
    BEGIN TRANSACTION;
    INSERT INTO LichTrinhTau (MaLichTrinh, TrangThai) VALUES ('LT89', N'Đang hoạt động');
    INSERT INTO NhatKyTau (MaNhatKy, MaTau, MaLichTrinh, NgayGio, TrangThai) 
    VALUES ('NK89', 'TA1', 'LT89', DATEADD(DAY, 2, GETDATE()), N'Chưa hoàn thành');
    INSERT INTO Ve (MaVe, MaNhatKy, MaHoaDon, GiaVe, MaKhoang, Stt_Ghe, DiemDi, DiemDen, DaThuHoi)
    VALUES ('VE89', 'NK89', 'HD89', 100000, 'K1', 1, 'GA1', 'GA2', 0);
    UPDATE NhatKyTau SET TrangThai = N'Hủy' WHERE MaNhatKy = 'NK89';
    INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('trg_KiemTraCapNhatNhatKy', 'FAIL', 'Trigger cho phép cập nhật trạng thái Hủy khi có vé (không mong muốn).');
    ROLLBACK;
END TRY
BEGIN CATCH
    INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('trg_KiemTraCapNhatNhatKy', 'PASS', 'Trigger chặn cập nhật trạng thái đúng: ' + ERROR_MESSAGE());
    ROLLBACK;
END CATCH
GO

---- 15. Kiểm tra trg_SetDaXoa_TaiKhoanNhanVien
--PRINT 'Kiểm tra trg_SetDaXoa_TaiKhoanNhanVien (nhân viên có phân công):';
--BEGIN TRY
--    BEGIN TRANSACTION;
--    INSERT INTO NhanVien (MaNhanVien, TenNhanVien) VALUES ('NV3', N'Test NV');
--    INSERT INTO TaiKhoanNhanVien (Email, MaNhanVien, MatKhau, DaXoa) VALUES ('nv3@example.com', 'NV3', 'pass123', 0);
--    INSERT INTO LichTrinhTau (MaLichTrinh, TrangThai) VALUES ('LT88', N'Đang hoạt động');
--    INSERT INTO NhatKyTau (MaNhatKy, MaTau, MaLichTrinh, NgayGio, TrangThai) 
--    VALUES ('NK88', 'TA1', 'LT88', DATEADD(DAY, 1, GETDATE()), N'Chưa hoàn thành');
--    INSERT INTO PhanCong (MaPhanCong, MaNhanVien, MaNhatKy) VALUES ('PC88', 'NV3', 'NK88');
--    DELETE FROM TaiKhoanNhanVien WHERE Email = 'nv3@example.com';
--    INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('trg_SetDaXoa_TaiKhoanNhanVien', 'FAIL', 'Trigger cho phép xóa tài khoản có phân công (không mong muốn).');
--    ROLLBACK;
--END TRY
--BEGIN CATCH
--    INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('trg_SetDaXoa_TaiKhoanNhanVien', 'PASS', 'Trigger chặn xóa tài khoản đúng: ' + ERROR_MESSAGE());
--    ROLLBACK;
--END CATCH
--GO

-- 16. Kiểm tra trg_TuDongSetTrangThaiSauKhiThem
PRINT 'Kiểm tra trg_TuDongSetTrangThaiSauKhiThem:';
BEGIN TRY
    BEGIN TRANSACTION;
    INSERT INTO HoaDon (MaHoaDon, MaKhach, ThanhTien, ThoiGianLapHoaDon) 
    VALUES ('HD87', 'KH03241', 100000, '2025-06-11');
    INSERT INTO PhanHoi (MaHoaDon, NoiDung, NgayPhanHoi, SoSao) 
    VALUES ('HD87', N'Test phản hồi', '2025-06-11', 5);
    IF EXISTS (SELECT 1 FROM PhanHoi WHERE MaHoaDon = 'HD87' AND TrangThai = N'Đã xử lý')
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('trg_TuDongSetTrangThaiSauKhiThem', 'PASS', 'Trigger cập nhật TrangThai = Đã xử lý đúng.');
    ELSE
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('trg_TuDongSetTrangThaiSauKhiThem', 'FAIL', 'Trigger không cập nhật TrangThai = Đã xử lý.');
    ROLLBACK;
END TRY
BEGIN CATCH
    INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('trg_TuDongSetTrangThaiSauKhiThem', 'FAIL', 'Lỗi không mong đợi: ' + ERROR_MESSAGE());
    ROLLBACK;
END CATCH
GO

-- 17. Kiểm tra trg_Them_HanhLy
PRINT 'Kiểm tra trg_Them_HanhLy:';
BEGIN TRY
    BEGIN TRANSACTION;
    INSERT INTO LichTrinhTau (MaLichTrinh, TrangThai) VALUES ('LT86', N'Đang hoạt động');
    INSERT INTO NhatKyTau (MaNhatKy, MaTau, MaLichTrinh, NgayGio, TrangThai) 
    VALUES ('NK86', 'TA1', 'LT86', DATEADD(DAY, 1, GETDATE()), N'Chưa hoàn thành');
    INSERT INTO Ve (MaVe, MaNhatKy, MaHoaDon, GiaVe, MaKhoang, Stt_Ghe, DiemDi, DiemDen, DaThuHoi)
    VALUES ('VE86', 'NK86', 'HD86', 100000, 'K1', 1, 'GA1', 'GA2', 0);
    INSERT INTO HanhLy (MaVe, KhoiLuong) VALUES ('VE86', 5.0);
    DECLARE @NewMaHanhLy VARCHAR(20);
    SELECT @NewMaHanhLy = MaHanhLy FROM HanhLy WHERE MaVe = 'VE86';
    IF @NewMaHanhLy LIKE 'HL[0-9]%'
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('trg_Them_HanhLy', 'PASS', 'Trigger tạo MaHanhLy đúng định dạng HLx.');
    ELSE
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('trg_Them_HanhLy', 'FAIL', 'Trigger không tạo MaHanhLy đúng định dạng: ' + @NewMaHanhLy);
    ROLLBACK;
END TRY
BEGIN CATCH
    INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('trg_Them_HanhLy', 'FAIL', 'Lỗi không mong đợi: ' + ERROR_MESSAGE());
    ROLLBACK;
END CATCH
GO

-- 18. Kiểm tra trg_InsertKhuyenMai
PRINT 'Kiểm tra trg_InsertKhuyenMai:';
BEGIN TRY
    BEGIN TRANSACTION;
    INSERT INTO KhuyenMai (TenKhuyenMai, SoTienGiamToiDa, PhanTramGiam, NgayBatDau, NgayKetThuc, SoLuong, SoLuongConLai)
    VALUES (N'Khuyến mãi Test', 50000, 10.0, '2025-06-01', '2025-06-30', 100, 100);
    DECLARE @NewMaKhuyenMai VARCHAR(10);
    SELECT @NewMaKhuyenMai = MaKhuyenMai FROM KhuyenMai WHERE TenKhuyenMai = N'Khuyến mãi Test';
    IF @NewMaKhuyenMai LIKE 'KM[0-9]%'
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('trg_InsertKhuyenMai', 'PASS', 'Trigger tạo MaKhuyenMai đúng định dạng KMx.');
    ELSE
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('trg_InsertKhuyenMai', 'FAIL', 'Trigger không tạo MaKhuyenMai đúng định dạng: ' + @NewMaKhuyenMai);
    ROLLBACK;
END TRY
BEGIN CATCH
    INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('trg_InsertKhuyenMai', 'FAIL', 'Lỗi không mong đợi: ' + ERROR_MESSAGE());
    ROLLBACK;
END CATCH
GO

-- In kết quả kiểm tra
PRINT '===== KẾT QUẢ KIỂM TRA TRIGGER =====';
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