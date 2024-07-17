/*  Usuarios y roles de la base de datos
	Empresa: MGSolutionsGroup
	Tipos de usuarios: Administrador y Soporte
*/

-- Usamos master
USE master
GO

-- Creamos el login para administrador
CREATE LOGIN administrador WITH PASSWORD = 'MGsolutionadmin'

-- Usamos la base de datos MGSolutionsGroup
USE MGSolutionsGroup
GO

-- Cremos el usuario admin_MGSolutions
CREATE USER admin_MGSolutions FOR LOGIN administrador

-- Asignando el rol de acceso como administrador a la bd
ALTER ROLE db_accessadmin
ADD MEMBER admin_MGSolutions

-- Creacion del usuario soporte con su usuario soporte*/
CREATE LOGIN soporte WITH PASSWORD = 'MGsolutionsupport'

USE MGSolutionsGroup 
CREATE USER support_MGSolutions FOR LOGIN soporte

-- Asignando rol de modificar roles personalizados y manejar permisos*/
ALTER ROLE db_securityadmin
ADD MEMBER support_MGSolutions

-- Asignado rol para generar copias de seguridad*/
ALTER ROLE db_backupoperator
ADD MEMBER support_MGSolutions

