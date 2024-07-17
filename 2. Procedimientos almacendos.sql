/*  Creacion de Procedimientos Almacenados para la base de datos
	Empresa: MGSolutionsGroup
*/

-- Usamos la base de datos MGSolutionsGroup
USE MGSolutionsGroup
GO

-- Creamos las tablas con sus respectivos atributos

	-- [*] Creacion del procedimiento sp_RegistrarVenta

	CREATE OR ALTER PROCEDURE sp_RegistrarVenta
	(
		@id_usuario INT,
		@id_tipoComprobante INT,
		@documentoCliente VARCHAR(11),
		@serie VARCHAR(4),
		@numeroComprobante VARCHAR(15),
		@fechaEmision DATETIME2,
		@fechaVencimiento DATETIME,
		@fechaPago DATETIME2,
		@id_moneda INT,
		@id_tipoEstado INT,
		@id_item INT = NULL,
		@id_servicio INT = NULL,
		@cantidad INT
	)
	AS
	BEGIN
		IF NOT ((@serie LIKE '[A-Z][0-9A-Z][0-9][0-9]') AND (@numeroComprobante NOT LIKE '%[^0-9]%'))
		BEGIN
			RAISERROR('Serie o numero Comprobante no validos', 15, 1)
			RETURN
		END

		DECLARE @ClienteID VARCHAR = (SELECT Cliente.documento FROM Cliente WHERE Cliente.documento = @documentoCliente);

		IF @ClienteID IS NULL
		BEGIN
			RAISERROR('Cliente inexistente', 15, 1)
			RETURN
		END

		DECLARE @stock_ INT = 0;
		DECLARE @PrecioUnitarioProd MONEY = 0;

		IF @id_servicio IS NULL AND @id_item IS NOT NULL
		BEGIN
			SET @stock_ = (SELECT ISNULL(Item.stock, 0) FROM Item WHERE Item.id_item = @id_item) - @cantidad;
			SET @PrecioUnitarioProd = 
			(
				SELECT ISNULL(I.precioUnitario, 0) FROM Item AS I WHERE I.id_item = @id_item
			)
		END
		ELSE
		BEGIN
			SET @PrecioUnitarioProd = 
			(
				SELECT ISNULL(S.precioUnitario, 0) FROM Servicio AS S WHERE S.id_servicio = @id_servicio
			)	
		END


		IF @stock_ < 0 OR @cantidad <= 0
		BEGIN
			RAISERROR('Cantidad invalida o falta Stock', 15, 1)
			RETURN
		END


		DECLARE @UltimoRegistroClienteVenta INT = 
		(
			SELECT Venta.id_venta FROM Venta 
			WHERE (Venta.documentoCliente = @documentoCliente AND Venta.serie = @serie) 
				AND (Venta.numeroComprobante = @numeroComprobante)
		)

		BEGIN TRANSACTION
		BEGIN TRY
			IF (@id_item IS NOT NULL OR @id_servicio IS NOT NULL) AND
				(@id_item IS NULL OR @id_servicio IS NULL)
			BEGIN
				IF @UltimoRegistroClienteVenta IS NOT NULL
				BEGIN
					IF NOT EXISTS (
						SELECT 1
						FROM DetalleVentaGeneral
						WHERE (id_item = @id_item OR id_servicio = @id_servicio) AND id_venta = @UltimoRegistroClienteVenta
					)
					BEGIN
						INSERT INTO DetalleVentaGeneral (id_venta, id_servicio, id_item, cantidad, precioUnitario) 
						VALUES (@UltimoRegistroClienteVenta, @id_servicio, @id_item, @cantidad, @PrecioUnitarioProd)

						IF @id_item IS NOT NULL
						BEGIN
							UPDATE Item SET stock = @stock_ WHERE Item.id_item = @id_item
						END

					END
					ELSE
					BEGIN
						RAISERROR('Se ha tratado de registrar un producto que ya se encuentra en dicha venta', 15, 1)
						RETURN
					END
				END
				ELSE
				BEGIN
					INSERT INTO Venta 
					(
						id_usuario, documentoCliente, id_tipoComprobante, serie,
						numeroComprobante, fechaEmision, fechaPago, fechaVencimiento,
						id_moneda, id_tipoEstado
					)
					VALUES (
						@id_usuario, @documentoCliente, @id_tipoComprobante, @serie,
						@numeroComprobante, @fechaEmision, @fechaPago, @fechaVencimiento,
						@id_moneda, @id_tipoEstado
					)

					DECLARE @id_VentaCreada INT = SCOPE_IDENTITY()

					INSERT INTO DetalleVentaGeneral (id_venta, id_servicio, id_item, cantidad, precioUnitario) 
					VALUES (@id_VentaCreada, @id_servicio, @id_item, @cantidad, @PrecioUnitarioProd)

					IF @id_item IS NOT NULL
					BEGIN
						UPDATE Item SET stock = @stock_ WHERE Item.id_item = @id_item
					END

				END
			END
			ELSE
			BEGIN
				RAISERROR('No se pudo agregar un registro más a la venta, verifique los datos ingresados y las restricciones de la tabla DetalleVentaGeneral', 15, 1)
				RETURN
			END
			COMMIT
		END TRY
		BEGIN CATCH
			ROLLBACK
			DECLARE @MENSAJE_ERROR VARCHAR(500) = ERROR_MESSAGE()
			DECLARE @NUMERO_SEVERO INT = ERROR_SEVERITY()
			RAISERROR(@MENSAJE_ERROR, @NUMERO_SEVERO, 1)
			RETURN
		END CATCH
	END
	GO

	-- [*] Creacion del procedimiento sp_InsertarUsuario

	CREATE OR ALTER PROCEDURE sp_InsertarUsuario
	(
		@id_tipoUsuario INT,
		@id_empleado INT,
		@email VARCHAR(64) = NULL,
		@apiToken VARCHAR(100)
	)
	AS
	BEGIN
		BEGIN TRANSACTION
		BEGIN TRY

			DECLARE @correo CHAR(35)

			SELECT @correo = TRANSLATE(LOWER(
								CONCAT(
									SUBSTRING(Empleado.nombre, 0, 3),
									SUBSTRING(Empleado.apellidoPaterno, 0, 3),
									SUBSTRING(Empleado.apellidoMaterno, 0, 3),
									Empleado.DNI,
									'@mgsolutionsgroup.com'
								)
							), 'áéíóúüñ', 'aeiouun')
			FROM Empleado WHERE Empleado.id_empleado = @id_empleado

			INSERT INTO Usuario (id_tipoUsuario, id_empleado, email, apiToken) 
			VALUES (@id_tipoUsuario, @id_empleado, ISNULL(@email, @correo), @apiToken)

			COMMIT
		END TRY
		BEGIN CATCH
			ROLLBACK
			DECLARE @MENSAJE_ERROR VARCHAR(500) = ERROR_MESSAGE()
			DECLARE @NUMERO_SEVERO INT = ERROR_SEVERITY()
			RAISERROR(@MENSAJE_ERROR, @NUMERO_SEVERO, 1)
		END CATCH
	END
	GO

	-- [*] Creacion del procedimiento sp_EliminarFacturaVenta

	CREATE OR ALTER PROCEDURE sp_EliminarFacturaVenta
	(
		@id_venta INT = NULL,
		@serie VARCHAR(4) = NULL,
		@numeroComprobante VARCHAR(15) = NULL
	)
	AS
	BEGIN

		IF (@id_venta IS NULL) AND (@serie IS NULL OR @numeroComprobante IS NULL)
		BEGIN
			RAISERROR('No se puede obtener la venta que se esta queriendo eliminar, revise los valores ingresados!', 15, 1)
			RETURN
		END

		IF (@id_venta IS NULL) AND (@serie IS NOT NULL AND @numeroComprobante IS NOT NULL)
		BEGIN
			SET @id_venta = 
			(
				SELECT id_venta FROM Venta WHERE serie = @serie AND numeroComprobante = @numeroComprobante
			)
		END

		BEGIN TRANSACTION
		BEGIN TRY

			DECLARE @CantidadRegistrosDetalleVentaG INT = 
			(
				SELECT ISNULL(COUNT(id_detallesVenta), 0) FROM DetalleVentaGeneral WHERE 
				(id_venta = @id_venta)
			)

			WHILE @CantidadRegistrosDetalleVentaG > 0
			BEGIN
				DECLARE @UltimoRegistroDetalleVentaG INT = 
				(
					SELECT TOP 1 id_detallesVenta FROM DetalleVentaGeneral WHERE 
					(id_venta = @id_venta)
				)
				PRINT(@UltimoRegistroDetalleVentaG)
				DELETE FROM DetalleVentaGeneral WHERE id_detallesVenta = @UltimoRegistroDetalleVentaG
				SET @CantidadRegistrosDetalleVentaG -= 1
			END

		COMMIT
		END TRY
		BEGIN CATCH
			ROLLBACK
			DECLARE @MENSAJE_ERROR VARCHAR(500) = ERROR_MESSAGE()
			DECLARE @NUMERO_SEVERO INT = ERROR_SEVERITY()
			RAISERROR(@MENSAJE_ERROR, @NUMERO_SEVERO, 1)
		END CATCH
	END
	GO

	