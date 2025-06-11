-- File: Test_Functions.sql
-- Mục đích: Kiểm tra tự động các function trong cơ sở dữ liệu với PASS/FAIL và cleanup
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

-- 1. Kiểm tra LayTenGa
PRINT 'Kiểm tra LayTenGa:';
BEGIN TRY
    BEGIN TRANSACTION;
    INSERT INTO Ga (MaGa, TenGa) VALUES ('GA999', N'Ga Test');
    INSERT INTO LichTrinhTau (MaLichTrinh, TrangThai) VALUES ('LT999', N'Đang hoạt động');
    INSERT INTO ChiTietLichTrinh (MaChiTiet, MaLichTrinh, MaGa, Stt_Ga) VALUES ('CT999', 'LT999', 'GA999', 1);
    DECLARE @TenGa NVARCHAR(100);
    SET @TenGa = dbo.LayTenGa('CT999');
    IF @TenGa = N'Ga Test'
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('LayTenGa', 'PASS', 'Hàm trả về tên ga đúng.');
    ELSE
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('LayTenGa', 'FAIL', 'Hàm trả về tên ga không đúng: ' + ISNULL(@TenGa, 'NULL'));
    ROLLBACK;
END TRY
BEGIN CATCH
    INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('LayTenGa', 'FAIL', 'Lỗi không mong đợi: ' + ERROR_MESSAGE());
    ROLLBACK;
END CATCH
GO

-- 2. Kiểm tra LaySoThuTuLonNhatTrongThang (Prefix = HD)
PRINT 'Kiểm tra LaySoThuTuLonNhatTrongThang (HD):';
BEGIN TRY
    BEGIN TRANSACTION;
    INSERT INTO KhachHang (MaKhach, TenKhach, NamSinh, Email, SDT, CCCD, DiaChi) 
    VALUES ('KH999', N'Test', '1990-01-01', 'test@example.com', '0999999999', '123456789012', N'Test');
    INSERT INTO HoaDon (MaHoaDon, MaKhach, ThanhTien, ThoiGianLapHoaDon) 
    VALUES ('HD010625001', 'KH999', 100000, '2025-06-01');
    DECLARE @SoThuTu INT;
    SET @SoThuTu = dbo.LaySoThuTuLonNhatTrongThang('2025-06-01', 'HD');
    IF @SoThuTu = 1
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('LaySoThuTuLonNhatTrongThang_HD', 'PASS', 'Hàm trả về số thứ tự lớn nhất đúng.');
    ELSE
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('LaySoThuTuLonNhatTrongThang_HD', 'FAIL', 'Hàm trả về số thứ tự không đúng: ' + CAST(@SoThuTu AS NVARCHAR));
    ROLLBACK;
END TRY
BEGIN CATCH
    INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('LaySoThuTuLonNhatTrongThang_HD', 'FAIL', 'Lỗi không mong đợi: ' + ERROR_MESSAGE());
    ROLLBACK;
END CATCH
GO

-- 3. Kiểm tra TaoMa (Prefix = VE)
PRINT 'Kiểm tra TaoMa (VE):';
BEGIN TRY
    BEGIN TRANSACTION;
    INSERT INTO LichTrinhTau (MaLichTrinh, TrangThai) VALUES ('LT998', N'Đang hoạt động');
    INSERT INTO NhatKyTau (MaNhatKy, MaTau, MaLichTrinh, NgayGio, TrangThai) 
    VALUES ('NK998', 'TA1', 'LT998', '2025-06-11', N'Chưa hoàn thành');
    INSERT INTO HoaDon (MaHoaDon, MaKhach, ThanhTien, ThoiGianLapHoaDon) 
    VALUES ('HD998', 'KH999', NULL, '2025-06-11');
    INSERT INTO Ve (MaVe, MaNhatKy, MaHoaDon, GiaVe, MaKhoang, Stt_Ghe, DiemDi, DiemDen, DaThuHoi) 
    VALUES ('VE110625001', 'NK998', 'HD998', 500000, 'K1', 1, 'CT1', 'CT2', 0);
    DECLARE @Ma NVARCHAR(19);
    SET @Ma = dbo.TaoMa('VE', '2025-06-11');
    IF @Ma LIKE 'VE110625002'
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('TaoMa_VE', 'PASS', 'Hàm tạo mã vé đúng định dạng.');
    ELSE
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('TaoMa_VE', 'FAIL', 'Hàm tạo mã vé không đúng: ' + @Ma);
    ROLLBACK;
