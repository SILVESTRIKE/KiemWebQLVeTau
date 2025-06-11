-- File: tSQLt_Test_Suite.sql
-- Purpose: Automated tSQLt test suite for database constraints, functions, stored procedures, and triggers
-- Date: 2025-06-11
-- Note: Uses tSQLt framework for testing with transaction isolation and cleanup

-- Ensure tSQLt is installed
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'tSQLt')
BEGIN
    RAISERROR ('tSQLt framework is not installed. Please install tSQLt before running tests.', 16, 1);
    RETURN;
END
GO
-- Create test class
EXEC tSQLt.NewTestClass @ClassName = 'RailwaySystemTests';
GO
-- Create test class
EXEC tSQLt.NewTestClass @ClassName = 'RailwaySystemTests';
GO

-- Test 1: PRIMARY KEY constraint on KhachHang
CREATE PROCEDURE RailwaySystemTests.Test_PrimaryKey_KhachHang
AS
BEGIN
    EXEC tSQLt.FakeTable @TableName = 'KhachHang';
    INSERT INTO KhachHang (MaKhach, TenKhach, NamSinh, Email, SDT, CCCD, DiaChi)
    VALUES ('KH03241', N'Trần Văn Test', '19900101', 'test@example.com', '0999999999', '999999999999', N'Test Address');

    EXEC tSQLt.ExpectException @ExpectedMessagePattern = '%PRIMARY KEY%';
    INSERT INTO KhachHang (MaKhach, TenKhach, NamSinh, Email, SDT, CCCD, DiaChi)
    VALUES ('KH03241', N'Trần Văn Test', '19900101', 'test@example.com', '0999999999', '999999999999', N'Test Address');
END;
GO

-- Test 2: FOREIGN KEY constraint on TaiKhoan (Email)
CREATE PROCEDURE RailwaySystemTests.Test_ForeignKey_TaiKhoan_Email
AS
BEGIN
    EXEC tSQLt.FakeTable @TableName = 'KhachHang';
    EXEC tSQLt.FakeTable @TableName = 'TaiKhoan';

    EXEC tSQLt.ExpectException @ExpectedMessagePattern = '%FOREIGN KEY%';
    INSERT INTO TaiKhoan (MaTaiKhoan, Email, MatKhau, DaXoa)
    VALUES ('TK999', 'nonexistent@example.com', 'test123', 0);
END;
GO

-- Test 3: UNIQUE constraint on KhachHang (Email)
CREATE PROCEDURE RailwaySystemTests.Test_Unique_KhachHang_Email
AS
BEGIN
    EXEC tSQLt.FakeTable @TableName = 'KhachHang';
    INSERT INTO KhachHang (MaKhach, TenKhach, NamSinh, Email, SDT, CCCD, DiaChi)
    VALUES ('KH998', N'Nguyễn Văn Test', '19900101', 'nguyenminhtam@gmail.com', '0999999998', '999999999998', N'Test Address');

    EXEC tSQLt.ExpectException @ExpectedMessagePattern = '%UNIQUE%';
    INSERT INTO KhachHang (MaKhach, TenKhach, NamSinh, Email, SDT, CCCD, DiaChi)
    VALUES ('KH999', N'Nguyễn Văn Test', '19900101', 'nguyenminhtam@gmail.com', '0999999998', '999999999998', N'Test Address');
END;
GO

-- Test 4: CHECK constraint on KhuyenMai (PhanTramGiam)
CREATE PROCEDURE RailwaySystemTests.Test_Check_KhuyenMai_PhanTramGiam
AS
BEGIN
    EXEC tSQLt.FakeTable @TableName = 'KhuyenMai';

    EXEC tSQLt.ExpectException @ExpectedMessagePattern = '%CHECK%';
    INSERT INTO KhuyenMai (MaKhuyenMai, TenKhuyenMai, SoTienGiamToiDa, PhanTramGiam, NgayBatDau, NgayKetThuc, SoLuong, SoLuongConLai)
    VALUES ('KM999', N'Khuyến mãi test', 50000, 150.0, '20250601', '20250630', 100, 100);
END;
GO

-- Test 5: NOT NULL constraint on KhachHang (TenKhach)
CREATE PROCEDURE RailwaySystemTests.Test_NotNull_KhachHang_TenKhach
AS
BEGIN
    EXEC tSQLt.FakeTable @TableName = 'KhachHang';

    EXEC tSQLt.ExpectException @ExpectedMessagePattern = '%NULL%';
    INSERT INTO KhachHang (MaKhach, TenKhach, NamSinh, Email, SDT, CCCD, DiaChi)
    VALUES ('KH998', NULL, '19900101', 'test2@example.com', '0999999997', '999999999997', N'Test Address');
END;
GO

-- Test 6: CHECK constraint on PhanHoi (SoSao)
CREATE PROCEDURE RailwaySystemTests.Test_Check_PhanHoi_SoSao
AS
BEGIN
    EXEC tSQLt.FakeTable @TableName = 'PhanHoi';

    EXEC tSQLt.ExpectException @ExpectedMessagePattern = '%CHECK%';
    INSERT INTO PhanHoi (MaHoaDon, NoiDung, NgayPhanHoi, TrangThai, SoSao)
    VALUES ('HD0111241', N'Test phản hồi', '20250611', N'Chưa xử lý', 6);
END;
GO

-- Test 7: CHECK constraint on Khoang (SoChoNgoiToiDa)
CREATE PROCEDURE RailwaySystemTests.Test_Check_Khoang_SoChoNgoiToiDa
AS
BEGIN
    EXEC tSQLt.FakeTable @TableName = 'Khoang';

    EXEC tSQLt.ExpectException @ExpectedMessagePattern = '%CHECK%';
    INSERT INTO Khoang (MaKhoang, MaToa, SoKhoang, SoChoNgoiToiDa)
    VALUES ('K999', 'TO1', 5, 0);
END;
GO

-- Test 8: FOREIGN KEY constraint on Ve (DiemDi)
CREATE PROCEDURE RailwaySystemTests.Test_ForeignKey_Ve_DiemDi
AS
BEGIN
    EXEC tSQLt.FakeTable @TableName = 'Ve';
    EXEC tSQLt.FakeTable @TableName = 'ChiTietLichTrinh';

    EXEC tSQLt.ExpectException @ExpectedMessagePattern = '%FOREIGN KEY%';
    INSERT INTO Ve (MaVe, MaNhatKy, MaHoaDon, GiaVe, MaKhoang, Stt_Ghe, DiemDi, DiemDen, DaThuHoi)
    VALUES ('VE999', 'TA10111241', 'HD0111241', 300000, 'K1', 3, 'INVALID', 'SE1-5', 0);
END;
GO

-- Test 9: Trigger trg_capNhatSLConLai_KM
CREATE PROCEDURE RailwaySystemTests.Test_Trigger_KhuyenMai_SoLuongConLai
AS
BEGIN
    EXEC tSQLt.FakeTable @TableName = 'KhuyenMai';
    EXEC tSQLt.FakeTable @TableName = 'HoaDon';
    
    INSERT INTO KhuyenMai (MaKhuyenMai, TenKhuyenMai, SoTienGiamToiDa, PhanTramGiam, NgayBatDau, NgayKetThuc, SoLuong, SoLuongConLai)
    VALUES ('KM7', N'Khuyến mãi Test', 50000, 10.0, '20250601', '20250630', 100, 50);
    
    INSERT INTO HoaDon (MaHoaDon, MaKhach, MaKhuyenMai, ThanhTien, ThoiGianLapHoaDon)
    VALUES ('HD999', 'KH03241', 'KM7', 250000.00, '20250611');
    
    DECLARE @SoLuongConLai INT;
    SELECT @SoLuongConLai = SoLuongConLai FROM KhuyenMai WHERE MaKhuyenMai = 'KM7';
    
    EXEC tSQLt.AssertEquals @Expected = 49, @Actual = @SoLuongConLai, @Message = 'Trigger did not update SoLuongConLai correctly.';
END;
GO

-- Test 10: ON UPDATE CASCADE on PhanHoi
CREATE PROCEDURE RailwaySystemTests.Test_OnUpdateCascade_PhanHoi
AS
BEGIN
    EXEC tSQLt.FakeTable @TableName = 'HoaDon';
    EXEC tSQLt.FakeTable @TableName = 'PhanHoi';
    
    INSERT INTO HoaDon (MaHoaDon, MaKhach, ThanhTien, ThoiGianLapHoaDon)
    VALUES ('HD0111241', 'KH03241', 250000.00, '20250611');
    INSERT INTO PhanHoi (MaHoaDon, NoiDung, NgayPhanHoi, TrangThai, SoSao)
    VALUES ('HD0111241', N'Test phản hồi', '20250611', N'Chưa xử lý', 5);
    
    UPDATE HoaDon
    SET MaHoaDon = 'HD999999'
    WHERE MaHoaDon = 'HD0111241';
    
    DECLARE @Count INT;
    SELECT @Count = COUNT(*) FROM PhanHoi WHERE MaHoaDon = 'HD999999';
    
    EXEC tSQLt.AssertEquals @Expected = 1, @Actual = @Count, @Message = 'ON UPDATE CASCADE did not update PhanHoi correctly.';
END;
GO

-- Test 11: ON UPDATE CASCADE on HanhLy
CREATE PROCEDURE RailwaySystemTests.Test_OnUpdateCascade_HanhLy
AS
BEGIN
    EXEC tSQLt.FakeTable @TableName = 'Ve';
    EXEC tSQLt.FakeTable @TableName = 'HanhLy';
    
    INSERT INTO Ve (MaVe, MaNhatKy, MaHoaDon, GiaVe, MaKhoang, Stt_Ghe, DiemDi, DiemDen, DaThuHoi)
    VALUES ('VE0111241', 'TA10111241', 'HD0111241', 300000, 'K1', 3, 'CT1', 'CT2', 0);
    INSERT INTO HanhLy (MaHanhLy, MaVe, KhoiLuong)
    VALUES ('HL999', 'VE0111241', 5.0);
    
    UPDATE Ve
    SET MaVe = 'VE999999'
    WHERE MaVe = 'VE0111241';
    
    DECLARE @Count INT;
    SELECT @Count = COUNT(*) FROM HanhLy WHERE MaVe = 'VE999999';
    
    EXEC tSQLt.AssertEquals @Expected = 1, @Actual = @Count, @Message = 'ON UPDATE CASCADE did not update HanhLy correctly.';
END;
GO

-- Test 12: CHECK constraint on HanhLy (KhoiLuong)
CREATE PROCEDURE RailwaySystemTests.Test_Check_HanhLy_KhoiLuong
AS
BEGIN
    EXEC tSQLt.FakeTable @TableName = 'HanhLy';
    EXEC tSQLt.FakeTable @TableName = 'Ve';
    
    INSERT INTO Ve (MaVe, MaNhatKy, MaHoaDon, GiaVe, MaKhoang, Stt_Ghe, DiemDi, DiemDen, DaThuHoi)
    VALUES ('VE0111242', 'TA10111241', 'HD0111241', 300000, 'K1', 3, 'CT1', 'CT2', 0);
    
    EXEC tSQLt.ExpectException @ExpectedMessagePattern = '%CHECK%';
    INSERT INTO HanhLy (MaHanhLy, MaVe, KhoiLuong)
    VALUES ('HL999', 'VE0111242', 15.0);
END;
GO

-- Test 13: Function LayTenGa
CREATE PROCEDURE RailwaySystemTests.Test_Function_LayTenGa
AS
BEGIN
    EXEC tSQLt.FakeTable @TableName = 'Ga';
    EXEC tSQLt.FakeTable @TableName = 'LichTrinhTau';
    EXEC tSQLt.FakeTable @TableName = 'ChiTietLichTrinh';
    
    INSERT INTO Ga (MaGa, TenGa) VALUES ('GA999', N'Ga Test');
    INSERT INTO LichTrinhTau (MaLichTrinh, TrangThai) VALUES ('LT999', N'Đang hoạt động');
    INSERT INTO ChiTietLichTrinh (MaChiTiet, MaLichTrinh, MaGa, Stt_Ga) VALUES ('CT999', 'LT999', 'GA999', 1);
    
    DECLARE @TenGa NVARCHAR(100);
    SET @TenGa = dbo.LayTenGa('CT999');
    
    EXEC tSQLt.AssertEqualsString @Expected = N'Ga Test', @Actual = @TenGa, @Message = 'LayTenGa returned incorrect station name.';
END;
GO

-- Test 14: Function LaySoThuTuLonNhatTrongThang (HD)
CREATE PROCEDURE RailwaySystemTests.Test_Function_LaySoThuTuLonNhatTrongThang_HD
AS
BEGIN
    EXEC tSQLt.FakeTable @TableName = 'KhachHang';
    EXEC tSQLt.FakeTable @TableName = 'HoaDon';
    
    INSERT INTO KhachHang (MaKhach, TenKhach, NamSinh, Email, SDT, CCCD, DiaChi) 
    VALUES ('KH999', N'Test', '19900101', 'test@example.com', '0999999999', '123456789012', N'Test');
    INSERT INTO HoaDon (MaHoaDon, MaKhach, ThanhTien, ThoiGianLapHoaDon) 
    VALUES ('HD010625001', 'KH999', 100000, '20250601');
    
    DECLARE @SoThuTu INT;
    SET @SoThuTu = dbo.LaySoThuTuLonNhatTrongThang('20250601', 'HD');
    
    EXEC tSQLt.AssertEquals @Expected = 1, @Actual = @SoThuTu, @Message = 'LaySoThuTuLonNhatTrongThang returned incorrect sequence number.';
END;
GO

