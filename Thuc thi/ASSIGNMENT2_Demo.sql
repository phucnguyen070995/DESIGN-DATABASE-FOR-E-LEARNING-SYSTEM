﻿USE ASSIGNMENT2_V2
GO

/*CREATE PROCEDURE INSERT_TEACHER @USERNAME CHAR(20), @BANGCAP NVARCHAR(15), @PASS CHAR(50), @NGAYSINH DATE, @DIACHI NVARCHAR(100), @HOTEN NVARCHAR(40), @GIOITINH CHAR(3)
AS
BEGIN
	BEGIN TRY 			
		INSERT INTO dbo.NguoiDung VALUES (@USERNAME, @PASS, @NGAYSINH, GETDATE(), @DIACHI, @HOTEN, @GIOITINH)
		INSERT INTO dbo.GiaoVien VALUES (@USERNAME , @BANGCAP)
		INSERT INTO dbo.ViDienTu (SOTIENHIENTAI,NGAYTAOVI,USERNAMEGV) VALUES (0, GETDATE(), @USERNAME)
		PRINT(N'Tạo tài khoản thành công')
	END TRY
	BEGIN CATCH
		PRINT(N'Có lỗi khi nhập dữ liệu')
	END CATCH
END
GO

DROP PROC dbo.INSERT_TEACHER*/

EXEC dbo.INSERT_TEACHER @USERNAME = 'nhyen',          
                        @BANGCAP = N'Thạc sĩ',           
                        @PASS = '123456789',             
                        @NGAYSINH = '19930919', 
                        @DIACHI = N'Quận 7',           
                        @HOTEN = N'Nguyễn Hoàng Yến',           
                        @GIOITINH = 'Nu'           

SELECT * FROM dbo.NGUOIDUNG
SELECT * FROM dbo.GIAOVIEN
SELECT * FROM dbo.VIDIENTU

GO

-- 2 trigger

--insert khoa hoc de test duyet lop
	
INSERT INTO dbo.KHOAHOC
(IDKHOAHOC, TENKHOAHOC, THOILUONG, HOCPHI, MOTAKHOAHOC, USERNAMEGV, USERNAMEQTV)
VALUES
('vl2', N'Vật lý 2', 2000, 200000, N'Đại cương cho các ngành kỹ thuật', 'nhnghia', NULL)

SELECT * FROM dbo.KHOAHOC
SELECT * FROM dbo.TAOLOP
GO

--trigger duyet lop

/*CREATE TRIGGER TRIGGER_DUYETLOP 
ON dbo.TAOLOP
AFTER UPDATE 
AS
BEGIN
    UPDATE dbo.KHOAHOC
	SET USERNAMEQTV = (SELECT Inserted.USERNAMEQTV FROM Inserted)
	WHERE dbo.KHOAHOC.IDKHOAHOC = (SELECT Inserted.IDKHOAHOC FROM Inserted)
	PRINT(N'Khóa học đã được duyệt')
END*/

--test duyet lop

UPDATE dbo.TAOLOP SET USERNAMEQTV = 'ltthien' WHERE IDKHOAHOC = 'vl2'

SELECT * FROM dbo.KHOAHOC
SELECT * FROM dbo.TAOLOP
GO

--trigger tinh toan vi dien tu

/*CREATE TRIGGER TRIGGER_VIDIENTU
ON dbo.GIAODICH
AFTER INSERT, DELETE, UPDATE
AS
BEGIN
	DECLARE @get INT
	DECLARE @current INT
	DECLARE @delete INT
	DECLARE @insert INT
	IF (EXISTS (SELECT * FROM Inserted) AND NOT EXISTS (SELECT * FROM Deleted))
		BEGIN
			SET @get = (SELECT VI.SOTIENHIENTAI FROM dbo.VIDIENTU AS VI JOIN Inserted AS I ON I.IDVI = VI.IDVI)
			SET @insert = (SELECT I.SOTIENRUT FROM Inserted AS I)
			IF (@get < @insert)
				BEGIN
					PRINT(N'Số tiền còn lại không đủ để thực hiện giao dịch')
					ROLLBACK TRAN
				END
			ELSE
        		BEGIN
					SET @current = @get - @insert
					UPDATE dbo.VIDIENTU
					SET SOTIENHIENTAI = @current 
					WHERE IDVI = (SELECT Inserted.IDVI FROM Inserted)
				END
		END
	IF (EXISTS (SELECT * FROM Inserted) AND EXISTS (SELECT * FROM Deleted))
		BEGIN
			SET @get = (SELECT VI.SOTIENHIENTAI FROM dbo.VIDIENTU AS VI JOIN Inserted AS I ON I.IDVI = VI.IDVI)
			SET @insert = (SELECT I.SOTIENRUT FROM Inserted AS I)
			SET @delete = (SELECT D.SOTIENRUT FROM Deleted AS D)
			IF (@get + @delete < @insert)
				BEGIN
					PRINT(N'Số tiền còn lại không đủ để thực hiện giao dịch')
					ROLLBACK TRAN
				END
			ELSE
        		BEGIN
					SET @current = @get - @insert + @delete
					UPDATE dbo.VIDIENTU
					SET SOTIENHIENTAI = @current 
					WHERE IDVI = (SELECT Inserted.IDVI FROM Inserted)
				END
		END
	IF (NOT EXISTS (SELECT * FROM Inserted) AND EXISTS (SELECT * FROM Deleted))
		BEGIN
			SET @get = (SELECT VI.SOTIENHIENTAI FROM dbo.VIDIENTU AS VI JOIN Deleted AS D ON D.IDVI = VI.IDVI)
			SET @delete = (SELECT D.SOTIENRUT FROM Deleted AS D)
			BEGIN
				SET @current = @get + @delete
				UPDATE dbo.VIDIENTU
				SET SOTIENHIENTAI = @current 
				WHERE IDVI = (SELECT Deleted.IDVI FROM Deleted)
			END
		END
END*/

