
/* ================================================================================================
// Func.: FormatReal
// Desc.: Formata moeda, padrão real.
// Param.: i > inteiro
// Return: string
* ================================================================================================= */
function FormatReal(moneyBrInt) {

    var tmp = moneyBrInt + '', tmpLenght;

    if (tmp.indexOf('-') != -1) {
        tmpLenght = tmp.length - 1;
    } else {
        tmpLenght = tmp.length;
    }

    if (tmpLenght == 1) {
        tmp = tmp.replace(/([0-9]{0})$/g, "$1,00");
    } else if (tmpLenght == 2) {
        tmp = tmp.replace(/([0-9]{2})$/g, "0,$1");
    } else if (tmpLenght > 2 && tmpLenght <= 5) {
        tmp = tmp.replace(/([0-9]{2})$/g, ",$1");
    } else if (tmpLenght >= 6) {
        tmp = tmp.replace(/([0-9]{2})$/g, ",$1");
        tmp = tmp.replace(/([0-9]{3}),([0-9]{2}$)/g, ".$1,$2");
    }

    if (tmp.indexOf("-") != 0) {
        if (tmp.length > 10) {
            tmpSplit = tmp.split('.');
            tt = tmpSplit[0].length;
            dif = tmpSplit[0].length - 3;
            tmp = tmpSplit[0].substr(0, dif) + "." + tmpSplit[0].substr(dif, tt) + "." + tmpSplit[1]
        }
    }

    return tmp;
}


/* ================================================================================================
// Func.: FormatRealOrInt
// Desc.: Formata moeda para Inteiro
// Param.: valor > string
// Return: int
* ================================================================================================= */
function FormatRealOrInt(valor) {

    valor = parseInt(valor.replace('R$ ', '').replace('.', '').replace('.', '').replace('.', '').replace(',', ''));

    return valor;
}


/* ================================================================================================
// Func.: CheckTime
// Desc.: Método atualiza hora/minutos/segundos.
// Param.: i > inteiro
// Return: inteiro
* ================================================================================================= */
function CheckTime(valor) {
    if (valor < 10) {
        valor = "0" + valor;
    }
    return valor;
}

/* ================================================================================================
// Func.: ProcurarIndiceArray
// Desc.: Método consulta o indice de um objeto no array caso exista.
// Param.: arraySearch > array
// Param.: atributo > string
// Param.: valor > string
// Return: array
* ================================================================================================= */
function ProcurarIndiceArray(arraySearch, atributo, valor) {
    var cont = 0;
    var indices = [];
    for (var i in arraySearch) {
        var row = arraySearch[i];
        if (row[atributo] == valor) {
            indices.push(cont)
        }
        cont++;
    }
    return indices;
}

/* ================================================================================================
// Func.: round10
// Desc.: Método arredonda valor com 2 casas decimal.
// Param.: valor > decimal
// Param.: casas decimais > number
* ================================================================================================= */
// Closure
(function () {
    /**
     * Decimal adjustment of a number.
     *
     * @param {String}  type  The type of adjustment.
     * @param {Number}  value The number.
     * @param {Integer} exp   The exponent (the 10 logarithm of the adjustment base).
     * @returns {Number} The adjusted value.
     */
    function decimalAdjust(type, value, exp) {
        // If the exp is undefined or zero...
        if (typeof exp === 'undefined' || +exp === 0) {
            return Math[type](value);
        }
        value = +value;
        exp = +exp;
        // If the value is not a number or the exp is not an integer...
        if (isNaN(value) || !(typeof exp === 'number' && exp % 1 === 0)) {
            return NaN;
        }
        // Shift
        value = value.toString().split('e');
        value = Math[type](+(value[0] + 'e' + (value[1] ? (+value[1] - exp) : -exp)));
        // Shift back
        value = value.toString().split('e');
        return +(value[0] + 'e' + (value[1] ? (+value[1] + exp) : exp));
    }

    // Decimal round
    if (!Math.round10) {
        Math.round10 = function (value, exp) {
            return decimalAdjust('round', value, exp);
        };
    }
    // Decimal floor
    if (!Math.floor10) {
        Math.floor10 = function (value, exp) {
            return decimalAdjust('floor', value, exp);
        };
    }
    // Decimal ceil
    if (!Math.ceil10) {
        Math.ceil10 = function (value, exp) {
            return decimalAdjust('ceil', value, exp);
        };
    }
})();