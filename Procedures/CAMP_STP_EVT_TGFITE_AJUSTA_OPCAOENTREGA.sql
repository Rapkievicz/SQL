--------------------------------------------------------------------------------------
-- OBJETIVO: Ajusta os campos de empresa estoque e empresa entrega conforme operacao
-- AUTOR: Luis Rapkievicz
-- DATA: 08/02/2023

-- OPCOES DE ENTREGA
	--  C	CLIENTE RETIRA DO CD
	--  CL	CLIENTE LEVA / CAIXA RAPIDO / CHECKOUT
	--  E	ENTREGA
	--  R	CLIENTE RETIRA LOJA/EXPEDICAO
	--  I   CLIENTE RETIRA NA INDUSTRIA
	--	F   FRETE
--------------------------------------------------------------------------------------

CREATE PROCEDURE [JIVA].[CAMP_STP_EVT_TGFITE_AJUSTA_OPCAOENTREGA] (
    @NUNOTA         	INT
    ,@SEQUENCIA     	INT
) AS

DECLARE
    @AD_EMPENTREGA  	INT
    ,@AD_EMPESTOQUE 	INT
    ,@CODEMPNEGOC   	INT
    ,@CODEMP        	INT
    ,@CODTIPOPER    	INT
    ,@OPCENTREGA    	VARCHAR(10)

BEGIN
    SELECT 
	    @AD_EMPENTREGA = ITE.AD_EMPRETIRA
		,@AD_EMPESTOQUE = ITE.AD_EMPESTOQUE
		,@CODEMPNEGOC = CAB.CODEMPNEGOC
		,@CODEMP = CAB.CODEMP
		,@CODTIPOPER = CAB.CODTIPOPER
		,@OPCENTREGA = ITE.AD_OPCAODEENTREGA 
	FROM 
	    TGFITE ITE 
		    INNER JOIN TGFCAB CAB ON (CAB.NUNOTA = ITE.NUNOTA) 
	WHERE 
	    CAB.NUNOTA = @NUNOTA
	    AND ITE.SEQUENCIA = @SEQUENCIA
    
    /*CASO OS CAMPOS EMPRESA DE ESTOQUE, EMPRESA DE ENTREGA E OPCAO DE ENTREGA ESTEJA EM BRANCO*/
	IF @AD_EMPENTREGA IS NULL 
        AND @AD_EMPESTOQUE IS NULL 
        AND @OPCENTREGA IS NULL 
        AND @CODTIPOPER IN (1001,1002,1004,1005,1008,1022,1026,1027,1006,1007,1003)

		BEGIN
	    	UPDATE 
				TGFITE 
			SET
				AD_EMPESTOQUE = @CODEMP
			  	,AD_EMPRETIRA = @CODEMP
			  	,AD_OPCAODEENTREGA = (CASE
                                        WHEN @CODTIPOPER IN (1006)
                                            THEN 'C'
										WHEN @CODTIPOPER IN (1007)
                                            THEN 'I'
										WHEN @CODTIPOPER IN (1001,1002,1004,1005,1008,1022,1026,1027) 
                                            THEN 'E'
										WHEN @CODTIPOPER IN (1003) AND @CODEMP IN (2,3) 
                                            THEN 'CL'
										WHEN @CODTIPOPER IN (1003) AND @CODEMP = 1
                                            THEN 'E'
										END
									)																											
	    	WHERE 
				NUNOTA = @NUNOTA 
				AND SEQUENCIA = @SEQUENCIA 			
		END

	/*CASO EMPRESA DE ESTOQUE E EMPRESA DE ENTREGA ESTEJAM EM BRANCO E OPCAO DE ENTREGA PREENCHIDO*/
	IF @AD_EMPENTREGA IS NULL 
        AND @AD_EMPESTOQUE IS NULL 
        AND @OPCENTREGA IS NOT NULL 
        AND @CODTIPOPER IN (1001,1002,1004,1005,1008,1022,1026,1027,1006,1007,1003)
		
        BEGIN
	    	UPDATE 
				TGFITE 
			SET 
				AD_EMPESTOQUE = @CODEMP
		  		,AD_EMPRETIRA = @CODEMP
		  		,AD_OPCAODEENTREGA = (CASE 
                                        WHEN @CODTIPOPER IN (1006)
                                            THEN 'C'
		                            	WHEN @CODTIPOPER IN (1007)
                                            THEN 'I'
										WHEN @CODTIPOPER IN (1008,1022,1026,1027)
                                            THEN 'E'
										WHEN @CODTIPOPER IN (1003) AND @CODEMP IN (2,3)
                                            THEN 'CL'
										WHEN @CODTIPOPER IN (1003) AND @CODEMP = 1
                                            THEN 'E' 
										ELSE @OPCENTREGA 
										END
									)
	    	WHERE 
				NUNOTA = @NUNOTA
				AND SEQUENCIA = @SEQUENCIA
		END

END