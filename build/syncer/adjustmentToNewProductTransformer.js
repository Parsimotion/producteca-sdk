(function() {
  var AdjustmentToNewProductTransformer,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  module.exports = AdjustmentToNewProductTransformer = (function() {
    function AdjustmentToNewProductTransformer(settings) {
      this.settings = settings != null ? settings : {};
      this.transform = __bind(this.transform, this);
    }

    AdjustmentToNewProductTransformer.prototype.transform = function(adjustments) {
      var firstAdjustment, product;
      firstAdjustment = adjustments[0];
      product = firstAdjustment.productData();
      product.description = product.description || firstAdjustment.name;
      product.sku = this.settings.identifier === "sku" ? firstAdjustment.identifier : firstAdjustment.code;
      product.prices = firstAdjustment.forEachPrice((function(_this) {
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
      product.variations = adjustments.map((function(_this) {
        return function(adjustment) {
          var variation;
          variation = {
            pictures: adjustment.pictures,
            stocks: adjustment.forEachStock(function(stock, warehouse) {
              if (warehouse == null) {
                warehouse = _this.settings.warehouse;
              }
              return {
                quantity: stock,
                warehouse: warehouse
              };
            }),
            primaryColor: adjustment.primaryColor,
            secondaryColor: adjustment.secondaryColor,
            size: adjustment.size
          };
          if (_this.settings.identifier === "barcode") {
            variation.barcode = adjustment.identifier;
          }
          return variation;
        };
      })(this));
      return product;
    };

    return AdjustmentToNewProductTransformer;

  })();

}).call(this);
