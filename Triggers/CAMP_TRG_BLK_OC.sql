ALTER TRIGGER [JIVA].[CAMP_TRG_BLK_OC] ON [JIVA].[TGFORD] 
AFTER INSERT AS
-- =============================================
-- Autor:		Luis Rapkievicz
-- Data: 		27/12/2022
-- Objetivo:	Bloquear motorista de iniciar em nova carga caso a anterior nao tenha sido finalizada
-- =============================================
DECLARE
	@ORDEMCARGA 		INT,
	@CODPARCMOTORISTA 	INT,
    @ORDEMCARGAOLD      VARCHAR(10),
    @STATUSOC 			VARCHAR
BEGIN
	SELECT 
        @CODPARCMOTORISTA = INS.CODPARCMOTORISTA
        ,@ORDEMCARGA = INS.ORDEMCARGA 
    FROM
        INSERTED INS;

    IF @CODPARCMOTORISTA IS NOT NULL AND @CODPARCMOTORISTA <> 0
    BEGIN
        SELECT
            @STATUSOC = ORD.AD_STATUSOC
            ,@ORDEMCARGAOLD = CAST(ORD.ORDEMCARGA AS VARCHAR(10)) 
        FROM
            TGFORD ORD
        WHERE
            ORD.ORDEMCARGA = (
                SELECT MAX(FORD.ORDEMCARGA) FROM TGFORD FORD WHERE FORD.CODPARCMOTORISTA = @CODPARCMOTORISTA AND FORD.ORDEMCARGA < @ORDEMCARGA
                )

	    IF @STATUSOC <> 'F'
	        BEGIN
	    	    RAISERROR (N'Motorista vinculado a OC não finalizada não pode ser adicionado a novas cargas. OC:%s',16,1,@ORDEMCARGAOLD);
	    	    ROLLBACK;
	        END
    END
END