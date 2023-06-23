CREATE TRIGGER [JIVA].[CAMP_TRG_TGFPAEM_BLK_TAB] ON [JIVA].[TGFPAEM] 
FOR INSERT, UPDATE AS
-- =============================================
-- Autor:		Luis Rapkievicz
-- Data: 		15/02/2023
-- Objetivo:	Bloquear a insercao de parceiro com a tabela 10 na empresa 4
-- =============================================
DECLARE
    @CODPARC        INT,
    @CODTAB         INT,
    @CODEMP         INT,
    @ERROR          VARCHAR(200)
BEGIN
    SELECT 
        @CODEMP = INS.CODEMP
        ,@CODTAB = INS.CODTAB
    FROM
        INSERTED INS;

	    IF @CODTAB = 10 AND @CODEMP = 4
	        BEGIN
	    	    RAISERROR (N'Operação bloqueada, Motivo: Empresa 4 não pode usar a Tabela de preço 10',16,1);
	    	    ROLLBACK;
	        END
END