DECLARE @FechaInicio DATE = '2020-01-01'
DECLARE @FechaFin DATE = '2030-12-31'
DECLARE @FechaActual DATE = @FechaInicio

DECLARE @TiempoKey INT
DECLARE @Dia TINYINT
DECLARE @Mes TINYINT
DECLARE @Anio SMALLINT

WHILE @FechaActual<= @FechaFin
BEGIN
	SET @TiempoKey = CONVERT(INT, CONVERT(VARCHAR(8),@FechaActual,112))
	SET @Dia = DAY(@FechaActual)
	SET @Mes = MONTH(@FechaActual)
	SET @Anio = YEAR(@FechaActual)

	INSERT INTO DimTiempo(TiempoKey, Fecha, Dia,Mes,Anio)
	VALUES(@TiempoKey, @FechaActual, @Dia, @Mes, @Anio)

	SET @FechaActual = DATEADD(DAY,1,@FechaActual)
END

select * from DimTiempo