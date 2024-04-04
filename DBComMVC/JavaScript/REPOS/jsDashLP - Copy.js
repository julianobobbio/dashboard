/* ================================================================================================
 // Desc.: Variáveis globais da aplicação
* ================================================================================================= */
var atualizacaoDash = 30000;
var totalMetaEquipes = 0;
var totalVendaMes = 0;
var resultaPercentagem = 0;
var totalFatuamentoEquipes = 0;
var perc_resultPercentagemDiferenca = 0;
var aFaturarGeralMarca = 0, aFaturarEquipe = 0, aFaturarEquipePerc = 0 ;
var ttMetaGeralEquipes = 0, perc_ttMetaGeralEquipes = 0;
var valFatuMesEquipes = "", percFatuMesEquipes = 0;
var valConsolidadoDia = "", valConsolidadoMes = "", valConsolidadoDiaEqp = 0;
var ArrConsolidadoDia = Array();
var totalMarca = 0;
var perc_resultPercentagem = 0;
var arrayCodsGerentes = Array();
var arrayCanaisGerente = Array();
var nmGerente = null;
var codGerenteAtual = null;
var codGerenteAtualEquipe = null;
var gerenteAtualEquipe;
var canais = "";
var qtdEquipes = 0;
var chart = "";
var canaisLP = ["000012", "000013", "000014", "000015", "000016", "000017", "000018", "000019", "000020", "000024", "000025"];

/* ================================================================================================
 // Desc.: Método principal, é executado quando o DOM é carregado.
* ================================================================================================= */
$('documento').ready(function () {
    AtualizaDashBoard(atualizacaoDash);
    AtualizacaoDatasConsulta();
    AtualizacaoGraficoPIE(0.10, 99, 80);
});

/* ================================================================================================
 // Desc.: Atualiza Campos Gerais "VENDAS A FATURAR", "CONSOLIDADO DIA" e "VENDAS MÊS" 
 // Param: moneyBrInt > Inteiro. 
* ================================================================================================= */
function AtualizaCamposGerais() {
    
    // VENDAS A FATURAR   
    $.getJSON("api/DB_Vendas_a_Faturar/'L'")
        .done(function (data) {

            // Begin > "A FATURAR GERAL"
            aFaturarGeralMarca = 0;
            $.each(data, function (key, equipe) {
                if (canaisLP.indexOf(equipe.COD_CANAL) > -1) {
                    aFaturarGeralMarca += parseInt(equipe.TT_CTGs_VENDA.replace('R$ ', '').replace('.', '').replace('.', '').replace('.', '').replace(',', ''));
                }
            });

            $("#aFaturar").fadeOut("fast").html('R$ ' + FormatReal(aFaturarGeralMarca)).fadeIn("slow");            
            // End > "A FATURAR GERAL"

            // Begin > "A FATURAR EQUIPE"
            for (i = 0; i < data.length; i++) {

                item = data[i];

                if (codGerenteAtualEquipe == item.COD_GERENTE_CANAL)
                {
                    aFaturarEquipe += parseInt(item.TT_CTGs_VENDA.replace('R$ ', '').replace('.', '').replace('.', '').replace('.', '').replace(',', ''));
                }

            };
           
           aFaturarParcialPerc = ((aFaturarEquipe / aFaturarGeralMarca) * 100)

            // A Faturar "R$"=            
            $('#aFaturarParcial')
                .fadeOut('slow')
                .text('R$ ' + FormatReal(aFaturarEquipe.toString()))
                .fadeIn('slow');
                
            // A Faturar "%"
            $('#aFaturarParcialPerc')
                .fadeOut('slow')
                .text(Math.round10(aFaturarParcialPerc, -1) + "%")
                .fadeIn('slow');
            
            aFaturarEquipe = 0;
            // End > "A FATURAR EQUIPE"

        })
    
    // VENDAS CONSOLIDADO DIA (FATURAMENTO DIA)    
    $.getJSON("api/DB_Vendas_Consolidado_Dia/'L'")
        .done(function (data) {
            ArrConsolidadoDia = Array();
            valConsolidadoDia = 0;
            $.each(data, function (key, item) {
                if (canaisLP.indexOf(item.COD_CANAL) > -1) {
                    valConsolidadoDia += parseInt(item.TT_CTGs_VENDA.replace('R$ ', '').replace('.', '').replace('.', '').replace('.', '').replace(',', ''));
                    ArrConsolidadoDia.push({
                        "COD_CANAL": item.COD_CANAL,
                        "TOTAL_DIA_CTG_LP": item.TT_CTG_LAPASTINA,
                        "TOTAL_DIA_CTG_WW": item.TT_CTG_WORLDWINE,
                        "TOTAL_DIA_CTG_F": item.TT_CTG_FASANO,
                        "TOTAL_DIA_CTG": item.TT_CTGs_VENDA
                    });
                };
            })
        }) 
    
}

