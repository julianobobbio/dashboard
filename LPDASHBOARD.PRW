#Include "Totvs.ch"
#Include "RestFul.ch"
#Include "Protheus.ch"
#Include "Tbiconn.ch"
#Include "Topconn.ch"

WSRESTFUL LPDASH DESCRIPTION ("<h1>Consultas DashBoard Comercial</h1>")

    WSMETHOD GET               DESCRIPTION "Consultas DashBoard Comercial - Get API'S"                                         WSSYNTAX  "LPDASH"         
    WSMETHOD GET CANAIS        DESCRIPTION "Consultas DashBoard Comercial - Valores de vendas dos canais/equipes/vendedores"   WSSYNTAX  "/LPDASH/CANAIS"        PATH "/LPDASH/CANAIS"  
    WSMETHOD GET CONSOLIDADO   DESCRIPTION "Consultas DashBoard Comercial - Valores de vendas do dia corrente"                 WSSYNTAX  "/LPDASH/CONSOLIDADO"   PATH "/LPDASH/CONSOLIDADO"
    WSMETHOD GET PREVISTO      DESCRIPTION "Consultas DashBoard Comercial - Valores a Faturar"                                 WSSYNTAX  "/LPDASH/PREVISTO"      PATH "/LPDASH/PREVISTO"
	WSMETHOD GET PERIODO       DESCRIPTION "Consultas DashBoard Comercial - Periodo Mes"	                                   WSSYNTAX  "/LPDASH/PERIODO"       PATH "/LPDASH/PERIODO"

End WSRESTFUL

/*/{Protheus.doc} LPDASH - GET

Método para retornar lista de API´s

@type function
@version 
@author juliano.bobbio
@since 14/12/2020
@return Lógico, Verdadeiro
/*/
WSMETHOD GET WSSERVICE LPDASH

    Local cList		:= ""
	Local nX		:= 0
	Local _aGets	:= ClassMethArr( Self, .f. )

	cList += "Lista de API's: " +	 CRLF

	For nX := 1 To Len(_aGets)
		cList += "			" + _aGets[nX][1] + CRLF
	Next nX

    _aGets := {}

	::SetContentType("application/json")
	::SetResponse('{')
	::SetResponse(EncodeUtf8('"RETORNO":' + cList))
	::SetResponse('}')

Return .T.

