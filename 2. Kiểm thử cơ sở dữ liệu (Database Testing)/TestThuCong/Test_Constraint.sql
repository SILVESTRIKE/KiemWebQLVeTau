-- File: Test_Constraint.sql
-- Mục đích: Kiểm tra các ràng buộc (constraints) trong cơ sở dữ liệu
-- Ngày tạo: 2025-06-11

-- Bật hiển thị thông báo lỗi
SET NOCOUNT ON;
GO

-- 1. Kiểm tra ràng buộc PRIMARY KEY
-- Thử thêm một KhachHang với MaKhach trùng lặp
PRINT 'Kiểm tra ràng buộc PRIMARY KEY trên bảng KhachHang:';
BEGIN TRY
    INSERT INTO KhachHang (MaKhach, TenKhach, NamSinh, Email, SDT, CCCD, DiaChi)
    VALUES ('KH03241', N'Trần Văn Test', '1990-01-01', 'test@example.com', '0999999999', '999999999999', N'Test Address');
    PRINT 'Thêm thành công (không mong muốn).';
END TRY
BEGIN CATCH
    PRINT 'Lỗi: ' + ERROR_MESSAGE();
END CATCH
GO

-- 2. Kiểm tra ràng buộc FOREIGN KEY
-- Thử thêm một TaiKhoan với Email không tồn tại trong KhachHang
PRINT 'Kiểm tra ràng buộc FOREIGN KEY trên bảng TaiKhoan (Email):';
BEGIN TRY
    INSERT INTO TaiKhoan (MaTaiKhoan, Email, MatKhau, DaXoa)
    VALUES ('TK999', 'nonexistent@example.com', 'test123', 0);
    PRINT 'Thêm thành công (không mong muốn).';
END TRY
BEGIN CATCH
    PRINT 'Lỗi: ' + ERROR_MESSAGE();
END CATCH
GO

-- 3. Kiểm tra ràng buộc UNIQUE
-- Thử thêm một KhachHang với Email trùng lặp
PRINT 'Kiểm tra ràng buộc UNIQUE trên bảng KhachHang (Email):';
BEGIN TRY
    INSERT INTO KhachHang (MaKhach, TenKhach, NamSinh, Email, SDT, CCCD, DiaChi)
    VALUES ('KH999', N'Nguyễn Văn Test', '1990-01-01', 'nguyenminhtam@gmail.com', '0999999998', '999999999998', N'Test Address');
    PRINT 'Thêm thành công (không mong muốn).';
END TRY
BEGIN CATCH
    PRINT 'Lỗi: ' + ERROR_MESSAGE();
END CATCH
GO

-- 4. Kiểm tra ràng buộc CHECK
-- Thử thêm một KhuyenMai với PhanTramGiam ngoài khoảng [0, 100]
PRINT 'Kiểm tra ràng buộc CHECK trên bảng KhuyenMai (PhanTramGiam):';
BEGIN TRY
    INSERT INTO KhuyenMai (MaKhuyenMai, TenKhuyenMai, SoTienGiamToiDa, PhanTramGiam, NgayBatDau, NgayKetThuc, SoLuong, SoLuongConLai)
    VALUES ('KM999', N'Khuyến mãi test', 50000, 150.0, '2025-06-01', '2025-06-30', 100, 100);
    PRINT 'Thêm thành công (không mong muốn).';
END TRY
BEGIN CATCH
    PRINT 'Lỗi: ' + ERROR_MESSAGE();
END CATCH
GO

-- 5. Kiểm tra ràng buộc NOT NULL
-- Thử thêm một KhachHang với TenKhach là NULL
PRINT 'Kiểm tra ràng buộc NOT NULL trên bảng KhachHang (TenKhach):';
BEGIN TRY
    INSERT INTO KhachHang (MaKhach, TenKhach, NamSinh, Email, SDT, CCCD, DiaChi)
    VALUES ('KH998', NULL, '1990-01-01', 'test2@example.com', '0999999997', '999999999997', N'Test Address');
    PRINT 'Thêm thành công (không mong muốn).';
END TRY
BEGIN CATCH
    PRINT 'Lỗi: ' + ERROR_MESSAGE();
END CATCH
GO

-- 6. Kiểm tra ràng buộc CHECK trên bảng PhanHoi (SoSao)
-- Thử thêm một PhanHoi với SoSao ngoài khoảng [1, 5]
PRINT 'Kiểm tra ràng buộc CHECK trên bảng PhanHoi (SoSao):';
BEGIN TRY
    INSERT INTO PhanHoi (MaHoaDon, NoiDung, NgayPhanHoi, TrangThai, SoSao)
    VALUES ('HD0111241', N'Test phản hồi', '2025-06-11', N'Chưa xử lý', 6);
    PRINT 'Thêm thành công (không mong muốn).';
END TRY
BEGIN CATCH
    PRINT 'Lỗi: ' + ERROR_MESSAGE();
END CATCH
GO

