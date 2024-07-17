/*  Funciones de usuario de la base de datos
	Empresa: MGSolutionsGroup
*/

-- Usamos la base de datos MGSolutionsGroup
USE MGSolutionsGroup
GO

-- Creamos funciones de usuarios

	-- [*] Creacion de la funcion udf_MontoTotalCompras

	CREATE OR ALTER FUNCTION udf_MontoTotalCompras
	(
		@año INT = NULL,
		@mes INT = NULL,
		@dia INT = NULL,
		@id_usuario INT = NULL
	)
	RETURNS MONEY
	AS
	BEGIN
		SET @año = NULLIF(@año, 0)
		SET @mes = NULLIF(@mes, 0)
		SET @dia = NULLIF(@dia, 0)
		SET @id_usuario = NULLIF(@id_usuario, 0)

		DECLARE @MontoTotalCompras MONEY = 0
		SELECT @MontoTotalCompras = SUM(total)
		FROM Compra
		WHERE
			(@año IS NULL OR YEAR(fechaEmision) = @año) AND
			(@mes IS NULL OR MONTH(fechaEmision) = @mes) AND
			(@dia IS NULL OR DAY(fechaEmision) = @dia) AND
			(@id_usuario IS NULL OR Compra.id_usuario = @id_usuario)

		RETURN @MontoTotalCompras;
	END
	GO

	-- [*] Creacion de la funcion udf_MontoTotalComprasAProveedor

	CREATE OR ALTER FUNCTION udf_MontoTotalComprasAProveedor
	(
		@año INT = NULL,
		@mes INT = NULL,
		@dia INT = NULL,
		@id_proveedor INT
	)
	RETURNS MONEY
	AS
	BEGIN
		SET @año = NULLIF(@año, 0)
		SET @mes = NULLIF(@mes, 0)
		SET @dia = NULLIF(@dia, 0)
		SET @id_proveedor = NULLIF(@id_proveedor, 0)
		DECLARE @MontoTotal MONEY = 0

		IF @id_proveedor IS NOT NULL
		BEGIN
			DECLARE @documentoCliente INT = 
			(
				SELECT RUC FROM Proveedor WHERE id_proveedor = @id_proveedor
			)
		END

		SELECT @MontoTotal = SUM(total)
		FROM Compra
		WHERE
			(@año IS NULL OR YEAR(fechaEmision) = @año) AND
			(@mes IS NULL OR MONTH(fechaEmision) = @mes) AND
			(@dia IS NULL OR DAY(fechaEmision) = @dia) AND
			(@id_proveedor IS NULL OR documento = @documentoCliente)

		RETURN @MontoTotal
	END
	GO

	-- [*] Creacion de la funcion udf_MontoTotalVendido
	
	CREATE OR ALTER FUNCTION udf_MontoTotalVendido
	(
		@año INT = NULL,
		@mes INT = NULL,
		@dia INT = NULL,
		@id_usuario INT = NULL

	)
	RETURNS MONEY
	AS
	BEGIN
		SET @año = NULLIF(@año, 0)
		SET @mes = NULLIF(@mes, 0)
		SET @dia = NULLIF(@dia, 0)
		SET @id_usuario = NULLIF(@id_usuario, 0)

		DECLARE @MontoTotalVendido MONEY = 0
		SELECT @MontoTotalVendido = SUM(importeTotal)
		FROM Venta
		WHERE
			(@año IS NULL OR YEAR(fechaEmision) = @año) AND
			(@mes IS NULL OR MONTH(fechaEmision) = @mes) AND
			(@dia IS NULL OR DAY(fechaEmision) = @dia) AND
			(@id_usuario IS NULL OR Venta.id_usuario = @id_usuario)

		RETURN @MontoTotalVendido
	END
	GO

	-- [*] Creacion de la funcion udf_MontoTotalVendidoACliente

	CREATE OR ALTER FUNCTION udf_MontoTotalVendidoACliente
	(
		@año INT = NULL,
		@mes INT = NULL,
		@dia INT = NULL,
		@id_cliente INT
	)
	RETURNS MONEY
	AS
	BEGIN
		SET @año = NULLIF(@año, 0)
		SET @mes = NULLIF(@mes, 0)
		SET @dia = NULLIF(@dia, 0)
		SET @id_cliente = NULLIF(@id_cliente, 0)

		DECLARE @MontoTotalVendido MONEY = 0
		IF @id_cliente IS NOT NULL
		BEGIN
			DECLARE @documentoCliente INT = 
			(
				SELECT documento FROM Cliente WHERE id_cliente = @id_cliente
			)
		END

		SELECT @MontoTotalVendido = SUM(importeTotal)
		FROM Venta
		WHERE
			(@año IS NULL OR YEAR(fechaEmision) = @año) AND
			(@mes IS NULL OR MONTH(fechaEmision) = @mes) AND
			(@dia IS NULL OR DAY(fechaEmision) = @dia) AND
			(@id_cliente IS NULL OR Venta.documentoCliente = @documentoCliente)

		RETURN @MontoTotalVendido
	END
	GO
	