END TRY
BEGIN CATCH
    INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('TaoMa_VE', 'FAIL', 'Lỗi không mong đợi: ' + ERROR_MESSAGE());
    ROLLBACK;
END CATCH
GO

-- 4. Kiểm tra LayLichTrinhTheoDiemDiDiemDen
PRINT 'Kiểm tra LayLichTrinhTheoDiemDiDiemDen:';
BEGIN TRY
    BEGIN TRANSACTION;
    INSERT INTO Ga (MaGa, TenGa) VALUES ('GA997', N'Ga A'), ('GB997', N'Ga B');
    INSERT INTO LichTrinhTau (MaLichTrinh, TrangThai) VALUES ('LT997', N'Đang hoạt động');
    INSERT INTO ChiTietLichTrinh (MaChiTiet, MaLichTrinh, MaGa, Stt_Ga) 
    VALUES ('CT997-1', 'LT997', 'GA997', 1), ('CT997-2', 'LT997', 'GB997', 2);
    DECLARE @Result TABLE (TenGaDi NVARCHAR(100), SttGaDi INT, MaLichTrinh VARCHAR(10), TenGaDen NVARCHAR(100), SttGaDen INT);
    INSERT INTO @Result
    SELECT * FROM dbo.LayLichTrinhTheoDiemDiDiemDen(N'Ga A', N'Ga B');
    IF EXISTS (SELECT 1 FROM @Result WHERE TenGaDi = N'Ga A' AND TenGaDen = N'Ga B' AND MaLichTrinh = 'LT997' AND SttGaDi = 1 AND SttGaDen = 2)
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('LayLichTrinhTheoDiemDiDiemDen', 'PASS', 'Hàm trả về lịch trình đúng.');
    ELSE
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('LayLichTrinhTheoDiemDiDiemDen', 'FAIL', 'Hàm không trả về lịch trình đúng.');
    ROLLBACK;
END TRY
BEGIN CATCH
    INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('LayLichTrinhTheoDiemDiDiemDen', 'FAIL', 'Lỗi không mong đợi: ' + ERROR_MESSAGE());
    ROLLBACK;
END CATCH
GO

-- 5. Kiểm tra SoLuongToiDaCuaTau
PRINT 'Kiểm tra SoLuongToiDaCuaTau:';
BEGIN TRY
    BEGIN TRANSACTION;
    INSERT INTO Tau (MaTau, TenTau, DaXoa) VALUES ('TA997', N'Tàu Test', 0);
    INSERT INTO Toa (MaToa, MaTau, SoToa, MaLoaiToa) VALUES ('TO997', 'TA997', 1, 'LT1');
    INSERT INTO Khoang (MaKhoang, MaToa, SoKhoang, SoChoNgoiToiDa) VALUES ('K997', 'TO997', 1, 20);
    DECLARE @SoLuong INT;
    SET @SoLuong = dbo.SoLuongToiDaCuaTau('TA997');
    IF @SoLuong = 20
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('SoLuongToiDaCuaTau', 'PASS', 'Hàm trả về số lượng chỗ đúng.');
    ELSE
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('SoLuongToiDaCuaTau', 'FAIL', 'Hàm trả về số lượng chỗ không đúng: ' + CAST(@SoLuong AS NVARCHAR));
    ROLLBACK;
END TRY
BEGIN CATCH
    INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('SoLuongToiDaCuaTau', 'FAIL', 'Lỗi không mong đợi: ' + ERROR_MESSAGE());
    ROLLBACK;
END CATCH
GO

