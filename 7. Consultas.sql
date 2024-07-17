/*  Consultas de la base de datos
	Empresa: MGSolutionsGroup
*/

-- Usamos la base de datos MGSolutionsGroup
USE MGSolutionsGroup
GO

-- Aqui se listan algunas consultas de ejemplo
-- Que se pueden aplicar en la base de datos

	-- Productos mas vendidos
	SELECT TOP 10 DVG.id_item, I.nombreItem, SUM(DVG.cantidad) AS cantidad_vendida
	FROM DetalleVentaGeneral AS DVG
	INNER JOIN Item AS I
	ON DVG.id_item = I.id_item
	GROUP BY DVG.id_item, I.nombreItem
	ORDER BY SUM(DVG.cantidad) DESC

	-- Mostrar empleados que tengan licencia activa
	SELECT CONCAT(nombre,' ', apellidoPaterno, ' ', apellidoMaterno) AS nombreCompleto, licencia, estadoActivo 
	FROM Conductor INNER JOIN Empleado ON Empleado.id_empleado = Conductor.id_empleado
	WHERE licencia IS NOT NULL AND estadoActivo = 1

	-- Empleado asignado para conducir
	SELECT CONCAT(E.nombre,' ', E.apellidoPaterno, ' ', E.apellidoMaterno) AS nombreCompleto, C.licencia, CV.fechaRegistro AS fechaRegistroAsignacion
	FROM ConductorVehiculo AS CV
	INNER JOIN Conductor AS  C
	ON C.id_conductor = CV.id_Conductor
	INNER JOIN Empleado AS E
	ON E.id_empleado = C.id_empleado

	-- Total de ventas por año 
	SELECT ISNULL(dbo.udf_MontoTotalVendido(2022, DEFAULT, DEFAULT, DEFAULT), 0) AS MontoTotalDeVentasPorAño

	-- Total de ventas por mes y año 
	SELECT ISNULL(dbo.udf_MontoTotalVendido(2023, 7, DEFAULT, DEFAULT), 0) AS MontoTotalDeVentasPorAño

	-- Para saber cuantos servicios realizó un empleado en un mes específico
	SELECT COUNT(DVG.id_servicio) AS TotalServicios
	FROM DetalleVentaGeneral DVG
	INNER JOIN Venta V ON DVG.id_venta = V.id_venta
	WHERE V.id_usuario = 5
	  AND MONTH(V.fechaEmision) = 9;

	-- Total de ventas (incluyendo servicios) realizadas por un empleado en un mes específico
	SELECT COUNT(DISTINCT V.id_venta) AS TotalVentasConServicios
	FROM DetalleVentaGeneral DVG
	INNER JOIN Venta V ON DVG.id_venta = V.id_venta
	WHERE V.id_usuario = 4
	  AND MONTH(V.fechaEmision) = 1;

	-- Consulta sobre la cantidad de ingreso que hizo el usuario en el año 2023 desde mayo hasta la actualidad
	SELECT Empleado.nombre, Empleado.apellidoPaterno, COUNT(ActividadSistema.id_usuario) AS numero_Ingreso
	FROM ActividadSistema
	INNER JOIN Usuario
	ON Usuario.id_usuario = ActividadSistema.id_usuario
	INNER JOIN Empleado
	ON Empleado.id_empleado = Usuario.id_empleado
	WHERE YEAR(ActividadSistema.fechaConexion) = 2023
	AND MONTH(ActividadSistema.fechaConexion) > 5
	GROUP BY Empleado.nombre, Empleado.apellidoPaterno

	-- Cantidad de productos almacenados por marca que tienen menos de 20 en stock
	SELECT MarcaProducto.marca, Item.nombreItem, stock AS cantidad_Items
	FROM Item INNER JOIN MarcaProducto ON MarcaProducto.id_marcaProducto = Item.id_marcaProducto
	WHERE stock < 20

	-- Total de ventas (incluyendo servicios) realizadas por un empleado en un mes específico
	SELECT COUNT(DISTINCT V.id_venta) AS TotalVentasConServicios
	FROM DetalleVentaGeneral DVG
	INNER JOIN Venta V ON DVG.id_venta = V.id_venta
	WHERE V.id_usuario = 5
	AND MONTH(V.fechaEmision) = 1;