-- Test 15: Function TaoMa (VE)
CREATE PROCEDURE RailwaySystemTests.Test_Function_TaoMa_VE
AS
BEGIN
    EXEC tSQLt.FakeTable @TableName = 'LichTrinhTau';
    EXEC tSQLt.FakeTable @TableName = 'NhatKyTau';
    EXEC tSQLt.FakeTable @TableName = 'HoaDon';
    EXEC tSQLt.FakeTable @TableName = 'Ve';
    
    INSERT INTO LichTrinhTau (MaLichTrinh, TrangThai) VALUES ('LT998', N'Đang hoạt động');
    INSERT INTO NhatKyTau (MaNhatKy, MaTau, MaLichTrinh, NgayGio, TrangThai) 
    VALUES ('NK998', 'TA1', 'LT998', '20250611', N'Chưa hoàn thành');
    INSERT INTO HoaDon (MaHoaDon, MaKhach, ThanhTien, ThoiGianLapHoaDon) 
    VALUES ('HD998', 'KH999', NULL, '20250611');
    INSERT INTO Ve (MaVe, MaNhatKy, MaHoaDon, GiaVe, MaKhoang, Stt_Ghe, DiemDi, DiemDen, DaThuHoi) 
    VALUES ('VE110625001', 'NK998', 'HD998', 500000, 'K1', 1, 'CT1', 'CT2', 0);
    
    DECLARE @Ma NVARCHAR(19);
    SET @Ma = dbo.TaoMa('VE', '20250611');
    
    EXEC tSQLt.AssertEqualsString @Expected = 'VE110625002', @Actual = @Ma, @Message = 'TaoMa returned incorrect ticket code.';
END;
GO

-- Test 16: Function LayLichTrinhTheoDiemDiDiemDen
CREATE PROCEDURE RailwaySystemTests.Test_Function_LayLichTrinhTheoDiemDiDiemDen
AS
BEGIN
    EXEC tSQLt.FakeTable @TableName = 'Ga';
    EXEC tSQLt.FakeTable @TableName = 'LichTrinhTau';
    EXEC tSQLt.FakeTable @TableName = 'ChiTietLichTrinh';
    
    INSERT INTO Ga (MaGa, TenGa) VALUES ('GA997', N'Ga A'), ('GB997', N'Ga B');
    INSERT INTO LichTrinhTau (MaLichTrinh, TrangThai) VALUES ('LT997', N'Đang hoạt động');
    INSERT INTO ChiTietLichTrinh (MaChiTiet, MaLichTrinh, MaGa, Stt_Ga) 
    VALUES ('CT997-1', 'LT997', 'GA997', 1), ('CT997-2', 'LT997', 'GB997', 2);
    
    DECLARE @Result TABLE (TenGaDi NVARCHAR(100), SttGaDi INT, MaLichTrinh VARCHAR(10), TenGaDen NVARCHAR(100), SttGaDen INT);
    INSERT INTO @Result
    SELECT * FROM dbo.LayLichTrinhTheoDiemDiDiemDen(N'Ga A', N'Ga B');
    
    DECLARE @Count INT;
    SELECT @Count = COUNT(*) FROM @Result 
    WHERE TenGaDi = N'Ga A' AND TenGaDen = N'Ga B' AND MaLichTrinh = 'LT997' AND SttGaDi = 1 AND SttGaDen = 2;
    
    EXEC tSQLt.AssertEquals @Expected = 1, @Actual = @Count, @Message = 'LayLichTrinhTheoDiemDiDiemDen returned incorrect schedule.';
END;
GO

-- Test 17: Function SoLuongToiDaCuaTau
CREATE PROCEDURE RailwaySystemTests.Test_Function_SoLuongToiDaCuaTau
AS
BEGIN
    EXEC tSQLt.FakeTable @TableName = 'Tau';
    EXEC tSQLt.FakeTable @TableName = 'Toa';
    EXEC tSQLt.FakeTable @TableName = 'Khoang';
    
    INSERT INTO Tau (MaTau, TenTau, DaXoa) VALUES ('TA997', N'Tàu Test', 0);
    INSERT INTO Toa (MaToa, MaTau, SoToa, MaLoaiToa) VALUES ('TO997', 'TA997', 1, 'LT1');
    INSERT INTO Khoang (MaKhoang, MaToa, SoKhoang, SoChoNgoiToiDa) VALUES ('K997', 'TO997', 1, 20);
    
    DECLARE @SoLuong INT;
    SET @SoLuong = dbo.SoLuongToiDaCuaTau('TA997');
    
    EXEC tSQLt.AssertEquals @Expected = 20, @Actual = @SoLuong, @Message = 'SoLuongToiDaCuaTau returned incorrect seat count.';
END;
GO

-- Test 18: Function TinhTongThoiGianDiChuyen
CREATE PROCEDURE RailwaySystemTests.Test_Function_TinhTongThoiGianDiChuyen
AS
BEGIN
    EXEC tSQLt.FakeTable @TableName = 'Ga';
    EXEC tSQLt.FakeTable @TableName = 'LichTrinhTau';
    EXEC tSQLt.FakeTable @TableName = 'NhatKyTau';
    EXEC tSQLt.FakeTable @TableName = 'ChiTietLichTrinh';
    
    INSERT INTO Ga (MaGa, TenGa) VALUES ('GA996', 'Ga A'), ('GB996', 'Ga B');
    INSERT INTO LichTrinhTau (MaLichTrinh, TrangThai) VALUES ('LT996', N'Đang hoạt động');
    INSERT INTO NhatKyTau (MaNhatKy, MaTau, MaLichTrinh, NgayGio, TrangThai) 
    VALUES ('NK996', 'TA1', 'LT996', '20250611 08:00:00', N'Chưa hoàn thành');
    INSERT INTO ChiTietLichTrinh (MaChiTiet, MaLichTrinh, MaGa, Stt_Ga, ThoiGianDiChuyenTuTramTruoc) 
    VALUES ('CT996-1', 'LT996', 'GA996', 1, NULL), ('CT996-2', 'LT996', 'GB996', 2, '01:00:00');
    
    DECLARE @ThoiGianDen DATETIME;
    SET @ThoiGianDen = dbo.TinhTongThoiGianDiChuyen('NK996', '20250611 08:00:00', 'GA996', 'GB996');
    
    EXEC tSQLt.AssertEqualsString @Expected = '20250611 09:15:00', @Actual = @ThoiGianDen, @Message = 'TinhTongThoiGianDiChuyen returned incorrect arrival time.';
END;
GO

-- Test 19: Function LayTau
CREATE PROCEDURE RailwaySystemTests.Test_Function_LayTau
AS
BEGIN
    EXEC tSQLt.FakeTable @TableName = 'Ga';
    EXEC tSQLt.FakeTable @TableName = 'LichTrinhTau';
    EXEC tSQLt.FakeTable @TableName = 'NhatKyTau';
    EXEC tSQLt.FakeTable @TableName = 'ChiTietLichTrinh';
    EXEC tSQLt.FakeTable @TableName = 'Tau';
    EXEC tSQLt.FakeTable @TableName = 'Toa';
    EXEC tSQLt.FakeTable @TableName = 'Khoang';
    
    INSERT INTO Ga (MaGa, TenGa) VALUES ('GA995', N'Ga A'), ('GB995', N'Ga B');
    INSERT INTO LichTrinhTau (MaLichTrinh, TrangThai) VALUES ('LT995', N'Đang hoạt động');
    INSERT INTO NhatKyTau (MaNhatKy, MaTau, MaLichTrinh, NgayGio, TrangThai) 
    VALUES ('NK995', 'TA995', 'LT995', '20250611 08:00:00', N'Chưa hoàn thành');
    INSERT INTO ChiTietLichTrinh (MaChiTiet, MaLichTrinh, MaGa, Stt_Ga, ThoiGianDiChuyenTuTramTruoc) 
    VALUES ('CT995-1', 'LT995', 'GA995', 1, NULL), ('CT995-2', 'LT995', 'GB995', 2, '01:00:00');
    INSERT INTO Tau (MaTau, TenTau, DaXoa) VALUES ('TA995', N'Tàu Test', 0);
    INSERT INTO Toa (MaToa, MaTau, SoToa, MaLoaiToa) VALUES ('TO995', 'TA995', 1, 'LT1');
    INSERT INTO Khoang (MaKhoang, MaToa, SoKhoang, SoChoNgoiToiDa) VALUES ('K995', 'TO995', 1, 20);
    
    DECLARE @Result TABLE (MaTau NVARCHAR(100), MaNhatKy NVARCHAR(100), ThoiGianDi DATETIME, ThoiGianDen DATETIME, SLChoTrong INT);
    INSERT INTO @Result
    SELECT * FROM dbo.LayTau('20250611', N'Ga A', N'Ga B');
    
    DECLARE @Count INT;
    SELECT @Count = COUNT(*) FROM @Result WHERE MaTau = 'TA995' AND MaNhatKy = 'NK995' AND SLChoTrong = 20;
    
    EXEC tSQLt.AssertEquals @Expected = 1, @Actual = @Count, @Message = 'LayTau returned incorrect train list.';
END;
GO

-- Test 20: Function LAYTOA
CREATE PROCEDURE RailwaySystemTests.Test_Function_LAYTOA
AS
BEGIN
    EXEC tSQLt.FakeTable @TableName = 'Tau';
    EXEC tSQLt.FakeTable @TableName = 'Toa';
    
    INSERT INTO Tau (MaTau, TenTau, DaXoa) VALUES ('TA994', N'Tàu Test', 0);
    INSERT INTO Toa (MaToa, MaTau, SoToa, MaLoaiToa) VALUES ('TO994', 'TA994', 1, 'LT1');
    
    DECLARE @Result TABLE (MaToa VARCHAR(10), MaTau VARCHAR(10), SoToa INT, MaLoaiToa VARCHAR(10));
    INSERT INTO @Result
    SELECT * FROM dbo.LAYTOA('TA994');
    
    DECLARE @Count INT;
    SELECT @Count = COUNT(*) FROM @Result WHERE MaToa = 'TO994' AND MaTau = 'TA994' AND SoToa = 1;
    
    EXEC tSQLt.AssertEquals @Expected = 1, @Actual = @Count, @Message = 'LAYTOA returned incorrect carriage list.';
END;
GO

-- Test 21: Function GiaVe (version 1)
CREATE PROCEDURE RailwaySystemTests.Test_Function_GiaVe_v1
AS
BEGIN
    EXEC tSQLt.FakeTable @TableName = 'LoaiToa';
    
    INSERT INTO LoaiToa (MaLoaiToa, TenLoaiToa, GiaMacDinh, CoDieuHoa) VALUES ('LT999', N'Loại Test', 100000, 1);
    
    DECLARE @GiaVe DECIMAL(10,2);
    SET @GiaVe = dbo.GiaVe('LT999');
    
    EXEC tSQLt.AssertEquals @Expected = 110000.00, @Actual = @GiaVe, @Message = 'GiaVe returned incorrect ticket price.';
END;
GO

-- Test 22: Function LayKhuyenMai
CREATE PROCEDURE RailwaySystemTests.Test_Function_LayKhuyenMai
AS
BEGIN
    EXEC tSQLt.FakeTable @TableName = 'KhuyenMai';
    
    INSERT INTO KhuyenMai (MaKhuyenMai, TenKhuyenMai, SoTienGiamToiDa, PhanTramGiam, NgayBatDau, NgayKetThuc, SoLuong, SoLuongConLai)
    VALUES ('KM998', N'Khuyến mãi Test', 50000, 10.0, '20250601', '20250630', 100, 50);
    
    DECLARE @Result TABLE (MaKhuyenMai VARCHAR(10), TenKhuyenMai NVARCHAR(100), SoTienGiamToiDa INT, PhanTramGiam FLOAT, NgayBatDau DATE, NgayKetThuc DATE, SoLuong INT, SoLuongConLai INT);
    INSERT INTO @Result
    SELECT * FROM dbo.LayKhuyenMai();
    
    DECLARE @Count INT;
    SELECT @Count = COUNT(*) FROM @Result WHERE MaKhuyenMai = 'KM998' AND SoLuongConLai = 50;
    
    EXEC tSQLt.AssertEquals @Expected = 1, @Actual = @Count, @Message = 'LayKhuyenMai returned incorrect promotion list.';
END;
GO

-- Test 23: Function LaySttGaFromMaChiTiet
CREATE PROCEDURE RailwaySystemTests.Test_Function_LaySttGaFromMaChiTiet
AS
BEGIN
    EXEC tSQLt.FakeTable @TableName = 'LichTrinhTau';
    EXEC tSQLt.FakeTable @TableName = 'ChiTietLichTrinh';
    
    INSERT INTO LichTrinhTau (MaLichTrinh, TrangThai) VALUES ('LT996', N'Đang hoạt động');
    INSERT INTO ChiTietLichTrinh (MaChiTiet, MaLichTrinh, MaGa, Stt_Ga) VALUES ('CT996', 'LT996', 'GA1', 3);
    
    DECLARE @SttGa INT;
    SET @SttGa = dbo.LaySttGaFromMaChiTiet('CT996');
    
    EXEC tSQLt.AssertEquals @Expected = 3, @Actual = @SttGa, @Message = 'LaySttGaFromMaChiTiet returned incorrect station order.';
END;
GO

