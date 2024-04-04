/* ================================================================================================
 // Desc.: Variáveis globais da aplicação
* ================================================================================================= */
var atualizacaoDash = 30000;
var totalMetaEquipes = 0;
var totalVendaMes = 0;
var resultaPercentagem = 0;
var totalFatuamentoEquipes = 0;
var perc_resultPercentagemDiferenca = 0;
var valFatuMesEquipes = "", percFatuMesEquipes = 0;
var valConsolidadoDia = "", valConsolidadoMes = "", valConsolidadoDiaEqp = 0;
var ArrConsolidadoDia = Array();
var totalMarca = 0;
var perc_resultPercentagem = 0;
var arrayCodsGerentes = Array();
var arrayCanaisGerente = Array();
var nmGerente = null;
var codGerenteAtual = null;
var canais = "";
var qtdEquipes = 0;
var chart = "";
var canaisLP = [000001, 000002, 000003, 000004, 000005, 000006, 000007, 000008, 000009, 000010, 000011, 000021];

/* ================================================================================================
 // Desc.: Método principal, é executado quando o DOM é carregado.
* ================================================================================================= */
$('documento').ready(function () {
    //$containers = $('#containerOne'),
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
    $.getJSON("api/DB_Vendas_a_Faturar/'F','W'")
        .done(function (data) {
            $.each(data, function (key, item) {
                if (item.VENDAS_A_FATURAR != "") {
                    $("#aFaturar").fadeOut("fast").html('R$ ' + FormatReal(item.VENDAS_A_FATURAR.replace('.', '').replace('.', '').replace('.', '').replace(',', ''))).fadeIn("slow");
                }
            })
        })

    // VENDAS CONSOLIDADO DIA (FATURAMENTO DIA)    
    $.getJSON("api/DB_Resultado_Dia_Eqp/WW")
        .done(function (data) {
            ArrConsolidadoDia = Array();
            valConsolidadoDia = 0;
            $.each(data, function (key, item) {
                valConsolidadoDia += parseInt(item.TT_CTGs_VENDA.replace('R$ ', '').replace('.', '').replace('.', '').replace('.', '').replace(',', ''));
                ArrConsolidadoDia.push({
                    "COD_CANAL": item.COD_CANAL,
                    "TOTAL_DIA_CTG_LP": item.TT_CTG_LAPASTINA,
                    "TOTAL_DIA_CTG_WW": item.TT_CTG_WORLDWINE,
                    "TOTAL_DIA_CTG_F": item.TT_CTG_FASANO,
                    "TOTAL_DIA_CTG": item.TT_CTGs_VENDA
                });
            })
        })

    // VENDAS MÊS (FATURAMENTO)
    /*
    $.getJSON("api/DB_Vendas_Faturamento/LP")
        .done(function (data) {
            $.each(data, function (key, item) {
                if (item.VENDAS_FATURADAS.length != 0) {
                    $("#vendaMes").fadeOut("fast").html(item.VENDAS_FATURADAS).fadeIn("slow");
                    valConsolidadoMes = parseInt(item.VENDAS_FATURADAS.replace('R$ ', '').replace('.', '').replace('.', '').replace('.', '').replace(',', ''));
                }
            })
        })
    */
}

/* ================================================================================================
// Desc.: Atualiza campos "RESULTADO EQUIPES", "% A FATURAR", "%DEVOLUÇÕES" E "CONSOLIDADO DIA"
// Param: moneyBrInt > Inteiro. 
* ================================================================================================= */
function AtualizaResultadoCanaisEquipes() {

    // RESULTADO EQUIPES
    $.getJSON("api/DB_Resultado_Equipes/WW")
        .done(function (data) {
            qtdEquipes = (data.length - 1);

            // Limpeza Table > Tbody
            $('#tbBodyPrincipal').fadeOut("slow").empty().fadeIn("fast");

            // Begin > Resultado Marca
            totalMarca = 0;
            $.each(data, function (key, equipe) { totalMarca += parseInt(equipe.TT_CTGs_VENDA.replace('R$ ', '').replace('.', '').replace('.', '').replace('.', '').replace(',', '')); });
            $("#vendaMes").fadeOut("fast").html("R$ " + FormatReal(totalMarca)).fadeIn("slow");
            $("#consolidadoDia").fadeOut("fast").html("R$ " + FormatReal(valConsolidadoDia)).fadeIn("slow");
            // End > Resultado Marca

            // Begin> Gerente Canal
            $.each(data, function (key, equipe) {

                if (arrayCodsGerentes.indexOf(equipe.COD_GERENTE_CANAL) == -1) {

                    if (codGerenteAtual == null) { codGerenteAtual = equipe.COD_GERENTE_CANAL; };

                    if (equipe.COD_GERENTE_CANAL == codGerenteAtual) {

                        percMeta = (equipe.PERC_STATUS_META * 100).toString().substring(0, 5) + " %";
                        percMetaLength = percMeta.substring(0, 2).indexOf('.') == -1 ? percMeta.substring(0, 2) : percMeta.substring(0, 1);

                        // ADICIONA EQUIPES AO DASBOARD
                        $('#tbBodyPrincipal').append(
                           $('<tr>').append(
                               // CANAL / SUPERVISOR
                               $('<td></td>').append(
                                   $('<div>', { class: 'media-body', style: 'display:inline-block;' }).append(
                                       $('<h4>', { class: 'media-heading', style: 'font-weight:400; font-size:17px; ' }).text(equipe.NOME_EQUIPE),
                                       $('<p>', { style: 'font-size:12px; font-weight:400; color:#8899A6; margin:0px;' }).append($('<i></i>').text(equipe.NOME_SUPERVISOR_EQUIPE))
                                   )
                               ),
                               // RESULTADO X META
                               $('<td></td>').append(
                                   $('<div>', { class: 'progress', style: 'margin:10px 0px !important; border-radius:0px;;' }).append(
                                       $('<div>', {
                                           class: 'progress-bar',
                                           role: "progressbar",
                                           'aria-valuenow': percMetaLength,
                                           'aria-valuemin': "0",
                                           'aria-valuemax': "100",
                                           style: "width: " + percMetaLength + "%; background-color:#2d9e05 !important;"
                                       }).text(percMeta)
                                   )
                               ),
                               // R$ META
                               $('<td></td>').append(
                                   $('<div>', { style: 'margin: 6px 0px;' }).append(
                                       $('<p>', { style: 'font-size:16px; font-weight:400; color:#8899A6; margin:0px;' }).text(equipe.TT_META_MES)
                                   )
                               ),
                               // R$ FATURAMENTO
                               $('<td></td>').append(
                                   $('<div>', { style: 'margin: 6px 0px;' }).append(
                                       $('<p>', { style: 'font-size:16px; font-weight:400; color:#8899A6; margin:0px;' }).text(equipe.TT_CTGs_VENDA)
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

                            //ProcurarIndiceArray(ArrConsolidadoDia, "COD_CANAL", equipe.COD_CANAL)

                        }

                    }

                    if (equipe.COD_GERENTE_CANAL != codGerenteAtual) {
                        arrayCodsGerentes.push(codGerenteAtual);
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
                        AtualizacaoGraficoPIE(perc_resultPercentagem, perc_resultPercentagemDiferenca);

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
            })
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