/* ================================================================================================
// Param: moneyBrInt > Inteiro.  
* ================================================================================================= */
function AtualizaResultadoCanaisEquipes() {

    // RESULTADO EQUIPES
    $.getJSON("api/DB_Resultado_Equipes/LP")
        .done(function (data) {
            qtdEquipes = (data.length - 1);

            // Limpeza Table > Tbody
            $('#tbBodyPrincipal').fadeOut("slow").empty().fadeIn("fast");

            // Begin > Resultado Marca
            totalMarca = 0;
            ttMetaGeralEquipes = 0;

            $.each(data, function (key, equipe) {
                totalMarca += parseInt(equipe.TT_MARCA_LP.replace('R$ ', '').replace('.', '').replace('.', '').replace('.', '').replace(',', ''));                
            });

            $("#vendaMes").fadeOut("fast").html("R$ " + FormatReal(totalMarca)).fadeIn("slow");
            $("#consolidadoDia").fadeOut("fast").html("R$ " + FormatReal(valConsolidadoDia)).fadeIn("slow");
            // End > Resultado Marca
            
            // Begin> Gerente Canal
            $.each(data, function (key, equipe) {

                if (canaisLP.indexOf(equipe.COD_CANAL) > -1) {

                    if (arrayCodsGerentes.indexOf(equipe.COD_GERENTE_CANAL) == -1) {

                        if (codGerenteAtual == null) { codGerenteAtual = equipe.COD_GERENTE_CANAL; };

                        if (equipe.COD_GERENTE_CANAL == codGerenteAtual) {

                            percMeta = (equipe.PERC_STATUS_META * 100).toString().substring(0, 5) + " %";
                            percMetaLength = percMeta.substring(0, 2).indexOf('.') == -1 ? percMeta.substring(0, 2) : percMeta.substring(0, 1);
                            arrEquipes = [];

                            if (equipe.NOME_SUPERVISOR_EQUIPE.trim() == '.')
                            {
                                arrEquipes.push($('<h4>', { class: 'media-heading', style: 'font-weight:400; font-size:16px; white-space:nowrap; margin:8px 0px 5px 0px;' }).text(equipe.NOME_EQUIPE))
                            } else {
                                arrEquipes.push($('<h4>', { class: 'media-heading', style: 'font-weight:400; font-size:16px; white-space:nowrap;' }).text(equipe.NOME_EQUIPE));
                                arrEquipes.push($('<p>', { style: 'font-size:12px; font-weight:400; color:#8899A6; margin:0px;' }).append($('<i></i>').text(equipe.NOME_SUPERVISOR_EQUIPE)))
                            }
                            
                            // ADICIONA EQUIPES AO DASBOARD
                            $('#tbBodyPrincipal').append(
                               $('<tr>').append(

                                   // EQUIPE
                                   $('<td></td>').append(
                                       $('<div>', { class: 'media-body', style: 'display:inline-block;' }).append(arrEquipes)
                                   ),

                                   // RESULTADO X META
                                   $('<td></td>').append(
                                       $('<div>', { class: 'progress', style: 'margin:16px 5px 10px 0px !important; border-radius:0px; width:80%; display: inline-flex;'}).append(
                                           $('<div>', {
                                               class: 'progress-bar',
                                               role: "progressbar",
                                               'aria-valuenow': percMetaLength,
                                               'aria-valuemin': "0",
                                               'aria-valuemax': "100",
                                               style: "width: " + percMetaLength + "%; background-color:#2d9e05 !important;"
                                           })
                                       ),
                                        $('<span>', {
                                            class: "badge",
                                            style: "padding:7px 7px !important; border-radius:20px !important; background-color:#d9534f; font-weight:500;"
                                        }).text(Math.round10(percMeta.replace(" %",""), -1) + "%")
                                   ),
                                   // R$ META
                                   $('<td></td>').append(
                                       $('<div>', { style: 'margin: 6px 0px;' }).append(
                                           $('<p>', { style: 'font-size:16px; font-weight:400; color:#515151; margin:0px;' }).text(equipe.TT_META_MES)
                                       )
                                   ),
                                   // R$ FATURAMENTO
                                   $('<td></td>').append(
                                       $('<div>', { style: 'margin: 6px 0px;' }).append(
                                           $('<p>', { style: 'font-size:16px; font-weight:400; color:#515151; margin:0px;' }).text(equipe.TT_CTGs_VENDA)
                                       )
                                   )
                               )
                             ).fadeIn('slow');

                            // SOMA METAS EQUIPES
                            totalMetaEquipes += parseInt(equipe.TT_META_MES.replace('R$ ', '').replace('.', '').replace('.', '').replace('.', '').replace(',', ''));
                            totalVendaMes += parseInt(equipe.TT_CTGs_VENDA.replace('R$ ', '').replace('.', '').replace('.', '').replace('.', '').replace(',', ''));

                            // VERIFICA CANAIS DO GERENTE
                            if (ProcurarIndiceArray(arrayCanaisGerente, "NOME_CANAL", equipe.NOME_CANAL).length == 0) {
                                arrayCanaisGerente.push({ "COD_CANAL": equipe.COD_CANAL, "NOME_CANAL": equipe.NOME_CANAL });
                                nmGerente = equipe.NOME_GERENTE_CANAL.trim();

                                //SOMA CONSOLIDADO DIA EQUIPE
                                var arrResultConsolidDia = ProcurarIndiceArray(ArrConsolidadoDia, "COD_CANAL", equipe.COD_CANAL);
                                for (var i = 0; i < arrResultConsolidDia.length; i++) {
                                    resultado = ArrConsolidadoDia[arrResultConsolidDia[i]]
                                    valConsolidadoDiaEqp += parseInt((resultado.TOTAL_DIA_CTG).replace('R$ ', '').replace('.', '').replace('.', '').replace('.', '').replace(',', ''));
                                }
                            }
                        }

                        if (equipe.COD_GERENTE_CANAL != codGerenteAtual) {
                            codGerenteAtualEquipe = codGerenteAtual;
                            arrayCodsGerentes.push(codGerenteAtual);
                            resultaPercentagem = Math.round10(((totalVendaMes / totalMetaEquipes) * 100).toString().substring(0, 4), -1) + '%';
                            perc_resultPercentagem = ((totalVendaMes / totalMetaEquipes) * 100);
                            perc_resultPercentagemDiferenca = 100 - ((totalVendaMes / totalMetaEquipes) * 100);
                            valFatuMesEquipes = 'R$ ' + FormatReal(totalVendaMes.toString());
                            percFatuMesEquipes = ((totalVendaMes / totalMarca) * 100).toString().substring(0, 5) + '%';
                            valConsolidDiaEqptext = 'R$ ' + FormatReal(valConsolidadoDiaEqp.toString());
                            perConlDiaEqp = ((valConsolidadoDiaEqp / valConsolidadoDia) * 100).toString().substring(0, 5) + '%';

                            for (var i = 0; i < arrayCanaisGerente.length; i++) { canais += arrayCanaisGerente[i].NOME_CANAL + ", "; }

                            $('#IconeGerente').text(nmGerente.substring(0, 1));
                            $('#nmGerente').text(nmGerente);
                            $('#canalGerente').text(canais);
                            $('#resultParcial').fadeOut('slow').text(resultaPercentagem).fadeIn('slow');
                            $('#aFaturarMes').text(valFatuMesEquipes);
                            $('#perAFaturarMes').text(percFatuMesEquipes);
                            $("#aConsolidDiaEqp").text(valConsolidDiaEqptext);
                            $("#perConlDiaEqp").text(perConlDiaEqp);

                            // ATUALIZA GRÁFICO
                            AtualizacaoGraficoPIE(perc_resultPercentagem, perc_resultPercentagemDiferenca);

                            //ATUALIZA "Á FATURAR"
                            AtualizaCamposGerais();

                            // REINICIAR VARIÁVEIS
                            canais = "";
                            perc_resultPercentagem = 0;
                            perc_resultPercentagemDiferenca = 0;
                            totalMetaEquipes = 0;
                            totalVendaMes = 0;
                            resultaPercentagem = 0;
                            valConsolidadoDiaEqp = 0;
                            arrayCanaisGerente = Array();
                            codGerenteAtual = null;

                            return false;
                        }

                        if (qtdEquipes == key) {

                            codGerenteAtualEquipe = codGerenteAtual;
                            resultaPercentagem = ((totalVendaMes / totalMetaEquipes) * 100).toString().substring(0, 5) + '%';
                            perc_resultPercentagem = ((totalVendaMes / totalMetaEquipes) * 100);
                            perc_resultPercentagemDiferenca = 100 - ((totalVendaMes / totalMetaEquipes) * 100);
                            valFatuMesEquipes = 'R$ ' + FormatReal(totalVendaMes.toString());
                            percFatuMesEquipes = ((totalVendaMes / totalMarca) * 100).toString().substring(0, 5) + '%';
                            valConsolidDiaEqptext = 'R$ ' + FormatReal(valConsolidadoDiaEqp.toString());
                            perConlDiaEqp = ((valConsolidadoDiaEqp / valConsolidadoDia) * 100).toString().substring(0, 5) + '%';

                            for (var i = 0; i < arrayCanaisGerente.length; i++) { canais += arrayCanaisGerente[i].NOME_CANAL + ", "; }

                            $('#IconeGerente').text(nmGerente.substring(0, 1));
                            $('#nmGerente').text(nmGerente);
                            $('#canalGerente').text(canais);
                            $('#resultParcial').fadeOut('slow').text(resultaPercentagem).fadeIn('slow');
                            $('#aFaturarMes').text(valFatuMesEquipes);
                            $('#perAFaturarMes').text(percFatuMesEquipes);
                            $("#aConsolidDiaEqp").text(valConsolidDiaEqptext);
                            $("#perConlDiaEqp").text(perConlDiaEqp);

                            // ATUALIZA GRÁFICO
                            AtualizacaoGraficoPIE(perc_resultPercentagem, perc_resultPercentagemDiferenca)

                            //ATUALIZA "Á FATURAR"
                            AtualizaCamposGerais();

                            // REINICIAR VARIÁVEIS
                            canais = "";
                            perc_resultPercentagem = 0;
                            perc_resultPercentagemDiferenca = 0;
                            totalMetaEquipes = 0;
                            totalVendaMes = 0;
                            resultaPercentagem = 0;
                            valConsolidadoDiaEqp = 0;
                            arrayCanaisGerente = Array();
                            arrayCodsGerentes = Array();
                            codGerenteAtual = null;
                            return false;
                        };
                    };
                }            
            })

            // Begin > Inseri valor total e percentagem da meta no dashboard.
            $.each(data, function (key, equipe){
                if (canaisLP.indexOf(equipe.COD_CANAL) > -1) {
                    ttMetaGeralEquipes += parseInt(equipe.TT_META_MES.replace('R$ ', '').replace('.', '').replace('.', '').replace('.', '').replace(',', ''));
                }
            });

            perc_ttMetaGeralEquipes = ((totalMarca / ttMetaGeralEquipes) * 100);

            $('#valMetaTT')
                .fadeOut('slow')
                .text('R$ ' + FormatReal(ttMetaGeralEquipes.toString()))
                .fadeIn('slow');

            $('#percResultaVsMetaTT')
                .fadeOut('slow')
                .text(Math.round10(perc_ttMetaGeralEquipes, -1) + "% ")
                .fadeIn('slow');
            // End > Inseri valor total e percentagem da meta no dashboard.

            // End > Gerente Canal
        })
}