--insert test

INSERT INTO dbo.GIAODICH
(SOTIENRUT, NGAYRUT, IDVI, USERNAMEGV)
VALUES

(20000, GETDATE(), 2, 'nhnghia')

SELECT * FROM dbo.GIAODICH
SELECT * FROM dbo.VIDIENTU

--delete test

DELETE FROM dbo.GIAODICH WHERE IDGIAODICH = 3

SELECT * FROM dbo.GIAODICH
SELECT * FROM dbo.VIDIENTU

--update test

UPDATE dbo.GIAODICH SET SOTIENRUT = 10000 WHERE IDGIAODICH = 2

SELECT * FROM dbo.GIAODICH
SELECT * FROM dbo.VIDIENTU
GO

-- 2 proc

--Hien khoa hoc co luong hoc sinh dang ki nhieu nhat va ten giao vien day mon do

/*CREATE PROC KHOAHOC_MAX_SV
AS
BEGIN
	DECLARE @maxSV INT
	SET @maxSV = (SELECT MAX(A.SOLUONGSVDK) FROM (SELECT IDKHOAHOC, COUNT(*) AS SOLUONGSVDK FROM dbo.DANGKY GROUP BY IDKHOAHOC) AS A)
	SELECT ND.HOTEN AS N'Giáo viên giảng dạy',KH.TENKHOAHOC, A.SOLUONGSVDK 
	FROM dbo.NGUOIDUNG AS ND, dbo.KHOAHOC AS KH, (SELECT IDKHOAHOC, COUNT(*) AS SOLUONGSVDK FROM dbo.DANGKY GROUP BY IDKHOAHOC) AS A 
	WHERE A.IDKHOAHOC = KH.IDKHOAHOC 
	AND KH.USERNAMEGV = ND.USERNAME
	AND A.SOLUONGSVDK = @maxSV
END*/

--test 

SELECT IDKHOAHOC, COUNT(*) AS SOLUONGSVDK FROM dbo.DANGKY GROUP BY IDKHOAHOC

EXEC dbo.KHOAHOC_MAX_SV
GO

--Hien giang vien co luong sinh vien theo hoc nhieu nhat

/*CREATE PROC GIANGVIEN_MAX_SV
AS
BEGIN
	DECLARE @maxSV INT
	SET @maxSV = (SELECT MAX(A.SOLUONGSVDK) FROM (SELECT KH.USERNAMEGV, COUNT(*) AS SOLUONGSVDK FROM dbo.KHOAHOC AS KH JOIN dbo.DANGKY AS DK ON KH.IDKHOAHOC = DK.IDKHOAHOC GROUP BY KH.USERNAMEGV) AS A)
	SELECT ND.HOTEN AS N'Giáo viên giảng dạy', A.SOLUONGSVDK 
	FROM dbo.NGUOIDUNG AS ND JOIN (SELECT KH.USERNAMEGV, COUNT(*) AS SOLUONGSVDK FROM dbo.KHOAHOC AS KH JOIN dbo.DANGKY AS DK ON KH.IDKHOAHOC = DK.IDKHOAHOC GROUP BY KH.USERNAMEGV) AS A
	ON A.USERNAMEGV = ND.USERNAME
	WHERE A.SOLUONGSVDK = @maxSV
END*/

--test 