/*/{Protheus.doc} LPDASH - GET CANAIS

Método para consulta de venda de Canais

@type function
@version 1.0
@author juliano.bobbio
@since 14/12/2020
@return Lógico, Verdadeiro
/*/
WSMETHOD GET CANAIS WSSERVICE LPDASH

    Local cQry   := GetNextAlias()
	Local aDados := {}
    Local oJson	 := JsonObject():New()
	//Local _cCfop := ''
	/*
	_cCfop := "%( SC6.C6_CF LIKE '%102%'""
	_cCfop += " OR SC6.C6_CF LIKE '%104%'" 
	_cCfop += " OR SC6.C6_CF LIKE '%108%'" 
	_cCfop += " OR SC6.C6_CF LIKE '%114%'"
	_cCfop += " OR SC6.C6_CF LIKE '%115%'"
	_cCfop += " OR SC6.C6_CF LIKE '%116%'" 
	_cCfop += " OR SC6.C6_CF LIKE '%119%'" 
	_cCfop += " OR SC6.C6_CF LIKE '%120%'" 
	_cCfop += " OR SC6.C6_CF LIKE '%403%'" 
	_cCfop += " OR SC6.C6_CF LIKE '%404%'" 
	_cCfop += " OR SC6.C6_CF LIKE '%405%'" 
	_cCfop += " OR SC6.C6_CF LIKE '%551%'"
	_cCfop += " OR SC6.C6_CF LIKE '%929%'" 
	_cCfop += " OR SC6.C6_CF LIKE '%922%'"
	_cCfop += " OR TRIM (SC6.C6_CF) IS NULL)%"
    */
	//VW_EQUIPE_RESULTADO
    BeginSql Alias cQry

        SELECT * FROM
            (
            SELECT 
					
						NVL(CAD_PRODUTOS.B1_XCATALO, '-') AS VENDA_CATALOGO , 
						NVL(SUM(VALOR_TOTAL), 0)          AS TOTAL_VENDA , 
						NVL(METAS.CT_XSTATUS, '-')        AS META_CATALOGO , 
						NVL(METAS.VALOR, 0)               AS META_MES , 
						CANAIS.ADK_COD                    AS CANAL_CODIGO , 
						CANAIS.ADK_NOME                   AS CANAL_NOME , 
						GERENTE.A3_COD                    AS GERENTE_CODIGO , 
						GERENTE.A3_NOME                   AS GERENTE_NOME , 
						EQUIPES.ACA_GRPREP                AS EQUIPE_CODIGO , 
						EQUIPES.ACA_DESCRI                AS EQUIPE_NOME , 
						SUPERVISOR.A3_COD                 AS SUPERVISOR_CODIGO , 
						SUPERVISOR.A3_NREDUZ              AS SUPERVISOR_NOME , 
						VENDEDORES.A3_COD                 AS VENDEDOR_CODIGO , 
						VENDEDORES.A3_NOME                AS VENDEDOR_NOME 
					FROM 
						SA3030 VENDEDORES 
						
						LEFT JOIN 
						(
							SELECT 
								SF2.F2_DOC, 
								SD2.D2_EMISSAO, 
								D2_TOTAL     AS VALOR_TOTAL, 
								SF2.F2_VEND1 AS VENDEDOR, 
								SD2.D2_COD   AS CODIGO 
							FROM 
								SD2030 SD2 
								INNER JOIN SF2030 SF2 ON SF2.F2_FILIAL = SD2.D2_FILIAL 
									AND SF2.F2_DOC     = SD2.D2_DOC 
									AND SF2.F2_SERIE   = SD2.D2_SERIE 
									AND SF2.%NotDel% 
														WHERE 
								SD2.%NotDel%
								AND SD2.D2_EMISSAO BETWEEN TO_CHAR(TRUNC(SYSDATE, 'MM'), 'YYYYMMDD') AND TO_CHAR(SYSDATE, 'YYYYMMDD') 
								AND SUBSTR(SD2.D2_CF,2,3) IN (  '102','104','108','114','115','116','119','120','403','404','405','551','929','922' )
                            UNION ALL 
							SELECT 
									SF2.F2_DOC, 
									SD1.D1_DTDIGIT, 
									(D1_TOTAL - D1_VALDESC) * -1 AS VALOR_TOTAL, 
									SF2.F2_VEND1                 AS VENDEDOR, 
									SD2.D2_COD                   AS CODIGO 
							FROM 
								SD2030 SD2 
								INNER JOIN SF2030 SF2 ON SF2.F2_FILIAL   = SD2.D2_FILIAL 
									AND SF2.F2_DOC     = SD2.D2_DOC 
									AND SF2.F2_SERIE   = SD2.D2_SERIE 
									AND SF2.%NotDel% 
								INNER JOIN SD1030 SD1 ON SD1.D1_FILIAL                    = SD2.D2_FILIAL 
									AND SD1.D1_NFORI                    = SD2.D2_DOC 
									AND SD1.D1_TIPO                     = 'D' 
									AND SD1.D1_FORNECE                  = SD2.D2_CLIENTE 
									AND SD1.D1_LOJA                     = SD2.D2_LOJA 
									AND SUBSTR (TRIM (SD2.D2_ITEM), -2) = SUBSTR (TRIM (SD1.D1_ITEMORI), -2) 
									AND SD1.%NotDel%
							WHERE 
								SD2.%NotDel% 
								AND SD1.D1_DTDIGIT BETWEEN TO_CHAR(TRUNC(SYSDATE, 'MM'),'YYYYMMDD') AND TO_CHAR(SYSDATE, 'YYYYMMDD') 
								AND SUBSTR(SD1.D1_CF,2,3) IN ( '202','411' )
							UNION ALL 
							SELECT 
								SF2.F2_DOC, 
								SD2.D2_EMISSAO, 
								NVL (D2_TOTAL, 0) AS VALOR_TOTAL, 
								SF2.F2_VEND1      AS VENDEDOR, 
								SD2.D2_COD        AS CODIGO 
							FROM 
								SD2080 SD2 
								INNER JOIN SF2080 SF2 ON SF2.F2_FILIAL   = SD2.D2_FILIAL 
									AND SF2.F2_SERIE   = SD2.D2_SERIE 
									AND SF2.F2_DOC     = SD2.D2_DOC 
									AND SF2.%NotDel%
							WHERE 
								SD2.%NotDel%
								AND SD2.D2_EMISSAO BETWEEN TO_CHAR(TRUNC(SYSDATE, 'MM'),'YYYYMMDD') AND TO_CHAR(SYSDATE, 'YYYYMMDD') 
								AND SUBSTR(SD2.D2_CF,2,3) IN (  '102','104','108','114','115','116','119','120','403','404','405','551','929','922' )
							UNION ALL 
							SELECT 
								SF2.F2_DOC, 
								SD1.D1_DTDIGIT, 
		    	                NVL ((D1_TOTAL - D1_VALDESC) * -1, 0) AS VALOR_TOTAL, 
								SF2.F2_VEND1                          AS VENDEDOR, 
								SD2.D2_COD                            AS CODIGO 
							FROM 
								SD2080 SD2 
								INNER JOIN SF2080 SF2 ON SF2.F2_FILIAL   = SD2.D2_FILIAL 
									AND SF2.F2_SERIE   = SD2.D2_SERIE 
									AND SF2.F2_DOC     = SD2.D2_DOC 
									AND SF2.%NotDel%
								INNER JOIN SD1080 SD1 ON SD1.%NotDel%
									AND SD1.D1_FILIAL                   = SD2.D2_FILIAL 
									AND SD1.D1_NFORI                    = SD2.D2_DOC 
									AND SD1.D1_TIPO                     = 'D' 
									AND SD1.D1_FORNECE                  = SD2.D2_CLIENTE 
									AND SD1.D1_LOJA                     = SD2.D2_LOJA 
									AND SUBSTR (TRIM (SD2.D2_ITEM), -2) = SUBSTR (TRIM (SD1.D1_ITEMORI), -2) 
							WHERE 
								SD2.%NotDel% 
								AND SD1.D1_DTDIGIT BETWEEN TO_CHAR(TRUNC(SYSDATE, 'MM'),'YYYYMMDD') AND TO_CHAR(SYSDATE, 'YYYYMMDD') 
								AND SUBSTR(SD1.D1_CF,2,3) IN ( '202','411' )
							UNION ALL 
							SELECT 
								SF2.F2_DOC, 
								SD2.D2_EMISSAO, 
								NVL (D2_TOTAL, 0) AS VALOR_TOTAL, 
								SF2.F2_VEND1      AS VENDEDOR, 
								SD2.D2_COD        AS CODIGO 
							FROM 
								SD2100 SD2 
								INNER JOIN SF2100 SF2 ON SF2.F2_FILIAL     = SD2.D2_FILIAL 
									AND SF2.F2_SERIE     = SD2.D2_SERIE 
									AND SF2.F2_DOC       = SD2.D2_DOC 
									AND SF2.%NotDel%
								WHERE 
									SD2.%NotDel%
									AND SD2.D2_EMISSAO BETWEEN TO_CHAR(TRUNC(SYSDATE, 'MM'), 'YYYYMMDD') AND TO_CHAR(SYSDATE, 'YYYYMMDD') 
						) RESULTADO_VENDAS ON RESULTADO_VENDAS.VENDEDOR = VENDEDORES.A3_COD 
						
						JOIN ACA030 EQUIPES ON EQUIPES.ACA_GRPREP   = VENDEDORES.A3_GRPREP 
							AND EQUIPES.%NotDel%
						
						JOIN ADK030 CANAIS ON CANAIS.ADK_COD      = EQUIPES.ACA_GRPSUP AND CANAIS.%NotDel%
						
						JOIN SA3030 GERENTE ON GERENTE.A3_COD       = CANAIS.ADK_RESP AND GERENTE.%NotDel%
					
						LEFT JOIN SA3030 SUPERVISOR ON SUPERVISOR.A3_SUPER     = ' ' 
							AND SUPERVISOR.A3_GEREN    = VENDEDORES.A3_GEREN 
							AND SUPERVISOR.A3_GRPREP   = VENDEDORES.A3_GRPREP 
							AND SUPERVISOR.%NotDel%
						
						LEFT JOIN SB1030 CAD_PRODUTOS ON CAD_PRODUTOS.B1_FILIAL    = ' ' 
							AND CAD_PRODUTOS.B1_COD      = CODIGO 
							AND CAD_PRODUTOS.%NotDel%		
						
						LEFT JOIN ( 
							(
								SELECT 
									SCT.CT_VEND, 
									SCT.CT_DATA, 
									SCT.CT_XSTATUS , 
									SUM(SCT.CT_VALOR) VALOR 
								FROM 
									SCT030 SCT 
								WHERE 
									SCT.CT_FILIAL = '06'
									AND SUBSTR(SCT.CT_DATA,1,6) = To_char(TRUNC(SYSDATE, 'MM'), 'YYYYMM')
									AND SCT.%NotDel%	
								GROUP BY 
									SCT.CT_VEND, 
									SCT.CT_DATA, 
									SCT.CT_XSTATUS 
							) 
						)  METAS ON METAS.CT_VEND      = VENDEDORES.A3_COD 
						
						WHERE 
							VENDEDORES.A3_MSBLQL <> ' ' 
							AND VENDEDORES.%NotDel%
                        
						GROUP BY 
							CAD_PRODUTOS.B1_XCATALO , 
							METAS.CT_XSTATUS , 
							METAS.VALOR, 
							CANAIS.ADK_COD , 
							CANAIS.ADK_NOME , 
							GERENTE.A3_COD , 
							GERENTE.A3_NOME , 
							EQUIPES.ACA_GRPREP , 
							EQUIPES.ACA_DESCRI , 
							SUPERVISOR.A3_COD , 
							SUPERVISOR.A3_NREDUZ , 
							VENDEDORES.A3_COD , 
							VENDEDORES.A3_NOME 
							
						ORDER BY 
							GERENTE.A3_COD,
							CANAIS.ADK_COD, 
							EQUIPES.ACA_GRPREP , 
							SUPERVISOR.A3_COD , 
							VENDEDORES.A3_COD 
            )
        WHERE META_MES <> 0

    EndSql

	Conout("*** Query Canais ***")
	Conout(GetLastQuery()[2])

    Do While (cQry)->(!Eof())

		aAdd(aDados, { 	(cQry)->VENDA_CATALOGO		,;//[1]  VENDA_CATALOGO
						(cQry)->TOTAL_VENDA			,;//[2]  TOTAL_VENDA
						(cQry)->META_CATALOGO		,;//[3]  META_CATALOGO
						(cQry)->META_MES			,;//[4]  META_MES
						(cQry)->CANAL_CODIGO		,;//[5]  CANAL_CODIGO
						(cQry)->CANAL_NOME			,;//[6]  CANAL_NOME
						(cQry)->GERENTE_CODIGO		,;//[7]  GERENTE_CODIGO
						(cQry)->GERENTE_NOME		,;//[8]  GERENTE_NOME
						(cQry)->EQUIPE_CODIGO 		,;//[9]  EQUIPE_CODIGO
						(cQry)->EQUIPE_NOME 		,;//[10] EQUIPE_NOME
						(cQry)->SUPERVISOR_CODIGO 	,;//[11] SUPERVISOR_CODIGO
						(cQry)->SUPERVISOR_NOME 	,;//[12] SUPERVISOR_NOME
						(cQry)->VENDEDOR_CODIGO 	,;//[13] VENDEDOR_CODIGO
						(cQry)->VENDEDOR_NOME		,;//[14] VENDEDOR_NOME
						.T.							,;//[15] EXIBE_DASH
						0							,;//[16] CONTABILIZA_MARCA_LP	
						0							})//[17] CONTABILIZA_MARCA_WW	
        
        (cQry)->(DbSkip())

    EndDo   
    
    (cQry)->(DbCloseArea())

	::SetContentType("application/json")

	If Len(aDados) > 0

		//Tratamento de regras de negocio
		FRulesOne(@aDados)
		FRulesTwo(@aDados)

		//Somatorias/agrupamentos e estruturação de Json
		FSumValue(@aDados,@oJson)

		::SetResponse( EncodeUTF8( FWJsonSerialize( oJson, .F., .F., .T.)))
	//	Conout(EncodeUTF8( FWJsonSerialize( oJson, .F., .F., .T.)))
	//	Conout("________________________________________")
	Else

		::SetResponse( EncodeUTF8( FWJsonSerialize( '"ERRO":"Não há dados."', .F., .F., .T.)))

	EndIf	

	//Zera Array para limpeza de memoria
	aDados := {}

    //Limpa instancia Objeto
    FreeObj(oJson)

