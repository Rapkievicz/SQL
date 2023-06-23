CREATE FUNCTION CAMP_GET_REGIAO_ENTREGA(@NUNOTA INT)
RETURNS INT
AS
/*
-- Autor:		<LUIS RAPKIEVICZ>
-- Data: 		<15/05/2023>
-- Objetivo:	<VERIFICA A REGIÇAO DA ENTREGA>
-- Resultados:  0 - SEM OC
--              1 - NORTESUL
--              2 - ATACADO
--              3 - LOJAS
--              4 - FALTAS
--              5 - VOLTOU
*/
BEGIN
    DECLARE 
        @RESULT             INT,
        @CODREG             INT,
        @CODCIDENTREGA      INT,
        @CODTIPOPER         INT,
        @CODEMPNEGOC        INT

    SELECT
        @CODREG = COALESCE(ORD.CODREG,0)
        ,@CODCIDENTREGA = JIVA.CAMP_GET_CODCID_ENTREGA(CAB.NUNOTA)
        ,@CODTIPOPER = CAB.CODTIPOPER
        ,@CODEMPNEGOC = CAB.CODEMPNEGOC
    FROM
        TGFCAB CAB
            LEFT JOIN TGFORD ORD ON (CAB.ORDEMCARGA = ORD.ORDEMCARGA)
    WHERE
        CAB.NUNOTA = @NUNOTA

    --0 - SEM OC
    IF @CODREG = 0
        BEGIN
            SET @RESULT = 0
        END

    --1 - NORTESUL
    IF @CODREG > 50000 
        AND @CODCIDENTREGA NOT IN (1613,2949,1877,2026) /*Domingos Martins, Marechal Floriano, Fundao e Guarapari nao entrarao como norte/sul.*/
        AND @CODTIPOPER NOT IN (1087,1067) /*Tops de reentrega*/
        BEGIN
            SET @RESULT = 1
        END

    --2 - ATACADO
    IF (@CODEMPNEGOC IN (1,4) OR (@CODEMPNEGOC IN (2,3) AND @CODTIPOPER IN (1040)))
        AND (@CODREG < 50000 OR @CODCIDENTREGA IN (1613,2949,1877,2026)) 
        AND @CODTIPOPER NOT IN (1087,1067) 
        BEGIN
            SET @RESULT = 2
        END
    
    --3 - LOJAS
    IF @CODEMPNEGOC IN (2,3)
        AND (@CODREG < 50000 OR @CODCIDENTREGA IN (1613,2949,1877,2026))
        AND @CODTIPOPER NOT IN (1040,1087,1067)
        BEGIN
            SET @RESULT = 3
        END

    --4 - FALTAS
    IF @CODTIPOPER IN (1087) /*PED. DE SEP. - REENTREGA - FALTA/AVARIA*/
        BEGIN
            SET @RESULT = 4
        END

    --5 - VOLTOU
    IF @CODTIPOPER IN (1067) /*PEDIDO DE SEPARAÇÃO - REENTREGA*/
        BEGIN
            SET @RESULT = 5
        END

    RETURN @RESULT
END