-- 6. Kiểm tra TinhTongThoiGianDiChuyen
PRINT 'Kiểm tra TinhTongThoiGianDiChuyen:';
BEGIN TRY
    BEGIN TRANSACTION;
    INSERT INTO Ga (MaGa, TenGa) VALUES ('GA996', 'Ga A'), ('GB996', 'Ga B');
    INSERT INTO LichTrinhTau (MaLichTrinh, TrangThai) VALUES ('LT996', N'Đang hoạt động');
    INSERT INTO NhatKyTau (MaNhatKy, MaTau, MaLichTrinh, NgayGio, TrangThai) 
    VALUES ('NK996', 'TA1', 'LT996', '2025-06-11 08:00:00', N'Chưa hoàn thành');
    INSERT INTO ChiTietLichTrinh (MaChiTiet, MaLichTrinh, MaGa, Stt_Ga, ThoiGianDiChuyenTuTramTruoc) 
    VALUES ('CT996-1', 'LT996', 'GA996', 1, NULL), ('CT996-2', 'LT996', 'GB996', 2, '01:00:00');
    DECLARE @ThoiGianDen DATETIME;
    SET @ThoiGianDen = dbo.TinhTongThoiGianDiChuyen('NK996', '2025-06-11 08:00:00', 'GA996', 'GB996');
    IF @ThoiGianDen = '2025-06-11 09:15:00' -- 1 giờ di chuyển + 15 phút dừng
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('TinhTongThoiGianDiChuyen', 'PASS', 'Hàm tính thời gian đến đúng.');
    ELSE
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('TinhTongThoiGianDiChuyen', 'FAIL', 'Hàm tính thời gian đến không đúng: ' + CAST(@ThoiGianDen AS NVARCHAR));
    ROLLBACK;
END TRY
BEGIN CATCH
    INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('TinhTongThoiGianDiChuyen', 'FAIL', 'Lỗi không mong đợi: ' + ERROR_MESSAGE());
    ROLLBACK;
END CATCH
GO

-- 7. Kiểm tra LayTau
PRINT 'Kiểm tra LayTau:';
BEGIN TRY
    BEGIN TRANSACTION;
    INSERT INTO Ga (MaGa, TenGa) VALUES ('GA995', N'Ga A'), ('GB995', N'Ga B');
    INSERT INTO LichTrinhTau (MaLichTrinh, TrangThai) VALUES ('LT995', N'Đang hoạt động');
    INSERT INTO NhatKyTau (MaNhatKy, MaTau, MaLichTrinh, NgayGio, TrangThai) 
    VALUES ('NK995', 'TA995', 'LT995', '2025-06-11 08:00:00', N'Chưa hoàn thành');
    INSERT INTO ChiTietLichTrinh (MaChiTiet, MaLichTrinh, MaGa, Stt_Ga, ThoiGianDiChuyenTuTramTruoc) 
    VALUES ('CT995-1', 'LT995', 'GA995', 1, NULL), ('CT995-2', 'LT995', 'GB995', 2, '01:00:00');
    INSERT INTO Tau (MaTau, TenTau, DaXoa) VALUES ('TA995', N'Tàu Test', 0);
    INSERT INTO Toa (MaToa, MaTau, SoToa, MaLoaiToa) VALUES ('TO995', 'TA995', 1, 'LT1');
    INSERT INTO Khoang (MaKhoang, MaToa, SoKhoang, SoChoNgoiToiDa) VALUES ('K995', 'TO995', 1, 20);
    DECLARE @Result TABLE (MaTau NVARCHAR(100), MaNhatKy NVARCHAR(100), ThoiGianDi DATETIME, ThoiGianDen DATETIME, SLChoTrong INT);
    INSERT INTO @Result
    SELECT * FROM dbo.LayTau('2025-06-11', N'Ga A', N'Ga B');
    IF EXISTS (SELECT 1 FROM @Result WHERE MaTau = 'TA995' AND MaNhatKy = 'NK995' AND SLChoTrong = 20)
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('LayTau', 'PASS', 'Hàm trả về danh sách tàu đúng.');
    ELSE
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('LayTau', 'FAIL', 'Hàm không trả về danh sách tàu đúng.');
    ROLLBACK;
END TRY
BEGIN CATCH
    INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('LayTau', 'FAIL', 'Lỗi không mong đợi: ' + ERROR_MESSAGE());
    ROLLBACK;
END CATCH
GO