-- Test 24: Function LayVeTheoGaDiDen
CREATE PROCEDURE RailwaySystemTests.Test_Function_LayVeTheoGaDiDen
AS
BEGIN
    EXEC tSQLt.FakeTable @TableName = 'Ga';
    EXEC tSQLt.FakeTable @TableName = 'LichTrinhTau';
    EXEC tSQLt.FakeTable @TableName = 'NhatKyTau';
    EXEC tSQLt.FakeTable @TableName = 'ChiTietLichTrinh';
    EXEC tSQLt.FakeTable @TableName = 'HoaDon';
    EXEC tSQLt.FakeTable @TableName = 'Khoang';
    EXEC tSQLt.FakeTable @TableName = 'Ve';
    
    INSERT INTO Ga (MaGa, TenGa) VALUES ('GA994', N'Ga A'), ('GB994', N'Ga B');
    INSERT INTO LichTrinhTau(MaLichTrinh, TrangThai) VALUES ('LT994', N'Đang hoạt động');
    INSERT INTO NhatKyTau (MaNhatKy, MaTau, MaLichTrinh, NgayGio, TrangThai) 
    VALUES ('NK994', 'TA1', 'LT994', '20250811', N'Chưa hoàn thành');
    INSERT INTO ChiTietLichTrinh (MaChiTiet, MaLichTrinh, MaGa, Stt_Ga) 
    VALUES ('CT994-1', 'LT994', 'GA994', 1), ('CT994-2', 'LT994', 'GB994', 2);
    INSERT INTO HoaDon (MaHoaDon, MaKhach, ThanhTien, ThoiGianLapHoaDon) 
    VALUES ('HD999', 'KH999', NULL, '20250611');
    INSERT INTO Khoang (MaKhoang, MaToa, SoKhoang, SoChoNgoiToiDa) VALUES ('K994', 'TO1', 1, 20);
    INSERT INTO Ve (MaVe, MaNhatKy, MaHoaDon, GiaVe, MaKhoang, Stt_Ghe, DiemDi, DiemDen, DaThuHoi) 
    VALUES ('VE994', 'NK994', 'HD999', 50000, 'K994', 1, 'CT994-1', 'CT994-2', 0);
    
    DECLARE @Result TABLE (MaVe VARCHAR(15), SttVe INT, SttGaDi INT, SttGaDen INT, TenGaDi NVARCHAR(100), TenGaDen NVARCHAR(100));
    INSERT INTO @Result
    SELECT * FROM dbo.LayVeTheoGaDiDen('K994', 'NK994', N'Ga A', N'Ga B');
    
    DECLARE @Count INT;
    SELECT @Count = COUNT(*) FROM @Result 
    WHERE MaVe = 'VE994' AND SttGaDi = 1 AND SttGaDen = 2 AND TenGaDi = N'Ga A' AND TenGaDen = N'Ga B';
    
    EXEC tSQLt.AssertEquals @Expected = 1, @Actual = @Count, @Message = 'LayVeTheoGaDiDen returned incorrect ticket list.';
END;
GO

-- Test 25: Function SinhMaLichTrinh
CREATE PROCEDURE RailwaySystemTests.Test_Function_SinhMaLichTrinh
AS
BEGIN
    EXEC tSQLt.FakeTable @TableName = 'LichTrinhTau';
    
    INSERT INTO LichTrinhTau (MaLichTrinh, TrangThai) VALUES ('LT01', N'Đang hoạt động');
    
    DECLARE @MaLichTrinh VARCHAR(10);
    SET @MaLichTrinh = dbo.SinhMaLichTrinh('LT');
    
    EXEC tSQLt.AssertEqualsString @Expected = 'LT02', @Actual = @MaLichTrinh, @Message = 'SinhMaLichTrinh returned incorrect schedule code.';
END;
GO

-- Test 26: Function KiemTraThoiGianDenCuaGa
CREATE PROCEDURE RailwaySystemTests.Test_Function_KiemTraThoiGianDenCuaGa
AS
BEGIN
    EXEC tSQLt.FakeTable @TableName = 'Ga';
    EXEC tSQLt.FakeTable @TableName = 'LichTrinhTau';
    EXEC tSQLt.FakeTable @TableName = 'NhatKyTau';
    EXEC tSQLt.FakeTable @TableName = 'ChiTietLichTrinh';
    
    INSERT INTO Ga (MaGa, TenGa) VALUES ('GA993', 'Ga A');
    INSERT INTO LichTrinhTau (MaLichTrinh, TrangThai) VALUES ('LT993', N'Đang hoạt động'), ('LT992', N'Đang hoạt động');
    INSERT INTO NhatKyTau (MaNhatKy, MaTau, MaLichTrinh, NgayGio, TrangThai) 
    VALUES ('NK993', 'TA1', 'LT993', '20250811 08:00:00', N'Chưa hoàn thành'), 
           ('NK992', 'TA2', 'LT992', '20250811 08:10:00', N'Chưa hoàn thành');
    INSERT INTO ChiTietLichTrinh (MaChiTiet, MaLichTrinh, MaGa, Stt_Ga, ThoiGianDiChuyenTuTramTruoc) 
    VALUES ('CT993-1', 'LT993', 'GA993', 1, NULL), ('CT992-1', 'LT992', 'GA993', 1, NULL);
    
    DECLARE @Result BIT;
    SET @Result = dbo.KiemTraThoiGianDenCuaGa('LT993', '20250811 08:00:00', 'GA993', '20250811 08:10:00');
    
    EXEC tSQLt.AssertEquals @Expected = 1, @Actual = @Result, @Message = 'KiemTraThoiGianDenCuaGa did not detect overlapping arrival time correctly.';
END;
GO

-- Test 27: Function HoaDonTheoNgay
CREATE PROCEDURE RailwaySystemTests.Test_Function_HoaDonTheoNgay
AS
BEGIN
    EXEC tSQLt.FakeTable @TableName = 'KhachHang';
    EXEC tSQLt.FakeTable @TableName = 'HoaDon';
    
    INSERT INTO KhachHang (MaKhach, TenKhach, NamSinh, Email, SDT, CCCD, DiaChi) 
    VALUES ('KH9998', N'Test Khách', '19900101', NULL, '0999999998', NULL, NULL);
    INSERT INTO HoaDon (MaHoaDon, MaKhach, ThanhTien, ThoiGianLapHoaDon) 
    VALUES ('HD993', 'KH9998', 200000, '20250611 10:00:00');
    
    DECLARE @Result TABLE (MaHoaDon VARCHAR(10), TenKhach NVARCHAR(100), MaKhach VARCHAR(10), ThanhTien DECIMAL(19,2), ThoiGianLapHoaDon DATETIME);
    INSERT INTO @Result
    SELECT * FROM dbo.HoaDonTheoNgay('20250611');
    
    DECLARE @Count INT;
    SELECT @Count = COUNT(*) FROM @Result 
    WHERE MaHoaDon = 'HD993' AND TenKhach = N'Test Khách' AND ThanhTien = 200000;
    
    EXEC tSQLt.AssertEquals @Expected = 1, @Actual = @Count, @Message = 'HoaDonTheoNgay returned incorrect invoice list.';
END;
GO

-- Test 28: Stored Procedure TAOHOADON
CREATE PROCEDURE RailwaySystemTests.Test_StoredProcedure_TAOHOADON
AS
BEGIN
    EXEC tSQLt.FakeTable @TableName = 'KhachHang';
    EXEC tSQLt.FakeTable @TableName = 'KhuyenMai';
    EXEC tSQLt.FakeTable @TableName = 'HoaDon';
    
    INSERT INTO KhachHang (MaKhach, TenKhach, NamSinh, Email, SDT, CCCD, DiaChi)
    VALUES ('KH999', N'Test Khách', '19900101', 'test@example.com', '0999999999', '123456789012', N'Test Address');
    INSERT INTO KhuyenMai (MaKhuyenMai, TenKhuyenMai, SoTienGiamToiDa, PhanTramGiam, NgayBatDau, NgayKetThuc, SoLuong, SoLuongConLai)
    VALUES ('KM999', N'Test KM', 50000, 10.0, '20250601', '20250630', 100, 100);
    
    DECLARE @MaHoaDon VARCHAR(100);
    EXEC @MaHoaDon = dbo.TAOHOADON @Email = 'test@example.com', @MaKhuyenMai = 'KM999', @ThanhTien = 100000.00, @ThoiGian = '20250611';
    
    DECLARE @Count INT;
    SELECT @Count = COUNT(*) FROM HoaDon WHERE MaHoaDon = @MaHoaDon AND MaKhach = 'KH999' AND ThanhTien = 100000.00;
    
    EXEC tSQLt.AssertEquals @Expected = 1, @Actual = @Count, @Message = 'TAOHOADON did not create invoice correctly.';
END;
GO

-- Test 29: Stored Procedure TAOVE
CREATE PROCEDURE RailwaySystemTests.Test_StoredProcedure_TAOVE
AS
BEGIN
    EXEC tSQLt.FakeTable @TableName = 'LichTrinhTau';
    EXEC tSQLt.FakeTable @TableName = 'NhatKyTau';
    EXEC tSQLt.FakeTable @TableName = 'Ga';
    EXEC tSQLt.FakeTable @TableName = 'ChiTietLichTrinh';
    EXEC tSQLt.FakeTable @TableName = 'HoaDon';
    EXEC tSQLt.FakeTable @TableName = 'Khoang';
    EXEC tSQLt.FakeTable @TableName = 'Ve';
    
    INSERT INTO LichTrinhTau (MaLichTrinh, TrangThai) VALUES ('LT999', N'Đang hoạt động');
    INSERT INTO NhatKyTau (MaNhatKy, MaTau, MaLichTrinh, NgayGio, TrangThai) 
    VALUES ('NK999', 'TA1', 'LT999', '20250612', N'Chưa hoàn thành');
    INSERT INTO Ga (MaGa, TenGa) VALUES ('GA999', N'Ga A'), ('GB999', N'Ga B');
    INSERT INTO ChiTietLichTrinh (MaChiTiet, MaLichTrinh, MaGa, Stt_Ga) 
    VALUES ('CT999-1', 'LT999', 'GA999', 1), ('CT999-2', 'LT999', 'GB999', 2);
    INSERT INTO HoaDon (MaHoaDon, MaKhach, ThanhTien, ThoiGianLapHoaDon) 
    VALUES ('HD999', 'KH999', NULL, '20250611');
    INSERT INTO Khoang (MaKhoang, MaToa, SoKhoang, SoChoNgoiToiDa) VALUES ('K999', 'TO1', 1, 20);
    
    EXEC dbo.TAOVE @MaNhatKy = 'NK999', @MaHoaDon = 'HD999', @GiaVe = 500000, @MaKhoang = 'K999', @stt = 5, @DiemDi = N'Ga A', @DiemDen = N'Ga B';
    
    DECLARE @Count INT;
    SELECT @Count = COUNT(*) FROM Ve 
    WHERE MaNhatKy = 'NK999' AND MaHoaDon = 'HD999' AND GiaVe = 500000 AND MaKhoang = 'K999' AND Stt_Ghe = 5 AND DiemDi = 'CT999-1' AND DiemDen = 'CT999-2';
    
    EXEC tSQLt.AssertEquals @Expected = 1, @Actual = @Count, @Message = 'TAOVE did not create ticket correctly.';
END;
GO

-- Test 30: Stored Procedure TraVe
CREATE PROCEDURE RailwaySystemTests.Test_StoredProcedure_TraVe
AS
BEGIN
    EXEC tSQLt.FakeTable @TableName = 'LichTrinhTau';
    EXEC tSQLt.FakeTable @TableName = 'NhatKyTau';
    EXEC tSQLt.FakeTable @TableName = 'HoaDon';
    EXEC tSQLt.FakeTable @TableName = 'Ve';
    EXEC tSQLt.FakeTable @TableName = 'LichSuDoiTraVe';
    
    INSERT INTO LichTrinhTau (MaLichTrinh, TrangThai) VALUES ('LT998', N'Đang hoạt động');
    INSERT INTO NhatKyTau (MaNhatKy, MaTau, MaLichTrinh, NgayGio, TrangThai) 
    VALUES ('NK998', 'TA1', 'LT998', DATEADD(DAY, 4, GETDATE()), N'Chưa hoàn thành');
    INSERT INTO HoaDon (MaHoaDon, MaKhach, ThanhTien, ThoiGianLapHoaDon) 
    VALUES ('HD998', 'KH999', NULL, '20250611');
    INSERT INTO Ve (MaVe, MaNhatKy, MaHoaDon, GiaVe, MaKhoang, Stt_Ghe, DiemDi, DiemDen, DaThuHoi)
    VALUES ('VE998', 'NK998', 'HD998', 1000000, 'K1', 1, 'CT1', 'CT2', 0);
    
    EXEC dbo.TraVe @MaVe = 'VE998';
    
    DECLARE @Count INT;
    SELECT @Count = COUNT(*) FROM LichSuDoiTraVe WHERE MaVe = 'VE998' AND EXISTS (SELECT 1 FROM Ve WHERE MaVe = 'VE998' AND DaThuHoi = 1);
    
    EXEC tSQLt.AssertEquals @Expected = 1, @Actual = @Count, @Message = 'TraVe did not update ticket status and history correctly.';
END;
GO

-- Test 31: Stored Procedure ThemLichTrinh
CREATE PROCEDURE RailwaySystemTests.Test_StoredProcedure_ThemLichTrinh
AS
BEGIN
    EXEC tSQLt.FakeTable @TableName = 'LichTrinhTau';
    
    EXEC dbo.ThemLichTrinh @TienTo = 'LT', @TenLichTrinh = N'Lịch trình Test';
    
    DECLARE @Count INT;
    SELECT @Count = COUNT(*) FROM LichTrinhTau WHERE TenLichTrinh = N'Lịch trình Test' AND MaLichTrinh LIKE 'LT%';
    
    EXEC tSQLt.AssertEquals @Expected = 1, @Actual = @Count, @Message = 'ThemLichTrinh did not create schedule correctly.';
END;
GO

-- Test 32: Stored Procedure ThemNhanVien
CREATE PROCEDURE RailwaySystemTests.Test_StoredProcedure_ThemNhanVien
AS
BEGIN
    EXEC tSQLt.FakeTable @TableName = 'ChucVu';
    EXEC tSQLt.FakeTable @TableName = 'NhanVien';
    EXEC tSQLt.FakeTable @TableName = 'TaiKhoanNhanVien';
    
    INSERT INTO ChucVu (MaChucVu, TenChucVu) VALUES ('CV1', 'Nhân viên bán vé');
    
    EXEC dbo.ThemNhanVien @TenNhanVien = N'Test NV', @Email = 'nv@example.com', @SDT = '0999999999', @CCCD = '123456789012', @NamSinh = 1990, @VaiTro = 'BanHang', @ChucVu = 'Nhân viên bán vé', @MoTa = '', @Luong = 5.5, @DefaultPassword = '123456';
    
    DECLARE @Count INT;
    SELECT @Count = COUNT(*) FROM NhanVien WHERE TenNhanVien = N'Test NV' AND Email = 'nv@example.com';
    DECLARE @CountTaiKhoan INT;
    SELECT @CountTaiKhoan = COUNT(*) FROM TaiKhoanNhanVien WHERE Email = 'nv@example.com';
    
    EXEC tSQLt.AssertEquals @Expected = 1, @Actual = @Count, @Message = 'ThemNhanVien did not create employee correctly.';
    EXEC tSQLt.AssertEquals @Expected = 1, @Actual = @CountTaiKhoan, @Message = 'ThemNhanVien did not create employee account correctly.';
