/*  Triggers para la base de datos
	Empresa: MGSolutionsGroup
*/

-- Usamos la base de datos MGSolutionsGroup
USE MGSolutionsGroup
GO

-- Creamos los TRIGGERS necesarios

	-- [*] Creacion del trigger tr_ModificarRegistroDetalleVentaGeneral
	/*
		Su funcionalidad principal es el de llevar control a la hora
		de modificar la cantidad de un registro de venta (Especialmente
		si se trata de items), validando si hay stock o no,
		y en el caso de que se quite cantidad, le agregaria stock
		al item que se le esta modificando
	*/

	CREATE OR ALTER TRIGGER tr_ModificarRegistroDetalleVentaGeneral
	ON DetalleVentaGeneral
	INSTEAD OF UPDATE
	AS
	BEGIN
		IF(SELECT COUNT(*) FROM inserted) > 0
		BEGIN
			DECLARE @id_servicio INT, @id_item INT, @id_DetalleVenta INT, @cantidadIngresada INT;
			SELECT
				@id_servicio = id_Servicio,
				@id_item = id_item,
				@id_DetalleVenta = id_detallesVenta,
				@cantidadIngresada = cantidad
			FROM inserted;

			IF (@id_servicio IS NULL AND @id_item IS NOT NULL) AND @cantidadIngresada > 0
			BEGIN
				DECLARE @stockItemActual INT = 
				(
					SELECT stock FROM Item 
					WHERE Item.id_item = @id_item
				)
				DECLARE @cantidadItemDVGRegistrado INT = 
				(
					SELECT cantidad FROM DetalleVentaGeneral
					WHERE DetalleVentaGeneral.id_detallesVenta = @id_DetalleVenta
				)

				IF (@cantidadIngresada > @cantidadItemDVGRegistrado)
				BEGIN
					IF ((@cantidadIngresada-@cantidadItemDVGRegistrado) <= @stockItemActual)
					BEGIN
						UPDATE DetalleVentaGeneral SET cantidad = @cantidadIngresada 
						WHERE DetalleVentaGeneral.id_detallesVenta = @id_DetalleVenta
						UPDATE Item SET stock = (@cantidadIngresada-@cantidadItemDVGRegistrado) - @stockItemActual
						WHERE Item.id_item = @id_item
					END
					ELSE
					BEGIN
						RAISERROR('No hay suficiente stock para realizar esta modificacion!', 15, 1)
						RETURN
					END
					
				END
				IF (@cantidadIngresada < @cantidadItemDVGRegistrado)
				BEGIN
					UPDATE DetalleVentaGeneral SET cantidad = @cantidadIngresada 
					WHERE DetalleVentaGeneral.id_detallesVenta = @id_DetalleVenta
					UPDATE Item SET stock = (@cantidadItemDVGRegistrado - @cantidadIngresada) + @stockItemActual
					WHERE Item.id_item = @id_item
				END

			END
			ELSE
			BEGIN
				RAISERROR('Problemas con la restriccion o la cantidad que intenta ingresar no es valida!', 15, 1)
				RETURN
			END

		END
	END
	GO

	-- [*] Creacion del trigger tr_EliminarRegistroDetalleVentaGeneral

	CREATE OR ALTER TRIGGER tr_EliminarRegistroDetalleVentaGeneral
	ON DetalleVentaGeneral
	AFTER DELETE
	AS
	BEGIN
		DECLARE @cantidadEliminada INT, @id_item INT, @id_servicio INT, @id_venta INT, @id_detalleVenta INT

		SELECT
			@cantidadEliminada = deleted.cantidad,
			@id_item = deleted.id_item,
			@id_servicio = deleted.id_servicio,
			@id_venta = deleted.id_venta,
			@id_detalleVenta = deleted.id_detallesVenta
		FROM deleted

		DECLARE @stock INT = 
		(
			SELECT ISNULL(stock, 0) FROM Item WHERE Item.id_item = @id_item
		)

		DECLARE @existeDVG INT = 
		(
			SELECT COUNT(*) FROM DetalleVentaGeneral WHERE DetalleVentaGeneral.id_venta = @id_venta
		)

		IF (@id_servicio IS NULL AND @id_item IS NOT NULL) 
		BEGIN
			UPDATE Item SET stock = (@stock + @cantidadEliminada)
			WHERE Item.id_item = @id_item
			IF (@existeDVG = 0)
			BEGIN
				DELETE FROM Venta WHERE Venta.id_venta = @id_venta
				PRINT('Se eliminó la factura(venta), por falta de productos o servicios')
			END
		END
		ELSE
		BEGIN
			IF (@id_servicio IS NOT NULL AND @id_item IS NOT NULL)
			BEGIN
				RAISERROR('Problemas con la restriccion!', 15, 1)
				RETURN
			END
			IF (@existeDVG = 0)
			BEGIN
				DELETE FROM Venta WHERE Venta.id_venta = @id_venta
				PRINT('Se eliminó la factura(venta), por falta de productos o servicios')
			END
		END
	END
	GO

	-- [*] Creacion del trigger tr_ActualizarFechaItem

	CREATE OR ALTER TRIGGER tr_ActualizarFechaItem
	ON Item
	AFTER UPDATE
	AS
	BEGIN
		IF UPDATE(precioUnitario)
		BEGIN
			BEGIN TRANSACTION
			BEGIN TRY
				DECLARE @id_item INT = 
				(
					SELECT id_item FROM inserted
				)
				UPDATE Item SET fechaActualizacion = GETDATE() WHERE id_item = @id_item
				COMMIT
			END TRY
			BEGIN CATCH
				ROLLBACK
				DECLARE @MENSAJE_ERROR VARCHAR(500) = ERROR_MESSAGE()
				DECLARE @NUMERO_SEVERO INT = ERROR_SEVERITY()
				RAISERROR(@MENSAJE_ERROR, @NUMERO_SEVERO, 1)
			END CATCH
		END
	END
	GO
