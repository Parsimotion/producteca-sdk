(function() {
  var AdjustmentToNewProductTransformer,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  module.exports = AdjustmentToNewProductTransformer = (function() {
    function AdjustmentToNewProductTransformer(settings) {
      this.settings = settings != null ? settings : {};
      this.transform = __bind(this.transform, this);
    }

    AdjustmentToNewProductTransformer.prototype.transform = function(adjustment) {
      var product, variation;
      product = adjustment.productData();
      product.description = adjustment.name;
      if (this.settings.identifier === "sku") {
        product.sku = adjustment.identifier;
      }
      product.prices = adjustment.forEachPrice((function(_this) {
        return function(value, priceList) {
          if (priceList == null) {
            priceList = _this.settings.priceList;
          }
          return {
            priceList: priceList,
            amount: value || 0
          };
        };
      })(this));
      variation = {
        stocks: adjustment.forEachStock((function(_this) {
          return function(stock, warehouse) {
            if (warehouse == null) {
              warehouse = _this.settings.warehouse;
            }
            return {
              quantity: stock,
              warehouse: warehouse
            };
          };
        })(this))
      };
      if (this.settings.identifier === "barcode") {
        variation.barcode = adjustment.identifier;
      }
      product.variations = [variation];
      return product;
    };

    return AdjustmentToNewProductTransformer;

  })();

}).call(this);