Return .T.

/*/{Protheus.doc} LPDASH - GET CONSOLIDADO

Método para consulta de venda de CONSOLIDADO

@type function
@version 
@author juliano.bobbio
@since 14/12/2020
@return Lógico, Verdadeiro
/*/
WSMETHOD GET CONSOLIDADO WSSERVICE LPDASH

    Local cQry  	:= GetNextAlias()
	Local aDados	:= {}
    Local oJson		:= JsonObject():New()
	//Local _cCfop := ''
	/*
	_cCfop := "%( SC6.C6_CF LIKE '%102%'""
	_cCfop += " OR SC6.C6_CF LIKE '%104%'" 
	_cCfop += " OR SC6.C6_CF LIKE '%108%'" 
	_cCfop += " OR SC6.C6_CF LIKE '%114%'"
	_cCfop += " OR SC6.C6_CF LIKE '%115%'"
	_cCfop += " OR SC6.C6_CF LIKE '%116%'" 
	_cCfop += " OR SC6.C6_CF LIKE '%119%'" 
	_cCfop += " OR SC6.C6_CF LIKE '%120%'" 
	_cCfop += " OR SC6.C6_CF LIKE '%403%'" 
	_cCfop += " OR SC6.C6_CF LIKE '%404%'" 
	_cCfop += " OR SC6.C6_CF LIKE '%405%'" 
	_cCfop += " OR SC6.C6_CF LIKE '%551%'"
	_cCfop += " OR SC6.C6_CF LIKE '%929%'" 
	_cCfop += " OR SC6.C6_CF LIKE '%922%'"
	_cCfop += " OR TRIM (SC6.C6_CF) IS NULL)%"
    */
	//APP_DBC_CONSOL_DIA_EQP
    BeginSql Alias cQry
		
		SELECT * FROM
            (
				SELECT
					/*+INDEX*/
					NVL(CAD_PRODUTOS.B1_XCATALO, '-') AS VENDA_CATALOGO,
					NVL(SUM(VALOR_TOTAL), 0)          AS TOTAL_VENDA,
					NVL(METAS.CT_XSTATUS, '-')        AS META_CATALOGO,
					NVL(METAS.VALOR, 0)               AS META_MES,
					CANAIS.ADK_COD                    AS CANAL_CODIGO,
					CANAIS.ADK_NOME                   AS CANAL_NOME,
					GERENTE.A3_COD                    AS GERENTE_CODIGO,
					GERENTE.A3_NOME                   AS GERENTE_NOME,
					EQUIPES.ACA_GRPREP                AS EQUIPE_CODIGO , 
					EQUIPES.ACA_DESCRI                AS EQUIPE_NOME , 
					SUPERVISOR.A3_COD                 AS SUPERVISOR_CODIGO , 
					SUPERVISOR.A3_NREDUZ              AS SUPERVISOR_NOME , 
					VENDEDORES.A3_COD                 AS VENDEDOR_CODIGO , 
					VENDEDORES.A3_NOME                AS VENDEDOR_NOME
				FROM 
					SA3030 VENDEDORES 
					/*-- RESULTADO VENDAS NO PERIODO*/
					LEFT JOIN
					(
						SELECT 
							SF2.F2_DOC, 
							SD2.D2_EMISSAO, 
							D2_TOTAL     AS VALOR_TOTAL, 
							SF2.F2_VEND1 AS VENDEDOR, 
							SD2.D2_COD   AS CODIGO
						FROM 
							SD2030 SD2
							INNER JOIN SF2030 SF2 ON SF2.F2_FILIAL   = SD2.D2_FILIAL
								AND SF2.F2_DOC     = SD2.D2_DOC 
								AND SF2.F2_SERIE   = SD2.D2_SERIE 
								AND SF2.%NotDel% 
						WHERE 
							SD2.%NotDel%
							AND SD2.D2_EMISSAO      = TO_CHAR (SYSDATE, 'YYYYMMDD')
							AND SUBSTR(SD2.D2_CF,2,3) IN (  '102','104','108','114','115','116','119','120','403','404','405','551','929','922' )
						UNION ALL
						SELECT 
							SF2.F2_DOC, 
							SD1.D1_DTDIGIT, 
				            (D1_TOTAL - D1_VALDESC) * -1 AS VALOR_TOTAL, 
							SF2.F2_VEND1                 AS VENDEDOR, 
							SD2.D2_COD                   AS CODIGO 
						FROM 
							SD2030 SD2 
							INNER JOIN SF2030 SF2 ON SF2.F2_FILIAL   = SD2.D2_FILIAL 
								AND SF2.F2_DOC     = SD2.D2_DOC 
								AND SF2.F2_SERIE   = SD2.D2_SERIE 
								AND SF2.%NotDel%
							INNER JOIN SD1030 SD1 ON SD1.D1_FILIAL                    = SD2.D2_FILIAL 
								AND SD1.D1_NFORI                    = SD2.D2_DOC 
								AND SD1.D1_TIPO                     = 'D' 
								AND SD1.D1_FORNECE                  = SD2.D2_CLIENTE 
								AND SD1.D1_LOJA                     = SD2.D2_LOJA 
								AND SUBSTR (TRIM (SD2.D2_ITEM), -2) = SUBSTR (TRIM (SD1.D1_ITEMORI), -2) 
								AND SD1.%NotDel%
						WHERE 
							SD2.%NotDel%
							AND SD1.D1_DTDIGIT = TO_CHAR(SYSDATE, 'YYYYMMDD')
								AND SUBSTR(SD1.D1_CF,2,3) IN ( '202','411' )
						UNION ALL 
						SELECT 
							SF2.F2_DOC, 
							SD2.D2_EMISSAO, 
							NVL (D2_TOTAL, 0) AS VALOR_TOTAL, 
							SF2.F2_VEND1      AS VENDEDOR, 
							SD2.D2_COD        AS CODIGO 
						FROM 
							SD2080 SD2 
							INNER JOIN SF2080 SF2 ON SF2.F2_FILIAL   = SD2.D2_FILIAL 
								AND SF2.F2_SERIE   = SD2.D2_SERIE 
								AND SF2.F2_DOC     = SD2.D2_DOC 
								AND SF2.%NotDel%
						WHERE 
							SD2.%NotDel%
							AND SD2.D2_EMISSAO = TO_CHAR(SYSDATE, 'YYYYMMDD')
							AND SUBSTR(SD2.D2_CF,2,3) IN (  '102','104','108','114','115','116','119','120','403','404','405','551','929','922' )
						UNION ALL 
						SELECT 
							SF2.F2_DOC, 
							SD1.D1_DTDIGIT, 
							NVL ((D1_TOTAL - D1_VALDESC) * -1, 0) AS VALOR_TOTAL, 
							SF2.F2_VEND1                          AS VENDEDOR, 
							SD2.D2_COD                            AS CODIGO 
						FROM 
							SD2080 SD2 
							INNER JOIN SF2080 SF2 ON SF2.F2_FILIAL   = SD2.D2_FILIAL 
								AND SF2.F2_SERIE   = SD2.D2_SERIE 
								AND SF2.F2_DOC     = SD2.D2_DOC 
								AND SF2.%NotDel%
							INNER JOIN SD1080 SD1 ON SD1.%NotDel%
								AND SD1.D1_FILIAL                   = SD2.D2_FILIAL 
								AND SD1.D1_NFORI                    = SD2.D2_DOC 
								AND SD1.D1_TIPO                     = 'D' 
								AND SD1.D1_FORNECE                  = SD2.D2_CLIENTE 
								AND SD1.D1_LOJA                     = SD2.D2_LOJA 
								AND SUBSTR (TRIM (SD2.D2_ITEM), -2) = SUBSTR (TRIM (SD1.D1_ITEMORI), -2) 
						WHERE 
							SD2.%NotDel%
							AND SD1.D1_DTDIGIT     = TO_CHAR(SYSDATE, 'YYYYMMDD')
							AND SUBSTR(SD1.D1_CF,2,3) IN ( '202','411' )				
						UNION ALL 
						SELECT 
							SF2.F2_DOC, 
							SD2.D2_EMISSAO, 
							NVL (D2_TOTAL, 0) AS VALOR_TOTAL, 
							SF2.F2_VEND1      AS VENDEDOR, 
							SD2.D2_COD        AS CODIGO 
						FROM 
							SD2100 SD2 
							INNER JOIN SF2100 SF2 ON SF2.F2_FILIAL     = SD2.D2_FILIAL 
								AND SF2.F2_SERIE     = SD2.D2_SERIE 
								AND SF2.F2_DOC       = SD2.D2_DOC 
								AND SF2.%NotDel%
							WHERE 
								SD2.%NotDel%
							AND SD2.D2_EMISSAO = TO_CHAR(SYSDATE, 'YYYYMMDD')
                    ) RESULTADO_VENDAS ON RESULTADO_VENDAS.VENDEDOR = VENDEDORES.A3_COD 
					/*-- EQUIPES*/ 
					JOIN ACA030 EQUIPES ON EQUIPES.ACA_GRPREP   = VENDEDORES.A3_GRPREP 
						AND EQUIPES.%NotDel% 
					/*-- CANAIS*/ 
					JOIN ADK030 CANAIS ON CANAIS.ADK_COD      = EQUIPES.ACA_GRPSUP 
						AND CANAIS.%NotDel% 
					/*-- GERENTES*/ 
					JOIN SA3030 GERENTE ON GERENTE.A3_COD       = CANAIS.ADK_RESP 
						AND GERENTE.%NotDel%
					/*--SUPERVIDORES*/ 
					LEFT JOIN SA3030 SUPERVISOR ON SUPERVISOR.A3_SUPER     = ' ' 
						AND SUPERVISOR.A3_GEREN    = VENDEDORES.A3_GEREN 
						AND SUPERVISOR.A3_GRPREP   = VENDEDORES.A3_GRPREP 
						AND SUPERVISOR.%NotDel% 
					/*-- PRODUTOS*/ 
					LEFT JOIN SB1030 CAD_PRODUTOS ON CAD_PRODUTOS.B1_FILIAL    = ' ' 
						AND CAD_PRODUTOS.B1_COD      = CODIGO 
						AND CAD_PRODUTOS.%NotDel%		
					/*-- METAS*/ 
					LEFT JOIN ( 
						(
							SELECT 
								SCT.CT_VEND, 
								SCT.CT_DATA, 
								SCT.CT_XSTATUS , 
								SUM(SCT.CT_VALOR) VALOR 
							FROM 
								SCT030 SCT 
							WHERE 
								SCT.CT_FILIAL = '06'
								AND SUBSTR(SCT.CT_DATA,1,6) = To_char(TRUNC(SYSDATE, 'MM'), 'YYYYMM')
								AND SCT.%NotDel%
							GROUP BY 
								SCT.CT_VEND, 
								SCT.CT_DATA, 
								SCT.CT_XSTATUS 
						) 
					)  METAS ON METAS.CT_VEND      = VENDEDORES.A3_COD 
					WHERE 
						VENDEDORES.A3_MSBLQL <> ' ' 
						AND VENDEDORES.%NotDel%
					GROUP BY 
						CAD_PRODUTOS.B1_XCATALO , 
						METAS.CT_XSTATUS , 
						METAS.VALOR, 
						CANAIS.ADK_COD , 
						CANAIS.ADK_NOME , 
						GERENTE.A3_COD , 
						GERENTE.A3_NOME , 
						EQUIPES.ACA_GRPREP , 
						EQUIPES.ACA_DESCRI , 
						SUPERVISOR.A3_COD , 
						SUPERVISOR.A3_NREDUZ , 
						VENDEDORES.A3_COD , 
						VENDEDORES.A3_NOME 
					ORDER BY 
						GERENTE.A3_COD,
						CANAIS.ADK_COD, 
						EQUIPES.ACA_GRPREP , 
						SUPERVISOR.A3_COD , 
						VENDEDORES.A3_COD
            )
            WHERE META_MES <> 0
    
    EndSql

    Do While (cQry)->(!Eof())
		
		aAdd(aDados, { 	(cQry)->VENDA_CATALOGO		,;//[1]  VENDA_CATALOGO
						(cQry)->TOTAL_VENDA			,;//[2]  TOTAL_VENDA
						(cQry)->META_CATALOGO		,;//[3]  META_CATALOGO
						(cQry)->META_MES			,;//[4]  META_MES
						(cQry)->CANAL_CODIGO		,;//[5]  CANAL_CODIGO
						(cQry)->CANAL_NOME			,;//[6]  CANAL_NOME
						(cQry)->GERENTE_CODIGO		,;//[7]  GERENTE_CODIGO
						(cQry)->GERENTE_NOME		,;//[8]  GERENTE_NOME
						(cQry)->EQUIPE_CODIGO 		,;//[9]  EQUIPE_CODIGO
						(cQry)->EQUIPE_NOME 		,;//[10] EQUIPE_NOME
						(cQry)->SUPERVISOR_CODIGO 	,;//[11] SUPERVISOR_CODIGO
						(cQry)->SUPERVISOR_NOME 	,;//[12] SUPERVISOR_NOME
						(cQry)->VENDEDOR_CODIGO 	,;//[13] VENDEDOR_CODIGO
						(cQry)->VENDEDOR_NOME		,;//[14] VENDEDOR_NOME
						.T.							,;//[15] EXIBE_DASH
						0							,;//[16] CONTABILIZA_MARCA_LP	
						0							})//[17] CONTABILIZA_MARCA_WW	
        
        (cQry)->(DbSkip())

    EndDo   
    
    (cQry)->(DbCloseArea())

	If Len(aDados) > 0

		::SetContentType("application/json")

		//Tratamento de regras de negocio
		FRulesOne(@aDados)
		FRulesTwo(@aDados)

		//Somatorias/agrupamentos e estruturação de Json
		FSumValue(@aDados,@oJson)

		::SetResponse( EncodeUTF8( FWJsonSerialize( oJson, .F., .F., .T.)))

		//Zera Array para limpeza de memoria
		aDados := {}
	Else

		::SetResponse( EncodeUTF8( FWJsonSerialize( '"ERRO":"Não há dados."', .F., .F., .T.)))

	EndIf

    //Limpa instancia Objeto
    FreeObj(oJson)

