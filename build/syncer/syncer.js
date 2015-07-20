(function() {
  var Q, Syncer, _,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  Q = require("q");

  _ = require("lodash");

  module.exports = Syncer = (function() {
    function Syncer(productecaApi, settings, products) {
      this.productecaApi = productecaApi;
      this.settings = settings;
      this.products = products;
      this._getProductsForAdjustments = __bind(this._getProductsForAdjustments, this);
      this._getVariation = __bind(this._getVariation, this);
      this._getStock = __bind(this._getStock, this);
      this._updateStock = __bind(this._updateStock, this);
      this._updatePrice = __bind(this._updatePrice, this);
      this._updateStocksAndPrices = __bind(this._updateStocksAndPrices, this);
      this._joinAdjustmentsAndProducts = __bind(this._joinAdjustmentsAndProducts, this);
      this.execute = __bind(this.execute, this);
    }

    Syncer.prototype.execute = function(adjustments) {
      var adjustmentsAndProducts;
      adjustmentsAndProducts = this._joinAdjustmentsAndProducts(adjustments);
      return (Q.allSettled(this._updateStocksAndPrices(adjustmentsAndProducts))).then((function(_this) {
        return function(results) {
          return _.mapValues(adjustmentsAndProducts, function(adjustmentsAndProducts) {
            return adjustmentsAndProducts.map(function(it) {
              return _.pick(it.adjustment, "identifier");
            });
          });
        };
      })(this));
    };

    Syncer.prototype._joinAdjustmentsAndProducts = function(adjustments) {
      var hasProducts, join;
      join = _(adjustments).filter("identifier").groupBy("identifier").map((function(_this) {
        return function(adjustments) {
          var adjustment;
          adjustment = _.head(adjustments);
          return {
            adjustment: adjustment,
            products: _this._getProductsForAdjustments(adjustment)
          };
        };
      })(this)).value();
      hasProducts = (function(_this) {
        return function(it) {
          return !_.isEmpty(it.products);
        };
      })(this);
      return {
        linked: _.filter(join, hasProducts),
        unlinked: _.reject(join, hasProducts)
      };
    };

    Syncer.prototype._updateStocksAndPrices = function(adjustmentsAndProducts) {
      var syncPrices, syncStocks;
      syncPrices = this.settings.synchro.prices;
      syncStocks = this.settings.synchro.stocks;
      return adjustmentsAndProducts.linked.map((function(_this) {
        return function(it) {
          var products, updateIf;
          products = it.products;
          updateIf = function(condition, update) {
            if (condition) {
              return products.map(update);
            } else {
              return [];
            }
          };
          return Q.all(_.flatten([
            updateIf(syncPrices, function(p) {
              return _this._updatePrice(it.adjustment, p);
            }), updateIf(syncStocks, function(p) {
              return _this._updateStock(it.adjustment, p);
            })
          ])).then(function() {
            return {
              ids: _.map(products, "id"),
              identifier: it.adjustment.identifier
            };
          });
        };
      })(this));
    };

    Syncer.prototype._updatePrice = function(adjustment, product) {
      return adjustment.forEachPrice((function(_this) {
        return function(price, priceList) {
          if (priceList == null) {
            priceList = _this.settings.priceList;
          }
          console.log("Updating price of ~" + adjustment.identifier + "(" + product.id + ") in priceList " + priceList + " with value $" + price + "...");
          return _this.productecaApi.updatePrice(product, priceList, price);
        };
      })(this));
    };

    Syncer.prototype._updateStock = function(adjustment, product) {
      var variationId;
      variationId = this._getVariation(product, adjustment).id;
      return adjustment.forEachStock((function(_this) {
        return function(stock, warehouse) {
          if (warehouse == null) {
            warehouse = _this.settings.warehouse;
          }
          console.log("Updating stock of ~" + adjustment.identifier + "(" + product.id + ", " + variationId + ") in warehouse " + warehouse + " with quantity " + stock + "...");
          return _this.productecaApi.updateStocks({
            id: product.id,
            warehouse: warehouse,
            stocks: [
              {
                variation: variationId,
                quantity: stock
              }
            ]
          });
        };
      })(this));
    };

    Syncer.prototype._getStock = function(product) {
      var stock;
      stock = _.find((this._getVariation(product)).stocks, {
        warehouse: this.settings.warehouse
      });
      if (stock != null) {
        return stock.quantity;
      } else {
        return 0;
      }
    };

    Syncer.prototype._getVariation = function(product, adjustment) {
      return product.getVariationForAdjustment(adjustment) || product.firstVariation();
    };

    Syncer.prototype._getProductsForAdjustments = function(adjustment) {
      var findBySku, matches;
      findBySku = (function(_this) {
        return function() {
          return _.filter(_this.products, {
            sku: adjustment.identifier
          });
        };
      })(this);
      if (this.settings.identifier === "sku") {
        return findBySku();
      }
      matches = _(this.products).filter((function(_this) {
        return function(it) {
          return it.getVariationForAdjustment(adjustment) != null;
        };
      })(this)).value();
      if (_.isEmpty(matches)) {
        return findBySku();
      } else {
        return matches;
      }
    };

    return Syncer;

  })();

}).call(this);