/* ================================================================================================
// Func.: AtualizacaoGraficoPIE
// Desc.: Atualiza o gréfico pie.
// Return: N/A 
* ================================================================================================= */
function AtualizacaoGraficoPIE(percIni, percFinal) {
    
    percIni == 0 ? percIni = 0.10 : percIni;
    percFinal == 0 ? percFinal = 99.80 : percFinal;
  
    var chartPieParameters = JSON;

    chartPieParameters.type = "pie";
    chartPieParameters.theme = "light";
    chartPieParameters.colors = ["#2d9e05", "#e5e5e1"];
    chartPieParameters.dataProvider = [{ "value": percIni }, { "value": percFinal }];
    chartPieParameters.valueField = "value";
    chartPieParameters.labelRadius = 5;
    chartPieParameters.radius = "42%";
    chartPieParameters.innerRadius = "70%";
    chartPieParameters.labelText = "";
    chartPieParameters.export = { "enabled": true };

    var chart = AmCharts.makeChart("chartPieDiv", chartPieParameters);
}

/* ================================================================================================
// Func.: AtualizacaoDatas
// Desc.: Atualiza o periodo de data que é considerado nas consultas.
// Return: N/A 
* ================================================================================================= */
function AtualizacaoDatasConsulta() {

    $.getJSON("api/DB_DataHoraServer")
        .done(function (data) {
            $("#periodoConsulta").text(data).fadeIn("slow");
        })

}

/* ================================================================================================
// Func.: AtualizaDashBoard
// Desc.: Estabelece os ciclos das consultas na base.
// Param.: stepTime > Inteiro > Tempo de atualização do método.
// Return: N/A
* ================================================================================================= */
function AtualizaDashBoard(stepTime) {

    AtualizaCamposGerais();

    AtualizaResultadoCanaisEquipes();

    var today = new Date();
    var h = today.getHours();
    var m = today.getMinutes();
    var s = today.getSeconds();
    m = CheckTime(m);
    s = CheckTime(s);
    $("#txt").html(h + ":" + m + ":" + s);

    t = setTimeout(function () { AtualizaDashBoard() }, atualizacaoDash); // ATUALIZA PAGINA
}