Return .T.

/*/{Protheus.doc} LPDASH - GET PREVISTO

Método para consulta de venda de PREVISTO

@type function
@version 
@author juliano.bobbio
@since 14/12/2020
@return Lógico, Verdadeiro
/*/
WSMETHOD GET PREVISTO WSSERVICE LPDASH

    Local cQry  := GetNextAlias()
	Local aDados := {}
    Local oJson	:= JsonObject():New()
    
	//APP_DBC_A_FATURAR
    BeginSql Alias cQry
		
		SELECT * FROM
            (
				SELECT
					/*+INDEX*/
					NVL(CATALOGO, '-')         AS VENDA_CATALOGO,
					NVL(SUM(VALOR_TOTAL), 0)    AS TOTAL_VENDA,
					NVL(METAS.CT_XSTATUS, '-') AS META_CATALOGO,
					NVL(METAS.VALOR, 0)   AS META_MES,
					CANAIS.ADK_COD             AS CANAL_CODIGO,
					CANAIS.ADK_NOME            AS CANAL_NOME,
					GERENTE.A3_COD             AS GERENTE_CODIGO,
					GERENTE.A3_NOME            AS GERENTE_NOME,
					EQUIPES.ACA_GRPREP         AS EQUIPE_CODIGO,
					EQUIPES.ACA_DESCRI         AS EQUIPE_NOME,
					SUPERVISOR.A3_COD          AS SUPERVISOR_CODIGO,
					SUPERVISOR.A3_NREDUZ       AS SUPERVISOR_NOME,
					VENDEDORES.A3_COD          AS VENDEDOR_CODIGO,
					VENDEDORES.A3_NOME         AS VENDEDOR_NOME
				FROM 
					SA3030 VENDEDORES
					/*-- RESULTADO VENDAS NO PERIODO*/
					LEFT JOIN
					(
						SELECT
				            /*+ INDEX */
							SUM(C6_VALOR)  AS VALOR_TOTAL,
							SB1.B1_XCATALO AS CATALOGO,
							SC5.C5_VEND1   AS VENDEDOR
						FROM 
							SC9030 SC9
							JOIN SC5030 SC5 ON SC5.C5_FILIAL = SC9.C9_FILIAL
								AND SC5.C5_NUM   = SC9.C9_PEDIDO
							JOIN SC6030 SC6 ON SC6.C6_FILIAL    = SC9.C9_FILIAL
								AND SC6.C6_NUM      = SC9.C9_PEDIDO
								AND SC6.C6_ITEM     = SC9.C9_ITEM
								AND SC6.%NotDel%
							JOIN SF4030 SF4 ON SF4.F4_CODIGO    = SC6.C6_TES
								AND SF4.%NotDel%
							JOIN SB1030 SB1 ON SB1.B1_COD       = SC9.C9_PRODUTO
								AND SB1.B1_FILIAL   = ' '
								AND SB1.%NotDel%
						WHERE 
							SC9.C9_DATALIB BETWEEN TO_CHAR(TRUNC(SYSDATE, 'MM'),'YYYYMMDD') AND TO_CHAR(SYSDATE, 'YYYYMMDD')
							AND SC9.C9_BLEST   = ' '
							AND SC9.C9_BLCRED  = ' '
							AND SC9.C9_QTDLIB  > 0
							AND SF4.F4_DUPLIC  = 'S'
							AND SC9.C9_NFISCAL = ' '
							AND SC9.%NotDel%
						GROUP BY 
							B1_XCATALO,
							SC5.C5_VEND1
					) RESULTADO_VENDAS ON RESULTADO_VENDAS.VENDEDOR = VENDEDORES.A3_COD
					/*-- EQUIPES*/
					JOIN ACA030 EQUIPES ON EQUIPES.ACA_GRPREP   = VENDEDORES.A3_GRPREP
						AND EQUIPES.%NotDel%
					/*-- CANAIS*/
					JOIN ADK030 CANAIS ON CANAIS.ADK_COD      = EQUIPES.ACA_GRPSUP
						AND CANAIS.%NotDel%
					/*-- GERENTES*/
					JOIN SA3030 GERENTE ON GERENTE.A3_COD       = CANAIS.ADK_RESP
						AND GERENTE.%NotDel% 
					/*--SUPERVIDORES*/
					LEFT JOIN SA3030 SUPERVISOR ON SUPERVISOR.A3_SUPER     = ' '
						AND SUPERVISOR.A3_GEREN    = VENDEDORES.A3_GEREN
						AND SUPERVISOR.A3_GRPREP   = VENDEDORES.A3_GRPREP
						AND SUPERVISOR.%NotDel%
					/*-- METAS*/
					LEFT JOIN (
						(
							SELECT 
								SCT.CT_VEND,
								SCT.CT_DATA,
								SCT.CT_XSTATUS ,
								SUM(SCT.CT_VALOR) VALOR
							FROM 
								SCT030 SCT
							WHERE 
								SCT.CT_FILIAL = '06'
								AND SUBSTR(SCT.CT_DATA,1,6) = To_char(TRUNC(SYSDATE, 'MM'), 'YYYYMM')
								AND SCT.%NotDel%
							GROUP BY 
								SCT.CT_VEND,
								SCT.CT_DATA,
								SCT.CT_XSTATUS
						) 
					) METAS ON METAS.CT_VEND = VENDEDORES.A3_COD
				WHERE
					VENDEDORES.A3_MSBLQL <> ' '
					AND VENDEDORES.%NotDel%
				GROUP BY 
					CATALOGO,
					METAS.CT_XSTATUS,
					METAS.valor,
					CANAIS.ADK_COD,
					CANAIS.ADK_NOME,
					GERENTE.A3_COD,
					GERENTE.A3_NOME,
					EQUIPES.ACA_GRPREP,
					EQUIPES.ACA_DESCRI,
					SUPERVISOR.A3_COD,
					SUPERVISOR.A3_NREDUZ,
					VENDEDORES.A3_COD,
					VENDEDORES.A3_NOME
				ORDER BY 
					GERENTE.A3_COD, 	
					CANAIS.ADK_COD,
					EQUIPES.ACA_GRPREP,
					SUPERVISOR.A3_COD,
					VENDEDORES.A3_COD
            )
            WHERE 
				META_MES <> 0
		
    EndSql

    Do While (cQry)->(!Eof())

		aAdd(aDados, { 	(cQry)->VENDA_CATALOGO		,;//[1]  VENDA_CATALOGO
						(cQry)->TOTAL_VENDA			,;//[2]  TOTAL_VENDA
						(cQry)->META_CATALOGO		,;//[3]  META_CATALOGO
						(cQry)->META_MES			,;//[4]  META_MES
						(cQry)->CANAL_CODIGO		,;//[5]  CANAL_CODIGO
						(cQry)->CANAL_NOME			,;//[6]  CANAL_NOME
						(cQry)->GERENTE_CODIGO		,;//[7]  GERENTE_CODIGO
						(cQry)->GERENTE_NOME		,;//[8]  GERENTE_NOME
						(cQry)->EQUIPE_CODIGO 		,;//[9]  EQUIPE_CODIGO
						(cQry)->EQUIPE_NOME 		,;//[10] EQUIPE_NOME
						(cQry)->SUPERVISOR_CODIGO 	,;//[11] SUPERVISOR_CODIGO
						(cQry)->SUPERVISOR_NOME 	,;//[12] SUPERVISOR_NOME
						(cQry)->VENDEDOR_CODIGO 	,;//[13] VENDEDOR_CODIGO
						(cQry)->VENDEDOR_NOME		,;//[14] VENDEDOR_NOME
						.T.							,;//[15] EXIBE_DASH
						0							,;//[16] CONTABILIZA_MARCA_LP	
						0							})//[17] CONTABILIZA_MARCA_WW	
        
        (cQry)->(DbSkip())

    EndDo   
	
    (cQry)->(DbCloseArea())

	If Len(aDados) > 0 

		::SetContentType("application/json")

		//Tratamento de regras de negocio
		FRulesOne(@aDados)

		//Somatorias/agrupamentos e estruturação de Json
		FSumValue(@aDados,@oJson)

		::SetResponse( EncodeUTF8( FWJsonSerialize( oJson, .F., .F., .T.)))

	Else

		::SetResponse( EncodeUTF8( FWJsonSerialize( '"ERRO":"Não há dados."', .F., .F., .T.)))
	
	EndIf

	//Zera Array para limpeza de memoria
	aDados := {}

    //Limpa instancia Objeto
    FreeObj(oJson)

