/*  Usuarios y roles de la base de datos
	Empresa: MGSolutionsGroup
	Tipos de usuarios: Vendor y Marketing
*/
-- Usamos master
USE master
GO

-- Creamos los logins
CREATE LOGIN VendedorMartinez WITH PASSWORD = 'MartinezVentas'
CREATE LOGIN VendedorHernandez WITH PASSWORD = 'HernandezVentas'
CREATE LOGIN VendedorSerrano WITH PASSWORD = 'SerranoVentas'
CREATE LOGIN VendedorTorres WITH PASSWORD = 'TorresVentas'
CREATE LOGIN MarketingNavarro WITH PASSWORD = 'NavarroMarketing'
CREATE LOGIN VendedorRuiz WITH PASSWORD = 'RuizVentas'
CREATE LOGIN MarketingOrtega WITH PASSWORD = 'OrtegaMarketing'
CREATE LOGIN MarketingHerrera WITH PASSWORD = 'HerreraMarketing'
CREATE LOGIN VendedorHuanca WITH PASSWORD = 'HuancaVentas'
CREATE LOGIN VendedorGuevara WITH PASSWORD = 'GuevaraVentas'

-- Usamos la base de datos MGSolutionsGroup
USE MGSolutionsGroup
GO

-- Creamos los usuarios y les asignamos un login
CREATE USER VentaMartinez_MGSolutions FOR LOGIN VendedorMartinez
CREATE USER VentaHernandez_MGSolutions FOR LOGIN VendedorHernandez
CREATE USER VentaSerrano_MGSolutions FOR LOGIN VendedorSerrano
CREATE USER VentaTorres_MGSolutions FOR LOGIN VendedorTorres
CREATE USER MarketingNavarro_MGSolutions FOR LOGIN MarketingNavarro
CREATE USER VentaRuiz_MGSolutions FOR LOGIN VendedorRuiz
CREATE USER MarketingOrtega_MGSolutions FOR LOGIN MarketingOrtega
CREATE USER MarketingHerrera_MGSolutions FOR LOGIN MarketingHerrera
CREATE USER VentaHuanca_MGSolutions FOR LOGIN VendedorHuanca
CREATE USER VentaGuevara_MGSolutions FOR LOGIN VendedorGuevara

-- Creando el roles
CREATE ROLE vendedores
CREATE ROLE marketing

-- Asignando permisos para ejecucion de procedimientos, funciones, triggers, vistas
GRANT EXECUTE ON sp_RegistrarVenta TO vendedores, marketing
GRANT EXECUTE ON sp_EliminarFacturaVenta TO vendedores, marketing
GRANT EXECUTE ON udf_MontoTotalVendido TO vendedores, marketing
GRANT EXECUTE ON udf_MontoTotalVendidoACliente TO vendedores, marketing
GRANT EXECUTE ON tr_ModificarRegistroDetalleVentaGeneral TO vendedores, marketing
GRANT EXECUTE ON tr_EliminarRegistroDetalleVentaGeneral TO vendedores, marketing
GRANT EXECUTE ON tr_ActualizarFechaItem TO vendedores, marketing
GRANT EXECUTE ON udv_TopClientes TO vendedores, marketing
GRANT EXECUTE ON udv_TopProveedores TO vendedores, marketing
GRANT EXECUTE ON udv_InformacionClientes TO vendedores, marketing
GRANT EXECUTE ON udv_InformacionProveedores TO vendedores, marketing

-- Asignando roles y asignando INSERT Y SELECT de la tabla Compra al rol vendedores
GRANT INSERT, SELECT ON dbo.Compra TO vendedores

-- Asignando INSERT Y SELECT de la tabla Proveedor al rol vendedores
GRANT INSERT, SELECT ON dbo.Proveedor TO vendedores

-- Asignando INSERT a la tabla Servicio a los roles vendedores y marketing
GRANT INSERT, SELECT ON dbo.Servicio TO vendedores, marketing

-- Asignando SELECT a la tabla MarcaProducto a los roles vendedores y marketing
GRANT SELECT ON dbo.MarcaProducto TO vendedores, marketing

-- Asignando SELECT a la tabla Region a los roles vendedores y marketing
GRANT SELECT ON dbo.Region TO vendedores, marketing

-- Asignando INSERT Y SELECT de la tabla UbicacionGeograficaCliente a los roles vendedores y marketing
GRANT INSERT, SELECT ON dbo.UbicacionGeograficaCliente TO vendedores, marketing

-- Asignando INSERT Y SELECT de la tabla Venta a los roles vendedores y marketing
GRANT INSERT, SELECT ON dbo.Venta TO vendedores, marketing

-- Asignando INSERT Y SELECT de la tabla Distrito a los roles vendedores y marketing
GRANT INSERT, SELECT ON dbo.Distrito TO vendedores, marketing

-- Asignando SELECT a la tabla Item a los roles vendedores y marketing
GRANT SELECT ON dbo.Item TO vendedores, marketing;

-- Asignando INSERT Y SELECT de la tabla Cliente a los roles vendedores y marketing
GRANT INSERT, SELECT ON dbo.Cliente TO vendedores, marketing

-- Asignando SELECT a la tabla Provincia a los roles vendedores y marketing
GRANT SELECT ON dbo.Provincia TO vendedores, marketing

-- Asignando INSERT Y SELECT de la tabla DetalleVentaGeneral a los roles vendedores y marketing
GRANT INSERT, SELECT ON dbo.DetalleVentaGeneral TO vendedores, marketing

-- Asignando SELECT a la tabla Pais a los roles vendedores y marketing
GRANT SELECT ON dbo.Pais TO vendedores, marketing

-- Asignando INSERT Y SELECT de la tabla GuiaRemitente a los roles vendedores y marketing
GRANT INSERT, SELECT ON dbo.GuiaRemitente TO vendedores, marketing

-- Asignando SELECT a la tabla TipoCliente a los roles vendedores y marketing
GRANT SELECT ON dbo.TipoCliente TO vendedores, marketing

-- Asignando el rol vendedores al cargo de vendedor o marketing
ALTER ROLE vendedores ADD MEMBER VentaMartinez_MGSolutions
ALTER ROLE vendedores ADD MEMBER VentaHernandez_MGSolutions 
ALTER ROLE vendedores ADD MEMBER VentaSerrano_MGSolutions 
ALTER ROLE vendedores ADD MEMBER VentaTorres_MGSolutions 
ALTER ROLE marketing ADD MEMBER MarketingNavarro_MGSolutions 
ALTER ROLE vendedores ADD MEMBER VentaRuiz_MGSolutions 
ALTER ROLE marketing ADD MEMBER MarketingOrtega_MGSolutions 
ALTER ROLE marketing ADD MEMBER MarketingHerrera_MGSolutions 
ALTER ROLE vendedores ADD MEMBER VentaHuanca_MGSolutions 
ALTER ROLE vendedores ADD MEMBER VentaGuevara_MGSolutions




