USE [SANKHYA_PROD]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE FUNCTION CAMP_GET_DATA_HORA_DIF(@DataIni DATETIME, @DataFin DATETIME)
RETURNS VARCHAR(200)
AS
BEGIN

-- =============================================
-- Autor:		Luis Rapkievicz
-- Data: 		25/05/2022
-- Objetivo:	Calcular a diferença entre duas datas e retornando o conteúdo por extenso, em anos, meses, dias e tempo
-- ())====D
-- =============================================

	DECLARE @result VARCHAR(100);
	DECLARE @Anos INT, @Meses INT, @Dias INT,
		@Horas INT, @Minutos INT, @Segundos INT, @MiliSegundos INT;

	--SET @DataIni = '1900-01-01 00:00:00.000'
	--SET @DataFin = '2018-12-12 07:08:01.123'

	SELECT @Anos = DATEDIFF(yy, @DataIni, @DataFin)
	IF DATEADD(yy, -@Anos, @DataFin) < @DataIni 
	SELECT @Anos = @Anos-1
	SET @DataFin = DATEADD(yy, -@Anos, @DataFin)

	SELECT @Meses = DATEDIFF(mm, @DataIni, @DataFin)
	IF DATEADD(mm, -@Meses, @DataFin) < @DataIni 
	SELECT @Meses=@Meses-1
	SET @DataFin= DATEADD(mm, -@Meses, @DataFin)

	SELECT @Dias=DATEDIFF(dd, @DataIni, @DataFin)
	IF DATEADD(dd, -@Dias, @DataFin) < @DataIni 
	SELECT @Dias=@Dias-1
	SET @DataFin= DATEADD(dd, -@Dias, @DataFin)

	SELECT @Horas=DATEDIFF(hh, @DataIni, @DataFin)
	IF DATEADD(hh, -@Horas, @DataFin) < @DataIni 
	SELECT @Horas=@Horas-1
	SET @DataFin= DATEADD(hh, -@Horas, @DataFin)

	SELECT @Minutos=DATEDIFF(mi, @DataIni, @DataFin)
	IF DATEADD(mi, -@Minutos, @DataFin) < @DataIni 
	SELECT @Minutos=@Minutos-1
	SET @DataFin= DATEADD(mi, -@Minutos, @DataFin)

	SELECT @Segundos=DATEDIFF(s, @DataIni, @DataFin)
	IF DATEADD(s, -@Segundos, @DataFin) < @DataIni 
	SELECT @Segundos=@Segundos-1
	SET @DataFin= DATEADD(s, -@Segundos, @DataFin)


	SELECT @MiliSegundos=DATEDIFF(ms, @DataIni, @DataFin)

	SELECT @result= ISNULL(CAST(NULLIF(@Anos,0) AS VARCHAR(10)) + case when @Anos = 1 then ' Ano,' else ' Anos,' end,'')
		 + ISNULL(' ' + CAST(NULLIF(@Meses,0) AS VARCHAR(10)) + case when @Meses = 1 then ' Mês,' else ' Meses,' end,'')    
		 + ISNULL(' ' + CAST(NULLIF(@Dias,0) AS VARCHAR(10)) + case when @Dias = 1 then ' Dia,' else ' Dias,' end,'')
		 + ISNULL(' ' + CAST(NULLIF(@Horas,0) AS VARCHAR(10)) + case when @Horas = 1 then ' Hora,' else ' Horas,' end,'')
		 + ISNULL(' ' + CAST(@Minutos AS VARCHAR(10)) + case when @Minutos = 1 then ' Minuto e,' else ' Minutos e,' end,'')
		 + ISNULL(' ' + CAST(@Segundos AS VARCHAR(10)) 
		 + CASE
				WHEN @MiliSegundos > 0
					THEN ',' + CAST(@MiliSegundos AS VARCHAR(10)) 
				ELSE ''
		   END 
		 + case when @Segundos = 1 then ' Segundo' else ' Segundos' end,'')

	return @result
END