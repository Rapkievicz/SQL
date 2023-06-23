-------------------------------------------------------------------------
-- OBJETIVO: Salvar os valores de GIFTBACK na tabela AD_VLRBONUS
-- AUTOR: Luis Rapkievicz
-- DATA: 11/05/2023
-------------------------------------------------------------------------	

ALTER PROCEDURE [JIVA].[CAMP_STP_ACT_TGFCAB_GIFTBACK]
AS
DECLARE
    @VLRGIFTBACK            FLOAT
    ,@NROUNICO              INT
    ,@CODPARC               INT
    ,@VLRDISP               FLOAT
    ,@NUNOTA                INT
    ,@MAXNUNOTA             INT
    ,@VLRNOTA               FLOAT
    ,@DTINI                 DATETIME
    ,@DTFIM                 DATETIME
    ,@CODTIPOPER            INT
    ,@STATUSNOTA            CHAR
    ,@TIPMOV                CHAR
    ,@PRAZOINI              INT
    ,@PRAZOFIM              INT
    ,@TIPPESSOA             CHAR
    ,@DIASCALCULO           INT
    ,@CALCULAGIFTBACK       CHAR

BEGIN
    SET @VLRGIFTBACK    = 10        --Percentual % de GIFTBACK gerado por nota
    SET @PRAZOINI       = 1         --Quantidade de dias apos a compra que o saldo estara disponivel
    SET @PRAZOFIM       = 31        --Quantidade de dias apos a compra ate o saldo expirar
    SET @DIASCALCULO    = 1         --Quantidade de dias retroativos para a rotina buscar as notas aprovadas para gerar os valores

    SET @NUNOTA = (SELECT MAX(NUNOTA) FROM TGFCAB WHERE DTMOV < (GETDATE() -@DIASCALCULO))
    SET @MAXNUNOTA = (SELECT MAX(NUNOTA) FROM TGFCAB)
    
    WHILE @NUNOTA <= @MAXNUNOTA
        BEGIN
            SELECT
                @CODTIPOPER = CAB.CODTIPOPER
                ,@STATUSNOTA = CAB.STATUSNOTA
                ,@TIPMOV = CAB.TIPMOV
                ,@TIPPESSOA = PAR.TIPPESSOA
                ,@CODPARC = CAB.CODPARC
                ,@CALCULAGIFTBACK = TPP.AD_CALCULAGIFTBACK
                FROM TGFCAB CAB
                    LEFT JOIN TGFTOP TPP ON (CAB.CODTIPOPER = TPP.CODTIPOPER AND CAB.DHTIPOPER = TPP.DTALTER)
                    LEFT JOIN TGFPAR PAR ON (CAB.CODPARC = PAR.CODPARC)
                WHERE CAB.NUNOTA = @NUNOTA

            SET @NROUNICO = (SELECT COALESCE(MAX(NROUNICO),0)+1 FROM AD_VLRBONUS)

            --Venda confirmada gera 10% do valor total pago pelo cliente de giftback
            IF @CALCULAGIFTBACK = 'V'
                AND @STATUSNOTA = 'L'
                AND @TIPPESSOA = 'F'
                AND @CODPARC <> 1000
                AND @NUNOTA NOT IN (SELECT NUNOTA FROM AD_VLRBONUS)

                BEGIN
                    SELECT
                        @VLRDISP = ROUND(((CAB.VLRNOTA * @VLRGIFTBACK)/100 ),2)   
                        ,@VLRNOTA = CAB.VLRNOTA
                        ,@DTINI = CAB.DTMOV + @PRAZOINI    
                        ,@DTFIM = CAB.DTMOV + @PRAZOFIM
                        FROM
                            TGFCAB CAB
                        WHERE 
                            CAB.NUNOTA = @NUNOTA

                    INSERT INTO JIVA.AD_VLRBONUS (NROUNICO,CODPARC,VLRDISP,NUNOTA,VLRNOTA,DTINI,DTFIM)
                        VALUES (@NROUNICO,@CODPARC,@VLRDISP,@NUNOTA,@VLRNOTA,@DTINI,@DTFIM)
                END

            --Caso houver devolucao cria um giftback negativo 
            IF @CALCULAGIFTBACK = 'D'
                AND @STATUSNOTA = 'L'
                AND @TIPPESSOA = 'F'
                AND @CODPARC <> 1000
                AND @NUNOTA NOT IN (SELECT NUNOTA FROM AD_VLRBONUS)

                BEGIN
                    SELECT
                        @VLRDISP = ROUND(((CAB.VLRNOTA * @VLRGIFTBACK)/100) * -1,2)   
                        ,@VLRNOTA = CAB.VLRNOTA
                        ,@DTINI = CAB.DTMOV + @PRAZOINI    
                        ,@DTFIM = CAB.DTMOV + @PRAZOFIM
                        FROM
                            TGFCAB CAB
                        WHERE 
                            CAB.NUNOTA = @NUNOTA

                    INSERT INTO AD_VLRBONUS (NROUNICO,CODPARC,VLRDISP,NUNOTA,VLRNOTA,DTINI,DTFIM)
                        VALUES (@NROUNICO,@CODPARC,@VLRDISP,@NUNOTA,@VLRNOTA,@DTINI,@DTFIM)
                END

            SET @NUNOTA = (SELECT TOP 1 NUNOTA FROM TGFCAB WHERE NUNOTA > @NUNOTA)

        END   
END
