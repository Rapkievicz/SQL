CREATE FUNCTION CAMP_GET_CREDITO_CLIENTE(@CODPARC INT)
RETURNS INT
AS
/*
-- Autor:		<LUIS RAPKIEVICZ>
-- Data: 		<23/03/2023>
-- Objetivo:	<VERIFICA O VALOR DE CREDITO QUE O CLIENTE TEM DISPONIVEL>
--              <CASO SEJA FILIAL TRAZ SOMADO JUNTO O VALOR DA MATRIZ E DEMAIS FILIAIS>
--              <SE FOR MATRIZ TRAZ SOMENTE O VALOR DA MATRIZ>
*/
BEGIN
    DECLARE @RESULT             INT;
    DECLARE @CODPARCMATRIZ      INT;
    DECLARE @CODTIPTIT          INT;

    SET @CODTIPTIT = 20 /*Tipo de Titulo Credito de Cliente*/

    SELECT 
        @CODPARCMATRIZ = PAR.CODPARCMATRIZ
        FROM TGFPAR PAR
        WHERE PAR.CODPARC = @CODPARC

    IF @CODPARC = @CODPARCMATRIZ
        BEGIN
            SELECT @RESULT = COALESCE(SUM(FIN.VLRDESDOB),0) 
                FROM TGFFIN FIN 
                WHERE FIN.RECDESP = -1 
                    AND FIN.DHBAIXA IS NULL 
                    AND FIN.PROVISAO = 'N'
                    AND FIN.CODTIPTIT = @CODTIPTIT 
                    AND FIN.CODPARC = @CODPARC
        END

    ELSE
        BEGIN
            SELECT @RESULT = COALESCE(SUM(FIN.VLRDESDOB),0) 
                FROM TGFFIN FIN 
                WHERE FIN.RECDESP = -1 
                    AND FIN.DHBAIXA IS NULL 
                    AND FIN.PROVISAO = 'N' 
                    AND FIN.CODTIPTIT = @CODTIPTIT 
                    AND FIN.CODPARC IN (
                        SELECT
                            PAR.CODPARC 
                            FROM TGFPAR PAR
                            WHERE PAR.CODPARCMATRIZ = @CODPARCMATRIZ
                    )
        END
	
    RETURN @RESULT
END

