(function() {
  var Product, _,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  _ = require("lodash");

  module.exports = Product = (function() {
    function Product(properties) {
      this.updateWith = __bind(this.updateWith, this);
      this.toJSON = __bind(this.toJSON, this);
      this.updatePrice = __bind(this.updatePrice, this);
      this.firstVariation = __bind(this.firstVariation, this);
      this.getVariationForAdjustment = __bind(this.getVariationForAdjustment, this);
      this.hasVariantes = __bind(this.hasVariantes, this);
      _.extend(this, properties);
    }

    Product.prototype.hasVariantes = function() {
      return _.size(this.variations > 1);
    };

    Product.prototype.getVariationForAdjustment = function(adjustment) {
      return _.find(this.variations, (function(_this) {
        return function(it) {
          return it.barcode === adjustment.identifier;
        };
      })(this));
    };

    Product.prototype.firstVariation = function() {
      return _.head(this.variations);
    };

    Product.prototype.updatePrice = function(priceList, amount) {
      return this.prices = _(this.prices).reject({
        priceList: priceList
      }).concat({
        priceList: priceList,
        amount: amount
      }).value();
    };

    Product.prototype.toJSON = function() {
      return _.omit(this, _.isFunction);
    };

    Product.prototype.updateWith = function(obj) {
      return _.assign(this, obj);
    };

    return Product;

  })();

}).call(this);
