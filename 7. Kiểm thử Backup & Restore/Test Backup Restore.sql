/************************************************************************************
 * KỊCH BẢN KIỂM THỬ TỰ ĐỘNG SAO LƯU VÀ PHỤC HỒI 
 ************************************************************************************/

-- ==================================================================================
-- ==================================================================================
PRINT '-----------------------------------------------------------------';
PRINT 'PHAN 0: KIEM TRA ;
PRINT '-----------------------------------------------------------------';
USE [master];
GO
IF DATABASEPROPERTYEX('QL_VETAU', 'Status') = 'RESTORING'
BEGIN
    PRINT '=> Phat hien database dang o trang thai "RESTORING". Tien hanh giai cuu...';
    RESTORE DATABASE [QL_VETAU] WITH RECOVERY;
    PRINT '=> Giai cuu thanh cong. Database da online.';
END
ELSE
    PRINT '=> Database o trang thai binh thuong. Tiep tuc...';
GO

-- ==================================================================================
-- PHẦN 1: THIẾT LẬP MÔI TRƯỜNG KIỂM THỬ
-- ==================================================================================
PRINT CHAR(13);
PRINT '-----------------------------------------------------------------';
PRINT 'PHAN 1: THIET LAP MOI TRUONG KIEM THU';
PRINT '-----------------------------------------------------------------';
USE [master];
ALTER DATABASE [QL_VETAU] SET MULTI_USER;
ALTER DATABASE [QL_VETAU] SET RECOVERY FULL;
PRINT '=> Da dam bao database [QL_VETAU] o che do RECOVERY FULL và MULTI_USER.';

