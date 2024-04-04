var i = 0;
var atualizacaoDash = 30000;
var totalMetaEquipes = 0;
var totalVendaMes = 0;
var resultaPercentagem = 0;
var totalFatuamentoEquipes = 0;
var perc_resultPercentagemDiferenca = 0;
var aFaturarGeralMarca = 0, aFaturarEquipe = 0, aFaturarEquipePerc = 0;
var ttMetaGeralEquipes = 0, perc_ttMetaGeralEquipes = 0;
var valFatuMesEquipes = "", percFatuMesEquipes = 0;
var valConsolidadoDia = "", valConsolidadoMes = "", valConsolidadoDiaEqp = 0;
var ArrConsolidadoDia = [];
var totalMarca = 0;
var perc_resultPercentagem = 0;
var arrayCodsGerentes = [];
var arrayCanaisGerente = [];
var nmGerente = null;
var codGerenteAtual = null;
var codGerenteAtualEquipe = null;
var gerenteAtualEquipe;
var canais = "";
var qtdEquipes = 0;
var chart = "";
var aFaturarParcialPerc = 0;
var item = [];
var canaisLP = ["000012", "000013", "000014", "000015", "000016", "000017", "000018", "000019", "000020", "000024", "000025"];
$('documento').ready(function () {
	agora();
	AtualizaDashBoard(atualizacaoDash);
	AtualizacaoDatasConsulta();
	AtualizacaoGraficoPIE(0.10, 99, 80);
});
function AtualizaCamposGerais() {
	$.getJSON("api/DB_Vendas_a_Faturar/'L'").done(function (data) {
		aFaturarGeralMarca = 0;
		$.each(data, function (key, equipe) {
			if (canaisLP.indexOf(equipe.COD_CANAL) > -1) {
				aFaturarGeralMarca += parseInt(equipe.TT_CTGs_VENDA.replace('R$ ', '').replace('.', '').replace('.', '').replace('.', '').replace(',', ''));
			}
		});
		$("#aFaturar").fadeOut("fast").html('R$' + FormatReal(aFaturarGeralMarca)).fadeIn("slow");
		for (i = 0; i < data.length; i++) {
			item = data[i];
			if (codGerenteAtualEquipe === item.COD_GERENTE_CANAL) {
				aFaturarEquipe += parseInt(item.TT_CTGs_VENDA.replace('R$ ', '').replace('.', '').replace('.', '').replace('.', '').replace(',', ''));
			}
		};
		aFaturarParcialPerc = ((aFaturarEquipe / aFaturarGeralMarca) * 100);
		$('#aFaturarParcial').fadeOut('slow').text('R$ ' + FormatReal(aFaturarEquipe.toString())).fadeIn('slow');
		$('#aFaturarParcialPerc').fadeOut('slow').text(Math.round10(aFaturarParcialPerc, -1) + "%").fadeIn('slow');
		aFaturarEquipe = 0;
	})
	$.getJSON("api/DB_Vendas_Consolidado_Dia/'L'").done(function (data) {
		ArrConsolidadoDia = [];
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
};
function AtualizaResultadoCanaisEquipes() {
	$.getJSON("api/DB_Resultado_Equipes/LP").done(function (data) {
		qtdEquipes = (data.length - 1);
		$('#tbBodyPrincipal').fadeOut("slow").empty().fadeIn("fast");
		totalMarca = 0;
		ttMetaGeralEquipes = 0;
		$.each(data, function (key, equipe) {
			totalMarca += parseInt(equipe.TT_MARCA_LP.replace('R$ ', '').replace('.', '').replace('.', '').replace('.', '').replace(',', ''));
		});
		$("#vendaMes").fadeOut("fast").html("R$ " + FormatReal(totalMarca)).fadeIn("slow");
		$("#consolidadoDia").fadeOut("fast").html("R$ " + FormatReal(valConsolidadoDia)).fadeIn("slow");
		cont = 0;
		max = 0;
		$.each(data, function (key, equipe) {
			if (canaisLP.indexOf(equipe.COD_CANAL) > -1) {
				if (arrayCodsGerentes.indexOf(equipe.COD_GERENTE_CANAL) == -1) {
					if (codGerenteAtual == null) {
						codGerenteAtual = equipe.COD_GERENTE_CANAL;
					};
					if (equipe.COD_GERENTE_CANAL == codGerenteAtual) {
						percMeta = (equipe.PERC_STATUS_META * 100).toString().substring(0, 5) + " %";
						percMetaLength = percMeta.substring(0, 2).indexOf('.') == -1 ? percMeta.substring(0, 2) : percMeta.substring(0, 1);
						arrEquipes = [];
						if (equipe.NOME_SUPERVISOR_EQUIPE.trim() == '.') {
							arrEquipes.push($('<h4>', {
									class: 'media-heading',
									style: 'font-weight:400; font-size:16px; white-space:nowrap; margin:8px 0px 5px 0px;'
								}).text(equipe.NOME_EQUIPE))
						} else {
							arrEquipes.push($('<h4>', {
									class: 'media-heading',
									style: 'font-weight:400; font-size:16px; white-space:nowrap;'
								}).text(equipe.NOME_EQUIPE));
							arrEquipes.push($('<p>', {
									style: 'font-size:12px; font-weight:400; color:#8899A6; margin:0px;'
								}).append($('<i></i>').text(equipe.NOME_SUPERVISOR_EQUIPE)))
						}
						$('#tbBodyPrincipal').append($('<tr>').append($('<td></td>').append($('<div>', {
										class: 'media-body',
										style: 'display:inline-block;'
									}).append(arrEquipes)), $('<td></td>').append($('<div>', {
										class: 'progress',
										style: 'margin:16px 5px 10px 0px !important; border-radius:0px; width:80%; display: inline-flex;'
									}).append($('<div>', {
											class: 'progress-bar',
											role: "progressbar",
											'aria-valuenow': percMetaLength,
											'aria-valuemin': "0",
											'aria-valuemax': "100",
											style: "width: " + percMetaLength + "%; background-color:#2d9e05 !important;"
										})), $('<span>', {
										class: "badge",
										style: "padding:7px 7px !important; border-radius:20px !important; background-color:#d9534f; font-weight:500;"
									}).text(Math.round10(percMeta.replace(" %", ""), -1) + "%")), $('<td></td>').append($('<div>', {
										style: 'margin: 6px 0px;'
									}).append($('<p>', {
											style: 'font-size:16px; font-weight:400; color:#515151; margin:0px;'
										}).text(equipe.TT_META_MES))), $('<td></td>').append($('<div>', {
										style: 'margin: 6px 0px;'
									}).append($('<p>', {
											style: 'font-size:16px; font-weight:400; color:#515151; margin:0px;'
										}).text(equipe.TT_CTGs_VENDA))))).fadeIn('slow');
						totalMetaEquipes += parseInt(equipe.TT_META_MES.replace('R$ ', '').replace('.', '').replace('.', '').replace('.', '').replace(',', ''));
						totalVendaMes += parseInt(equipe.TT_CTGs_VENDA.replace('R$ ', '').replace('.', '').replace('.', '').replace('.', '').replace(',', ''));
						if (ProcurarIndiceArray(arrayCanaisGerente, "NOME_CANAL", equipe.NOME_CANAL).length == 0) {
							arrayCanaisGerente.push({
								"COD_CANAL": equipe.COD_CANAL,
								"NOME_CANAL": equipe.NOME_CANAL
							});
							nmGerente = equipe.NOME_GERENTE_CANAL.trim();
							var arrResultConsolidDia = ProcurarIndiceArray(ArrConsolidadoDia, "COD_CANAL", equipe.COD_CANAL);
							for (var i = 0; i < arrResultConsolidDia.length; i++) {
								resultado = ArrConsolidadoDia[arrResultConsolidDia[i]]
									valConsolidadoDiaEqp += parseInt((resultado.TOTAL_DIA_CTG).replace('R$ ', '').replace('.', '').replace('.', '').replace('.', '').replace(',', ''));
							}
						}
					}
					if (equipe.COD_GERENTE_CANAL == codGerenteAtual) {
						cont++;
					}
					if (equipe.COD_GERENTE_CANAL != codGerenteAtual) {
						max = cont;
					}
					if (equipe.COD_GERENTE_CANAL != codGerenteAtual) {
						codGerenteAtualEquipe = codGerenteAtual;
						arrayCodsGerentes.push(codGerenteAtual);
						nresultaPercentagem = ((totalVendaMes / totalMetaEquipes) * 100).toFixed(2);
						resultaPercentagem = nresultaPercentagem.toString().substring(0, 5) + '%';
						perc_resultPercentagem = ((totalVendaMes / totalMetaEquipes) * 100);
						perc_resultPercentagemDiferenca = 100 - ((totalVendaMes / totalMetaEquipes) * 100);
						valFatuMesEquipes = 'R$ ' + FormatReal(totalVendaMes.toString());
						npercFatuMesEquipes = ((totalVendaMes / totalMarca) * 100).toFixed(2);
						percFatuMesEquipes = npercFatuMesEquipes.toString().substring(0, 5) + '%';
						valConsolidDiaEqptext = 'R$ ' + FormatReal(valConsolidadoDiaEqp.toString());
						nperConlDiaEqp = ((valConsolidadoDiaEqp / valConsolidadoDia) * 100).toFixed(2);
						if (isNaN(nperConlDiaEqp)) {
							perConlDiaEqp = 0 + '%';
						} else {
							perConlDiaEqp = nperConlDiaEqp.toString().substring(0, 5) + '%';
						}
						for (var i = 0; i < arrayCanaisGerente.length; i++) {
							canais += arrayCanaisGerente[i].NOME_CANAL + ", ";
						}
						$('#IconeGerente').text(nmGerente.substring(0, 1));
						$('#nmGerente').text(nmGerente);
						$('#canalGerente').text(canais);
						$('#resultParcial').fadeOut('slow').text(resultaPercentagem).fadeIn('slow');
						$('#aFaturarMes').text(valFatuMesEquipes);
						$('#perAFaturarMes').text(percFatuMesEquipes);
						$("#aConsolidDiaEqp").text(valConsolidDiaEqptext);
						$("#perConlDiaEqp").text(perConlDiaEqp);
						AtualizacaoGraficoPIE(perc_resultPercentagem, perc_resultPercentagemDiferenca);
						AtualizaCamposGerais();
						canais = "";
						perc_resultPercentagem = 0;
						perc_resultPercentagemDiferenca = 0;
						totalMetaEquipes = 0;
						totalVendaMes = 0;
						resultaPercentagem = 0;
						valConsolidadoDiaEqp = 0;
						arrayCanaisGerente = [];
						codGerenteAtual = null;
						return false;
					}
					if ((qtdEquipes) == key) {
						codGerenteAtualEquipe = codGerenteAtual;
						nresultaPercentagem = ((totalVendaMes / totalMetaEquipes) * 100).toFixed(2);
						resultaPercentagem = nresultaPercentagem.toString().substring(0, 5) + '%';
						perc_resultPercentagem = ((totalVendaMes / totalMetaEquipes) * 100);
						perc_resultPercentagemDiferenca = 100 - ((totalVendaMes / totalMetaEquipes) * 100);
						valFatuMesEquipes = 'R$ ' + FormatReal(totalVendaMes.toString());
						npercFatuMesEquipes = ((totalVendaMes / totalMarca) * 100).toFixed(2);
						percFatuMesEquipes = npercFatuMesEquipes.toString().substring(0, 5) + '%';
						valConsolidDiaEqptext = 'R$ ' + FormatReal(valConsolidadoDiaEqp.toString());
						nperConlDiaEqp = ((valConsolidadoDiaEqp / valConsolidadoDia) * 100).toFixed(2);
						if (isNaN(nperConlDiaEqp)) {
							perConlDiaEqp = 0 + '%';
						} else {
							perConlDiaEqp = nperConlDiaEqp.toString().substring(0, 5) + '%';
						}
						for (var i = 0; i < arrayCanaisGerente.length; i++) {
							canais += arrayCanaisGerente[i].NOME_CANAL + ", ";
						}
						$('#IconeGerente').text(nmGerente.substring(0, 1));
						$('#nmGerente').text(nmGerente);
						$('#canalGerente').text(canais);
						$('#resultParcial').fadeOut('slow').text(resultaPercentagem).fadeIn('slow');
						$('#aFaturarMes').text(valFatuMesEquipes);
						$('#perAFaturarMes').text(percFatuMesEquipes);
						$("#aConsolidDiaEqp").text(valConsolidDiaEqptext);
						$("#perConlDiaEqp").text(perConlDiaEqp);
						AtualizacaoGraficoPIE(perc_resultPercentagem, perc_resultPercentagemDiferenca);
						AtualizaCamposGerais();
						canais = "";
						perc_resultPercentagem = 0;
						perc_resultPercentagemDiferenca = 0;
						totalMetaEquipes = 0;
						totalVendaMes = 0;
						resultaPercentagem = 0;
						valConsolidadoDiaEqp = 0;
						arrayCanaisGerente = [];
						arrayCodsGerentes = [];
						codGerenteAtual = null;
						return false;
					};
				};
			}
		})
		$.each(data, function (key, equipe) {
			if (canaisLP.indexOf(equipe.COD_CANAL) > -1) {
				ttMetaGeralEquipes += parseInt(equipe.TT_META_MES.replace('R$ ', '').replace('.', '').replace('.', '').replace('.', '').replace(',', ''));
			}
		});
		perc_ttMetaGeralEquipes = ((totalMarca / ttMetaGeralEquipes) * 100);
		$('#valMetaTT').fadeOut('slow').text('R$ ' + FormatReal(ttMetaGeralEquipes.toString())).fadeIn('slow');
		$('#percResultaVsMetaTT').fadeOut('slow').text(Math.round10(perc_ttMetaGeralEquipes, -1) + "% ").fadeIn('slow');
	})
};
function AtualizacaoGraficoPIE(percIni, percFinal) {
	percIni == 0 ? percIni = 0.10 : percIni;
	percFinal == 0 ? percFinal = 99.80 : percFinal;
	var chartPieParameters = JSON;
	chartPieParameters.type = "pie";
	chartPieParameters.theme = "light";
	chartPieParameters.colors = ["#2d9e05", "#e5e5e1"];
	chartPieParameters.dataProvider = [{
			"value": percIni
		}, {
			"value": percFinal
		}
	];
	chartPieParameters.valueField = "value";
	chartPieParameters.labelRadius = 5;
	chartPieParameters.radius = "42%";
	chartPieParameters.innerRadius = "70%";
	chartPieParameters.labelText = "";
	chartPieParameters.export = {
		"enabled": true
	};
	var chart = AmCharts.makeChart("chartPieDiv", chartPieParameters);
}
function AtualizacaoDatasConsulta() {
	$.getJSON("api/DB_DataHoraServer").done(function (data) {
		$("#periodoConsulta").text(data).fadeIn("slow");
	})
}
function AtualizaDashBoard(stepTime) {
	AtualizaCamposGerais();
	AtualizaResultadoCanaisEquipes();
	var today = new Date();
	var h = today.getHours();
	var m = today.getMinutes();
	var s = today.getSeconds();
	m = CheckTime(m);
	s = CheckTime(s);
	t = setTimeout(function () {
			AtualizaDashBoard()
		}, atualizacaoDash);
}
function addZero(z) {
	if (z < 10) {
		z = "0" + z;
	}
	return z;
}
function agora() {
	var i = 0;
	var weekday = new Array(7);
	weekday[0] = "Domingo";
	weekday[1] = "Segunda";
	weekday[2] = "Terça";
	weekday[3] = "Quarta";
	weekday[4] = "Quinta";
	weekday[5] = "Sexta";
	weekday[6] = "Sabado";
	var year = new Array(12);
	year[0] = "Janeiro";
	year[1] = "Fevereiro";
	year[2] = "Março";
	year[3] = "Abril";
	year[4] = "Maio";
	year[5] = "Junho";
	year[6] = "Julho";
	year[7] = "Agosto";
	year[8] = "Setembro";
	year[9] = "Outubro";
	year[10] = "Novembro";
	year[11] = "Dezembro";
	while (i <= atualizacaoDash) {
		i++;
		var d = new Date();
		if (d.getTimezoneOffset() == 120) {}
		else if (d.getTimezoneOffset() == 180) {}
		else {
			d.setTime(d.getTime() - 3 * 60 * 60 * 1000);
		}
		txt.innerHTML = weekday[d.getDay()] + ', dia ' + d.getDate() + ' de ' + year[d.getMonth()] + ' de ' + d.getUTCFullYear() + ".<br />" + addZero(d.getHours()) + ':' + addZero(d.getMinutes()) + ':' + addZero(d.getSeconds());
	}
	if (i < 1e9) {
		setTimeout(agora, 1000);
	}
}