END;
GO

-- Test 33: Stored Procedure LayNhanVienChuaPhanCong
CREATE PROCEDURE RailwaySystemTests.Test_StoredProcedure_LayNhanVienChuaPhanCong
AS
BEGIN
    EXEC tSQLt.FakeTable @TableName = 'NhanVien';
    EXEC tSQLt.FakeTable @TableName = 'LichTrinhTau';
    EXEC tSQLt.FakeTable @TableName = 'NhatKyTau';
    EXEC tSQLt.FakeTable @TableName = 'Ga';
    EXEC tSQLt.FakeTable @TableName = 'ChiTietLichTrinh';
    EXEC tSQLt.FakeTable @TableName = 'PhanCong';
    
    INSERT INTO NhanVien (MaNhanVien, TenNhanVien) VALUES ('NV999', N'Test NV');
    INSERT INTO LichTrinhTau (MaLichTrinh, TrangThai) VALUES ('LT997', N'Đang hoạt động');
    INSERT INTO NhatKyTau (MaNhatKy, MaTau, MaLichTrinh, NgayGio, TrangThai) 
    VALUES ('NK997', 'TA1', 'LT997', DATEADD(DAY, 2, GETDATE()), N'Chưa hoàn thành');
    INSERT INTO Ga (MaGa, TenGa) VALUES ('G1', 'Ga1'), ('G2', 'Ga2');
    INSERT INTO ChiTietLichTrinh (MaChiTiet, MaLichTrinh, MaGa, Stt_Ga) 
    VALUES ('CT997-1', 'LT997', 'G1', 1), ('CT997-2', 'LT997', 'G2', 2);
    
    DECLARE @Output TABLE (MaNhanVien VARCHAR(10));
    INSERT INTO @Output
    EXEC dbo.LayNhanVienChuaPhanCong @MaNhatKyChon = 'NK997';
    
    DECLARE @Count INT;
    SELECT @Count = COUNT(*) FROM @Output WHERE MaNhanVien = 'NV999';
    
    EXEC tSQLt.AssertEquals @Expected = 1, @Actual = @Count, @Message = 'LayNhanVienChuaPhanCong did not return unassigned employees correctly.';
END;
GO

-- Test 34: Stored Procedure spDoanhThuTheoTau
CREATE PROCEDURE RailwaySystemTests.Test_StoredProcedure_spDoanhThuTheoTau
AS
BEGIN
    EXEC tSQLt.FakeTable @TableName = 'Tau';
    EXEC tSQLt.FakeTable @TableName = 'LichTrinhTau';
    EXEC tSQLt.FakeTable @TableName = 'NhatKyTau';
    EXEC tSQLt.FakeTable @TableName = 'HoaDon';
    EXEC tSQLt.FakeTable @TableName = 'Ve';
    
    INSERT INTO Tau (MaTau, TenTau, DaXoa) VALUES ('TA999', N'Tàu Test', 0);
    INSERT INTO LichTrinhTau (MaLichTrinh, TrangThai) VALUES ('LT996', N'Đang hoạt động');
    INSERT INTO NhatKyTau (MaNhatKy, MaTau, MaLichTrinh, NgayGio, TrangThai) 
    VALUES ('NK996', 'TA999', 'LT996', '20250612', N'Chưa hoàn thành');
    INSERT INTO HoaDon (MaHoaDon, MaKhach, ThanhTien, ThoiGianLapHoaDon) 
    VALUES ('HD996', 'KH999', NULL, '20250611');
    INSERT INTO Ve (MaVe, MaNhatKy, MaHoaDon, GiaVe, MaKhoang, Stt_Ghe, DiemDi, DiemDen, DaThuHoi)
    VALUES ('VE996', 'NK996', 'HD996', 500000, 'K1', 1, 'CT1', 'CT2', 0);
    
    DECLARE @DoanhThu TABLE (TenTau NVARCHAR(100), SoLuongVeBan INT, DoanhThu DECIMAL(19,2));
    INSERT INTO @DoanhThu
    EXEC dbo.spDoanhThuTheoTau;
    
    DECLARE @Count INT;
    SELECT @Count = COUNT(*) FROM @DoanhThu WHERE TenTau = N'Tàu Test' AND SoLuongVeBan = 1 AND DoanhThu = 500000;
    
    EXEC tSQLt.AssertEquals @Expected = 1, @Actual = @Count, @Message = 'spDoanhThuTheoTau returned incorrect revenue data.';
END;
GO

-- Test 35: Stored Procedure BaoCaoTheoNgay
CREATE PROCEDURE RailwaySystemTests.Test_StoredProcedure_BaoCaoTheoNgay
AS
BEGIN
    EXEC tSQLt.FakeTable @TableName = 'NhanVien';
    EXEC tSQLt.FakeTable @TableName = 'LichTrinhTau';
    EXEC tSQLt.FakeTable @TableName = 'NhatKyTau';
    EXEC tSQLt.FakeTable @TableName = 'PhanCong';
    EXEC tSQLt.FakeTable @TableName = 'HoaDon';
    EXEC tSQLt.FakeTable @TableName = 'Ve';
    
    INSERT INTO NhanVien (MaNhanVien, TenNhanVien) VALUES ('NV998', N'Test NV');
    INSERT INTO LichTrinhTau (MaLichTrinh, TrangThai) VALUES ('LT995', N'Đang hoạt động');
    INSERT INTO NhatKyTau (MaNhatKy, MaTau, MaLichTrinh, NgayGio, TrangThai) 
    VALUES ('NK995', 'TA1', 'LT995', '20250611', N'Chưa hoàn thành');
    INSERT INTO PhanCong (MaPhanCong, MaNhanVien, MaNhatKy) VALUES ('PC995', 'NV998', 'NK995');
    INSERT INTO HoaDon (MaHoaDon, MaKhach, ThanhTien, ThoiGianLapHoaDon) 
    VALUES ('HD995', 'KH999', NULL, '20250611');
    INSERT INTO Ve (MaVe, MaNhatKy, MaHoaDon, GiaVe, MaKhoang, Stt_Ghe, DiemDi, DiemDen, DaThuHoi)
    VALUES ('VE995', 'NK995', 'HD995', 300000, 'K1', 1, 'CT1', 'CT2', 0);
    
    DECLARE @BaoCao TABLE (TenNhanVien NVARCHAR(100), MaPhanCong VARCHAR(15), MaNhatKy VARCHAR(11), NgayGio DATETIME, SoVeBanDuoc INT, TongDoanhThu DECIMAL(19,2));
    INSERT INTO @BaoCao
    EXEC dbo.BaoCaoTheoNgay @Ngay = '20250611';
    
    DECLARE @Count INT;
    SELECT @Count = COUNT(*) FROM @BaoCao WHERE TenNhanVien = N'Test NV' AND SoVeBanDuoc = 1 AND TongDoanhThu = 300000;
    
    EXEC tSQLt.AssertEquals @Expected = 1, @Actual = @Count, @Message = 'BaoCaoTheoNgay returned incorrect daily report.';
END;
GO

-- Test 36: Stored Procedure DangKy
CREATE PROCEDURE RailwaySystemTests.Test_StoredProcedure_DangKy
AS
BEGIN
    EXEC tSQLt.FakeTable @TableName = 'KhachHang';
    EXEC tSQLt.FakeTable @TableName = 'TaiKhoan';
    
    EXEC dbo.DangKy @TenKhach = N'Test Khách', @NamSinh = '19900101', @Email = 'new@example.com', @SDT = '0999999998', @CCCD = '123456789013', @DiaChi = N'Test Address', @MatKhau = 'pass123';
    
    DECLARE @CountKhach INT;
    SELECT @CountKhach = COUNT(*) FROM KhachHang WHERE Email = 'new@example.com' AND TenKhach = N'Test Khách';
    DECLARE @CountTaiKhoan INT;
    SELECT @CountTaiKhoan = COUNT(*) FROM TaiKhoan WHERE Email = 'new@example.com' AND MatKhau = 'pass123';
    
    EXEC tSQLt.AssertEquals @Expected = 1, @Actual = @CountKhach, @Message = 'DangKy did not create customer correctly.';
    EXEC tSQLt.AssertEquals @Expected = 1, @Actual = @CountTaiKhoan, @Message = 'DangKy did not create customer account correctly.';
END;
GO

-- Test 37: Trigger Trigger_Insert_TRAVE_VE
CREATE PROCEDURE RailwaySystemTests.Test_Trigger_Insert_TRAVE_VE
AS
BEGIN
    EXEC tSQLt.FakeTable @TableName = 'Ve';
    EXEC tSQLt.FakeTable @TableName = 'LichSuDoiTraVe';
    
    INSERT INTO Ve (MaVe, MaNhatKy, MaHoaDon, GiaVe, MaKhoang, Stt_Ghe, DiemDi, DiemDen, DaThuHoi)
    VALUES ('VE0111241', 'NK999', 'HD999', 100000, 'K1', 1, 'CT1', 'CT2', 0);
    
    INSERT INTO LichSuDoiTraVe (MaVe, HanhDong, ThoiGian, LePhi)
    VALUES ('VE0111241', N'Trả', '20250611', 100000);
    
    DECLARE @Count INT;
    SELECT @Count = COUNT(*) FROM Ve WHERE MaVe = 'VE0111241' AND DaThuHoi = 1;
    
    EXEC tSQLt.AssertEquals @Expected = 1, @Actual = @Count, @Message = 'Trigger_Insert_TRAVE_VE did not update DaThuHoi correctly.';
END;
GO

-- Test 38: Trigger trg_ThemTau
CREATE PROCEDURE RailwaySystemTests.Test_Trigger_ThemTau
AS
BEGIN
    EXEC tSQLt.FakeTable @TableName = 'Tau';
    
    INSERT INTO Tau (TenTau, DaXoa) VALUES (N'Tàu Test', 0);
    
    DECLARE @NewMaTau VARCHAR(10);
    SELECT @NewMaTau = MaTau FROM Tau WHERE TenTau = N'Tàu Test';
    
    EXEC tSQLt.AssertLike @ExpectedPattern = 'TA[0-9][0-9]', @Actual = @NewMaTau, @Message = 'trg_ThemTau did not create MaTau in correct format.';
END;
GO

-- Test 39: Trigger trg_SetDaXoa_Tau
CREATE PROCEDURE RailwaySystemTests.Test_Trigger_SetDaXoa_Tau
AS
BEGIN
    EXEC tSQLt.FakeTable @TableName = 'Tau';
    EXEC tSQLt.FakeTable @TableName = 'LichTrinhTau';
    EXEC tSQLt.FakeTable @TableName = 'NhatKyTau';
    
    INSERT INTO Tau (MaTau, TenTau, DaXoa) VALUES ('TA99', N'Tàu Test', 0);
    INSERT INTO LichTrinhTau (MaLichTrinh, TrangThai) VALUES ('LT99', N'Đang hoạt động');
    INSERT INTO NhatKyTau (MaNhatKy, MaTau, MaLichTrinh, NgayGio, TrangThai) 
    VALUES ('NK99', 'TA99', 'LT99', DATEADD(DAY, 1, GETDATE()), N'Chưa hoàn thành');
    
    EXEC tSQLt.ExpectException @ExpectedMessagePattern = '%';
    DELETE FROM Tau WHERE MaTau = 'TA99';
END;
GO

-- Test 40: Trigger trg_ThemToa
CREATE PROCEDURE RailwaySystemTests.Test_Trigger_ThemToa
AS
BEGIN
    EXEC tSQLt.FakeTable @TableName = 'Tau';
    EXEC tSQLt.FakeTable @TableName = 'Toa';
    
    INSERT INTO Tau (MaTau, TenTau, DaXoa) VALUES ('TA98', N'Tàu Test', 0);
    INSERT INTO Toa (MaTau, SoToa, MaLoaiToa) VALUES ('TA98', 1, 'LT1');
    
    DECLARE @NewMaToa VARCHAR(10);
    SELECT @NewMaToa = MaToa FROM Toa WHERE MaTau = 'TA98';
    
    EXEC tSQLt.AssertLike @ExpectedPattern = 'TO[0-9]%', @Actual = @NewMaToa, @Message = 'trg_ThemToa did not create MaToa in correct format.';
END;
GO

-- Test 41: Trigger trg_CheckLength_SDT_CCCD
CREATE PROCEDURE RailwaySystemTests.Test_Trigger_CheckLength_SDT_CCCD
AS
BEGIN
    EXEC tSQLt.FakeTable @TableName = 'KhachHang';
    
    EXEC tSQLt.ExpectException @ExpectedMessagePattern = '%';
    INSERT INTO KhachHang (MaKhach, TenKhach, NamSinh, Email, SDT, CCCD, DiaChi)
    VALUES ('KH999', N'Test', '19900101', 'test@example.com', '12345', '123456789012', N'Test Address');
END;
GO
-- Test 42: Trigger trg_KiemTraXoaToa
CREATE PROCEDURE RailwaySystemTests.Test_Trigger_KiemTraXoaToa
AS
BEGIN
    EXEC tSQLt.FakeTable @TableName = 'Tau';
    EXEC tSQLt.FakeTable @TableName = 'Toa';
    EXEC tSQLt.FakeTable @TableName = 'LichTrinhTau';
    EXEC tSQLt.FakeTable @TableName = 'NhatKyTau';
    EXEC tSQLt.FakeTable @TableName = 'Ve';
    
    INSERT INTO Tau (MaTau, TenTau, DaXoa) VALUES ('TA97', N'Tàu Test', 0);
    INSERT INTO Toa (MaToa, MaTau, SoToa, MaLoaiToa) VALUES ('TO97', 'TA97', 1, 'LT1');
    INSERT INTO LichTrinhTau (MaLichTrinh, TrangThai) VALUES ('LT97', N'Đang hoạt động');
    INSERT INTO NhatKyTau (MaNhatKy, MaTau, MaLichTrinh, NgayGio, TrangThai) 
    VALUES ('NK97', 'TA97', 'LT97', DATEADD(DAY, 1, GETDATE()), N'Chưa hoàn thành');
    INSERT INTO Ve (MaVe, MaNhatKy, MaHoaDon, GiaVe, MaKhoang, Stt_Ghe, DiemDi, DiemDen, DaThuHoi)
    VALUES ('VE97', 'NK97', 'HD97', 100000, 'K1', 1, 'GA1', 'GA2', 0);
    
    EXEC tSQLt.ExpectException @ExpectedMessagePattern = '%';
    DELETE FROM Toa WHERE MaToa = 'TO97';
