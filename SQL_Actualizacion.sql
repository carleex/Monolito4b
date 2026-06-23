-- ============================================================
-- SCRIPT DE ACTUALIZACIÓN - Ejecutar en SSMS sobre Monolito4am
-- ============================================================
USE Monolito4am
GO

-- 1. Tabla de fotos de perfil (permite múltiples imágenes por usuario)
CREATE TABLE tbl_foto_usuario (
    foto_id        INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    usu_id         INT NOT NULL REFERENCES tbl_usuario(usu_id),
    foto_imagen    VARBINARY(MAX),
    foto_nombre    VARCHAR(100),
    foto_tipo      VARCHAR(50),   -- 'image/jpeg', 'image/png', etc.
    foto_fecha     DATETIME DEFAULT GETDATE(),
    foto_principal CHAR(1) DEFAULT 'N'  -- 'S' = foto principal
)
GO

-- 2. Tabla para recuperación de contraseña (clave temporal)
CREATE TABLE tbl_recuperacion (
    rec_id      INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    usu_id      INT REFERENCES tbl_usuario(usu_id),
    rec_token   VARCHAR(20),       -- contraseña temporal (texto plano para envío)
    rec_expira  DATETIME,          -- expira en 30 minutos
    rec_usado   CHAR(1) DEFAULT 'N' -- 'N' no usado, 'S' ya usado
)
GO

-- 3. SP desbloqueo de usuario (para administrador)
DROP PROCEDURE IF EXISTS dbo.sp_desbloquear_usuario
GO
CREATE PROCEDURE dbo.sp_desbloquear_usuario
    @usu_id INT
AS
BEGIN
    SET NOCOUNT ON
    UPDATE tbl_usuario
    SET usu_estado               = 'A',
        usu_intentos             = 0,
        usu_fecha_ultimo_intento = NULL
    WHERE usu_id = @usu_id
END
GO

-- 6. SP reset de intentos al inicio de un nuevo día
--    @usu_id = NULL  → aplica a todos los usuarios
--    @usu_id = <id>  → aplica solo a ese usuario
DROP PROCEDURE IF EXISTS dbo.sp_reset_intentos_si_nuevo_dia
GO
CREATE PROCEDURE dbo.sp_reset_intentos_si_nuevo_dia
    @usu_id INT = NULL
AS
BEGIN
    SET NOCOUNT ON
    UPDATE tbl_usuario
    SET    usu_intentos             = 0,
           usu_fecha_ultimo_intento = NULL
    WHERE  usu_intentos             > 0
      AND  usu_fecha_ultimo_intento IS NOT NULL
      AND  CAST(usu_fecha_ultimo_intento AS DATE) < CAST(GETDATE() AS DATE)
      AND  (@usu_id IS NULL OR usu_id = @usu_id)
END
GO

-- 4. SP para recuperar usuario por correo
DROP PROCEDURE IF EXISTS sp_buscar_por_correo
GO
CREATE PROCEDURE dbo.sp_buscar_por_correo
    @correo VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON
    SELECT usu_id, usu_nick, usu_celular, usu_correo, usu_estado
    FROM tbl_usuario
    WHERE usu_correo = @correo
END
GO

-- 5. SP para marcar foto como principal (desactiva las demás del usuario)
DROP PROCEDURE IF EXISTS dbo.sp_set_foto_principal
GO
CREATE PROCEDURE dbo.sp_set_foto_principal
    @usu_id  INT,
    @foto_id INT
AS
BEGIN
    SET NOCOUNT ON
    UPDATE tbl_foto_usuario SET foto_principal = 'N' WHERE usu_id = @usu_id
    UPDATE tbl_foto_usuario SET foto_principal = 'S' WHERE foto_id = @foto_id AND usu_id = @usu_id
END
GO

