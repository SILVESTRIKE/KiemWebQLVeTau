-- File: Test_Cursors.sql
-- Mục đích: Kiểm tra tự động các cursor trong cơ sở dữ liệu với PASS/FAIL và cleanup
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

-- 1. Kiểm tra Cursor_KhuyenMaiDangHoatDong
PRINT 'Kiểm tra Cursor_KhuyenMaiDangHoatDong:';
BEGIN TRY
    BEGIN TRANSACTION;
    INSERT INTO KhuyenMai (MaKhuyenMai, TenKhuyenMai, SoTienGiamToiDa, PhanTramGiam, NgayBatDau, NgayKetThuc, SoLuong, SoLuongConLai)
    VALUES ('KM999', N'Test KM', 50000, 10.0, '2025-06-01', '2025-06-30', 100, 100);
    DECLARE @MaKhuyenMai VARCHAR(15), @Count INT = 0;
    DECLARE Cursor_KhuyenMaiDangHoatDong CURSOR FOR
    SELECT MaKhuyenMai FROM KhuyenMai WHERE NgayBatDau <= GETDATE() AND NgayKetThuc >= GETDATE();
    OPEN Cursor_KhuyenMaiDangHoatDong;
    FETCH NEXT FROM Cursor_KhuyenMaiDangHoatDong INTO @MaKhuyenMai;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @Count = @Count + 1;
        IF @MaKhuyenMai = 'KM999'
            INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('Cursor_KhuyenMaiDangHoatDong', 'PASS', 'Cursor trả về mã khuyến mãi đúng.');
        FETCH NEXT FROM Cursor_KhuyenMaiDangHoatDong INTO @MaKhuyenMai;
    END;
    IF @Count = 0
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('Cursor_KhuyenMaiDangHoatDong', 'FAIL', 'Cursor không trả về bản ghi nào.');
    CLOSE Cursor_KhuyenMaiDangHoatDong;
    DEALLOCATE Cursor_KhuyenMaiDangHoatDong;
    ROLLBACK;
END TRY
BEGIN CATCH
    INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('Cursor_KhuyenMaiDangHoatDong', 'FAIL', 'Lỗi không mong đợi: ' + ERROR_MESSAGE());
    IF CURSOR_STATUS('global', 'Cursor_KhuyenMaiDangHoatDong') >= 0
    BEGIN
        CLOSE Cursor_KhuyenMaiDangHoatDong;
        DEALLOCATE Cursor_KhuyenMaiDangHoatDong;
    END;
    ROLLBACK;
END CATCH
GO

-- 2. Kiểm tra Cursor_LichSuVe
PRINT 'Kiểm tra Cursor_LichSuVe:';
BEGIN TRY
    BEGIN TRANSACTION;
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
        IF @MaVe = 'VE999' AND @TenKhach = N'Test Khách' AND @ThanhTien = 100000
            INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('Cursor_LichSuVe', 'PASS', 'Cursor trả về lịch sử vé đúng.');
        FETCH NEXT FROM Cursor_LichSuVe INTO @MaVe, @SttGhe, @DiemDi, @DiemDen, @ThanhTien, @TenKhuyenMai, @TenKhach, @ThoiGianLapHoaDon;
    END;
    IF @Count = 0
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('Cursor_LichSuVe', 'FAIL', 'Cursor không trả về bản ghi nào.');
    CLOSE Cursor_LichSuVe;
    DEALLOCATE Cursor_LichSuVe;
    ROLLBACK;
END TRY
BEGIN CATCH
    INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('Cursor_LichSuVe', 'FAIL', 'Lỗi không mong đợi: ' + ERROR_MESSAGE());
    IF CURSOR_STATUS('global', 'Cursor_LichSuVe') >= 0
    BEGIN
        CLOSE Cursor_LichSuVe;
        DEALLOCATE Cursor_LichSuVe;
    END;
    ROLLBACK;
END CATCH
GO

-- 3. Kiểm tra ThayDoiTauCursor
PRINT 'Kiểm tra ThayDoiTauCursor:';
BEGIN TRY
    BEGIN TRANSACTION;
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
    IF EXISTS (SELECT 1 FROM Toa WHERE MaToa = 'TO999' AND MaTau = 'TA20') AND @Count = 1
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('ThayDoiTauCursor', 'PASS', 'Cursor cập nhật mã tàu đúng.');
    ELSE
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('ThayDoiTauCursor', 'FAIL', 'Cursor không cập nhật mã tàu đúng.');
    CLOSE ThayDoiTauCursor;
    DEALLOCATE ThayDoiTauCursor;
    ROLLBACK;
