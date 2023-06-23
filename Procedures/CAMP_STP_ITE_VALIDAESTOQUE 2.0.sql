ALTER PROCEDURE [JIVA].[CAMP_STP_ITE_VALIDAESTOQUE](
  @P_NUNOTA 		INT, 
  @P_SEQUENCIA 		INT,
  @P_SUCESSO 		VARCHAR OUT, 
  @P_MENSAGEM 		VARCHAR(1000) OUT ,
  @P_CODUSULIB 		INT OUT
  )
AS
-- =============================================
-- Autor:		Luis Rapkievicz
-- Data: 		09/05/23
-- Objetivos:	Gerar evento de liberacao-trava caso estoque da nota seja maior que o disponivel no local selecionado
-- =============================================
DECLARE
	@I_NUNOTA		INT,
    @CODPROD		INT,
	@SEQUENCIA		INT,
	@CODLOCALORIG	INT,
    @QTDNEG			FLOAT,
	@AD_EMPESTOQUE	INT
	
	
BEGIN
  	SET @P_SUCESSO = 'S'

	SELECT
		@I_NUNOTA		= ITE.NUNOTA
		,@SEQUENCIA		= ITE.SEQUENCIA
    	,@CODPROD		= ITE.CODPROD
		,@CODLOCALORIG	= ITE.CODLOCALORIG
    	,@QTDNEG		= ITE.QTDNEG
		,@AD_EMPESTOQUE	= ITE.AD_EMPESTOQUE
	FROM 
		TGFITE ITE 
	WHERE
        ITE.NUNOTA = @P_NUNOTA
			AND ITE.SEQUENCIA = @P_SEQUENCIA

	IF(
        SELECT 
            SUM(ITE.QTDNEG) 
        FROM 
            TGFITE ITE 
        WHERE
            ITE.NUNOTA = @P_NUNOTA
                AND ITE.SEQUENCIA = @P_SEQUENCIA
                AND ITE.CODPROD = @CODPROD
                AND ITE.CODPROD < 99997
                AND ITE.AD_EMPESTOQUE = @AD_EMPESTOQUE
        ) 
	> 
	(
        JIVA.CAMP_GET_VLR_EST_EMP_LOC(@CODPROD,@AD_EMPESTOQUE,@CODLOCALORIG)
        ) 
	AND @CODPROD < 99997

        BEGIN
	  	    SET @P_SUCESSO  = 'N'
	  	END

    ELSE

	    BEGIN
	        SET @P_SUCESSO  = 'S'
	    END

END