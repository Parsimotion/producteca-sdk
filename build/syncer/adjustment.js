(function() {
  var Adjustment, smartParseFloat, smartParseInt, trimIfStr, _,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  _ = require("lodash");

  smartParseFloat = function(str) {
    var decimalPart, integerPart, values;
    if (str == null) {
      return NaN;
    }
    if (_.isNumber(str)) {
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

  smartParseInt = (function(_this) {
    return function(n) {
      if (_.isNumber(n)) {
        return n;
      } else {
        return parseInt(n);
      }
    };
  })(this);

  trimIfStr = (function(_this) {
    return function(str) {
      if (_.isString(str)) {
        return str.trim();
      } else {
        return str;
      }
    };
  })(this);

  module.exports = Adjustment = (function() {
    function Adjustment(dto) {
      this.productData = __bind(this.productData, this);
      this._adaptStock = __bind(this._adaptStock, this);
      this._adaptPrice = __bind(this._adaptPrice, this);
      this.forEachStock = __bind(this.forEachStock, this);
      this.forEachPrice = __bind(this.forEachPrice, this);
      var _ref;
      dto = _.mapValues(dto, function(it) {
        if (_.isArray(it)) {
          return it.map((function(_this) {
            return function(val) {
              return _.mapValues(val, function(inner) {
                return trimIfStr(inner);
              });
            };
          })(this));
        } else {
          return trimIfStr(it);
        }
      });
      _.extend(this, dto);
      if (this.prices != null) {
        this.prices.forEach((function(_this) {
          return function(it) {
            return it.value = _this._adaptPrice(it.value);
          };
        })(this));
      } else {
        this.price = this._adaptPrice(this.price);
      }
      if (this.stocks != null) {
        if ((_ref = this.stocks) != null) {
          _ref.forEach((function(_this) {
            return function(it) {
              return it.quantity = _this._adaptStock(it.quantity);
            };
          })(this));
        }
      } else {
        this.stock = this._adaptStock(this.stock);
      }
    }

    Adjustment.prototype.forEachPrice = function(fn) {
      if (this.prices == null) {
        return [fn(this.price)];
      }
      return this.prices.map((function(_this) {
        return function(_arg) {
          var priceList, value;
          value = _arg.value, priceList = _arg.priceList;
          return fn(value, priceList);
        };
      })(this));
    };

    Adjustment.prototype.forEachStock = function(fn) {
      if (this.stocks == null) {
        return [fn(this.stock)];
      }
      return this.stocks.map((function(_this) {
        return function(_arg) {
          var quantity, warehouse;
          quantity = _arg.quantity, warehouse = _arg.warehouse;
          return fn(quantity, warehouse);
        };
      })(this));
    };

    Adjustment.prototype._adaptPrice = function(price) {
      return smartParseFloat(price);
    };

    Adjustment.prototype._adaptStock = function(stock) {
      return _.max([0, smartParseInt(stock)]);
    };

    Adjustment.prototype.productData = function() {
      return _.omit(_.omit(this, ['price', 'prices', 'stock', 'stocks', 'identifier', 'sku', 'name']), _.isFunction);
    };

    return Adjustment;

  })();

}).call(this);