DECLARE @BackupPath_Pristine NVARCHAR(MAX) = N'D:\hufi\hk7\QL Vé tàu\Do_An\backup\';
DECLARE @PristineFile NVARCHAR(MAX) = @BackupPath_Pristine + N'QL_VETAU_Pristine.bak';
PRINT '=> Tao ban sao luu "sach" ban dau...';
DECLARE @SqlPristine NVARCHAR(MAX) = N'BACKUP DATABASE [QL_VETAU] TO DISK = N''' + @PristineFile + N''' WITH INIT, STATS = 10;';
EXEC sp_executesql @SqlPristine;
PRINT '=> Da tao ban sao luu "sach" thanh cong.';
GO

-- ==================================================================================
-- TEST CASE 1 & 2: SAO LƯU VÀ PHỤC HỒI TỪ FULL BACKUP
-- ==================================================================================
PRINT CHAR(13);
PRINT '-----------------------------------------------------------------';
PRINT 'TEST CASE 1 & 2: FULL BACKUP & RESTORE';
PRINT '-----------------------------------------------------------------';

DECLARE @BackupPath_TC1 NVARCHAR(MAX) = N'D:\hufi\hk7\QL Vé tàu\Do_An\backup\';
DECLARE @FullFile_TC1 NVARCHAR(MAX) = @BackupPath_TC1 + N'QL_VETAU_Test_Full.bak';

PRINT 'Buoc 1: Thuc hien sao luu Full Backup...';
DECLARE @SqlFullBackup_TC1 NVARCHAR(MAX) = N'BACKUP DATABASE [QL_VETAU] TO DISK = N''' + @FullFile_TC1 + N''' WITH INIT, STATS = 10;';
EXEC sp_executesql @SqlFullBackup_TC1;
PRINT '=> [THANH CONG] File Full Backup da duoc tao.';

PRINT CHAR(13) + 'Buoc 2: Tao su co - Xoa bang [Ve]...';
USE [QL_VETAU];
IF OBJECT_ID('dbo.HanhLy', 'U') IS NOT NULL DROP TABLE [dbo].[HanhLy];
IF OBJECT_ID('dbo.LichSuDoiTraVe', 'U') IS NOT NULL DROP TABLE [dbo].LichSuDoiTraVe;
IF OBJECT_ID('dbo.Ve', 'U') IS NOT NULL DROP TABLE [dbo].Ve;
PRINT '=> [THANH CONG] Bang [Ve] va cac bang lien quan da bi xoa.';

PRINT CHAR(13) + 'Buoc 3: Phuc hoi tu Full Backup...';
USE [master];
ALTER DATABASE [QL_VETAU] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
DECLARE @SqlRestoreFull_TC1 NVARCHAR(MAX) = N'RESTORE DATABASE [QL_VETAU] FROM DISK = N''' + @FullFile_TC1 + N''' WITH REPLACE, STATS = 10;';
EXEC sp_executesql @SqlRestoreFull_TC1;
ALTER DATABASE [QL_VETAU] SET MULTI_USER;
PRINT '=> [THANH CONG] Da phuc hoi database tu Full Backup.';

PRINT CHAR(13) + 'Buoc 4: Kiem tra ket qua phuc hoi...';
USE [QL_VETAU];
IF OBJECT_ID('dbo.Ve', 'U') IS NOT NULL
    PRINT '=> [KET QUA MONG DOI] Bang [Ve] da duoc khoi phuc thanh cong!';
ELSE
    PRINT '=> [THAT BAI] Khong tim thay bang [Ve] sau khi phuc hoi.';
GO
-- *** SỬA LỖI: PHỤC HỒI LẠI TRẠNG THÁI SẠCH SAU KHI TEST CASE 1 & 2 KẾT THÚC ***
PRINT '=> Khoi phuc database ve trang thai sach de chuan bi cho Test Case tiep theo...';
USE master;
DECLARE @PristineFile_AfterTC1 NVARCHAR(MAX) = N'D:\hufi\hk7\QL Vé tàu\Do_An\backup\QL_VETAU_Pristine.bak';
ALTER DATABASE [QL_VETAU] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
DECLARE @SqlRestorePristine_AfterTC1 NVARCHAR(MAX) = N'RESTORE DATABASE [QL_VETAU] FROM DISK = N''' + @PristineFile_AfterTC1 + N''' WITH REPLACE, STATS = 10;';
EXEC sp_executesql @SqlRestorePristine_AfterTC1;
ALTER DATABASE [QL_VETAU] SET MULTI_USER;
PRINT '=> Da khoi phuc xong.';
GO
-- *** KẾT THÚC SỬA LỖI ***

-- ==================================================================================
-- TEST CASE 3 & 4: SAO LƯU VÀ PHỤC HỒI TỪ DIFFERENTIAL BACKUP
-- ==================================================================================
PRINT CHAR(13);
PRINT '-----------------------------------------------------------------';
PRINT 'TEST CASE 3 & 4: DIFFERENTIAL BACKUP & RESTORE';
PRINT '-----------------------------------------------------------------';

DECLARE @BackupPath_TC3 NVARCHAR(MAX) = N'D:\hufi\hk7\QL Vé tàu\Do_An\backup\';
DECLARE @FullFile_TC3 NVARCHAR(MAX) = @BackupPath_TC3 + N'QL_VETAU_Test_Full.bak';
DECLARE @DiffFile_TC3 NVARCHAR(MAX) = @BackupPath_TC3 + N'QL_VETAU_Test_Diff.bak';

PRINT 'Buoc 1: Tao lai Full Backup lam nen...';
DECLARE @SqlFullBackup_TC3 NVARCHAR(MAX) = N'BACKUP DATABASE [QL_VETAU] TO DISK = N''' + @FullFile_TC3 + N''' WITH INIT, STATS = 10;';
EXEC sp_executesql @SqlFullBackup_TC3;

PRINT CHAR(13) + 'Buoc 2: Tao thay doi - Them mot HoaDon moi...';
USE [QL_VETAU];
-- Kiểm tra xem bảng KhachHang có dữ liệu không trước khi thêm
IF (SELECT COUNT(*) FROM KhachHang) > 0
BEGIN
    DECLARE @MaKhach_Test VARCHAR(15);
    SELECT TOP 1 @MaKhach_Test = MaKhach FROM KhachHang;
    INSERT INTO [dbo].[HoaDon] ([MaHoaDon], [MaKhach], [ThanhTien]) VALUES ('HD_TEST_DIFF', @MaKhach_Test, 999999);
    PRINT '=> Da them HoaDon moi.';
END
ELSE
BEGIN
    PRINT '=> Canh bao: Bang KhachHang khong co du lieu de tao HoaDon. Bo qua buoc nay.';
END

PRINT CHAR(13) + 'Buoc 3: Thuc hien sao luu Differential...';
DECLARE @SqlDiffBackup_TC3 NVARCHAR(MAX) = N'BACKUP DATABASE [QL_VETAU] TO DISK = N''' + @DiffFile_TC3 + N''' WITH DIFFERENTIAL, INIT, STATS = 10;';
EXEC sp_executesql @SqlDiffBackup_TC3;
PRINT '=> Da tao file Differential Backup.';

PRINT CHAR(13) + 'Buoc 4: Tao su co - Xoa bang [KhachHang]...';
IF OBJECT_ID('dbo.TaiKhoan', 'U') IS NOT NULL DROP TABLE [dbo].[TaiKhoan];
IF OBJECT_ID('dbo.PhanHoi', 'U') IS NOT NULL DROP TABLE [dbo].[PhanHoi];
IF OBJECT_ID('dbo.Ve', 'U') IS NOT NULL DROP TABLE [dbo].Ve;
IF OBJECT_ID('dbo.HoaDon', 'U') IS NOT NULL DROP TABLE [dbo].[HoaDon];
IF OBJECT_ID('dbo.KhachHang', 'U') IS NOT NULL DROP TABLE [dbo].[KhachHang];
PRINT '=> [THANH CONG] Bang [KhachHang] va cac bang lien quan da bi xoa.';

PRINT CHAR(13) + 'Buoc 5: Phuc hoi (Full + Differential)...';
USE [master];
ALTER DATABASE [QL_VETAU] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
BEGIN TRY
    DECLARE @SqlRestoreFullDiff1 NVARCHAR(MAX) = N'RESTORE DATABASE [QL_VETAU] FROM DISK = N''' + @FullFile_TC3 + N''' WITH NORECOVERY, REPLACE, STATS = 10;';
    EXEC sp_executesql @SqlRestoreFullDiff1;

    DECLARE @SqlRestoreFullDiff2 NVARCHAR(MAX) = N'RESTORE DATABASE [QL_VETAU] FROM DISK = N''' + @DiffFile_TC3 + N''' WITH RECOVERY, STATS = 10;';
    EXEC sp_executesql @SqlRestoreFullDiff2;
    
    PRINT '=> [THANH CONG] Da hoan tat phuc hoi Full + Differential.';
END TRY
BEGIN CATCH
    PRINT '=> [THAT BAI] Qua trinh phuc hoi da xay ra loi:';
    PRINT ERROR_MESSAGE();
END CATCH
ALTER DATABASE [QL_VETAU] SET MULTI_USER;

PRINT CHAR(13) + 'Buoc 6: Kiem tra ket qua phuc hoi...';
USE [QL_VETAU];
IF EXISTS (SELECT 1 FROM [dbo].[HoaDon] WHERE MaHoaDon = 'HD_TEST_DIFF')
    PRINT '=> [KET QUA MONG DOI] HoaDon moi ''HD_TEST_DIFF'' da ton tai. Phuc hoi thanh cong!';
ELSE
    PRINT '=> [THAT BAI] Khong tim thay du lieu da thay doi sau khi phuc hoi.';
GO

-- ==================================================================================
-- DỌN DẸP CUỐI CÙNG
-- ==================================================================================
PRINT CHAR(13);
PRINT '-----------------------------------------------------------------';
PRINT 'HOAN TAT KIEM THU! PHUC HOI LAI DATABASE VE TRANG THAI BAN DAU.';
PRINT '-----------------------------------------------------------------';
USE [master];
DECLARE @PristineFile_Final NVARCHAR(MAX) = N'D:\hufi\hk7\QL Vé tàu\Do_An\backup\QL_VETAU_Pristine.bak';
ALTER DATABASE [QL_VETAU] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
DECLARE @SqlRestorePristine NVARCHAR(MAX) = N'RESTORE DATABASE [QL_VETAU] FROM DISK = N''' + @PristineFile_Final + N''' WITH REPLACE, STATS = 10;';
EXEC sp_executesql @SqlRestorePristine;
ALTER DATABASE [QL_VETAU] SET MULTI_USER;
PRINT '=> Da phuc hoi database ve trang thai "sach" ban dau.';
GO