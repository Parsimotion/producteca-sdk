(function() {
  var Product, _,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  _ = require("lodash");

  module.exports = Product = (function() {
    function Product(properties) {
      this.updatePrice = __bind(this.updatePrice, this);
      this.hasAllDimensions = __bind(this.hasAllDimensions, this);
      this.firstVariation = __bind(this.firstVariation, this);
      this.findVariationBySku = __bind(this.findVariationBySku, this);
      this.hasVariations = __bind(this.hasVariations, this);
      _.extend(this, properties);
    }

    Product.prototype.hasVariations = function() {
      return _.size(this.variations) > 1;
    };

    Product.prototype.findVariationBySku = function(sku) {
      return _.find(this.variations, {
        sku: sku
      });
    };

    Product.prototype.firstVariation = function() {
      return _.head(this.variations);
    };

    Product.prototype.hasAllDimensions = function() {
      return ["width", "height", "length", "weight"].every((function(_this) {
        return function(it) {
          return _this.dimensions[it] != null;
        };
      })(this));
    };

    Product.prototype.updatePrice = function(priceList, amount) {
      return this.prices = _(this.prices).reject({
        priceList: priceList
      }).concat({
        priceList: priceList,
        amount: amount
      }).value();
    };

    return Product;

  })();

}).call(this);
