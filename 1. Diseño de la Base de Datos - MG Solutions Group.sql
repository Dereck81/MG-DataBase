/*  Creacion de la base de datos
	Empresa: MGSolutionsGroup
*/

-- Usamos la base de datos master
USE master
GO

-- Creamos la base de datos MGSolutionsGroup
CREATE DATABASE MGSolutionsGroup;
GO

-- Usamos la base de datos MGSolutionsGroup
USE MGSolutionsGroup
GO

-- Creamos las tablas con sus respectivos atributos

	-- [*] Creacion de las tablas necesarias para la tabla Empleado

	CREATE TABLE TipoEmpleado
	(
		id_tipoEmpleado INT IDENTITY(1,1) PRIMARY KEY,
		tipoEmpleado VARCHAR(20) UNIQUE NOT NULL,
		cuenta BIT NOT NULL
	)
	GO

	CREATE TABLE Empleado
	(
		id_empleado INT IDENTITY(1,1) PRIMARY KEY,
		id_tipoEmpleado INT,
		DNI CHAR(8) UNIQUE NOT NULL,
		nombre VARCHAR(32) NOT NULL,
		apellidoPaterno VARCHAR(32) NOT NULL,
		apellidoMaterno VARCHAR(32) NOT NULL,
		telefono VARCHAR(9) UNIQUE NOT NULL,
		email VARCHAR(64) UNIQUE NOT NULL,
		fechaNacimiento DATETIME2 NOT NULL,
		FOREIGN KEY (id_tipoEmpleado) REFERENCES TipoEmpleado(id_tipoEmpleado),
		CONSTRAINT CK_ValidarEmailEmpleado 
			CHECK (email LIKE '%_@__%.__%'),
		CONSTRAINT CK_telefonoEmpleado
			CHECK (telefono NOT LIKE '%[^0-9]%'),
		CONSTRAINT CK_DNI
			CHECK (DNI NOT LIKE '%[a-zA-Z]%' AND LEN(DNI) = 8),
		CONSTRAINT CK_fechaNacimiento
			CHECK (DATEDIFF(DAY, fechaNacimiento, GETDATE())/365.25 >= 18)
	)
	GO

	----------------------------------------------------------------

	-- [*] Creacion de las tablas necesarias para la tabla Usuario

	CREATE TABLE tipoUsuario
	(
		id_tipoUsuario INT IDENTITY(1,1) PRIMARY KEY,
		tipoUsuario VARCHAR(20) UNIQUE NOT NULL,
	)
	GO

	CREATE TABLE Usuario
	(
		id_usuario INT IDENTITY(1,1) PRIMARY KEY,
		id_tipoUsuario INT,
		id_empleado INT UNIQUE,
		email VARCHAR(64) UNIQUE NOT NULL,
		apiToken VARCHAR(100) UNIQUE NOT NULL,
		FOREIGN KEY (id_tipoUsuario) REFERENCES tipoUsuario(id_tipoUsuario),
		FOREIGN KEY (id_empleado) REFERENCES Empleado(id_empleado),
		CONSTRAINT CK_ValidarEmailUsuario
			CHECK (email LIKE '%_@mgsolutionsgroup.com' OR email LIKE '%_@rrsoluciones.com')
	)
	GO

	-- [*] Creacion de las tablas necesarias para la tabla Dispositivo

	CREATE TABLE TipoDispositivo
	(
		id_dispositivo INT IDENTITY(1,1) PRIMARY KEY,
		nombreDispositivo VARCHAR(32) UNIQUE NOT NULL,
	)
	GO

	----------------------------------------------------------------

	-- [*] Creacion de las tablas necesarias para la tabla ActividadSistema

	CREATE TABLE ActividadSistema
	(
		id_usuario INT,
		id_dispositivo INT,
		nombreNavegador VARCHAR(50) NOT NULL,
		versionNavegador VARCHAR(20) NOT NULL,
		fechaConexion DATETIME2 NOT NULL,
		direccionIp VARCHAR(50) NOT NULL,
		actividad VARCHAR(100) NOT NULL,
		FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario),
		FOREIGN KEY (id_dispositivo) REFERENCES TipoDispositivo(id_dispositivo)
	)
	GO

	----------------------------------------------------------------

	-- [*] Creacion de las tablas necesarias para la tabla HistorialReporte

	CREATE TABLE TipoArchivo
	(
		id_tipoArchivo INT IDENTITY(1,1) PRIMARY KEY,
		tipoArchivo VARCHAR(5) UNIQUE NOT NULL,
	)
	GO

	CREATE TABLE TipoReporte
	(
		id_tipoReporte INT IDENTITY(1,1) PRIMARY KEY,
		tipoReporte VARCHAR(32) UNIQUE NOT NULL,
	)
	GO

	CREATE TABLE HistorialReporte
	(
		id_historialReporte INT IDENTITY(1,1) PRIMARY KEY,
		id_usuario INT,
		fechaRegistro DATETIME2 NOT NULL,
		nombreArchivo VARCHAR(120) NOT NULL,
		id_tipoArchivo INT,
		id_tipoReporte INT,
		FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario),
		FOREIGN KEY (id_tipoArchivo) REFERENCES TipoArchivo(id_tipoArchivo),
		FOREIGN KEY (id_tipoReporte) REFERENCES TipoReporte(id_tipoReporte)
	)
	GO

	-- [*] Creacion de las tablas necesarias para la tabla Conductor, ConductorVehiculo y Vehiculo

	CREATE TABLE Conductor
	(
		id_conductor INT IDENTITY(1,1) PRIMARY KEY,
		id_empleado INT,
		licencia VARCHAR(15) UNIQUE NOT NULL,
		estadoActivo BIT NOT NULL,
		FOREIGN KEY (id_empleado) REFERENCES Empleado(id_empleado)
	)
	GO


	CREATE TABLE Vehiculo
	(
		id_vehiculo INT IDENTITY(1,1) PRIMARY KEY,
		marca VARCHAR(20) NOT NULL,
		modelo VARCHAR(20) NOT NULL,
		placa VARCHAR(10) UNIQUE NOT NULL,
		estadoActivo BIT NOT NULL,
	)
	GO

	CREATE TABLE ConductorVehiculo
	(
		id_conductor INT,
		id_vehiculo INT,
		fechaRegistro DATETIME2 NOT NULL DEFAULT GETDATE(),
		PRIMARY KEY (id_conductor, id_vehiculo, fechaRegistro),
		FOREIGN KEY (id_conductor) REFERENCES Conductor(id_conductor),
		FOREIGN KEY (id_vehiculo) REFERENCES Vehiculo(id_vehiculo)
	)
	GO

	----------------------------------------------------------------

	-- [*] Creacion de las tablas necesarias para la tabla Cliente

	CREATE TABLE TipoCliente
	(
		id_tipoCliente INT IDENTITY(1,1) PRIMARY KEY,
		tipoCliente VARCHAR(32) UNIQUE NOT NULL
	)
	GO

	CREATE TABLE TipoDocumento
	(
		id_tipoDocumento INT IDENTITY(1,1) PRIMARY KEY,
		tipoDocumento VARCHAR(32) UNIQUE NOT NULL
	)
	GO

	CREATE TABLE Cliente
	(
		id_cliente INT IDENTITY(1,1) PRIMARY KEY,
		id_tipoCliente INT,
		id_tipoDocumento INT,
		documento VARCHAR(11) UNIQUE NOT NULL,
		nombre VARCHAR(255) NOT NULL,
		telefono VARCHAR(10),
		email VARCHAR(64),
		FOREIGN KEY (id_tipoCliente) REFERENCES TipoCliente(id_tipoCliente),
		FOREIGN KEY (id_tipoDocumento) REFERENCES TipoDocumento(id_tipoDocumento),
		CONSTRAINT CK_telefonoCliente 
			CHECK (telefono IS NULL OR (telefono NOT LIKE '%[^0-9]%')),
		CONSTRAINT CK_ValidarEmailCliente
			CHECK (email IS NULL OR email LIKE '%_@__%.__%'),
		CONSTRAINT CK_DocumentoCliente
			CHECK (documento NOT LIKE '%[^0-9]%')

	)
	GO

	----------------------------------------------------------------

	-- [*] Creacion de las tablas necesarias para la tabla Proovedor

	CREATE TABLE Proveedor
	(
		id_proveedor INT IDENTITY(1,1) PRIMARY KEY,
		RUC CHAR(11) UNIQUE,
		razonSocial VARCHAR(100) UNIQUE NOT NULL,
		telefono VARCHAR(10) NULL,
		email VARCHAR(64) NULL,
		CONSTRAINT CK_ValidarEmailProveedor
			CHECK (email LIKE '%_@__%.__%'),
		CONSTRAINT CK_ValirdarTelefonoProveedor
			CHECK (telefono IS NULL OR (telefono NOT LIKE '%[^0-9+]%' AND telefono LIKE '%[0-9]%')),
		CONSTRAINT CK_ProveedorTelefonoEmail
			CHECK (COALESCE(email, telefono) IS NOT NULL OR (email IS NOT NULL AND telefono IS NOT NULL)),
		CONSTRAINT CK_ValidarRUC
			CHECK (RUC NOT LIKE '%[^0-9]%' AND RUC LIKE '%[0-9]%')
	)
	GO


	----------------------------------------------------------------

	-- [*] Creacion de las tablas necesarias para la tabla Ubicacion Geografica

	CREATE TABLE Pais
	(
		id_pais INT IDENTITY(1,1) PRIMARY KEY,
		pais VARCHAR(15) UNIQUE NOT NULL,
	)
	GO

	CREATE TABLE Region
	(
		id_region INT IDENTITY(1,1) PRIMARY KEY,
		id_pais INT,
		region VARCHAR(32) UNIQUE NOT NULL,
		FOREIGN KEY (id_pais) REFERENCES Pais(id_pais)
	)
	GO

	CREATE TABLE Provincia
	(
		id_provincia INT IDENTITY(1,1) PRIMARY KEY,
		id_region INT,
		provincia VARCHAR(32) UNIQUE NOT NULL,
		FOREIGN KEY (id_region) REFERENCES Region(id_region)
	)
	GO

	CREATE TABLE Distrito
	(
		id_distrito INT IDENTITY(1,1) PRIMARY KEY,
		id_provincia INT,
		distrito VARCHAR(32) UNIQUE NOT NULL,
		FOREIGN KEY (id_provincia) REFERENCES Provincia(id_provincia)
	)
	GO

	CREATE TABLE UbicacionGeograficaProveedor
	(
		id_proveedor INT,
		id_distrito INT,
		direccion VARCHAR(255) NOT NULL,
		PRIMARY KEY (id_proveedor, id_distrito),
		FOREIGN KEY (id_proveedor) REFERENCES Proveedor(id_proveedor),
		FOREIGN KEY (id_distrito) REFERENCES Distrito(id_distrito)
	)
	GO
	
	CREATE TABLE UbicacionGeograficaCliente
	(
		id_cliente INT,
		id_distrito INT,
		direccion VARCHAR(255) NOT NULL,
		PRIMARY KEY (id_cliente, id_distrito),
		FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente),
		FOREIGN KEY (id_distrito) REFERENCES Distrito(id_distrito)
	)
	GO

	CREATE TABLE UbicacionGeograficaEmpleado
	(
		id_empleado INT,
		id_distrito INT,
		direccion VARCHAR(255) NOT NULL,
		PRIMARY KEY (id_empleado, id_distrito),
		FOREIGN KEY (id_empleado) REFERENCES Empleado(id_empleado),
		FOREIGN KEY (id_distrito) REFERENCES Distrito(id_distrito)
	)
	GO

	----------------------------------------------------------------

	-- [*] Creacion de las tablas necesarias para la tabla Moneda

	CREATE TABLE Moneda
	(
		id_moneda INT IDENTITY(1,1) PRIMARY KEY,
		moneda VARCHAR(10) UNIQUE NOT NULL
	)
	GO

	----------------------------------------------------------------

	-- [*] Creacion de las tablas necesarias para la tabla Compra

	CREATE TABLE TipoComprobante
	(
		id_tipoComprobante INT IDENTITY(1,1) PRIMARY KEY,
		tipoComprobante VARCHAR(30) UNIQUE NOT NULL
	)
	GO

	/*
		[!] Se creo una funcion de usuario para ser usada por una restriccion
		en el ingreso de datos de la tabla compra, para evitar un problema en el
		tipo de cambio
		Ya que SQLServer no permite subconsultas en la restriccion CHECK
		se tuvo la necesidad de crear una funcion en esta parte de dise�o de la BD
	*/

	CREATE OR ALTER FUNCTION udf_NombreMoneda
	(
		@id INT
	)
	RETURNS VARCHAR(10)
	AS
	BEGIN
		RETURN(
			SELECT moneda FROM Moneda WHERE Moneda.id_moneda = @id
		)
	END
	GO

	CREATE TABLE Compra
	(
		id_compra INT IDENTITY(1,1) PRIMARY KEY,
		id_usuario INT,
		id_tipoComprobante INT,
		documento CHAR(11),
		serieComprobante VARCHAR(4) NOT NULL,
		numeroComprobante VARCHAR(10) NOT NULL,
		fechaSubida DATETIME2 NOT NULL,
		fechaEmision DATETIME2 NOT NULL,
		fechaVencimiento DATETIME2 NOT NULL,
		id_moneda INT,
		tipoCambio DECIMAL(4,3) NOT NULL DEFAULT 1,
		importeTotal MONEY NOT NULL,
		operacionesGravadas AS CAST((importeTotal*tipoCambio)/1.18 AS MONEY) PERSISTED NOT NULL,
		operacionesNoGravadas MONEY NOT NULL DEFAULT 0,
		totalIGV AS CAST(((importeTotal*tipoCambio)/1.18)*0.18 AS MONEY) PERSISTED NOT NULL,
		total AS CAST(importeTotal*tipoCambio AS MONEY) PERSISTED NOT NULL,
		UNIQUE(documento, serieComprobante, numeroComprobante),
		FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario),
		FOREIGN KEY (id_tipoComprobante) REFERENCES TipoComprobante(id_tipoComprobante),
		FOREIGN KEY (documento) REFERENCES Proveedor(RUC),
		FOREIGN KEY (id_moneda) REFERENCES Moneda(id_moneda),
		CONSTRAINT CK_SerieComprobante
			CHECK (serieComprobante LIKE '[A-Z]%'),
		CONSTRAINT CK_TipoCambioCheck
			CHECK (tipoCambio > 0),
		CONSTRAINT CK_TipoCambioSoles
			CHECK (
				(dbo.udf_NombreMoneda(id_moneda) = 'SOLES' AND tipoCambio = 1)
				OR (dbo.udf_NombreMoneda(id_moneda) <> 'SOLES' AND tipoCambio <> 1)
				)
	)
	GO

	----------------------------------------------------------------

	-- [*] Creacion de las tablas necesarias para la tabla Servicio

	CREATE TABLE Servicio
	(
		id_servicio INT IDENTITY(1,1) PRIMARY KEY,
		nombre VARCHAR(150) UNIQUE NOT NULL,
		precioUnitario MONEY NOT NULL,
		fechaCreacion DATETIME2 NOT NULL,
		id_moneda INT,
		FOREIGN KEY (id_moneda) REFERENCES Moneda(id_moneda)
	)
	GO

	----------------------------------------------------------------

	-- [*] Creacion de las tablas necesarias para la tabla Item


	CREATE TABLE MarcaProducto
	(
		id_marcaProducto INT IDENTITY(1,1) PRIMARY KEY,
		marca VARCHAR(40) UNIQUE NOT NULL
	)
	GO

	CREATE TABLE Item
	(
		id_item INT IDENTITY(1,1) PRIMARY KEY,
		nombreItem VARCHAR(300) NOT NULL,
		id_marcaProducto INT,
		descripcion VARCHAR(255),
		precioUnitario MONEY NOT NULL,
		stock INT NOT NULL,
		IGVincluido BIT NOT NULL,
		fechaCreacion DATETIME2 NOT NULL DEFAULT GETDATE(),
		fechaActualizacion DATETIME2 NOT NULL DEFAULT GETDATE(),
		UNIQUE(nombreItem, id_marcaProducto),
		FOREIGN KEY (id_marcaProducto) REFERENCES MarcaProducto(id_marcaProducto)
	)
	GO

	----------------------------------------------------------------

	-- [*] Creacion de las tablas necesarias para la tabla Guia Remitente, Venta

	CREATE TABLE TipoEstado
	(
		id_tipoEstado INT IDENTITY(1,1) PRIMARY KEY,
		estado VARCHAR(15) UNIQUE NOT NULL
	)
	GO

	CREATE TABLE Venta
	(
		id_venta INT IDENTITY(1,1) PRIMARY KEY,
		id_usuario INT,
		documentoCliente VARCHAR(11),
		id_tipoComprobante INT,
		serie VARCHAR(4) NOT NULL,
		numeroComprobante VARCHAR(15) NOT NULL,
		fechaEmision DATETIME2 NOT NULL DEFAULT GETDATE(),
		fechaVencimiento DATETIME2 NOT NULL DEFAULT GETDATE(),
		fechaPago DATETIME2 NOT NULL DEFAULT GETDATE(),
		id_moneda INT,
		operacionesNoGravadas MONEY NOT NULL DEFAULT 0,
		id_tipoEstado INT,
		UNIQUE (serie, numeroComprobante),
		FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario),
		FOREIGN KEY (documentoCliente) REFERENCES Cliente(documento),
		FOREIGN KEY (id_tipoComprobante) REFERENCES TipoComprobante(id_tipoComprobante),
		FOREIGN KEY (id_moneda) REFERENCES Moneda(id_moneda),
		FOREIGN KEY (id_tipoEstado) REFERENCES TipoEstado(id_tipoEstado),
		CONSTRAINT CK_NumeroComprobante
			CHECK (numeroComprobante NOT LIKE '%[^0-9]%'),
		CONSTRAINT CK_SerieVenta
			CHECK (serie LIKE '[A-Z][A-Z0-9][0-9][0-9]')
	)
	GO


	CREATE TABLE DetalleVentaGeneral
	(
		id_detallesVenta INT IDENTITY(1,1) PRIMARY KEY,
		id_venta INT,
		id_servicio INT NULL,
		id_item INT NULL,
		cantidad INT NOT NULL,
		precioUnitario MONEY NOT NULL,
		UNIQUE(id_venta, id_servicio, id_item),
		FOREIGN KEY (id_venta) REFERENCES Venta(id_venta),
		FOREIGN KEY (id_servicio) REFERENCES Servicio(id_servicio),
		FOREIGN KEY (id_item) REFERENCES Item(id_item),
		CONSTRAINT CK_ProductoAndServicioDetalleVenta
			CHECK ((id_item IS NOT NULL AND id_servicio IS NULL) OR (id_item IS NULL AND id_servicio IS NOT NULL)),
		CONSTRAINT CK_CantidadItemDetalleVenta
			CHECK (cantidad >= 1)
	)
	GO

	CREATE TABLE GuiaRemitente
	(
		id_guiaRemitente INT IDENTITY(1,1) PRIMARY KEY,
		id_usuario INT,
		id_cliente INT,
		id_venta INT,
		serieGR VARCHAR(4) NOT NULL,
		numeroComprobanteGR VARCHAR(15) NOT NULL,
		fechaCreacion DATETIME2 NOT NULL,
		fechaEmision DATETIME2 NOT NULL,
		fechaEnvio DATETIME2 NOT NULL,
		descripcion VARCHAR(150),
		id_tipoEstado INT,
		UNIQUE(serieGR, numeroComprobanteGR),
		FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario),
		FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente),
		FOREIGN KEY (id_tipoEstado) REFERENCES TipoEstado(id_tipoEstado),
		FOREIGN KEY (id_venta) REFERENCES Venta(id_venta),
		CONSTRAINT CK_NumeroComprobanteGR
			CHECK (numeroComprobanteGR NOT LIKE '%[^0-9]%'),
		CONSTRAINT CK_SerieVentaGR
			CHECK (serieGR LIKE '[A-Z][A-Z0-9][0-9][0-9]')
	)
	GO