-- 7. SP de autenticación principal
--    @resultado: 1 = OK (genera OTP), -1 = cuenta bloqueada, 0 = credenciales inválidas
DROP PROCEDURE IF EXISTS dbo.sp_login
GO
CREATE PROCEDURE dbo.sp_login
    @nick      VARCHAR(50),
    @password  VARCHAR(50),
    @resultado INT          OUTPUT,
    @mensaje   VARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @usu_id   INT
    DECLARE @estado   CHAR(1)
    DECLARE @intentos INT
    DECLARE @hash     VARBINARY(MAX)

    SELECT @usu_id   = usu_id,
           @estado   = usu_estado,
           @intentos = ISNULL(usu_intentos, 0),
           @hash     = usu_contraseña
    FROM   tbl_usuario
    WHERE  usu_nick   = @nick
       OR  usu_cedula = @nick

    IF @usu_id IS NULL
    BEGIN
        SET @resultado = 0
        SET @mensaje   = 'Usuario no encontrado.'
        RETURN
    END

    IF @estado IN ('I', 'B')
    BEGIN
        SET @resultado = -1
        SET @mensaje   = 'Cuenta bloqueada. Contacte al administrador.'
        RETURN
    END

    IF @hash = dbo.encriptacon(@password)
    BEGIN
        UPDATE tbl_usuario
        SET    usu_intentos             = 0,
               usu_fecha_ultimo_intento = NULL
        WHERE  usu_id = @usu_id

        SET @resultado = 1
        SET @mensaje   = 'OK'
    END
    ELSE
    BEGIN
        DECLARE @nuevos INT = @intentos + 1

        UPDATE tbl_usuario
        SET    usu_intentos             = @nuevos,
               usu_fecha_ultimo_intento = GETDATE()
        WHERE  usu_id = @usu_id

        IF @nuevos >= 3
        BEGIN
            UPDATE tbl_usuario
            SET    usu_estado = 'B'
            WHERE  usu_id = @usu_id

            SET @resultado = -1
            SET @mensaje   = 'Cuenta bloqueada por exceder el número de intentos.'
        END
        ELSE
        BEGIN
            SET @resultado = 0
            SET @mensaje   = 'Credenciales incorrectas. Intento ' + CAST(@nuevos AS VARCHAR) + ' de 3.'
        END
    END
END
GO

-- ============================================================
-- 8. Columnas extra en tbl_usuario (ejecutar solo una vez)
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('tbl_usuario') AND name = 'usu_intentos')
    ALTER TABLE tbl_usuario ADD usu_intentos INT DEFAULT 0
GO
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('tbl_usuario') AND name = 'usu_fecha_ultimo_intento')
    ALTER TABLE tbl_usuario ADD usu_fecha_ultimo_intento DATETIME NULL
GO
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('tbl_usuario') AND name = 'usu_fecha_creacion')
    ALTER TABLE tbl_usuario ADD usu_fecha_creacion DATETIME DEFAULT GETDATE()
GO
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('tbl_usuario') AND name = 'usu_codigo_OTP')
    ALTER TABLE tbl_usuario ADD usu_codigo_OTP VARCHAR(10) NULL
GO

-- ============================================================
-- 9. Tabla de tipos de usuario (Administrador / Usuario-Jugador)
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID('tbl_tipo_usuario'))
BEGIN
    CREATE TABLE tbl_tipo_usuario (
        tusu_id     INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        tusu_nombre VARCHAR(50) NOT NULL
    )
END
GO

-- ============================================================
-- 10. CORRECCION: Garantizar tusu_id=1 y tusu_id=2 exactos
-- ============================================================
-- Limpiar y reinsertar con los IDs correctos
DELETE FROM tbl_tipo_usuario
GO

SET IDENTITY_INSERT tbl_tipo_usuario ON
INSERT INTO tbl_tipo_usuario (tusu_id, tusu_nombre) VALUES (1, 'Administrador')
INSERT INTO tbl_tipo_usuario (tusu_id, tusu_nombre) VALUES (2, 'Usuario')
SET IDENTITY_INSERT tbl_tipo_usuario OFF
GO

-- Verificar
SELECT * FROM tbl_tipo_usuario
GO
