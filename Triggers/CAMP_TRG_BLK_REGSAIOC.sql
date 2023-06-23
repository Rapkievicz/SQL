ALTER TRIGGER [JIVA].[CAMP_TRG_BLK_REGSAIOC] ON [JIVA].[AD_REGSAIOC] 
AFTER INSERT AS
-- =============================================
-- Autor:		Luis Rapkievicz
-- Data: 		09/01/2022
-- Objetivo:	Validar numero unico da OC
-- =============================================
DECLARE
	@ORDEMCARGA     INT,
    @NROUNICOOC     INT,
    @NROUNICOAD     INT
BEGIN
	SELECT 
        @NROUNICOOC = INS.NROUNICO
        ,@ORDEMCARGA = INS.OC
    FROM
        INSERTED INS;

    SELECT
        @NROUNICOAD = ORD.AD_NROUNICO
    FROM
        TGFORD ORD
    WHERE
        ORD.ORDEMCARGA = @ORDEMCARGA;

	IF @NROUNICOOC <> @NROUNICOAD OR @NROUNICOOC IS NULL
	    BEGIN
		    RAISERROR (N'Numero unico invalido para a OC',16,1);
		    ROLLBACK;
	    END
END