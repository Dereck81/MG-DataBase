/*  Vistas de la base de datos
	Empresa: MGSolutionsGroup
	Formato de fecha a aplicar: YYYY-MM-DD
*/

-- Usamos la base de datos MGSolutionsGroup
USE MGSolutionsGroup
GO

-- Creamos las vistas de la base de datos
	
	-- [*] Creamos la vista udv_TopClientes

	CREATE OR ALTER VIEW udv_TopClientes (ordenMerito, id_cliente, nombre, documento, montoComprado)
	AS
		SELECT TOP 5 ROW_NUMBER() OVER (ORDER BY SUM(importeTotal) DESC),
		C.id_cliente,
		C.nombre,
		C.documento,
		ISNULL(SUM(importeTotal), 0)
		FROM Venta AS V
		INNER JOIN Cliente AS C
		ON V.documentoCliente =  C.documento
		GROUP BY C.nombre, C.documento, C.id_cliente
	GO

	-- [*] Creamos la vista udv_TopProveedores
	
	CREATE OR ALTER VIEW udv_TopProveedores (ordenMerito, id_proveedor, razonSocial, RUC, montoInvertidoProductos)
	AS
		SELECT TOP 5 ROW_NUMBER() OVER (ORDER BY SUM(C.total) DESC),
		P.id_proveedor,
		P.razonSocial,
		P.RUC,
		ISNULL(SUM(C.total), 0)
		FROM Proveedor AS P
		INNER JOIN Compra AS C
		ON P.RUC =  C.documento
		GROUP BY P.id_proveedor, P.razonSocial, P.RUC
	GO

	-- [*] Creamos la vista udv_InformacionClientes

	CREATE OR ALTER VIEW udv_InformacionClientes
	(
		id_cliente,
		nombre,
		tipoDocumento,
		documento,
		telefono,
		email,
		direccion,
		distrito,
		provincia,
		region,
		pais
	)
	AS
		SELECT 
		C.id_cliente,
		C.nombre,
		(SELECT tipoDocumento FROM TipoDocumento WHERE id_tipoDocumento = C.id_tipoDocumento),
		C.documento,
		C.telefono,
		C.email,
		UbicacionGeograficaCliente.direccion,
		Distrito.distrito,
		Provincia.provincia,
		Region.region,
		Pais.pais 
		FROM Cliente AS C INNER JOIN UbicacionGeograficaCliente 
		ON C.id_cliente = UbicacionGeograficaCliente.id_cliente
		INNER JOIN Distrito 
		ON distrito.id_distrito = UbicacionGeograficaCliente.id_distrito
		INNER JOIN Provincia 
		ON provincia.id_provincia = distrito.id_provincia
		INNER JOIN Region
		ON Region.id_region = provincia.id_region
		INNER JOIN Pais
		ON pais.id_pais = Region.id_pais
	GO

	-- [*] Creamos la vista udv_InformacionProveedores

	CREATE OR ALTER VIEW udv_InformacionProveedores
	(
		id_proveedor,
		RUC,
		razonSocial,
		telefono,
		email,
		direccion,
		distrito,
		provincia,
		region,
		pais
	)
	AS
		SELECT
		Proveedor.id_proveedor,
		Proveedor.RUC,
		Proveedor.razonSocial,
		Proveedor.telefono,
		Proveedor.email,
		UbicacionGeograficaProveedor.direccion,
		Distrito.distrito,
		Provincia.provincia,
		Region.region,
		Pais.pais
		FROM Proveedor INNER JOIN UbicacionGeograficaProveedor
		ON Proveedor.id_proveedor = UbicacionGeograficaProveedor.id_proveedor
		INNER JOIN Distrito 
		ON distrito.id_distrito = UbicacionGeograficaProveedor.id_distrito
		INNER JOIN Provincia 
		ON provincia.id_provincia = distrito.id_provincia
		INNER JOIN Region
		ON Region.id_region = provincia.id_region
		INNER JOIN pais
		ON pais.id_pais = Region.id_pais
	GO

