--------------------------------------------------------------------------------------
-- OBJETIVO: Ajusta o campo de opção entrega
-- AUTOR: Luis Rapkievicz
-- DATA: 20/03/2023

-- CAMPO
	-- AD_OPCAODEENTREGA = [Opcao de Entrega]

-- VALORES - [Opcao de Entrega]
	--  C	= Cliente Retira no CD
	--  CL	= Checkout / Cx Rapido
	--  E	= Entrega
	--  R	= Cliente Retira na Expedição
	--  I   = Retira na Indústria
	--	F   = Frete
--------------------------------------------------------------------------------------

ALTER PROCEDURE "CAMP_STP_TGFITE_ALTERA_ENTREGA_USER" (
    @P_CODUSU                   INT,                
    @P_IDSESSAO                 VARCHAR(4000),    
    @P_QTDLINHAS                INT,             
    @P_MENSAGEM                 VARCHAR(4000) OUT 
) AS

DECLARE
    @FIELD_CODPROD              INT,
    @FIELD_NUNOTA               INT,
    @FIELD_SEQUENCIA            INT,
    
    @PARAM_AD_OPCAODEENTREGA    CHAR,
    @CODTIPOPER                 INT,

    @I                          INT

BEGIN
    SET @I = 1 
    WHILE @I <= @P_QTDLINHAS
        BEGIN
            SET @FIELD_CODPROD = JIVA.ACT_INT_FIELD(@P_IDSESSAO, @I, 'CODPROD')
            SET @FIELD_NUNOTA = JIVA.ACT_INT_FIELD(@P_IDSESSAO, @I, 'NUNOTA')
            SET @FIELD_SEQUENCIA = JIVA.ACT_INT_FIELD(@P_IDSESSAO, @I, 'SEQUENCIA')

            SET @PARAM_AD_OPCAODEENTREGA = JIVA.ACT_TXT_PARAM(@P_IDSESSAO, 'AD_OPCAODEENTREGA')

            SELECT 
                @CODTIPOPER = CAB.CODTIPOPER
                FROM 
                    TGFCAB CAB
                WHERE
                    CAB.NUNOTA = @FIELD_NUNOTA
                
            IF @PARAM_AD_OPCAODEENTREGA IS NOT NULL AND @CODTIPOPER IN (1001,1002,1003,1006,1007,1022,1026,1027,1095,1098,1099)
                BEGIN
                    UPDATE TGFITE 
                        SET AD_OPCAODEENTREGA = @PARAM_AD_OPCAODEENTREGA
                        WHERE NUNOTA = @FIELD_NUNOTA
                            AND SEQUENCIA = @FIELD_SEQUENCIA;
                    
                    SET @P_MENSAGEM = ('Alteração realizada com sucesso');
                END

            ELSE
                BEGIN
                    RAISERROR (N'Alteração não permitida',11,1)
                END
 
            SET @I = @I + 1;
        END

END