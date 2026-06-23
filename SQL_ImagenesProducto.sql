-- ════════════════════════════════════════════════════════════
-- Script: tbl_imagen_producto  +  carpeta temp  
-- Base de datos: Monolito4am
-- Ejecutar en SSMS antes de arrancar la aplicación
-- ════════════════════════════════════════════════════════════

-- 1. Tabla de imágenes adicionales (N imágenes por producto)
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'tbl_imagen_producto')
BEGIN
    CREATE TABLE [dbo].[tbl_imagen_producto] (
        [img_id]        INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [pro_id]        INT NOT NULL
            CONSTRAINT FK_img_prod FOREIGN KEY REFERENCES [dbo].[tbl_producto]([pro_id]),
        [img_path]      VARCHAR(255) NOT NULL,
        [img_nombre]    VARCHAR(100) NULL,
        [img_orden]     INT          NOT NULL DEFAULT 0,
        [img_principal] CHAR(1)      NOT NULL DEFAULT 'N',
        [img_fecha]     DATETIME     NOT NULL DEFAULT GETDATE()
    );
    PRINT 'Tabla tbl_imagen_producto creada.';
END
ELSE
    PRINT 'Tabla tbl_imagen_producto ya existe.';
GO

-- 2. Índice para búsquedas por producto
IF NOT EXISTS (SELECT 1 FROM sys.indexes
               WHERE name = 'IX_img_prod' AND object_id = OBJECT_ID('tbl_imagen_producto'))
BEGIN
    CREATE INDEX IX_img_prod ON [dbo].[tbl_imagen_producto] ([pro_id]);
    PRINT 'Índice IX_img_prod creado.';
END
GO