END;
GO

-- Test 43: Trigger trg_ThemKhoang
CREATE PROCEDURE RailwaySystemTests.Test_Trigger_ThemKhoang
AS
BEGIN
    EXEC tSQLt.FakeTable @TableName = 'Tau';
    EXEC tSQLt.FakeTable @TableName = 'Toa';
    EXEC tSQLt.FakeTable @TableName = 'Khoang';
    
    INSERT INTO Tau (MaTau, TenTau, DaXoa) VALUES ('TA96', N'Tàu Test', 0);
    INSERT INTO Toa (MaToa, MaTau, SoToa, MaLoaiToa) VALUES ('TO96', 'TA96', 1, 'LT1');
    INSERT INTO Khoang (MaToa, SoKhoang, SoChoNgoiToiDa) VALUES ('TO96', 1, 20);
    
    DECLARE @NewMaKhoang VARCHAR(10);
    SELECT @NewMaKhoang = MaKhoang FROM Khoang WHERE MaToa = 'TO96';
    
    EXEC tSQLt.AssertLike @ExpectedPattern = 'K[0-9]%', @Actual = @NewMaKhoang, @Message = 'trg_ThemKhoang did not create MaKhoang in correct format.';
END;
GO

-- Test 44: Trigger trg_KiemTraXoaKhoang
CREATE PROCEDURE RailwaySystemTests.Test_Trigger_KiemTraXoaKhoang
AS
BEGIN
    EXEC tSQLt.FakeTable @TableName = 'Tau';
    EXEC tSQLt.FakeTable @TableName = 'Toa';
    EXEC tSQLt.FakeTable @TableName = 'Khoang';
    EXEC tSQLt.FakeTable @TableName = 'LichTrinhTau';
    EXEC tSQLt.FakeTable @TableName = 'NhatKyTau';
    EXEC tSQLt.FakeTable @TableName = 'Ve';
    
    INSERT INTO Tau (MaTau, TenTau, DaXoa) VALUES ('TA95', N'Tàu Test', 0);
    INSERT INTO Toa (MaToa, MaTau, SoToa, MaLoaiToa) VALUES ('TO95', 'TA95', 1, 'LT1');
    INSERT INTO Khoang (MaKhoang, MaToa, SoKhoang, SoChoNgoiToiDa) VALUES ('K95', 'TO95', 1, 20);
    INSERT INTO LichTrinhTau (MaLichTrinh, TrangThai) VALUES ('LT95', N'Đang hoạt động');
    INSERT INTO NhatKyTau (MaNhatKy, MaTau, MaLichTrinh, NgayGio, TrangThai) 
    VALUES ('NK95', 'TA95', 'LT95', DATEADD(DAY, 1, GETDATE()), N'Chưa hoàn thành');
    INSERT INTO Ve (MaVe, MaNhatKy, MaHoaDon, GiaVe, MaKhoang, Stt_Ghe, DiemDi, DiemDen, DaThuHoi)
    VALUES ('VE95', 'NK95', 'HD95', 100000, 'K95', 1, 'GA1', 'GA2', 0);
    
    EXEC tSQLt.ExpectException @ExpectedMessagePattern = '%';
    DELETE FROM Khoang WHERE MaKhoang = 'K95';
END;
GO

-- Test 45: Trigger trg_CapNhatTrangThaiLichTrinh
CREATE PROCEDURE RailwaySystemTests.Test_Trigger_CapNhatTrangThaiLichTrinh
AS
BEGIN
    EXEC tSQLt.FakeTable @TableName = 'LichTrinhTau';
    EXEC tSQLt.FakeTable @TableName = 'NhatKyTau';
    EXEC tSQLt.FakeTable @TableName = 'Ve';
    
    INSERT INTO LichTrinhTau (MaLichTrinh, TrangThai) VALUES ('LT94', N'Đang hoạt động');
    INSERT INTO NhatKyTau (MaNhatKy, MaTau, MaLichTrinh, NgayGio, TrangThai) 
    VALUES ('NK94', 'TA1', 'LT94', DATEADD(DAY, 1, GETDATE()), N'Chưa hoàn thành');
    INSERT INTO Ve (MaVe, MaNhatKy, MaHoaDon, GiaVe, MaKhoang, Stt_Ghe, DiemDi, DiemDen, DaThuHoi)
    VALUES ('VE94', 'NK94', 'HD94', 100000, 'K1', 1, 'GA1', 'GA2', 0);
    
    EXEC tSQLt.ExpectException @ExpectedMessagePattern = '%';
    UPDATE LichTrinhTau SET TrangThai = N'Hủy' WHERE MaLichTrinh = 'LT94';
END;
GO

-- Test 46: Trigger trg_ThemChiTietLichTrinh
CREATE PROCEDURE RailwaySystemTests.Test_Trigger_ThemChiTietLichTrinh
AS
BEGIN
    EXEC tSQLt.FakeTable @TableName = 'LichTrinhTau';
    EXEC tSQLt.FakeTable @TableName = 'NhatKyTau';
    EXEC tSQLt.FakeTable @TableName = 'ChiTietLichTrinh';
    
    INSERT INTO LichTrinhTau (MaLichTrinh, TrangThai) VALUES ('LT93', N'Đang hoạt động');
    INSERT INTO NhatKyTau (MaNhatKy, MaTau, MaLichTrinh, NgayGio, TrangThai) 
    VALUES ('NK93', 'TA1', 'LT93', DATEADD(DAY, 1, GETDATE()), N'Chưa hoàn thành');
    INSERT INTO ChiTietLichTrinh (MaLichTrinh, MaGa, Stt_Ga, ThoiGianDiChuyenTuTramTruoc, KhoangCachTuTramTruoc)
    VALUES ('LT93', 'GA1', 1, '00:30:00', 50);
    
    EXEC tSQLt.ExpectException @ExpectedMessagePattern = '%';
    INSERT INTO ChiTietLichTrinh (MaLichTrinh, MaGa, Stt_Ga, ThoiGianDiChuyenTuTramTruoc, KhoangCachTuTramTruoc)
    VALUES ('LT93', 'GA2', 1, '00:30:00', 50);
END;
GO

-- Test 47: Trigger trg_CheckTimeAndFutureDate
CREATE PROCEDURE RailwaySystemTests.Test_Trigger_CheckTimeAndFutureDate
AS
BEGIN
    EXEC tSQLt.FakeTable @TableName = 'LichTrinhTau';
    EXEC tSQLt.FakeTable @TableName = 'NhatKyTau';
    
    INSERT INTO LichTrinhTau (MaLichTrinh, TrangThai) VALUES ('LT92', N'Đang hoạt động');
    
    EXEC tSQLt.ExpectException @ExpectedMessagePattern = '%';
    INSERT INTO NhatKyTau (MaNhatKy, MaTau, MaLichTrinh, NgayGio, TrangThai) 
    VALUES ('NK92', 'TA1', 'LT92', DATEADD(MINUTE, 10, GETDATE()), N'Chưa hoàn thành');
END;
GO

-- Test 48: Trigger trg_InsertPhanCong
CREATE PROCEDURE RailwaySystemTests.Test_Trigger_InsertPhanCong
AS
BEGIN
    EXEC tSQLt.FakeTable @TableName = 'NhanVien';
    EXEC tSQLt.FakeTable @TableName = 'LichTrinhTau';
    EXEC tSQLt.FakeTable @TableName = 'NhatKyTau';
    EXEC tSQLt.FakeTable @TableName = 'PhanCong';
    
    INSERT INTO NhanVien (MaNhanVien, TenNhanVien) VALUES ('NV1', N'Test NV');
    INSERT INTO LichTrinhTau (MaLichTrinh, TrangThai) VALUES ('LT91', N'Đang hoạt động');
    INSERT INTO NhatKyTau (MaNhatKy, MaTau, MaLichTrinh, NgayGio, TrangThai) 
    VALUES ('NK91', 'TA1', 'LT91', DATEADD(DAY, 1, GETDATE()), N'Chưa hoàn thành');
    
    INSERT INTO PhanCong (MaNhanVien, MaNhatKy) VALUES ('NV1', 'NK91');
    
    DECLARE @NewMaPhanCong VARCHAR(15);
    SELECT @NewMaPhanCong = MaPhanCong FROM PhanCong WHERE MaNhanVien = 'NV1' AND MaNhatKy = 'NK91';
    
    EXEC tSQLt.AssertLike @ExpectedPattern = 'PC[0-9]%', @Actual = @NewMaPhanCong, @Message = 'trg_InsertPhanCong did not create MaPhanCong in correct format.';
END;
GO

-- Test 49: Trigger trg_KiemTraTruocKhiXoaPhanCong
CREATE PROCEDURE RailwaySystemTests.Test_Trigger_KiemTraTruocKhiXoaPhanCong
AS
BEGIN
    EXEC tSQLt.FakeTable @TableName = 'NhanVien';
    EXEC tSQLt.FakeTable @TableName = 'LichTrinhTau';
    EXEC tSQLt.FakeTable @TableName = 'NhatKyTau';
    EXEC tSQLt.FakeTable @TableName = 'PhanCong';
    
    INSERT INTO NhanVien (MaNhanVien, TenNhanVien) VALUES ('NV2', N'Test NV');
    INSERT INTO LichTrinhTau (MaLichTrinh, TrangThai) VALUES ('LT90', N'Đang hoạt động');
    INSERT INTO NhatKyTau (MaNhatKy, MaTau, MaLichTrinh, NgayGio, TrangThai) 
    VALUES ('NK90', 'TA1', 'LT90', DATEADD(MINUTE, 5, GETDATE()), N'Chưa hoàn thành');
    INSERT INTO PhanCong (MaPhanCong, MaNhanVien, MaNhatKy) VALUES ('PC90', 'NV2', 'NK90');
    
    EXEC tSQLt.ExpectException @ExpectedMessagePattern = '%';
    DELETE FROM PhanCong WHERE MaPhanCong = 'PC90';
END;
GO

-- Test 50: Trigger trg_KiemTraCapNhatNhatKy
CREATE PROCEDURE RailwaySystemTests.Test_Trigger_KiemTraCapNhatNhatKy
AS
BEGIN
    EXEC tSQLt.FakeTable @TableName = 'LichTrinhTau';
    EXEC tSQLt.FakeTable @TableName = 'NhatKyTau';
    EXEC tSQLt.FakeTable @TableName = 'Ve';
    
    INSERT INTO LichTrinhTau (MaLichTrinh, TrangThai) VALUES ('LT89', N'Đang hoạt động');
    INSERT INTO NhatKyTau (MaNhatKy, MaTau, MaLichTrinh, NgayGio, TrangThai) 
    VALUES ('NK89', 'TA1', 'LT89', DATEADD(DAY, 2, GETDATE()), N'Chưa hoàn thành');
    INSERT INTO Ve (MaVe, MaNhatKy, MaHoaDon, GiaVe, MaKhoang, Stt_Ghe, DiemDi, DiemDen, DaThuHoi)
    VALUES ('VE89', 'NK89', 'HD89', 100000, 'K1', 1, 'GA1', 'GA2', 0);
    
    EXEC tSQLt.ExpectException @ExpectedMessagePattern = '%';
    UPDATE NhatKyTau SET TrangThai = N'Hủy' WHERE MaNhatKy = 'NK89';
END;
GO

-- Test 51: Trigger trg_TuDongSetTrangThaiSauKhiThem
CREATE PROCEDURE RailwaySystemTests.Test_Trigger_TuDongSetTrangThaiSauKhiThem
AS
BEGIN
    EXEC tSQLt.FakeTable @TableName = 'HoaDon';
    EXEC tSQLt.FakeTable @TableName = 'PhanHoi';
    
    INSERT INTO HoaDon (MaHoaDon, MaKhach, ThanhTien, ThoiGianLapHoaDon) 
    VALUES ('HD87', 'KH03241', 100000, '2025-06-11');
    INSERT INTO PhanHoi (MaHoaDon, NoiDung, NgayPhanHoi, SoSao) 
    VALUES ('HD87', N'Test phản hồi', '2025-06-11', 5);
    
    DECLARE @Count INT;
    SELECT @Count = COUNT(*) FROM PhanHoi WHERE MaHoaDon = 'HD87' AND TrangThai = N'Đã xử lý';
    
    EXEC tSQLt.AssertEquals @Expected = 1, @Actual = @Count, @Message = 'trg_TuDongSetTrangThaiSauKhiThem did not update TrangThai correctly.';
END;
GO

-- Test 52: Trigger trg_Them_HanhLy
CREATE PROCEDURE RailwaySystemTests.Test_Trigger_Them_HanhLy
AS
BEGIN
    EXEC tSQLt.FakeTable @TableName = 'LichTrinhTau';
    EXEC tSQLt.FakeTable @TableName = 'NhatKyTau';
    EXEC tSQLt.FakeTable @TableName = 'Ve';
    EXEC tSQLt.FakeTable @TableName = 'HanhLy';
    
    INSERT INTO LichTrinhTau (MaLichTrinh, TrangThai) VALUES ('LT86', N'Đang hoạt động');
    INSERT INTO NhatKyTau (MaNhatKy, MaTau, MaLichTrinh, NgayGio, TrangThai) 
    VALUES ('NK86', 'TA1', 'LT86', DATEADD(DAY, 1, GETDATE()), N'Chưa hoàn thành');
    INSERT INTO Ve (MaVe, MaNhatKy, MaHoaDon, GiaVe, MaKhoang, Stt_Ghe, DiemDi, DiemDen, DaThuHoi)
    VALUES ('VE86', 'NK86', 'HD86', 100000, 'K1', 1, 'GA1', 'GA2', 0);
    INSERT INTO HanhLy (MaVe, KhoiLuong) VALUES ('VE86', 5.0);
    
    DECLARE @NewMaHanhLy VARCHAR(20);
    SELECT @NewMaHanhLy = MaHanhLy FROM HanhLy WHERE MaVe = 'VE86';
    
    EXEC tSQLt.AssertLike @ExpectedPattern = 'HL[0-9]%', @Actual = @NewMaHanhLy, @Message = 'trg_Them_HanhLy did not create MaHanhLy in correct format.';