-- 8. Kiểm tra LAYTOA
PRINT 'Kiểm tra LAYTOA:';
BEGIN TRY
    BEGIN TRANSACTION;
    INSERT INTO Tau (MaTau, TenTau, DaXoa) VALUES ('TA994', N'Tàu Test', 0);
    INSERT INTO Toa (MaToa, MaTau, SoToa, MaLoaiToa) VALUES ('TO994', 'TA994', 1, 'LT1');
    DECLARE @Result TABLE (MaToa VARCHAR(10), MaTau VARCHAR(10), SoToa INT, MaLoaiToa VARCHAR(10));
    INSERT INTO @Result
    SELECT * FROM dbo.LAYTOA('TA994');
    IF EXISTS (SELECT 1 FROM @Result WHERE MaToa = 'TO994' AND MaTau = 'TA994' AND SoToa = 1)
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('LAYTOA', 'PASS', 'Hàm trả về danh sách toa đúng.');
    ELSE
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('LAYTOA', 'FAIL', 'Hàm không trả về danh sách toa đúng.');
    ROLLBACK;
END TRY
BEGIN CATCH
    INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('LAYTOA', 'FAIL', 'Lỗi không mong đợi: ' + ERROR_MESSAGE());
    ROLLBACK;
END CATCH
GO

-- 9. Kiểm tra GiaVe (phiên bản 1)
PRINT 'Kiểm tra GiaVe (phiên bản 1):';
BEGIN TRY
    BEGIN TRANSACTION;
    INSERT INTO LoaiToa (MaLoaiToa, TenLoaiToa, GiaMacDinh, CoDieuHoa) VALUES ('LT999', N'Loại Test', 100000, 1);
    DECLARE @GiaVe DECIMAL(10,2);
    SET @GiaVe = dbo.GiaVe('LT999');
    IF @GiaVe = 110000.00 -- 100000 + 10% điều hòa
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('GiaVe_v1', 'PASS', 'Hàm tính giá vé đúng.');
    ELSE
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('GiaVe_v1', 'FAIL', 'Hàm tính giá vé không đúng: ' + CAST(@GiaVe AS NVARCHAR));
    ROLLBACK;
END TRY
BEGIN CATCH
    INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('GiaVe_v1', 'FAIL', 'Lỗi không mong đợi: ' + ERROR_MESSAGE());
    ROLLBACK;
END CATCH
GO

-- 10. Kiểm tra LayKhuyenMai
PRINT 'Kiểm tra LayKhuyenMai:';
BEGIN TRY
    BEGIN TRANSACTION;
    INSERT INTO KhuyenMai (MaKhuyenMai, TenKhuyenMai, SoTienGiamToiDa, PhanTramGiam, NgayBatDau, NgayKetThuc, SoLuong, SoLuongConLai)
    VALUES ('KM998', N'Khuyến mãi Test', 50000, 10.0, '2025-06-01', '2025-06-30', 100, 50);
    DECLARE @Result TABLE (MaKhuyenMai VARCHAR(10), TenKhuyenMai NVARCHAR(100), SoTienGiamToiDa INT, PhanTramGiam FLOAT, NgayBatDau DATE, NgayKetThuc DATE, SoLuong INT, SoLuongConLai INT);
    INSERT INTO @Result
    SELECT * FROM dbo.LayKhuyenMai();
    IF EXISTS (SELECT 1 FROM @Result WHERE MaKhuyenMai = 'KM998' AND SoLuongConLai = 50)
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('LayKhuyenMai', 'PASS', 'Hàm trả về danh sách khuyến mãi đúng.');
    ELSE
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('LayKhuyenMai', 'FAIL', 'Hàm không trả về danh sách khuyến mãi đúng.');
    ROLLBACK;
END TRY
BEGIN CATCH
    INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('LayKhuyenMai', 'FAIL', 'Lỗi không mong đợi: ' + ERROR_MESSAGE());
    ROLLBACK;
END CATCH
GO

-- 11. Kiểm tra LaySttGaFromMaChiTiet
PRINT 'Kiểm tra LaySttGaFromMaChiTiet:';
BEGIN TRY
    BEGIN TRANSACTION;
    INSERT INTO LichTrinhTau (MaLichTrinh, TrangThai) VALUES ('LT996', N'Đang hoạt động');
    INSERT INTO ChiTietLichTrinh (MaChiTiet, MaLichTrinh, MaGa, Stt_Ga) VALUES ('CT996', 'LT996', 'GA1', 3);
    DECLARE @SttGa INT;
    SET @SttGa = dbo.LaySttGaFromMaChiTiet('CT996');
    IF @SttGa = 3
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('LaySttGaFromMaChiTiet', 'PASS', 'Hàm trả về số thứ tự ga đúng.');
    ELSE
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('LaySttGaFromMaChiTiet', 'FAIL', 'Hàm trả về số thứ tự ga không đúng: ' + CAST(@SttGa AS NVARCHAR));
    ROLLBACK;
