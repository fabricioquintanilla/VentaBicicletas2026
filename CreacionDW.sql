/*
Script general para construir nuestro DW para analisis de venta de bicicletas

DimTiempo
DimProducto
DimCliente
DimPromocion
DimVendedor
DimTerritorioVenta
FactVentas: Tabla de hechos transaccional

*/

--Crear la base de datos DWVentas20260629
create database DWVentas20260629
GO

--Cambiar a la nueva base de datos
use DWVentas20260629
GO

--Crear las dimensiones
create table DimTiempo
(TiempoKey int primary key, --Llave surrogada (SK)
--No es autonumerica, guarda las fechas en ISO.
Fecha datetime not null, --Llave de negocio (BK)
Dia tinyint not null,
Mes tinyint not null,
Anio smallint not null)
go

create table DimProducto
(ProductoKey int primary key identity(1,1), --Llave surrogada (SK)
ProductoID int not null,
Nombre varchar(50) not null,
NumeroProducto varchar(25) not null,
Color varchar(15) not null,
LineaProducto varchar(10) not null,
Clase varchar(6) not null,
Estilo varchar(10) not null,
PrecioLista float not null,
Modelo varchar(50) not null,
Subcategoria varchar(50) not null,
Categoria varchar(50) not null)
GO

create table DimCliente
(ClienteKey int primary key identity(1,1),
ClienteID int not null,
TipoPersona varchar(50) not null,
NombreCompleto varchar(150) not null)
GO

create table DimPromocion
(PromocionKey int primary key identity(1,1),
PromocionID int not null,
Descripcion varchar(255) not null,
Porcentaje float not null,
TipoPromocion varchar(50) not null,
CategoriaPromocion varchar(50) not null)
GO

create table DimVendedor
(VendedorKey int primary key identity(1,1),
VendedorID int not null,
TipoPersona varchar(50) not null,
NombreCompleto varchar(150) not null,
PorcentajeComision float not null,
Bono float not null)
GO

create table DimTerritorioVenta
(TerritorioVentaKey int primary key identity(1,1),
TerritorioID int not null,
NombreTerritorio varchar(50),
GrupoTerritorio varchar(50),
NombreRegion varchar(50))
GO

--Crear tabla de hechos
create table FactVentas
(TerritorioVentasKey int not null foreign key references
DimTerritorioVenta(TerritorioVentaKey),
VendedorKey int not null foreign key references
DimVendedor(VendedorKey),
PromocionKey int not null foreign key references
DimPromocion(PromocionKey),
ClienteKey int not null foreign key references
DimCliente(ClienteKey),
ProductoKey int not null foreign key references
DimProducto(ProductoKey),
FechaOrdenKey int not null foreign key references
DimTiempo(TiempoKey),
FechaEntregaKey int not null foreign key references
DimTiempo(TiempoKey),
FechaEnvioKey int not null foreign key references
DimTiempo(TiempoKey),
Cantidad int not null,
PrecioUnitario float not null,
Descuento float not null,
TotalLinea float not null,
NumeroOrden varchar(25) not null)
GO

