(function() {
  var Adjustment, smartParseFloat, _;

  _ = require("lodash");

  smartParseFloat = function(str) {
    var decimalPart, integerPart, values;
    if (str == null) {
      return NaN;
    }
    if (typeof str === 'number') {
      return str;
    }
    values = str.split(/\.|,/);
    if (values.length === 1) {
      return Number(str);
    }
    integerPart = (_.initial(values)).join("");
    decimalPart = _.last(values);
    return Number(integerPart + "." + decimalPart);
  };

  module.exports = Adjustment = (function() {
    function Adjustment(dto) {
      dto = _.mapValues(dto, function(it) {
        if (it != null) {
          return it.trim();
        } else {
          return it;
        }
      });
      _.extend(this, dto);
      this.price = smartParseFloat(dto.price);
      this.stock = _.max([0, parseInt(dto.stock)]);
    }

    return Adjustment;

  })();

}).call(this);