Return .T.

/*/{Protheus.doc} LPDASH - PERIODO - GET

Método para retornar Periodo

@type function
@version 
@author juliano.bobbio
@since 14/12/2020
@return Lógico, Verdadeiro
/*/
WSMETHOD GET PERIODO WSSERVICE LPDASH

	::SetContentType("application/json")
	
	::SetResponse(EncodeUtf8('"' + Upper(Substr(Mes(Date()),1,3) + ' 1' + ' - ' + Substr(Mes(Date()),1,3) + ' ' + cValToChar(Day(Date())) + '"')))

Return .T.

/*/{Protheus.doc} FRulesOne
    Regras comerciais, aplica regras comerciais para os vendedores que devem ficar ativos para serem exibidos
	
	Equivalente ao Metodo regrasGeraisOne() da Classe RegrasNegocioAdm 
@type function
@version 1.0
@author juliano.bobbio
@since 15/12/2020
@return Nil, Nulo
/*/
Static Function FRulesOne(aDados)

	Local nX 		 := 0
	Local cCodCanal  := ''
	Local cCatalago  := ''
	Local cCodEquipe := ''
	Local cGerDash   := AllTrim(SuperGetMV("LP_GERDAS",.F., "OFF TRADE WW- SP E RJ + GRANDES REDES WW"))

	For nX := 1 To Len(aDados)

		cCodCanal  := Alltrim(aDados[nX][5]) //Codigo Canal
		cCatalago  := Alltrim(aDados[nX][1]) //Codigo Catalago
		cCodEquipe := Alltrim(aDados[nX][9]) //Codigo Equipe

		// REGRA 1 (Todos os Catálogos)
        // Unidades de negócio: 000001 (Lojas), 000002 (Televendas), 000003 (E-commerce), 000017 (Consumidor LP).
        // Para estas unidades o faturamento considerado é a somas das vendas dos catálogos World Wine, La Pastina e Fasano.
		If cCodCanal $ '000001|000002|000003|000017'

			If !(cCatalago $ 'W|L|F')

				aDados[nX][15] := .F. //EXIBE_DASH

			Else

				aDados[nX][15] := .T. //EXIBE_DASH

			EndIf

		//REGRA 2 (Catálogo World Wine e Fasano)
        //Unidades de negócio: 000004 (On Trade WW - Grande SP), 000005 (On Trade WW – RJ), 000006 (Off Trade WW – RJ), 000007 (On Trade WW - Interior SP), 
		//000008 (Off Trade WW - Interior SP), 000009 (Grupo Fasano BR), 000010 (Off Trade WW - Grande SP) e 000011 (Off Trade WW - BR  - Exceto RJ).
        //Para estas unidades o faturamento considerado são as vendas dos catálogos World Wine e Fasano.
		ElseIf cCodCanal $ '000001|000002|000003|000004|000005|000006|000007|000008|000009|000010|000011|000021|000023|000030|000031|000032|000033|000036|000041|000042|000039|000040'//'000004|000005|000006|000007|000008|000009|000010|000011|000030|000031|000033|000036|000041|000042|000039|000040'

			If !(cCatalago $ 'W|F')

				aDados[nX][15] := .F. //EXIBE_DASH

			Else

				aDados[nX][15] := .T. //EXIBE_DASH

			EndIf

		//REGRA 3 (Catálogo La Pastina)
        //Unidades de negócio: 000012 (On Trade LP - São Paulo), 000013 (On Trade LP - Rio de Janeiro), 000014 (Off Trade LP - Rio de Janeiro), 
		//000015 (Off Trade LP  - São Paulo - Capital e ABC), 000016 (Off Trade LP - Diretas), 000018 (Off Trade LP - Sul, Sud e CO) e 000019 (Off Trade LP - No e Nd).
        //Para estas unidades o faturamento considerado são as vendas do catálogo La Pastina.
		ElseIf cCodCanal $ '000012|000013|000014|000015|000016|000018|000019|000043|000034|000035|000037|000038'

			If cCatalago <> 'L'

				aDados[nX][15] := .F. //EXIBE_DASH

			Else

				aDados[nX][15] := .T. //EXIBE_DASH

			EndIf

		//REGRA 4 (Grandes Redes LP)
        //Unidades de negócio: 000020 (Grandes Redes LP), XXXXXX (Grandes Redes WW) não foi criada uma unidade para as Grandes Redes WW, 
		//pois os códigos de vendedores são os mesmos e o sistema não permiti repetir.
        //Para a unidade (000020 - Grandes Redes LP), o faturamento considerado são as vendas do catálogo La Pastina;
		ElseIf cCodCanal == "000020"

			If cCatalago == 'L' .Or. cCatalago == '-'

				aDados[nX][15] := .T. //EXIBE_DASH
			
			Else
				//Contabiliza vendas para equipes WW		
			
				If cCodEquipe == '00028' // GRANDES REDES WAL MART E SAM CLUB WW

					aDados[nX][5]  := "000021"
                    aDados[nX][3]  := "W"
                    aDados[nX][6]  := "Grandes Redes WW"
                    aDados[nX][7]  := "300000"
                    aDados[nX][4]  := 0
                    aDados[nX][8]  := cGerDash //"Ricardo Soeiro"//"LEONARDO MILAN"
                    aDados[nX][9]  := "00032"
                    aDados[nX][10] := "WAL MART E SAM CLUB WW"
                    aDados[nX][11] := "78200"
                    aDados[nX][12] := "WAL MART WW"
                    aDados[nX][13] := "78001"
                    aDados[nX][14] := "Vendas Wall Mart e Sam Club WW"
                    aDados[nX][15] := .T.

				ElseIf cCodEquipe == '00033' // GRANDES REDES CARREFOUR WW

					aDados[nX][5]  := "000021"				//CANAL_CODIGO "000021";
                    aDados[nX][3]  := 'W'   				//META_CATALOGO 'W';
                    aDados[nX][6]  := "Grandes Redes WW"  	//CANAL_NOME "Grandes Redes WW";
                    aDados[nX][7]  := "300000"   			//GERENTE_CODIGO "300000";
                    aDados[nX][8]  := cGerDash //"Ricardo Soeiro"//"LEONARDO MILAN"   	//GERENTE_NOME "LEONARDO MILAN";
                    aDados[nX][9]  := "00033"   			//EQUIPE_CODIGO "00033";
                    aDados[nX][10] := "CARREFOUR WW"  		//EQUIPE_NOME "CARREFOUR WW";
                    aDados[nX][11] := "078300"  			//SUPERVISOR_CODIGO "078300";
                    aDados[nX][12] := "CARREFOUR WW" 	 	//SUPERVISOR_NOME "CARREFOUR WW";
                    aDados[nX][14] := "Vendas Carrefour WW" //VENDEDOR_NOME "Vendas Carrefour WW";
                    aDados[nX][15] := .T.  					//Exibe_Dashboard true;

				
				ElseIf cCodEquipe == '00035' // GRANDES REDES MAKRO/ATACADÃO

					aDados[nX][5]  := "000020"					 //CANAL_CODIGO
                    aDados[nX][3]  := 'W'      					 //META_CATALOGO
                    aDados[nX][6]  := "Grandes Redes WW"    	 //CANAL_NOME
                    aDados[nX][7]  := "300000"     				 //GERENTE_CODIGO
                    aDados[nX][8]  := cGerDash //"Ricardo Soeiro"//"LEONARDO MILAN"      	 //GERENTE_NOME
                    aDados[nX][9]  := "00035"      				 //EQUIPE_CODIGO
                    aDados[nX][10] := "MAKRO/ATACADÃO WW"        //EQUIPE_NOME
                    aDados[nX][11] := "78001"      				 //SUPERVISOR_CODIGO
                    aDados[nX][12] := "MAKRO/ATAC WW"      		 //SUPERVISOR_NOME
                    aDados[nX][14] := "Vendas Makro/Atacadão WW" //VENDEDOR_NOME
                    aDados[nX][15] := .T.
				
				ElseIf cCodEquipe == '00029' // GRANDES REDES GPA 

					aDados[nX][5]  := "000021" 			 //CANAL_CODIGO
                	aDados[nX][3]  := 'W' 			 	 //META_CATALOGO
                	aDados[nX][1]  := "W" 				 //VENDA_CATALOGO
                	aDados[nX][6]  := "Grandes Redes WW" //CANAL_NOME
                	aDados[nX][7]  := "300000" 			 //GERENTE_CODIGO
                	aDados[nX][4]  := 0 				 //META_MES
                	aDados[nX][8]  := cGerDash //"Ricardo Soeiro"//"LEONARDO MILAN"	 //GERENTE_NOME
                	aDados[nX][9]  := "00048" 			 //EQUIPE_CODIGO
                	aDados[nX][10] := "GPA WW" 			 //EQUIPE_NOME
                	aDados[nX][11] := "078500" 			 //SUPERVISOR_CODIGO
                	aDados[nX][12] := "GPA WW" 			 //SUPERVISOR_NOME
                	aDados[nX][14] := "Vendas GPA WW" 	 //VENDEDOR_NOME
                	aDados[nX][15] := .T. 				 //Exibe_Dashboard

				Else

					aDados[nX][15] := .T. //EXIBE_DASH

					If aDados[nX][3] <> aDados[nX][1] // META_CATALOGO <> VENDA_CATALOGO 
						
						If	aDados[nX][3] <> 'T' // META_CATALOGO

							aDados[nX][2] := 0.01 //TOTAL_VENDA

						EndIf

					EndIf

				EndIf

			EndIf

		//REGRA 5 (Logística)
        //Sem unidade, código único 050000 – LOGÍSTICA (Cobrança de avarias).
        //Para o faturamento desse código os valores devem ser divididos entre catálogo WW para o total
		//do grupo World Wine e os valores do catálogo LP para o total do grupo La Pastina.
		ElseIf cCodCanal == "000022"

			If cCatalago == 'L'

				aDados[nX][15] := .F. //EXIBE_DASH

			Else

				aDados[nX][15] := .T. //EXIBE_DASH

			EndIf

		EndIf 

	Next nX 