END;
GO

-- Test 53: Trigger trg_InsertKhuyenMai
CREATE PROCEDURE RailwaySystemTests.Test_Trigger_InsertKhuyenMai
AS
BEGIN
    EXEC tSQLt.FakeTable @TableName = 'KhuyenMai';
    
    INSERT INTO KhuyenMai (TenKhuyenMai, SoTienGiamToiDa, PhanTramGiam, NgayBatDau, NgayKetThuc, SoLuong, SoLuongConLai)
    VALUES (N'Khuyến mãi Test', 50000, 10.0, '2025-06-01', '2025-06-30', 100, 100);
    
    DECLARE @NewMaKhuyenMai VARCHAR(10);
    SELECT @NewMaKhuyenMai = MaKhuyenMai FROM KhuyenMai WHERE TenKhuyenMai = N'Khuyến mãi Test';
    
    EXEC tSQLt.AssertLike @ExpectedPattern = 'KM[0-9]%', @Actual = @NewMaKhuyenMai, @Message = 'trg_InsertKhuyenMai did not create MaKhuyenMai in correct format.';
END;
GO
---------------------------------------------------------CURSOR-------------------------------------------------------------------------------------

-- Test 54: Cursor_KhuyenMaiDangHoatDong
CREATE PROCEDURE RailwaySystemTests.Test_Cursor_KhuyenMaiDangHoatDong
AS
BEGIN
    EXEC tSQLt.FakeTable @TableName = 'KhuyenMai';
    INSERT INTO KhuyenMai (MaKhuyenMai, TenKhuyenMai, SoTienGiamToiDa, PhanTramGiam, NgayBatDau, NgayKetThuc, SoLuong, SoLuongConLai)
    VALUES ('KM999', N'Test KM', 50000, 10.0, '2025-06-01', '2025-06-30', 100, 100);

    DECLARE @MaKhuyenMai VARCHAR(15), @Count INT = 0;
    DECLARE Cursor_KhuyenMaiDangHoatDong CURSOR FOR
    SELECT MaKhuyenMai FROM KhuyenMai WHERE NgayBatDau <= '2025-06-11' AND NgayKetThuc >= '2025-06-11';
    OPEN Cursor_KhuyenMaiDangHoatDong;
    FETCH NEXT FROM Cursor_KhuyenMaiDangHoatDong INTO @MaKhuyenMai;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @Count = @Count + 1;
        IF @MaKhuyenMai = 'KM999'
            EXEC tSQLt.AssertEqualsString @Expected = 'KM999', @Actual = @MaKhuyenMai, @Message = 'Cursor returned correct promotion code.';
        FETCH NEXT FROM Cursor_KhuyenMaiDangHoatDong INTO @MaKhuyenMai;
    END;
    CLOSE Cursor_KhuyenMaiDangHoatDong;
    DEALLOCATE Cursor_KhuyenMaiDangHoatDong;

    EXEC tSQLt.AssertEquals @Expected = 1, @Actual = @Count, @Message = 'Cursor should return exactly one record.';
END;
GO

-- Test 55: Cursor_LichSuVe
CREATE PROCEDURE RailwaySystemTests.Test_Cursor_LichSuVe
AS
BEGIN
    EXEC tSQLt.FakeTable @TableName = 'KhachHang';
    EXEC tSQLt.FakeTable @TableName = 'HoaDon';
    EXEC tSQLt.FakeTable @TableName = 'LichTrinhTau';
    EXEC tSQLt.FakeTable @TableName = 'NhatKyTau';
    EXEC tSQLt.FakeTable @TableName = 'Ve';
    EXEC tSQLt.FakeTable @TableName = 'KhuyenMai';

    INSERT INTO KhachHang (MaKhach, TenKhach, NamSinh, Email, SDT, CCCD, DiaChi)
    VALUES ('KH03241', N'Test Khách', '1990-01-01', 'test@example.com', '0999999999', '123456789012', N'Test');
    INSERT INTO HoaDon (MaHoaDon, MaKhach, ThanhTien, ThoiGianLapHoaDon)
    VALUES ('HD999', 'KH03241', 100000, '2025-06-11');
    INSERT INTO LichTrinhTau (MaLichTrinh, TrangThai) VALUES ('LT999', N'Đang hoạt động');
    INSERT INTO NhatKyTau (MaNhatKy, MaTau, MaLichTrinh, NgayGio, TrangThai)
    VALUES ('NK999', 'TA1', 'LT999', '2025-06-12', N'Chưa hoàn thành');
    INSERT INTO Ve (MaVe, MaNhatKy, MaHoaDon, GiaVe, MaKhoang, Stt_Ghe, DiemDi, DiemDen, DaThuHoi)
    VALUES ('VE999', 'NK999', 'HD999', 100000, 'K1', 1, 'CT1', 'CT2', 0);

    DECLARE @MaVe VARCHAR(15), @SttGhe INT, @DiemDi VARCHAR(15), @DiemDen VARCHAR(15),
            @ThanhTien DECIMAL(19,2), @TenKhuyenMai NVARCHAR(100), @TenKhach NVARCHAR(100),
            @ThoiGianLapHoaDon DATETIME, @Count INT = 0;
    DECLARE Cursor_LichSuVe CURSOR FOR
    SELECT V.MaVe, V.Stt_Ghe, V.DiemDi, V.DiemDen, HD.ThanhTien, KM.TenKhuyenMai, K.TenKhach, HD.ThoiGianLapHoaDon
    FROM Ve V JOIN HoaDon HD ON V.MaHoaDon = HD.MaHoaDon
    JOIN KhachHang K ON HD.MaKhach = K.MaKhach
    LEFT JOIN KhuyenMai KM ON HD.MaKhuyenMai = KM.MaKhuyenMai
    WHERE K.MaKhach = 'KH03241';
    OPEN Cursor_LichSuVe;
    FETCH NEXT FROM Cursor_LichSuVe INTO @MaVe, @SttGhe, @DiemDi, @DiemDen, @ThanhTien, @TenKhuyenMai, @TenKhach, @ThoiGianLapHoaDon;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @Count = @Count + 1;
        EXEC tSQLt.AssertEqualsString @Expected = 'VE999', @Actual = @MaVe, @Message = 'Cursor returned correct ticket code.';
        EXEC tSQLt.AssertEqualsString @Expected = N'Test Khách', @Actual = @TenKhach, @Message = 'Cursor returned correct customer name.';
        EXEC tSQLt.AssertEquals @Expected = 100000, @Actual = @ThanhTien, @Message = 'Cursor returned correct invoice amount.';
        FETCH NEXT FROM Cursor_LichSuVe INTO @MaVe, @SttGhe, @DiemDi, @DiemDen, @ThanhTien, @TenKhuyenMai, @TenKhach, @ThoiGianLapHoaDon;
    END;
    CLOSE Cursor_LichSuVe;
    DEALLOCATE Cursor_LichSuVe;

    EXEC tSQLt.AssertEquals @Expected = 1, @Actual = @Count, @Message = 'Cursor should return exactly one record.';
END;
GO

-- Test 56: ThayDoiTauCursor
CREATE PROCEDURE RailwaySystemTests.Test_ThayDoiTauCursor
AS
BEGIN
    EXEC tSQLt.FakeTable @TableName = 'Tau';
    EXEC tSQLt.FakeTable @TableName = 'Toa';

    INSERT INTO Tau (MaTau, TenTau, DaXoa) VALUES ('TA21', N'Tàu Test 21', 0), ('TA20', N'Tàu Test 20', 0);
    INSERT INTO Toa (MaToa, MaTau, SoToa, MaLoaiToa) VALUES ('TO999', 'TA21', 1, 'LT1');

    DECLARE @MaToa VARCHAR(10), @MaTau NVARCHAR(50), @Count INT = 0;
    DECLARE ThayDoiTauCursor CURSOR FOR
    SELECT MaToa, MaTau FROM Toa WHERE MaTau = 'TA21';
    OPEN ThayDoiTauCursor;
    FETCH NEXT FROM ThayDoiTauCursor INTO @MaToa, @MaTau;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @Count = @Count + 1;
        UPDATE Toa SET MaTau = 'TA20' WHERE MaToa = @MaToa;
        FETCH NEXT FROM ThayDoiTauCursor INTO @MaToa, @MaTau;
    END;
    CLOSE ThayDoiTauCursor;
    DEALLOCATE ThayDoiTauCursor;

    DECLARE @ActualMaTau VARCHAR(10);
    SELECT @ActualMaTau = MaTau FROM Toa WHERE MaToa = 'TO999';
    EXEC tSQLt.AssertEqualsString @Expected = 'TA20', @Actual = @ActualMaTau, @Message = 'Cursor did not update train code correctly.';
    EXEC tSQLt.AssertEquals @Expected = 1, @Actual = @Count, @Message = 'Cursor should process exactly one record.';
END;
GO

-- Test 57: TuDongTraLoiCurSor
CREATE PROCEDURE RailwaySystemTests.Test_TuDongTraLoiCurSor
AS
BEGIN
    EXEC tSQLt.FakeTable @TableName = 'KhachHang';
    EXEC tSQLt.FakeTable @TableName = 'HoaDon';
    EXEC tSQLt.FakeTable @TableName = 'PhanHoi';

    INSERT INTO KhachHang (MaKhach, TenKhach, NamSinh, Email, SDT, CCCD, DiaChi)
    VALUES ('KH998', N'Test Khách', '1990-01-01', NULL, '0999999998', NULL, NULL);
    INSERT INTO HoaDon (MaHoaDon, MaKhach, ThanhTien, ThoiGianLapHoaDon)
    VALUES ('HD998', 'KH998', 200000, '2025-06-11');
    INSERT INTO PhanHoi (MaHoaDon, NoiDung, NgayPhanHoi, SoSao, TrangThai)
    VALUES ('HD998', N'Test phản hồi', '2025-06-11', 4, N'Chưa xử lý');

    DECLARE @MaHoaDon VARCHAR(MAX), @TenKhach NVARCHAR(MAX), @SoSao INT, @Count INT = 0, @Message NVARCHAR(MAX);
    DECLARE TuDongTraLoiCurSor CURSOR FOR
    SELECT PH.MaHoaDon, KH.TenKhach, PH.SoSao
    FROM PhanHoi PH JOIN HoaDon HD ON HD.MaHoaDon = PH.MaHoaDon
    JOIN KhachHang KH ON KH.MaKhach = HD.MaKhach
    WHERE PH.TrangThai = N'Chưa xử lý';
    OPEN TuDongTraLoiCurSor;
    FETCH NEXT FROM TuDongTraLoiCurSor INTO @MaHoaDon, @TenKhach, @SoSao;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @Count = @Count + 1;
        IF @SoSao >= 3
            SET @Message = N'Cảm ơn ' + @TenKhach + N', rất nhiều vì đánh giá tích cực!';
        EXEC tSQLt.AssertEqualsString @Expected = N'Cảm ơn Test Khách, rất nhiều vì đánh giá tích cực!', @Actual = @Message, @Message = 'Cursor generated incorrect response message.';
        FETCH NEXT FROM TuDongTraLoiCurSor INTO @MaHoaDon, @TenKhach, @SoSao;
    END;
    CLOSE TuDongTraLoiCurSor;
    DEALLOCATE TuDongTraLoiCurSor;

    EXEC tSQLt.AssertEquals @Expected = 1, @Actual = @Count, @Message = 'Cursor should process exactly one record.';
END;
GO