SELECT KH.USERNAMEGV, COUNT(*) AS SOLUONGSVDK FROM dbo.KHOAHOC AS KH JOIN dbo.DANGKY AS DK ON KH.IDKHOAHOC = DK.IDKHOAHOC GROUP BY KH.USERNAMEGV

EXEC dbo.GIANGVIEN_MAX_SV
GO

--Nhan Magv, so nguoi dang ky, va discount de cap nhat hoc phi cua cac khoa hoc do giang vien do gui (DUNG CON TRO)

/*CREATE PROC CAPNHATHOCPHI @USERNAME CHAR(20), @SONGUOIDK INT, @PERCENT INT
AS
BEGIN
	DECLARE DANGKYCURSOR CURSOR FOR SELECT KH.IDKHOAHOC, KH.USERNAMEGV,KH.USERNAMEQTV, A.SOLUONGSVDK 
	FROM dbo.KHOAHOC AS KH 
	LEFT JOIN (SELECT IDKHOAHOC, COUNT(*) AS SOLUONGSVDK FROM dbo.DANGKY AS DK GROUP BY DK.IDKHOAHOC) AS A 
	ON A.IDKHOAHOC = KH.IDKHOAHOC
    OPEN DANGKYCURSOR
	DECLARE @IDUSERGV CHAR(20)
	DECLARE @IDUSERQTV CHAR(20)
	DECLARE @IDKH char(20)
	DECLARE @SOLUONG INT
	FETCH NEXT FROM DANGKYCURSOR INTO @IDKH , @IDUSERGV, @IDUSERQTV, @SOLUONG
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF ((@IDUSERGV = @USERNAME AND @SOLUONG <= @SONGUOIDK) OR (@IDUSERGV = @USERNAME AND @SOLUONG IS NULL AND @IDUSERQTV IS NOT NULL))
			UPDATE dbo.KHOAHOC SET HOCPHI = HOCPHI*(100 - @PERCENT)/100 WHERE IDKHOAHOC = @IDKH
		FETCH NEXT FROM DANGKYCURSOR INTO @IDKH , @IDUSERGV, @IDUSERQTV, @SOLUONG
	END
	CLOSE DANGKYCURSOR
	DEALLOCATE DANGKYCURSOR
END
GO*/

--test

EXEC dbo.CAPNHATHOCPHI @USERNAME = 'htdat', -- char(20)
                       @SONGUOIDK = 2, -- int
                       @PERCENT = 20    -- int

SELECT * FROM dbo.KHOAHOC AS KH LEFT JOIN (SELECT IDKHOAHOC, COUNT(*) AS SOLUONGSVDK FROM dbo.DANGKY AS DK GROUP BY DK.IDKHOAHOC) AS A ON A.IDKHOAHOC = KH.IDKHOAHOC

--2 function

--Hien danh sach khoa hoc co so luong nguoi tham gia cao hon muc trung binh (tong so nguoi dang ki/tong so khoa hoc)

/*CREATE FUNCTION KHOAHOC_HOT()
RETURNS TABLE 
AS
RETURN
	SELECT * FROM (SELECT KH.TENKHOAHOC, COUNT(*) AS SOLUONGSVDK FROM dbo.DANGKY AS DK JOIN dbo.KHOAHOC AS KH ON KH.IDKHOAHOC = DK.IDKHOAHOC GROUP BY KH.TENKHOAHOC) AS A
	WHERE A.SOLUONGSVDK > (SELECT 1.0*(SELECT COUNT(*) FROM dbo.DANGKY)/(SELECT COUNT(USERNAMEQTV) FROM dbo.KHOAHOC))
GO*/

--test 

SELECT KH.TENKHOAHOC, COUNT(*) AS SOLUONGSVDK FROM dbo.DANGKY AS DK JOIN dbo.KHOAHOC AS KH ON KH.IDKHOAHOC = DK.IDKHOAHOC GROUP BY KH.TENKHOAHOC
SELECT 1.0*(SELECT COUNT(*) FROM dbo.DANGKY)/(SELECT COUNT(USERNAMEQTV) FROM dbo.KHOAHOC)

SELECT * FROM dbo.KHOAHOC_HOT()
GO

--DEM SO TAI LIEU CUA GIAO VIEN

/*CREATE FUNCTION FUNC_DEM_TAILIEU_CUA_GV
(@USERNAMEGV CHAR(20))
RETURNS INT
AS
BEGIN
	DECLARE @a INT
	SELECT @a = COUNT(*) FROM dbo.TAILIEU
	WHERE USERNAMEGV = @USERNAMEGV
	IF (@a IS NULL)
		SET @a = 0
	RETURN @a
END*/
GO

--test

SELECT dbo.FUNC_DEM_TAILIEU_CUA_GV('htdat')

SELECT * FROM dbo.TAILIEU