END TRY
BEGIN CATCH
    INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('LaySttGaFromMaChiTiet', 'FAIL', 'Lỗi không mong đợi: ' + ERROR_MESSAGE());
    ROLLBACK;
END CATCH
GO

-- 12. Kiểm tra LayVeTheoGaDiDen
PRINT 'Kiểm tra LayVeTheoGaDiDen:';
BEGIN TRY
    BEGIN TRANSACTION;
    INSERT INTO Ga (MaGa, TenGa) VALUES ('GA994', N'Ga A'), ('GB994', N'Ga B');
    INSERT INTO LichTrinhTau(MaLichTrinh, TrangThai) VALUES ('LT994', N'Đang hoạt động');
    INSERT INTO NhatKyTau (MaNhatKy, MaTau, MaLichTrinh, NgayGio, TrangThai) 
    VALUES ('NK994', 'TA1', 'LT994', '2025-08-11', N'Chưa hoàn thành');
    INSERT INTO ChiTietLichTrinh (MaChiTiet, MaLichTrinh, MaGa, Stt_Ga) 
    VALUES ('CT994-1', 'LT994', 'GA994', 1), ('CT994-2', 'LT994', 'GB994', 2);
    INSERT INTO HoaDon (MaHoaDon, MaKhach, ThanhTien, ThoiGianLapHoaDon) 
    VALUES ('HD999', 'KH999', NULL, NULL);
    INSERT INTO Khoang (MaKhoang, MaToa, SoKhoang, SoChoNgoiToiDa) VALUES ('K994', 'TO1', 1, 20);
    INSERT INTO Ve (MaVe, MaNhatKy, MaHoaDon, GiaVe, MaKhoang, Stt_Ghe, DiemDi, DiemDen, DaThuHoi) 
    VALUES ('VE994', 'NK994', 'HD999', 50000, 'K994', 1, 'CT994-1', 'CT994-2', 0);
    DECLARE @Result TABLE (MaVe VARCHAR(15), SttVe INT, SttGaDi INT, SttGaDen INT, TenGaDi NVARCHAR(100), TenGaDen NVARCHAR(100));
    INSERT INTO @Result
    SELECT * FROM dbo.LayVeTheoGaDiDen('K994', 'NK994', N'Ga A', N'Ga B');
    IF EXISTS (SELECT 1 FROM @Result WHERE MaVe = 'VE994' AND SttGaDi = 1 AND SttGaDen = 2 AND TenGaDi = N'Ga A' AND TenGaDen = N'Ga B')
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('LayVeTheoGaDiDen', 'PASS', 'Hàm trả về danh sách vé đúng.');
    ELSE
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('LayVeTheoGaDiDen', 'FAIL', 'Hàm không trả về danh sách vé đúng.');
    ROLLBACK;
END TRY
BEGIN CATCH
    INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('LayVeTheoGaDiDen', 'FAIL', 'Lỗi không mong đợi: ' + ERROR_MESSAGE());
    ROLLBACK;
END CATCH
GO

-- 13. Kiểm tra SinhMaLichTrinh
PRINT 'Kiểm tra SinhMaLichTrinh:';
BEGIN TRY
    BEGIN TRANSACTION;
    INSERT INTO LichTrinhTau (MaLichTrinh, TrangThai) VALUES ('LT01', N'Đang hoạt động');
    DECLARE @MaLichTrinh VARCHAR(10);
    SET @MaLichTrinh = dbo.SinhMaLichTrinh('LT');
    IF @MaLichTrinh = 'LT02'
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('SinhMaLichTrinh', 'PASS', 'Hàm tạo mã lịch trình đúng.');
    ELSE
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('SinhMaLichTrinh', 'FAIL', 'Hàm tạo mã lịch trình không đúng: ' + @MaLichTrinh);
    ROLLBACK;
END TRY
BEGIN CATCH
    INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('SinhMaLichTrinh', 'FAIL', 'Lỗi không mong đợi: ' + ERROR_MESSAGE());
    ROLLBACK;
END CATCH
GO