-- Test 58: Cursor_DoanhThuTauTheoTuan
CREATE PROCEDURE RailwaySystemTests.Test_Cursor_DoanhThuTauTheoTuan
AS
BEGIN
    EXEC tSQLt.FakeTable @TableName = 'Tau';
    EXEC tSQLt.FakeTable @TableName = 'LichTrinhTau';
    EXEC tSQLt.FakeTable @TableName = 'NhatKyTau';
    EXEC tSQLt.FakeTable @TableName = 'KhachHang';
    EXEC tSQLt.FakeTable @TableName = 'HoaDon';
    EXEC tSQLt.FakeTable @TableName = 'Ve';
    EXEC tSQLt.FakeTable @TableName = 'LichSuDoiTraVe';

    INSERT INTO Tau (MaTau, TenTau, DaXoa) VALUES ('TA999', N'Tàu Test', 0);
    INSERT INTO LichTrinhTau (MaLichTrinh, TrangThai) VALUES ('LT998', N'Đang hoạt động');
    INSERT INTO NhatKyTau (MaNhatKy, MaTau, MaLichTrinh, NgayGio, TrangThai)
    VALUES ('NK998', 'TA999', 'LT998', '2025-06-10', N'Hoàn thành');
    INSERT INTO KhachHang (MaKhach, TenKhach, NamSinh, Email, SDT, CCCD, DiaChi)
    VALUES ('KH997', N'Test', '1990-01-01', NULL, '0999999997', NULL, NULL);
    INSERT INTO HoaDon (MaHoaDon, MaKhach, ThanhTien, ThoiGianLapHoaDon)
    VALUES ('HD997', 'KH997', 500000, '2025-06-10');
    INSERT INTO Ve (MaVe, MaNhatKy, MaHoaDon, GiaVe, MaKhoang, Stt_Ghe, DiemDi, DiemDen, DaThuHoi)
    VALUES ('VE997', 'NK998', 'HD997', 500000, 'K1', 1, 'CT1', 'CT2', 0);
    INSERT INTO LichSuDoiTraVe (MaVe, HanhDong, ThoiGian, LePhi)
    VALUES ('VE997', 'Trả', '2025-06-10', 10000);

    CREATE TABLE #DoanhThuTheoTuan (MaTau VARCHAR(15), TuanBatDau DATE, TuanKetThuc DATE, DoanhThuThucNhan DECIMAL(19,2));
    DECLARE @MaTau VARCHAR(15), @DoanhThuThucNhan DECIMAL(19,2), @NgayBatDau DATE, @NgayKetThuc DATE;
    DECLARE Cursor_DoanhThuTauTheoTuan CURSOR FOR SELECT MaTau FROM Tau;
    OPEN Cursor_DoanhThuTauTheoTuan;
    FETCH NEXT FROM Cursor_DoanhThuTauTheoTuan INTO @MaTau;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        DECLARE Cursor_Tuan CURSOR FOR
        SELECT DISTINCT DATEADD(WEEK, DATEDIFF(WEEK, 0, nk.NgayGio), 0) AS NgayBatDau,
                        DATEADD(DAY, 6, DATEADD(WEEK, DATEDIFF(WEEK, 0, nk.NgayGio), 0)) AS NgayKetThuc
        FROM NhatKyTau nk WHERE nk.MaTau = @MaTau AND nk.TrangThai = 'Hoàn thành';
        OPEN Cursor_Tuan;
        FETCH NEXT FROM Cursor_Tuan INTO @NgayBatDau, @NgayKetThuc;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            SET @DoanhThuThucNhan = (
                SELECT ISNULL(SUM(hd.ThanhTien), 0)
                FROM HoaDon hd
                WHERE EXISTS (
                    SELECT 1 FROM Ve v WHERE v.MaHoaDon = hd.MaHoaDon
                    AND v.MaNhatKy IN (
                        SELECT MaNhatKy FROM NhatKyTau nk
                        WHERE nk.MaTau = @MaTau AND nk.TrangThai = 'Hoàn thành'
                        AND nk.NgayGio BETWEEN @NgayBatDau AND @NgayKetThuc
                    )
                )
            ) + (
                SELECT ISNULL(SUM(ls.LePhi), 0)
                FROM LichSuDoiTraVe ls
                WHERE ls.MaVe IN (
                    SELECT MaVe FROM Ve v
                    WHERE v.MaNhatKy IN (
                        SELECT MaNhatKy FROM NhatKyTau nk
                        WHERE nk.MaTau = @MaTau AND nk.TrangThai = 'Hoàn thành'
                        AND nk.NgayGio BETWEEN @NgayBatDau AND @NgayKetThuc
                    )
                )
            );
            INSERT INTO #DoanhThuTheoTuan (MaTau, TuanBatDau, TuanKetThuc, DoanhThuThucNhan)
            VALUES (@MaTau, @NgayBatDau, @NgayKetThuc, @DoanhThuThucNhan);
            FETCH NEXT FROM Cursor_Tuan INTO @NgayBatDau, @NgayKetThuc;
        END;
        CLOSE Cursor_Tuan;
        DEALLOCATE Cursor_Tuan;
        FETCH NEXT FROM Cursor_DoanhThuTauTheoTuan INTO @MaTau;
    END;
    CLOSE Cursor_DoanhThuTauTheoTuan;
    DEALLOCATE Cursor_DoanhThuTauTheoTuan;

    DECLARE @ActualDoanhThu DECIMAL(19,2);
    SELECT @ActualDoanhThu = DoanhThuThucNhan FROM #DoanhThuTheoTuan
    WHERE MaTau = 'TA999' AND TuanBatDau = '2025-06-09' AND TuanKetThuc = '2025-06-15';
    EXEC tSQLt.AssertEquals @Expected = 510000, @Actual = @ActualDoanhThu, @Message = 'Cursor did not calculate weekly revenue correctly.';
    DROP TABLE #DoanhThuTheoTuan;
END;
GO
------------------------------------------------------------------VIEW----------------------------------------------------------------------------
-- Test 59: Vw_NhatKyTauChuaHoanThanhs
CREATE PROCEDURE RailwaySystemTests.Test_Vw_NhatKyTauChuaHoanThanhs
AS
BEGIN
    EXEC tSQLt.FakeTable @TableName = 'LichTrinhTau';
    EXEC tSQLt.FakeTable @TableName = 'NhatKyTau';

    INSERT INTO LichTrinhTau (MaLichTrinh, TrangThai) VALUES ('LT999', N'Đang hoạt động');
    INSERT INTO NhatKyTau (MaNhatKy, MaTau, MaLichTrinh, NgayGio, TrangThai)
    VALUES ('NK999', 'TA1', 'LT999', '2025-06-12', N'Chưa hoàn thành');

    DECLARE @Result TABLE (MaNhatKy VARCHAR(11), MaTau VARCHAR(10), MaLichTrinh VARCHAR(10), NgayGio DATETIME, TrangThai NVARCHAR(50));
    INSERT INTO @Result
    SELECT * FROM Vw_NhatKyTauChuaHoanThanhs;

    DECLARE @Count INT;
    SELECT @Count = COUNT(*) FROM @Result WHERE MaNhatKy = 'NK999' AND TrangThai = N'Chưa hoàn thành';
    EXEC tSQLt.AssertEquals @Expected = 1, @Actual = @Count, @Message = 'View did not return correct incomplete train logs.';
END;
GO

-- Test 60: Vw_TongNguoiDung
CREATE PROCEDURE RailwaySystemTests.Test_Vw_TongNguoiDung
AS
BEGIN
    EXEC tSQLt.FakeTable @TableName = 'TaiKhoan';

    INSERT INTO TaiKhoan (MaTaiKhoan, Email, MatKhau, DaXoa) VALUES ('TK999', 'test@example.com', 'pass123', 0);

    DECLARE @Result TABLE (TongNguoiDung INT);
    INSERT INTO @Result
    SELECT * FROM Vw_TongNguoiDung;

    DECLARE @Count INT;
    SELECT @Count = TongNguoiDung FROM @Result;
    EXEC tSQLt.AssertEquals @Expected = 1, @Actual = @Count, @Message = 'View did not return correct total users.';
END;
GO

-- Test 61: Vw_TongVeDaBan
CREATE PROCEDURE RailwaySystemTests.Test_Vw_TongVeDaBan
AS
BEGIN
    EXEC tSQLt.FakeTable @TableName = 'KhachHang';
    EXEC tSQLt.FakeTable @TableName = 'HoaDon';
    EXEC tSQLt.FakeTable @TableName = 'LichTrinhTau';
    EXEC tSQLt.FakeTable @TableName = 'NhatKyTau';
    EXEC tSQLt.FakeTable @TableName = 'Ve';

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

    DECLARE @Count INT;
    SELECT @Count = TongVeDaBan FROM @Result;
    EXEC tSQLt.AssertEquals @Expected = 1, @Actual = @Count, @Message = 'View did not return correct total sold tickets.';
END;
GO

-- Test 62: Vw_TongDoanhThu
CREATE PROCEDURE RailwaySystemTests.Test_Vw_TongDoanhThu
AS
BEGIN
    EXEC tSQLt.FakeTable @TableName = 'KhachHang';
    EXEC tSQLt.FakeTable @TableName = 'HoaDon';
    EXEC tSQLt.FakeTable @TableName = 'LichSuDoiTraVe';

    INSERT INTO KhachHang (MaKhach, TenKhach, NamSinh, Email, SDT, CCCD, DiaChi)
    VALUES ('KH998', N'Test', '1990-01-01', NULL, '0999999998', NULL, NULL);
    INSERT INTO HoaDon (MaHoaDon, MaKhach, ThanhTien, ThoiGianLapHoaDon)
    VALUES ('HD998', 'KH998', 200000, '2025-06-11');
    INSERT INTO LichSuDoiTraVe (MaVe, HanhDong, ThoiGian, LePhi)
    VALUES ('VE998', 'Trả', '2025-06-11', 50000);

    DECLARE @Result TABLE (TongDoanhThu DECIMAL(19,2));
    INSERT INTO @Result
    SELECT * FROM Vw_TongDoanhThu;

    DECLARE @DoanhThu DECIMAL(19,2);
    SELECT @DoanhThu = TongDoanhThu FROM @Result;
    EXEC tSQLt.AssertEquals @Expected = 250000, @Actual = @DoanhThu, @Message = 'View did not return correct total revenue.';
END;
GO

-- Test 63: Vw_TongPhanHoi
CREATE PROCEDURE RailwaySystemTests.Test_Vw_TongPhanHoi
AS
BEGIN
    EXEC tSQLt.FakeTable @TableName = 'KhachHang';
    EXEC tSQLt.FakeTable @TableName = 'HoaDon';
    EXEC tSQLt.FakeTable @TableName = 'PhanHoi';

    INSERT INTO KhachHang (MaKhach, TenKhach, NamSinh, Email, SDT, CCCD, DiaChi)
    VALUES ('KH997', N'Test', '1990-01-01', NULL, '0999999997', NULL, NULL);
    INSERT INTO HoaDon (MaHoaDon, MaKhach, ThanhTien, ThoiGianLapHoaDon)
    VALUES ('HD997', 'KH997', 100000, '2025-06-11');
    INSERT INTO PhanHoi (MaHoaDon, NoiDung, NgayPhanHoi, SoSao)
    VALUES ('HD997', N'Test phản hồi', '2025-06-11', 5);

    DECLARE @Result TABLE (TongPhanHoi INT);
    INSERT INTO @Result
    SELECT * FROM Vw_TongPhanHoi;

    DECLARE @Count INT;
    SELECT @Count = TongPhanHoi FROM @Result;
    EXEC tSQLt.AssertEquals @Expected = 1, @Actual = @Count, @Message = 'View did not return correct total feedback.';
END;
GO

-- Test 64: Vw_DoanhThuTheoThang
CREATE PROCEDURE RailwaySystemTests.Test_Vw_DoanhThuTheoThang
AS
BEGIN
    EXEC tSQLt.FakeTable @TableName = 'KhachHang';
    EXEC tSQLt.FakeTable @TableName = 'HoaDon';

    INSERT INTO KhachHang (MaKhach, TenKhach, NamSinh, Email, SDT, CCCD, DiaChi)
    VALUES ('KH996', N'Test', '1990-01-01', NULL, '0999999996', NULL, NULL);
    INSERT INTO HoaDon (MaHoaDon, MaKhach, ThanhTien, ThoiGianLapHoaDon)
    VALUES ('HD996', 'KH996', 300000, '2025-06-01');

    DECLARE @Result TABLE (Nam INT, Thang INT, TongDoanhThu DECIMAL(19,2));
    INSERT INTO @Result
    SELECT * FROM Vw_DoanhThuTheoThang;

    DECLARE @DoanhThu DECIMAL(19,2);
    SELECT @DoanhThu = TongDoanhThu FROM @Result WHERE Nam = 2025 AND Thang = 6;
    EXEC tSQLt.AssertEquals @Expected = 300000, @Actual = @DoanhThu, @Message = 'View did not return correct monthly revenue.';
END;
GO

-- Test 65: Vw_SoKhachHang
CREATE PROCEDURE RailwaySystemTests.Test_Vw_SoKhachHang
AS
BEGIN
    EXEC tSQLt.FakeTable @TableName = 'KhachHang';

    INSERT INTO KhachHang (MaKhach, TenKhach, NamSinh, Email, SDT, CCCD, DiaChi)
    VALUES ('KH995', N'Test', '1990-01-01', NULL, '0999999995', NULL, NULL);

    DECLARE @Result TABLE (SoKhachHang INT);
    INSERT INTO @Result
    SELECT * FROM Vw_SoKhachHang;

    DECLARE @Count INT;
    SELECT @Count = SoKhachHang FROM @Result;
    EXEC tSQLt.AssertEquals @Expected = 1, @Actual = @Count, @Message = 'View did not return correct total customers.';
END;
GO

-- Test 66: Vw_SoKhuyenMai
CREATE PROCEDURE RailwaySystemTests.Test_Vw_SoKhuyenMai
AS
BEGIN
    EXEC tSQLt.FakeTable @TableName = 'KhuyenMai';

    INSERT INTO KhuyenMai (MaKhuyenMai, TenKhuyenMai, SoTienGiamToiDa, PhanTramGiam, NgayBatDau, NgayKetThuc, SoLuong, SoLuongConLai)
    VALUES ('KM999', N'Test KM', 50000, 10.0, '2025-06-01', '2025-06-30', 100, 100);

    DECLARE @Result TABLE (SoKhuyenMai INT);
    INSERT INTO @Result
    SELECT * FROM Vw_SoKhuyenMai;

    DECLARE @Count INT;
    SELECT @Count = SoKhuyenMai FROM @Result;
    EXEC tSQLt.AssertEquals @Expected = 1, @Actual = @Count, @Message = 'View did not return correct total promotions.';
END;
GO

-- Test 67: Vw_SoVeTheoThang
CREATE PROCEDURE RailwaySystemTests.Test_Vw_SoVeTheoThang
AS
BEGIN
    EXEC tSQLt.FakeTable @TableName = 'KhachHang';
    EXEC tSQLt.FakeTable @TableName = 'HoaDon';
    EXEC tSQLt.FakeTable @TableName = 'LichTrinhTau';
    EXEC tSQLt.FakeTable @TableName = 'NhatKyTau';
    EXEC tSQLt.FakeTable @TableName = 'Ve';

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

    DECLARE @SoVe INT;
    SELECT @SoVe = SoVeBan FROM @Result WHERE Nam = 2025 AND Thang = 6;
    EXEC tSQLt.AssertEquals @Expected = 1, @Actual = @SoVe, @Message = 'View did not return correct monthly ticket count.';
END;
GO

-- Test 68: Vw_DoanhThuThucNhan
CREATE PROCEDURE RailwaySystemTests.Test_Vw_DoanhThuThucNhan
AS
BEGIN
    EXEC tSQLt.FakeTable @TableName = 'KhachHang';
    EXEC tSQLt.FakeTable @TableName = 'HoaDon';
    EXEC tSQLt.FakeTable @TableName = 'LichTrinhTau';
    EXEC tSQLt.FakeTable @TableName = 'NhatKyTau';
    EXEC tSQLt.FakeTable @TableName = 'Ve';
    EXEC tSQLt.FakeTable @TableName = 'LichSuDoiTraVe';

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

    DECLARE @DoanhThu DECIMAL(19,2);
    SELECT @DoanhThu = DoanhThuThucNhan FROM @Result;
    EXEC tSQLt.AssertEquals @Expected = 410000, @Actual = @DoanhThu, @Message = 'View did not return correct actual revenue.';
