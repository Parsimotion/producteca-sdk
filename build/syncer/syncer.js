(function() {
  var AdjustmentToNewProductTransformer, Q, Syncer, _,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  Q = require("q");

  _ = require("lodash");

  AdjustmentToNewProductTransformer = require("./adjustmentToNewProductTransformer");

  module.exports = Syncer = (function() {
    function Syncer(productecaApi, settings, products) {
      this.productecaApi = productecaApi;
      this.settings = settings;
      this.products = products;
      this._createProducts = __bind(this._createProducts, this);
      this._shouldSyncProductData = __bind(this._shouldSyncProductData, this);
      this._getProductsForAdjustments = __bind(this._getProductsForAdjustments, this);
      this._getVariation = __bind(this._getVariation, this);
      this._getStock = __bind(this._getStock, this);
      this._updateStock = __bind(this._updateStock, this);
      this._updateProduct = __bind(this._updateProduct, this);
      this._sync = __bind(this._sync, this);
      this._joinAdjustmentsAndProducts = __bind(this._joinAdjustmentsAndProducts, this);
      this.execute = __bind(this.execute, this);
    }

    Syncer.prototype.execute = function(adjustments) {
      var adjustmentsAndProducts, promises;
      adjustmentsAndProducts = this._joinAdjustmentsAndProducts(adjustments);
      promises = this._sync(adjustmentsAndProducts);
      if (this.settings.createProducts) {
        promises = promises.concat(this._createProducts(adjustmentsAndProducts.unlinked));
      }
      return (Q.allSettled(promises)).then((function(_this) {
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

    Syncer.prototype._sync = function(adjustmentsAndProducts) {
      var syncProducts, syncStocks;
      syncProducts = this._shouldSyncProductData();
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
            updateIf(syncProducts, function(p) {
              return _this._updateProduct(it.adjustment, p);
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

    Syncer.prototype._updateProduct = function(adjustment, product) {
      if (this.settings.synchro.prices) {
        adjustment.forEachPrice((function(_this) {
          return function(price, priceList) {
            if (priceList == null) {
              priceList = _this.settings.priceList;
            }
            console.log("Updating price of ~" + adjustment.identifier + "(" + product.id + ") in priceList " + priceList + " with value $" + price + "...");
            return product.updatePrice(priceList, price);
          };
        })(this));
      }
      if (this.settings.synchro.data) {
        product.updateWith(adjustment.productData());
      }
      return this.productecaApi.updateProduct(product);
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

    Syncer.prototype._shouldSyncProductData = function() {
      return this.settings.synchro.prices || this.settings.synchro.data;
    };

    Syncer.prototype._createProducts = function(unlinkeds) {
      var adjustments, groupedAdjustmentsObj, noCodeAdjustments, transformer, withCodeAdjustments, _ref;
      transformer = new AdjustmentToNewProductTransformer(this.settings);
      adjustments = unlinkeds.map(function(it) {
        return it.adjustment;
      });
      groupedAdjustmentsObj = _.groupBy(adjustments, 'code');
      noCodeAdjustments = (_ref = groupedAdjustmentsObj[void 0]) != null ? _ref.map(function(it) {
        return [it];
      }) : void 0;
      withCodeAdjustments = _.values(_.omit(groupedAdjustmentsObj, function(it) {
        return it === void 0;
      }));
      return withCodeAdjustments.concat(noCodeAdjustments || []).map((function(_this) {
        return function(adjustments) {
          return _this.productecaApi.createProduct(transformer.transform(adjustments));
        };
      })(this));
    };

    return Syncer;

  })();

}).call(this);