-- 14. Kiểm tra KiemTraThoiGianDenCuaGa
PRINT 'Kiểm tra KiemTraThoiGianDenCuaGa:';
BEGIN TRY
    BEGIN TRANSACTION;
    INSERT INTO Ga (MaGa, TenGa) VALUES ('GA993', 'Ga A');
    INSERT INTO LichTrinhTau (MaLichTrinh, TrangThai) VALUES ('LT993', N'Đang hoạt động'), ('LT992', N'Đang hoạt động');
    INSERT INTO NhatKyTau (MaNhatKy, MaTau, MaLichTrinh, NgayGio, TrangThai) 
    VALUES ('NK993', 'TA1', 'LT993', '2025-08-11 08:00:00', N'Chưa hoàn thành'), 
                    ('NK992', 'TA2', 'LT992', '2025-08-11 08:10:00', N'Chưa hoàn thành');
    INSERT INTO ChiTietLichTrinh (MaChiTiet, MaLichTrinh, MaGa, Stt_Ga, ThoiGianDiChuyenTuTramTruoc) 
    VALUES ('CT993-1', 'LT993', 'GA993', 1, NULL), ('CT992-1', 'LT992', 'GA993', 1, NULL);
    DECLARE @Result BIT;
    SET @Result = dbo.KiemTraThoiGianDenCuaGa('LT993', '2025-08-11 08:00:00', 'GA993', '2025-08-11 08:10:00');
    IF @Result = 1
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('KiemTraThoiGianDenCuaGa', 'PASS', 'Hàm phát hiện thời gian đến trùng hợp lệ.');
    ELSE
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('KiemTraThoiGianDenCuaGa', 'FAIL', 'Hàm không phát hiện thời gian đến trùng.');
    ROLLBACK;
END TRY
BEGIN CATCH
    INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('KiemTraThoiGianDenCuaGa', 'FAIL', 'Lỗi không mong đợi: ' + ERROR_MESSAGE());
    ROLLBACK;
END CATCH
GO

-- 15. Kiểm tra HoaDonTheoNgay
PRINT 'Kiểm tra HoaDonTheoNgay:';
BEGIN TRY
    BEGIN TRANSACTION;
    INSERT INTO KhachHang (MaKhach, TenKhach, NamSinh, Email, SDT, CCCD, DiaChi) 
    VALUES ('KH9998', N'Test Khách', '1990-01-01', NULL, '0999999998', NULL, NULL);
    INSERT INTO HoaDon (MaHoaDon, MaKhach, ThanhTien, ThoiGianLapHoaDon) 
    VALUES ('HD993', 'KH9998', 200000, '2025-06-11 10:00:00');
    DECLARE @Result TABLE (MaHoaDon VARCHAR(10), TenKhach NVARCHAR(100), MaKhach VARCHAR(10), ThanhTien DECIMAL(19,2), ThoiGianLapHoaDon DATETIME);
    INSERT INTO @Result
    SELECT * FROM dbo.HoaDonTheoNgay('2025-06-11');
    IF EXISTS (SELECT 1 FROM @Result WHERE MaHoaDon = 'HD993' AND TenKhach = N'Test Khách' AND ThanhTien = 200000)
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('HoaDonTheoNgay', 'PASS', 'Hàm trả về danh sách hóa đơn đúng.');
    ELSE
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('HoaDonTheoNgay', 'FAIL', 'Hàm không trả về danh sách hóa đơn đúng.');
    ROLLBACK;
END TRY
BEGIN CATCH
    INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('HoaDonTheoNgay', 'FAIL', 'Lỗi không mong đợi: ' + ERROR_MESSAGE());
    ROLLBACK;
END CATCH
GO