Return Nil

/*/{Protheus.doc} FRulesTwo
    Regras comerciais, verifica quais valores devem ser contabilizado nos resultados das marcas LP E WW
	
	Equivalente ao Metodo regraGeraisTwo() da Classe RegrasNegocioAdm 
@type function
@version 1.0
@author juliano.bobbio
@since 15/12/2020
@return Nil, Nulo
/*/
Static Function FRulesTwo(aDados)

	Local nX 		 := 0
	Local cCatalago  := ''
	Local cCodEquipe := ''
	Local cCodVend1  := ''

	For nX := 1 To Len(aDados)
		
		cCatalago  := Alltrim(aDados[nX][1]) //Codigo Catalago
		cCodEquipe := Alltrim(aDados[nX][9]) //Codigo Equipe
		cCodVend1  := Alltrim(aDados[nX][13]) //Codigo Vendedor

		// TRATAMENTO MARCA WORLD WINE
		If cCodEquipe $ '00001|00002|00003|00004|00005|00006|00007|00008|00009|00010|00011|00012|00013|00014|00015|00016|00023|00025|00026|00031|00032|00036|00035|00037|00039|00040|00043|00045|00046|00047|00053|00054|00057|00060|00065|00066|00063|00064|000555|000556|000557|000558|000559'

			If cCatalago $ 'W|F'

				aDados[nX][17] := aDados[nX][2] //CONTABILIZA_MARCA_WW [17]

			Else

				aDados[nX][16] := aDados[nX][2] //CONTABILIZA_MARCA_LP [16]

				If aDados[nX][15] //Exbide_Dash

					aDados[nX][17] := aDados[nX][2] //CONTABILIZA_MARCA_WW [17]

				EndIf

			EndIf

		// TRATAMENTO MARCA LA PASTINA 
		ElseIf cCodEquipe $ '00017|00018|00019|00020|00021|00022|00024|00027|00028|00029|00030|00031|00014|00042|00044|00049|00055|00051|00052|00067|00057|00058|00059|00061|00062'

			If cCatalago == 'L'

				aDados[nX][16] := aDados[nX][2] //CONTABILIZA_MARCA_LP [16]

			Else

				If cCodVend1 $ '040337|040403'

					aDados[nX][16] := aDados[nX][2]  //CONTABILIZA_MARCA_LP [16]

				Else

					aDados[nX][17] := aDados[nX][2] //CONTABILIZA_MARCA_WW [17]

				EndIf

				If aDados[nX][15] //Exbide_Dash

					aDados[nX][16] := aDados[nX][2] //CONTABILIZA_MARCA_LP [16]

				EndIf

			Endif		

		// TRAMENTO NEGOCIAÇÕES
		ElseIf cCodEquipe == '00034'

			If cCatalago == 'L'

				aDados[nX][16] := aDados[nX][2] //CONTABILIZA_MARCA_LP [16]

			Else

				aDados[nX][17] := aDados[nX][2] //CONTABILIZA_MARCA_WW [17]

			Endif		

		EndIf

	Next nX