END TRY
BEGIN CATCH
    INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('ThayDoiTauCursor', 'FAIL', 'Lỗi không mong đợi: ' + ERROR_MESSAGE());
    IF CURSOR_STATUS('global', 'ThayDoiTauCursor') >= 0
    BEGIN
        CLOSE ThayDoiTauCursor;
        DEALLOCATE ThayDoiTauCursor;
    END;
    ROLLBACK;
END CATCH
GO

-- 4. Kiểm tra TuDongTraLoiCurSor
PRINT 'Kiểm tra TuDongTraLoiCurSor:';
BEGIN TRY
    BEGIN TRANSACTION;
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
        IF @SoSao >= 3 AND @TenKhach = N'Test Khách'
            SET @Message = N'Cảm ơn ' + @TenKhach + N', rất nhiều vì đánh giá tích cực!';
        IF @Message IS NOT NULL
            INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('TuDongTraLoiCurSor', 'PASS', 'Cursor tạo phản hồi đúng: ' + @Message);
        FETCH NEXT FROM TuDongTraLoiCurSor INTO @MaHoaDon, @TenKhach, @SoSao;
    END;
    IF @Count = 0
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('TuDongTraLoiCurSor', 'FAIL', 'Cursor không trả về bản ghi nào.');
    CLOSE TuDongTraLoiCurSor;
    DEALLOCATE TuDongTraLoiCurSor;
    ROLLBACK;
END TRY
BEGIN CATCH
    INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('TuDongTraLoiCurSor', 'FAIL', 'Lỗi không mong đợi: ' + ERROR_MESSAGE());
    IF CURSOR_STATUS('global', 'TuDongTraLoiCurSor') >= 0
    BEGIN
        CLOSE TuDongTraLoiCurSor;
        DEALLOCATE TuDongTraLoiCurSor;
    END;
    ROLLBACK;
END CATCH
GO

-- 5. Kiểm tra Cursor_DoanhThuTauTheoTuan
PRINT 'Kiểm tra Cursor_DoanhThuTauTheoTuan:';
BEGIN TRY
    BEGIN TRANSACTION;
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
    INSERT INTO LichSuDoiTraVe (MaVe, HanhDong, Thoigian, LePhi) 
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
    IF EXISTS (SELECT 1 FROM #DoanhThuTheoTuan WHERE MaTau = 'TA999' AND DoanhThuThucNhan = 510000 
               AND TuanBatDau = '2025-06-09' AND TuanKetThuc = '2025-06-15')
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('Cursor_DoanhThuTauTheoTuan', 'PASS', 'Cursor tính doanh thu theo tuần đúng.');
    ELSE
        INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('Cursor_DoanhThuTauTheoTuan', 'FAIL', 'Cursor không tính doanh thu theo tuần đúng.');
    DROP TABLE #DoanhThuTheoTuan;
    ROLLBACK;
END TRY
BEGIN CATCH
    INSERT INTO #TestResults (TestName, Result, Reason) VALUES ('Cursor_DoanhThuTauTheoTuan', 'FAIL', 'Lỗi không mong đợi: ' + ERROR_MESSAGE());
    IF CURSOR_STATUS('global', 'Cursor_DoanhThuTauTheoTuan') >= 0
    BEGIN
        CLOSE Cursor_DoanhThuTauTheoTuan;
        DEALLOCATE Cursor_DoanhThuTauTheoTuan;
    END;
    IF CURSOR_STATUS('global', 'Cursor_Tuan') >= 0
    BEGIN
        CLOSE Cursor_Tuan;
        DEALLOCATE Cursor_Tuan;
    END;
    IF OBJECT_ID('tempdb..#DoanhThuTheoTuan') IS NOT NULL
        DROP TABLE #DoanhThuTheoTuan;
    ROLLBACK;
END CATCH
GO

-- In kết quả kiểm tra
PRINT '===== KẾT QUẢ KIỂM TRA CURSOR =====';
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