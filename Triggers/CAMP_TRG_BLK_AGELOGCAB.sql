ALTER TRIGGER [JIVA].[CAMP_TRG_BLK_AGELOGCAB] ON [JIVA].[AD_AGELOGCAB] 
AFTER INSERT,UPDATE,DELETE
AS
-- =============================================
-- Autor:		Luis Rapkievicz
-- Data: 		27/04/2023
-- Objetivos:	1 - Não permite inserir registro em data retroativa
-- =============================================
DECLARE
	@EVENT_TYPE  	VARCHAR(42),
	@DATA   		DATE,
    @DTATUAL    	DATE,
	@QTDREG  		INT

BEGIN

	SET @EVENT_TYPE = (
		CASE WHEN EXISTS(SELECT * FROM INSERTED) AND EXISTS(SELECT * FROM DELETED) 
        		THEN 'UPDATE'
    		WHEN EXISTS(SELECT * FROM INSERTED) 
        		THEN 'INSERT'
    		WHEN EXISTS(SELECT * FROM DELETED)
        		THEN 'DELETE'
    		ELSE 
        		'UNKNOWN' --no rows affected - cannot determine event
    	END
	)

	IF @EVENT_TYPE = 'INSERT'
		BEGIN
			SELECT 
    		    @DATA = CONVERT(DATE,INS.DATA)
    		    ,@DTATUAL = CONVERT(DATE, GETDATE())
    		FROM
    		    INSERTED INS;

    		IF @DATA < @DTATUAL
    		    BEGIN
			        RAISERROR (N'Não é permitido inserir registros em datas retroativas',16,1);
			    	ROLLBACK;
			    END
		END

	IF @EVENT_TYPE = 'UPDATE'
		BEGIN		
			SELECT 
		        @DATA = CONVERT(DATE,INS.DATA)
		        ,@DTATUAL = CONVERT(DATE,GETDATE())
		    FROM
		        INSERTED INS;

		    IF @DATA < @DTATUAL
		        BEGIN
			        RAISERROR (N'Não é permitido alterar registros em datas retroativas',16,1);
			    	ROLLBACK;
			    END
		END
END