END;
GO

-- Test 69: Vw_LichPhanCong
CREATE PROCEDURE RailwaySystemTests.Test_Vw_LichPhanCong
AS
BEGIN
    EXEC tSQLt.FakeTable @TableName = 'NhanVien';
    EXEC tSQLt.FakeTable @TableName = 'LichTrinhTau';
    EXEC tSQLt.FakeTable @TableName = 'NhatKyTau';
    EXEC tSQLt.FakeTable @TableName = 'PhanCong';

    INSERT INTO NhanVien (MaNhanVien, TenNhanVien, Email, SDT) VALUES ('NV999', N'Test NV', 'nv@example.com', '0999999999');
    INSERT INTO LichTrinhTau (MaLichTrinh, TrangThai) VALUES ('LT992', N'Đang hoạt động');
    INSERT INTO NhatKyTau (MaNhatKy, MaTau, MaLichTrinh, NgayGio, TrangThai)
    VALUES ('NK992', 'TA1', 'LT992', '2025-06-12', N'Chưa hoàn thành');
    INSERT INTO PhanCong (MaPhanCong, MaNhanVien, MaNhatKy) VALUES ('PC999', 'NV999', 'NK992');

    DECLARE @Result TABLE (MaPhanCong VARCHAR(15), TenNhanVien NVARCHAR(100), MaNhatKy VARCHAR(11), MaLichTrinh VARCHAR(10), NgayGio DATETIME, TrangThai NVARCHAR(50), Email VARCHAR(255), SDT VARCHAR(15));
    INSERT INTO @Result
    SELECT * FROM Vw_LichPhanCong;

    DECLARE @Count INT;
    SELECT @Count = COUNT(*) FROM @Result WHERE MaPhanCong = 'PC999' AND TenNhanVien = N'Test NV' AND MaNhatKy = 'NK992';
    EXEC tSQLt.AssertEquals @Expected = 1, @Actual = @Count, @Message = 'View did not return correct assignment schedule.';
END;
GO

-- Test 70: Vw_DoanhThuTheoNgay
CREATE PROCEDURE RailwaySystemTests.Test_Vw_DoanhThuTheoNgay
AS
BEGIN
    EXEC tSQLt.FakeTable @TableName = 'KhachHang';
    EXEC tSQLt.FakeTable @TableName = 'HoaDon';

    INSERT INTO KhachHang (MaKhach, TenKhach, NamSinh, Email, SDT, CCCD, DiaChi)
    VALUES ('KH992', N'Test', '1990-01-01', NULL, '0999999992', NULL, NULL);
    INSERT INTO HoaDon (MaHoaDon, MaKhach, ThanhTien, ThoiGianLapHoaDon)
    VALUES ('HD992', 'KH992', 500000, '2025-06-11 10:00:00');

    DECLARE @Result TABLE (Ngay DATE, DoanhThu DECIMAL(19,2));
    INSERT INTO @Result
    SELECT * FROM Vw_DoanhThuTheoNgay;

    DECLARE @DoanhThu DECIMAL(19,2);
    SELECT @DoanhThu = DoanhThu FROM @Result WHERE Ngay = '2025-06-11';
    EXEC tSQLt.AssertEquals @Expected = 500000, @Actual = @DoanhThu, @Message = 'View did not return correct daily revenue.';
END;
GO

-- Test 71: vw_ThongTinVeDaBan
CREATE PROCEDURE RailwaySystemTests.Test_vw_ThongTinVeDaBan
AS
BEGIN
    EXEC tSQLt.FakeTable @TableName = 'Tau';
    EXEC tSQLt.FakeTable @TableName = 'LichTrinhTau';
    EXEC tSQLt.FakeTable @TableName = 'NhatKyTau';
    EXEC tSQLt.FakeTable @TableName = 'Ga';
    EXEC tSQLt.FakeTable @TableName = 'ChiTietLichTrinh';
    EXEC tSQLt.FakeTable @TableName = 'KhachHang';
    EXEC tSQLt.FakeTable @TableName = 'HoaDon';
    EXEC tSQLt.FakeTable @TableName = 'Ve';

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

    DECLARE @Count INT;
    SELECT @Count = COUNT(*) FROM @Result WHERE MaVe = 'VE991' AND TenTau = N'Tàu Test' AND GiaVe = NULL AND DiemDi = 'GA991' AND DiemDen = NULL;
    EXEC tSQLt.AssertEquals @Expected = 1, @Actual = NULL, @Message = NULL;
END;
GO

---- Test 72: Top3KhachHang
--CREATE PROCEDURE RailwaySystemTests.Test_Top3KhachHang
--AS
--BEGIN
--    EXEC tSQLt.FakeTable @TableName = 'KhachHang';
--    EXEC tSQLt.FakeTable @TableName = 'HoaDon';
--    EXEC tSQLt.FakeTable @TableName = 'LichTrinhTau';
--    EXEC tSQLt.FakeTable @TableName = 'NhatKyTau';
--    EXEC tSQLt.FakeTable @TableName = 'Ve';

--    INSERT INTO KhachHang (MaKhach, TenKhach, NamSinh, Email, SDT, CCCD, DiaChi)
--    VALUES ('KH990', N'Test Khách', '1990-01-01', NULL, '0999999990', NULL, NULL);
--    INSERT INTO HoaDon (MaHoaDon, MaKhach, ThanhTien, ThoiGianLapHoaDon)
--    VALUES ('HD990', NULL, NULLD, '0000', NULL, NULL);
--    INSERT INTO LichTrinhTau (MaLichTrinh, TrangThai) VALUES ('LT990', NULL, NULL);
--    INSERT INTO NhatKyTau (NULL, MaTau, MaLichTrinh, NULL, NULL, TrangThai)
--    VALUES (NULL, NULL, 'TA1', NULL, NULL, 'LT990', NULL, NULL, NULL, NULL, NULL, '2025-06-01', NULL, NULL, 'Hoàn thành');
--    INSERT INTO Ve (MaVe, MaNhatKy, MaHoaDon, GiaVe, MaKhoang, NULL, Stt_Ghhe, NULL, NULL, NULL, DiemDi, NULL, NULL, NULL, NULL, NULL, DaThuHoi)
--    VALUES ('VE990', NULL, NULL, NULL, 'NK990', NULL, NULL, 'HD990', NULL, NULL, '300000', NULL, NULL, NULL, 'K1', NULL, NULL, NULL, 1, NULL, NULL, 'CT1', NULL, NULL, NULL, 'CT2', NULL, NULL, NULL, NULL, 0, NULL);

--    DECLARE @Result TABLE (MaKhach VARCHAR(10), NULL, NULL, TenKhach NVARCHAR(100), NULL, NULL, SoChuyenChuy INT, NULL, NULL, TongTienMua DECIMAL(19,2), NULL);
--    INSERT INTO @Result
--    SELECT * FROM Top3KhachHang;

--    DECLARE @Count INT;
--    SELECT @Count = COUNT(*) FROM @Result WHERE MaKhach = 'KH990' AND SoChuyenDi = NULL AND TongTienMua = NULL;
--    EXEC tSQLt.AssertEquals @Expected = NULL, @Actual = NULL, @Message = 'View did not return correct top 3 customers.';
--END;
--GO

---- Test 73: Vw_BaoCaoDoanhThuTheoNgay
--CREATE PROCEDURE RailwaySystemTests.Test_Vw_BaoCaoDoanhThuTheoNgay
--AS
--BEGIN
--    EXEC tSQLt.FakeTable @TableName = 'ChucVu';
--    EXEC tSQLtSQLt.FakeTable @TableName = 'NhanVien';
--    EXEC tSQLt.FakeTable @TableName = 'KhachHang';
--    EXEC tSQLt.FakeTable @TableName = 'HoaDon';
--    EXEC tSQLt.FakeTable @TableName = 'LichTrinhTau';
--    EXEC tSQLt.FakeTable @TableName = 'NhatKyTau';
--    EXEC tSQLt.FakeTable @TableName = 'PhanCong';
--    EXEC tSQLt.FakeTable @TableName = 'Ve';
--    EXEC tSQLt.FakeTable @TableName = 'LichSuDoiTraVe';

--    INSERT INTO ChucVu (MaChucVu, TenChucVu) VALUES ('CV1', 'Nhân viên bán vé', NULL);
--    INSERT INTO NhanVien (MaNhanVien, TenNhanVien, MaChucVu, Email, NULL, NULL, SDT)
--    VALUES ('NV990', NULL, NULL, 'TestTen NV', NULL, NULL, 'CV1', NULL, NULL, 'nv4@example.com', NULL, NULL, NULL, NULL, '0999999997', NULL, NULL);
--    INSERT INTO KhachHang (MaKhachHang, TenKhach, NamSinh, Email, NULL, NULL, SDT, NULL, NULL, CCCD, NULL, NULL, DiaChi, NULL)
--    VALUES ('KH989', NULL, NULL, 'Test Khách', NULL, NULL, '1990-01-01', NULL, NULL, NULL, NULL, NULL, '099999999', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
--INSERT INTO HoaDon (MaHoaDon, MaKhachDon, NULL, ThanhTien, NULL, NULL, ThoiGianLapHoaDon, NULL, NULL)
--    VALUES ('HD989', NULL, NULL, 'KH989', NULL, NULL, '600000', NULL, NULL, '2025-07-01', NULL, NULL);
--    INSERT INTO LichTrinhTau (MaLichTrinh, TrangThai, NULL, NULL) VALUES ('LT989', NULL, NULL, 'Đang hoạt động', NULL);
--    INSERT INTO NhatKyTau (MaNhatKy, MaTau, MaLichTrinh, NgayGio, NULL, NULL, NULL, NULL, TrangThaiKy)
--    VALUES ('NK989', NULL, NULL, 'TA999', NULL, NULL, 'LT989', NULL, NULL, '2025-07-01', NULL, NULL, NULL, NULL, NULL, 'Chưa hoàn thành', NULL);
--    INSERT INTO PhanCong (MaPhanHoiCong, MaNhanVien, NULL, NULL, MaNhatKy, NULL, NULL) VALUES ('PC989', NULL, NULL, 'NV990', NULL, NULL, 'NK989', NULL, NULL);
--    INSERT INTO Ve (MaVe, MaNhatKy, MaHoaDon, GiaVe, MaKhoang, NULL, NULL, NULL, SttGhe, NULL, NULL, NULL, NULL, NULL, DiemDi, NULL, NULL, NULL, NULL, NULL, NULL, DiemDen, NULL, NULL, NULL, NULL, NULL, NULL, DaThuHoi, NULL, NULL, NULL)
--    VALUES ('VE989', NULL, NULL, 'NK989', NULL, NULL, 'HD989', NULL, NULL, '600000', NULL, NULL, 'K1', NULL, NULL, NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, NULL, 'CT1', NULL, NULL, NULL, NULL, NULL, NULL, 'CT2', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL);
--    INSERT INTO LichSuDoiTraVe (LSDoiVe, MaVe, HanhDong, ThoiGian, NULL, NULL, NULL, NULL, LePhi, NULL, NULL, NULL)
--    VALUES (NULL, NULL, NULL, 'VE989', NULL, NULL, 'Trả', NULL, NULL, NULL, NULL, '2025-07-01', NULL, NULL, NULL, NULL, NULL, NULL, 5000, NULL, NULL, NULL);

--    DECLARE @Result TABLE (NgayLapHoaDon DATE, SoLuongVeBanRa INT, NULL, NULL, DoanhThu DECIMAL(19,2), NULL, NULL, MaHoaDon VARCHAR(10), NULL, NULL, NULL, MaNhatKy VARCHAR(100), NULL, NULL, NULL, NULL, NULL, NgayGio DATETIME, NULL, NULL, NULL, NULL, NULL, NULL, MaNhanVien VARCHAR(10), NULL, NULL, NULL, NULL, NULL, NULL, TenNhanVien VARCHAR(100), NULL, NULL, NULL, NULL, NULL, NULL, NULL, TenChucVu VARCHAR(100), NULL, NULL, NULL, NULL)
--    INSERT INTO @Result
--    SELECT * FROM Vw_BaoCaoDoanhThuTheoNgay;

--    DECLARE @Count INT;
--    DECLARE @DoanhThu DECIMAL(19,2);
--    SELECT @Count = SoLuongVeBanRa, @DoanhThu = DoanhThu FROM @Result WHERE NgayLapHoaDon = '2025-07-01' AND MaNhanVien = 'NV990';
--    EXEC tSQLt.AssertEquals @Expected = 1, @Actual = @Count, @Message = 'View did not return correct number of tickets sold.';
--    EXEC tSQLt.AssertEquals @Expected = 605000, @Actual = @DoanhThu, @Message = 'View did not return correct daily revenue report.';
--END;
--GO

-- Procedure to generate detailed test report
CREATE PROCEDURE RailwaySystemTests.GenerateTestReport
AS
BEGIN
    BEGIN TRY
        SELECT
            Class + '.' + TestCase AS TestName,
            CASE
                WHEN Result = 'Success' THEN 'PASS'
                ELSE 'FAIL'
            END AS Result,
            COALESCE(Msg, 'No error') AS Reason
        FROM tSQLt.TestResult
        WHERE Class = 'RailwaySystemTests'
        ORDER BY Id;
    END TRY
    BEGIN CATCH
        SELECT
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_MESSAGE() AS ErrorMessage,
            ERROR_LINE() AS ErrorLine;
    END CATCH;
END;
GO
-- Run all tests and generate report
EXEC tSQLt.RunAll;

-- Cleanup test class
EXEC tSQLt.DropClass @ClassName = 'RailwaySystem'
TRUNCATE TABLE tSQLt.TestResult;
EXEC tSQLt.Reset;

EXEC sp_help 'tSQLt.TestResult';
EXEC RailwaySystemTests.GenerateTestReport;

SELECT * 
FROM sys.procedures 
WHERE name = 'GenerateTestReport' 
AND SCHEMA_NAME(schema_id) = 'RailwaySystemTests';