Return Nil

/*/{Protheus.doc} FSumValue
    Soma resultado do vendedor e calcula meta
	
	Equivalente ao Metodo desempenhoEquipesPorCanal() da Classe RegrasNegocioAdm 
@type function
@version 1.0
@author juliano.bobbio
@since 15/12/2020
@return Nil, Nulo
/*/
Static Function FSumValue(aDados,oJson)

	Local cCodEquipe := ''
	Local cCodVend	 := ''
	Local nTotLP  	 := 0
	Local nTotWW  	 := 0
	Local nTotFA  	 := 0
	Local nMeta   	 := 0
	Local nTotMLP 	 := 0
	Local nTotMWW 	 := 0
	Local nX 	  	 := 0 
	Local nQtd       := 0

	//Ordeno array para processamento e quebras corretas 
	aSort(aDados,,,{|x,y| x[7] + x[5] + x[9] + x[13] < y[7] + y[5] + y[9] + y[13]  })

	//Guardo primeiro código de equipe
	cCodEquipe := AllTrim(aDados[1][9])

	//Guardo primeiro código de vendedor
	cCodVend := AllTrim(aDados[1][13])

	//Inicializo valor de meta
	nMeta := aDados[1][4] 

	//Inicializo estrutura de Json
	oJson["resultado"] := {}

	//Rodo itens para incluir no Json
	For nX := 1 To Len(aDados)

		//Totalizador catalogo - Fasano | LaPastina | WorldWine
		If cCodEquipe == Alltrim(aDados[nX][9])

			If Alltrim(aDados[nX][1]) == 'F' //Fasano

				nTotFA += aDados[nX][2]

			ElseIf Alltrim(aDados[nX][1]) == 'W' //World Wine
				
				nTotWW += aDados[nX][2]

			ElseIf Alltrim(aDados[nX][1]) == 'L' //La Pastina

				nTotLP += aDados[nX][2]

			Endif

			//Atualizo meta, somente quando mudar o vendedor
			If cCodVend <> AllTrim(aDados[nX][13])
			
				If aDados[nX][4] > 0

					nMeta += aDados[nX][4] 

				Else 

					nMeta += 0.01 

				EndIf
			
			EndIf

			//Totalizador Marcas LP e WW
			nTotMLP += aDados[nX][16]
			nTotMWW += aDados[nX][17]

		Else

			nQtd++

			Aadd( oJson["resultado"] , JsonObject():New())	

			oJson["resultado"][nQtd]["COD_CANAL"]          		:= Alltrim(aDados[nX-1][5])
			oJson["resultado"][nQtd]["COD_EQUIPE"]          	:= Alltrim(aDados[nX-1][9])
			oJson["resultado"][nQtd]["COD_GERENTE_CANAL"]       := Alltrim(aDados[nX-1][7])
			oJson["resultado"][nQtd]["COD_SUPERVISOR_EQUIPE"]   := Alltrim(aDados[nX-1][11])
			oJson["resultado"][nQtd]["EXIBE_DASHBOARD"]         := Nil
			oJson["resultado"][nQtd]["NOME_CANAL"]          	:= Capital(aDados[nX-1][6])
			oJson["resultado"][nQtd]["NOME_EQUIPE"]          	:= Capital(aDados[nX-1][10])
			oJson["resultado"][nQtd]["NOME_GERENTE_CANAL"]      := Capital(aDados[nX-1][8])
			oJson["resultado"][nQtd]["NOME_SUPERVISOR_EQUIPE"]	:= Capital(aDados[nX-1][12])
			oJson["resultado"][nQtd]["PERC_STATUS_META"]        := (nTotFA + nTotLP + nTotWW) / nMeta
			oJson["resultado"][nQtd]["TT_CTG_FASANO"]          	:= TransForm(nTotFA,"@E 9,999,999,999,999.99")
			oJson["resultado"][nQtd]["TT_CTG_LAPASTINA"]        := TransForm(nTotLP,"@E 9,999,999,999,999.99")
			oJson["resultado"][nQtd]["TT_CTG_WORLDWINE"]        := TransForm(nTotWW,"@E 9,999,999,999,999.99")
			oJson["resultado"][nQtd]["TT_CTGs_VENDA"]          	:= TransForm(nTotFA + nTotLP + nTotWW, "@E 9,999,999,999,999.99")
			oJson["resultado"][nQtd]["TT_MARCA_LP"]          	:= TransForm(nTotMLP,"@E 9,999,999,999,999.99")
			oJson["resultado"][nQtd]["TT_MARCA_WW"]          	:= TransForm(nTotMWW,"@E 9,999,999,999,999.99")
			oJson["resultado"][nQtd]["TT_META_MES"]          	:= TransForm(nMeta,"@E 9,999,999,999,999.99")
			
			//Zera totalizadores
			nTotLP 	:= 0
			nTotWW 	:= 0
			nTotFA 	:= 0
			nMeta  	:= 0
			nTotMLP	:= 0
			nTotMWW	:= 0

			//Totalizador catalogo - Fasano | LaPastina | WorldWine
			If Alltrim(aDados[nX][1]) == 'F'

				nTotFA += aDados[nX][2]

			ElseIf Alltrim(aDados[nX][1]) == 'W'
				
				nTotWW += aDados[nX][2]

			ElseIf Alltrim(aDados[nX][1]) == 'L'

				nTotLP += aDados[nX][2]

			Endif

			//Atualizo meta, somente quando mudar o vendedor
			If cCodVend <> AllTrim(aDados[nX][13])
			
				If aDados[nX][4] > 0

					nMeta += aDados[nX][4] 

				Else 

					nMeta += 0.01 

				EndIf
			
			EndIf

			//Totalizador Marcas LP e WW
			nTotMLP += aDados[nX][16]
			nTotMWW += aDados[nX][17]

		EndIf

		If nX == Len(aDados)

			nQtd++

			Aadd( oJson["resultado"] , JsonObject():New())	

			oJson["resultado"][nQtd]["COD_CANAL"]          		:= Alltrim(aDados[nX][5])
			oJson["resultado"][nQtd]["COD_EQUIPE"]          	:= Alltrim(aDados[nX][9])
			oJson["resultado"][nQtd]["COD_GERENTE_CANAL"]       := Alltrim(aDados[nX][7])
			oJson["resultado"][nQtd]["COD_SUPERVISOR_EQUIPE"]   := Alltrim(aDados[nX][11])
			oJson["resultado"][nQtd]["EXIBE_DASHBOARD"]         := Nil
			oJson["resultado"][nQtd]["NOME_CANAL"]          	:= Capital(aDados[nX][6])
			oJson["resultado"][nQtd]["NOME_EQUIPE"]          	:= Capital(aDados[nX][10])
			oJson["resultado"][nQtd]["NOME_GERENTE_CANAL"]      := Capital(aDados[nX][8])
			oJson["resultado"][nQtd]["NOME_SUPERVISOR_EQUIPE"]	:= Capital(aDados[nX][12])
			oJson["resultado"][nQtd]["PERC_STATUS_META"]        := (nTotFA + nTotLP + nTotWW) / nMeta
			oJson["resultado"][nQtd]["TT_CTG_FASANO"]          	:= TransForm(nTotFA,"@E 9,999,999,999,999.99")
			oJson["resultado"][nQtd]["TT_CTG_LAPASTINA"]        := TransForm(nTotLP,"@E 9,999,999,999,999.99")
			oJson["resultado"][nQtd]["TT_CTG_WORLDWINE"]        := TransForm(nTotWW,"@E 9,999,999,999,999.99")
			oJson["resultado"][nQtd]["TT_CTGs_VENDA"]          	:= TransForm(nTotFA + nTotLP + nTotWW, "@E 9,999,999,999,999.99")
			oJson["resultado"][nQtd]["TT_MARCA_LP"]          	:= TransForm(nTotMLP,"@E 9,999,999,999,999.99")
			oJson["resultado"][nQtd]["TT_MARCA_WW"]          	:= TransForm(nTotMWW,"@E 9,999,999,999,999.99")
			oJson["resultado"][nQtd]["TT_META_MES"]      		:= TransForm(nMeta,"@E 9,999,999,999,999.99")

		EndIf

		//Alimento variavel de controle referente aos códigos
		cCodEquipe := AllTrim(aDados[nX][9])
		cCodVend   := AllTrim(aDados[nX][13])
	
	Next nX

Return Nil