-- 7. Kiểm tra ràng buộc CHECK trên bảng Khoang (SoChoNgoiToiDa)
-- Thử thêm một Khoang với SoChoNgoiToiDa <= 0
PRINT 'Kiểm tra ràng buộc CHECK trên bảng Khoang (SoChoNgoiToiDa):';
BEGIN TRY
    INSERT INTO Khoang (MaKhoang, MaToa, SoKhoang, SoChoNgoiToiDa)
    VALUES ('K999', 'TO1', 5, 0);
    PRINT 'Thêm thành công (không mong muốn).';
END TRY
BEGIN CATCH
    PRINT 'Lỗi: ' + ERROR_MESSAGE();
END CATCH
GO

-- 8. Kiểm tra ràng buộc FOREIGN KEY trên bảng Ve (DiemDi, DiemDen)
-- Thử thêm một Ve với DiemDi không tồn tại trong ChiTietLichTrinh
PRINT 'Kiểm tra ràng buộc FOREIGN KEY trên bảng Ve (DiemDi):';
BEGIN TRY
    INSERT INTO Ve (MaVe, MaNhatKy, MaHoaDon, GiaVe, MaKhoang, Stt_Ghe, DiemDi, DiemDen, DaThuHoi)
    VALUES ('VE999', 'TA10111241', 'HD0111241', 300000, 'K1', 3, 'INVALID', 'SE1-5', 0);
    PRINT 'Thêm thành công (không mong muốn).';
END TRY
BEGIN CATCH
    PRINT 'Lỗi: ' + ERROR_MESSAGE();
END CATCH
GO

-- 9. Kiểm tra trigger trg_capNhatSLConLai_KM
-- Thử thêm một HoaDon với MaKhuyenMai hợp lệ và kiểm tra SoLuongConLai
PRINT 'Kiểm tra trigger cập nhật SoLuongConLai trên bảng KhuyenMai:';
BEGIN TRY
    DECLARE @SoLuongConLaiTruoc INT;
    SELECT @SoLuongConLaiTruoc = SoLuongConLai FROM KhuyenMai WHERE MaKhuyenMai = 'KM7';
    INSERT INTO HoaDon (MaHoaDon, MaKhach, MaKhuyenMai, ThanhTien, ThoiGianLapHoaDon)
    VALUES ('HD999', 'KH03241', 'KM7', 250000.00, '2025-06-11');
    DECLARE @SoLuongConLaiSau INT;
    SELECT @SoLuongConLaiSau = SoLuongConLai FROM KhuyenMai WHERE MaKhuyenMai = 'KM7';
    PRINT 'Số lượng còn lại trước: ' + CAST(@SoLuongConLaiTruoc AS VARCHAR) + ', sau: ' + CAST(@SoLuongConLaiSau AS VARCHAR);
END TRY
BEGIN CATCH
    PRINT 'Lỗi: ' + ERROR_MESSAGE();
END CATCH
GO

-- 10. Kiểm tra ràng buộc ON UPDATE CASCADE trên bảng PhanHoi
-- Cập nhật MaHoaDon và kiểm tra xem PhanHoi có cập nhật theo không
PRINT 'Kiểm tra ON UPDATE CASCADE trên bảng PhanHoi:';
BEGIN TRY
    UPDATE HoaDon
    SET MaHoaDon = 'HD999999'
    WHERE MaHoaDon = 'HD0111241';
    IF EXISTS (SELECT 1 FROM PhanHoi WHERE MaHoaDon = 'HD999999')
        PRINT 'ON UPDATE CASCADE hoạt động đúng.';
    ELSE
        PRINT 'ON UPDATE CASCADE không hoạt động như mong đợi.';
END TRY
BEGIN CATCH
    PRINT 'Lỗi: ' + ERROR_MESSAGE();
END CATCH
GO

-- 11. Kiểm tra ràng buộc ON UPDATE CASCADE trên bảng HanhLy
-- Cập nhật MaVe và kiểm tra xem HanhLy có cập nhật theo không
PRINT 'Kiểm tra ON UPDATE CASCADE trên bảng HanhLy:';
BEGIN TRY
    UPDATE Ve
    SET MaVe = 'VE999999'
    WHERE MaVe = 'VE0111241';
    IF EXISTS (SELECT 1 FROM HanhLy WHERE MaVe = 'VE999999')
        PRINT 'ON UPDATE CASCADE hoạt động đúng.';
    ELSE
        PRINT 'ON UPDATE CASCADE không hoạt động như mong đợi.';
END TRY
BEGIN CATCH
    PRINT 'Lỗi: ' + ERROR_MESSAGE();
END CATCH
GO

-- 12. Kiểm tra ràng buộc CHECK trên bảng HanhLy (KhoiLuong)
-- Thử thêm một HanhLy với KhoiLuong ngoài khoảng (0, 10]
PRINT 'Kiểm tra ràng buộc CHECK trên bảng HanhLy (KhoiLuong):';
BEGIN TRY
    INSERT INTO HanhLy (MaHanhLy, MaVe, KhoiLuong)
    VALUES ('HL999', 'VE0111242', 15.0);
    PRINT 'Thêm thành công (không mong muốn).';
END TRY
BEGIN CATCH
    PRINT 'Lỗi: ' + ERROR_MESSAGE();
END CATCH
GO