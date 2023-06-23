/* 
Autor: Luis Rapkievicz
Data: 13/07/2022
Objetivo: Troca o valor do campo Fornecedor Principal (CODPARCFORN) pela empresa matriz (1) e salva o cod do fornecedor antigo no campo (AD_PARCFORNANT) nas matrizes 2447 e 244
*/
CREATE PROCEDURE "CAMP_STP_FORNECGIROMTZ" (
       @P_CODUSU INT,                
       @P_IDSESSAO VARCHAR(4000),    
       @P_QTDLINHAS INT,             
       @P_MENSAGEM VARCHAR(4000) OUT 
) AS
DECLARE
       @FIELD_CODPROD INT,
       @FIELD_CODREL INT,
	@FIELD_CODPARCFORN INT,
       @I INT
BEGIN
       SET @I = 1 
       WHILE @I <= @P_QTDLINHAS 
       BEGIN
           SET @FIELD_CODPROD = jiva.ACT_INT_FIELD(@P_IDSESSAO, @I, 'CODPROD')
           SET @FIELD_CODREL = jiva.ACT_INT_FIELD(@P_IDSESSAO, @I, 'CODREL')
           SET @FIELD_CODPARCFORN = jiva.ACT_INT_FIELD(@P_IDSESSAO, @I, 'CODPARCFORN')
		    IF @FIELD_CODREL = 2447 OR @FIELD_CODREL = 2448
			    UPDATE TGFGIR SET AD_PARCFORNANT = CODPARCFORN, CODPARCFORN = 1 WHERE CODREL = @FIELD_CODREL AND CODPARCFORN <> 1
			IF @FIELD_CODREL IN (2447,2448)
				SET @P_MENSAGEM = CONCAT('Fornecedor preferencial alterado para | 01 - Distribuidora Campeão | na Matriz: ',@FIELD_CODREL)
			IF @FIELD_CODREL NOT IN (2447,2448)
				RAISERROR (N'Alteração permitida somente para as matrizes 2447 e 2448',11,1)		
           SET @I = @I + 1
       END
END