---- 16. Kiểm tra GiaVe (phiên bản 2)
--PRINT 'Kiểm tra GiaVe (phiên bản 2):';
--BEGIN TRY
--    BEGIN TRANSACTION;
--    INSERT INTO LoaiToa (MaLoaiToa, TenLoaiToa, GiaMacDinh, CoDieuHoa) VALUES ('LT998', N'Toại Test', 100000, 1);
--    INSERT INTO Ga (MaGa, TenGa) VALUES ('GA992', N'Ga A'), ('GB992', N'Ga B');
--    INSERT INTO LichTrinhTau (MaLichTrinh, TrangThai) VALUES ('LT992', N'Đang hoạt động');
--    INSERT INTO NhatKyTau (MaNhatKy, MaTau, MaLichTrinh, NgayGio, TrangThai) 
--    VALUES ('NK992', 'TA1', 'LT992', '2025-08-11 08:00:00', N'Chưa hoàn thành');
--    INSERT INTO ChiTietLichTrinh (MaChiTiet, MaLichTrinh, MaGa, Stt_Ga, KhoangCachTuTramTruoc) 
--    VALUES ('CT992-1', 'LT992', 'GA992', 1, NULL), ('CT992-2', 'LT992', 'GB992', 2, 20);
--    DECLARE @GiaVe DECIMAL(10,2);
--    SET @GiaVe = dbo.Ve('LT998', 'NK992', N'Ga A', N'Ga B');
--    IF @GiaVe = 110000.00 + (20 * 30000 / 20) -- 100000 + 10% điều hòa + khoảng cách
--        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('GiaVe_v2', 'PASS', 'Hàm tính giá vé theo khoảng cách đúng.');
--    ELSE
--        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('GiaVe_v2', 'FAIL', 'Hàm tính giá vé không đúng: ' + CAST(@GiaVe AS NVARCHAR));
--    ROLLBACK;
--END TRY
--BEGIN CATCH
--    INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('GiaVe_v2', 'FAIL', 'Lỗi không mong đợi: ' + ERROR_MESSAGE());
--    ROLLBACK;
--END CATCH
--GO

---- 17. Kiểm tra LayKhoang
--PRINT 'Kiểm tra LayKhoang:';
--BEGIN TRY
--    BEGIN TRANSACTION;
--    INSERT INTO LoaiToa (MaLoaiToa, TenLoaiToa, GiaMacDinh, CoDieuHoa) VALUES ('LT997', N'Toại Test', 100000, 1);
--    INSERT INTO Tau (MaTau, TenTau, DaXoa) VALUES ('TA993', N'Tàu Test', 0);
--    INSERT INTO Toa (MaToa, MaTau, SoToa, MaLoaiToa) VALUES ('TO993', 'TA993', 1, 'LT997');
--    INSERT INTO Khoang (MaKhoang, MaToa, SoKhoang, SoChoNgoiToiDa) VALUES ('K993', 'TO993', 1, 10);
--    INSERT INTO Ga (MaGa, TenGa) VALUES ('GA991', N'Ga A'), ('GB991', N'Ga B');
--    INSERT INTO LichTrinhTau (MaLichTrinh, TrangThai) VALUES ('LT991', N'Đang hoạt động');
--    INSERT INTO NhatKyTau (MaNhatKy, MaTau, MaLichTrinh, NgayGio, TrangThai) 
--    VALUES ('NK991', 'TA993', 'LT991', '2025-08-01 08:00:00', N'Chưa hoàn thành');
--    INSERT INTO ChiTietLichTrinh (MaChiTiet, MaLichTrinh, MaGa, Stt_Ga, KhoangCachTuTramTruoc) 
--    VALUES ('CT991-1', 'LT991', 'GA991', 1, NULL), ('CT991-2', 'LT991', 'GB991', 2, NULL), ('CT991-2, 20');
--    DECLARE @Result TABLE (SoToa NVARCHAR(MAX), MaKhoang VARCHAR(10), SoKhoang INT, LoaiToa NVARCHAR(100), SLChoNgoi INT, GiaVe DECIMAL(10,2), DieuHoa INT);
--    INSERT INTO @Result
--    SELECT * FROM dbo.LayKhoang('TO993', 'NK991', N'Ga A', N'Ga B');
--    IF EXISTS (SELECT 1 FROM @Result WHERE MaKhoang = 'K993' AND SLChoNgoi = 10 AND DieuHoa = 1)
--        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('LayKhoang', 'PASS', 'Hàm trả về danh sách khoản đúng.');
--    ELSE
--        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('LayKhoang', 'FAIL', 'Hàm không trả về danh sách khoản đúng.');
--    ROLLBACK;
--END TRY
--BEGIN CATCH
--    INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('LayKhoang', 'FAIL', 'Lỗi không mong đợi: ' + ERROR_MESSAGE());
--    ROLLBACK;
--END CATCH
--GO

-- In kết quả kiểm tra
PRINT '===== KẾT QUẢ KIỂM TRA FUNCTION =====';
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