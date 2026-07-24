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
Color varchar(50) not null,
LineaProducto varchar(50) not null,
Clase varchar(50) not null,
Estilo varchar(50) not null,
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
Bono float not null,
Activo bit not null default 1,
FechaInicio datetime not null default getdate(),
FechaFin datetime null)
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

--crear tabla de parametros
create table Parametros(
ID int identity(1,1) not null primary key,
Nombre varchar(100) not null,
Valor varchar(500) not null)

--Crear el parametro de Fecha de Ejecucion
insert into Parametros (Nombre,Valor)values('UltimaFechaEjecucion','2026-07-18')

--select top 1 Valor from Parametros where Nombre='UltimaFechaEjecucion'
go
--Crear procedimiento para Actualizar vendedor
create or alter procedure ActualizarVendedor(@VendedorKey int, @TipoPersona varchar(100),
@NombreCompleto varchar(100), @PorcentajeComision float, @bono float)
AS
begin

--Lectura de los datos actuales
declare @TipoPersonaActual varchar(100),
		@NombreCompletoActual varchar(100),
		@VendedorID int,
		@PorcentajeComisionActual float,
		@BonoActual float

select @TipoPersonaActual=TipoPersona, @NombreCompletoActual=NombreCompleto,
	@VendedorID=VendedorID, @PorcentajeComisionActual=PorcentajeComision,
	@BonoActual=Bono from DimVendedor
	where VendedorKey=@VendedorKey

/*NombreCompleto y TipoPersona es SCD1
PorcentajeComision y Bono es SCD2
*/

--SCD1
if(@NombreCompletoActual<>@NombreCompleto or @TipoPersonaActual<>@TipoPersona)
	UPDATE DimVendedor SET NombreCompleto=@NombreCompleto, 
							TipoPersona=@TipoPersona
							where VendedorKey=@VendedorKey

--SCD2
--Agregar Activo, FechaInicio, FechaFin en la tabla DimVendedor
if(@BonoActual<>@bono or @PorcentajeComisionActual<>@PorcentajeComision)
begin
	update DimVendedor set Activo=0, FechaFin=GETDATE() where
	VendedorKey=@VendedorKey

	insert into DimVendedor(VendedorID, TipoPersona, NombreCompleto, PorcentajeComision,
	Bono)values(@VendedorID, @TipoPersona, @NombreCompleto, @PorcentajeComision, @bono)

end
end
/*
VendedorID	TipoPersona	NombreCompleto	Bono	PorcentajeComision	VendedorKey	NombreCompleto_mod
280	Sales person	Pamela O Ansman-Wolfe	5001	0.01	7	Pamela O Ansman-Wolfe
*/
--exec ActualizarVendedor 7,'Sales person','Pamela O Ansman-Wolfe',5001,0.01