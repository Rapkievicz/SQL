CREATE TRIGGER [JIVA].[CAMP_TRG_UPD_TSILIB] ON [JIVA].[TSILIB]
AFTER UPDATE
AS
-- =============================================
-- Autor:		Luis Rapkievicz
-- Data: 		09/05/2023
-- Objetivos:	Travar a liberacao de limites caso o limite solicitado de algum item seja maior que o limite que o usuario pode liberar
--              A rotina de liberacoes em eventos personalizados so funciona com valor ou percentual 100%
-- =============================================

DECLARE
    @NUCHAVE        INT,
    @EVENTO         SMALLINT,
    @SEQUENCIA      INT,
    @MAXSEQUENCIA   INT,
    @PERCDESC       FLOAT,
    @CODUSULIB      INT,
    @NOMEUSU        VARCHAR(25),   
    @LIMITE         FLOAT,
    @RESULT         INT

BEGIN
    SET @RESULT = 0

    SELECT
        @NUCHAVE = INS.NUCHAVE
        ,@MAXSEQUENCIA = MAX(ITE.SEQUENCIA)
        ,@EVENTO = INS.EVENTO
        ,@CODUSULIB = INS.CODUSULIB
        ,@NOMEUSU = USU.NOMEUSU
        ,@LIMITE = LIM.AD_LIMTRG
    FROM
        INSERTED INS
	        LEFT JOIN TGFCAB CAB ON (CAB.NUNOTA = INS.NUCHAVE)
	        LEFT JOIN TGFITE ITE ON (ITE.NUNOTA = CAB.NUNOTA)
            LEFT JOIN TSILIM LIM ON (LIM.CODUSU = INS.CODUSULIB AND LIM.EVENTO = INS.EVENTO)
            LEFT JOIN TSIUSU USU ON (LIM.CODUSU = USU.CODUSU)
    GROUP BY 
        INS.NUCHAVE
        ,ITE.SEQUENCIA
        ,INS.EVENTO
        ,INS.CODUSULIB
        ,USU.NOMEUSU
        ,LIM.AD_LIMTRG

    IF @EVENTO = 1005 /*EVENTOS PERSONALIZADOS QUE NECESSITAM DO CONTROLE EXTRA DESSA TRIGGER*/
        BEGIN
            SET @SEQUENCIA = 1
            WHILE @SEQUENCIA <= @MAXSEQUENCIA
                BEGIN
                    SELECT 
                        @PERCDESC = ITE.PERCDESC
	                FROM
                        TGFITE ITE
                    WHERE 
                        ITE.NUNOTA = @NUCHAVE
                            AND ITE.SEQUENCIA = @SEQUENCIA
            
                    IF @PERCDESC > @LIMITE
                        BEGIN
                            SET @RESULT = @RESULT + 1
                        END

                    SET @SEQUENCIA = @SEQUENCIA + 1 

                END

            IF @RESULT > 0
                BEGIN
	                RAISERROR (N'Liberação acima do limite permitido para o usuário %s',16,1,@NOMEUSU);
	                ROLLBACK;
	            END
        END

END
