(function() {
  var Product, _,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  _ = require("lodash");

  module.exports = Product = (function() {
    function Product(properties) {
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

    return Product;

  })();

}).call(this);
