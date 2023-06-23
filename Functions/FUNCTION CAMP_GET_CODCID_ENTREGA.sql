CREATE FUNCTION CAMP_GET_CODCID_ENTREGA(@NUNOTA INT)
RETURNS INT
AS
/*
-- Autor:		<LUIS RAPKIEVICZ>
-- Data: 		<13/04/2023>
-- Objetivo:	<VERIFICA O CODCID DE ENTREGA DA VENDA>
*/
BEGIN
    DECLARE @RESULT         INT;
    DECLARE @CODPARC        INT;
    DECLARE @CODCONTATO     INT;

    SELECT
        @CODPARC = CAB.CODPARC
        ,@CODCONTATO = CAB.CODCONTATO
        FROM TGFCAB CAB
        WHERE CAB.NUNOTA = @NUNOTA

    IF @CODCONTATO > 0
        SELECT 
            @RESULT = CTT.CODCID
            FROM TGFCTT CTT
            WHERE CTT.CODPARC = @CODPARC 
                AND CTT.CODCONTATO = @CODCONTATO

    ELSE
        SELECT
            @RESULT = (
                CASE WHEN CPL.CODCIDENTREGA IS NOT NULL OR CPL.CODCIDENTREGA <> 0
                        THEN CPL.CODCIDENTREGA
                    ELSE PAR.CODCID
                    END
            )
            FROM TGFPAR PAR
                LEFT JOIN TGFCPL CPL ON (PAR.CODPARC = CPL.CODPARC)
            WHERE PAR.CODPARC = @CODPARC
	
    RETURN @RESULT
END