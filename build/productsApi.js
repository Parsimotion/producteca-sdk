(function() {
  var Product, ProductsApi, _,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  Product = require("./product");

  _ = require("lodash");

  module.exports = ProductsApi = (function() {
    function ProductsApi(_arg) {
      this.client = _arg.client, this.asyncClient = _arg.asyncClient;
      this._mapDeprecatedProperties = __bind(this._mapDeprecatedProperties, this);
      this._createProducts = __bind(this._createProducts, this);
      this._getProductsPageByPage = __bind(this._getProductsPageByPage, this);
      this.returnMany = __bind(this.returnMany, this);
      this["return"] = __bind(this["return"], this);
      this.createProductAsync = __bind(this.createProductAsync, this);
      this.updateProductAsync = __bind(this.updateProductAsync, this);
      this.updateProduct = __bind(this.updateProduct, this);
      this.updatePrice = __bind(this.updatePrice, this);
      this.updateStocks = __bind(this.updateStocks, this);
      this.updateVariationPictures = __bind(this.updateVariationPictures, this);
      this.updateVariationStocks = __bind(this.updateVariationStocks, this);
      this.getMultipleProducts = __bind(this.getMultipleProducts, this);
      this.findProductByCode = __bind(this.findProductByCode, this);
      this.getProducts = __bind(this.getProducts, this);
      this.getProduct = __bind(this.getProduct, this);
    }

    ProductsApi.prototype.getProduct = function(id) {
      return this["return"](this.client.getAsync("/products/" + id));
    };

    ProductsApi.prototype.getProducts = function() {
      return this._getProductsPageByPage().then((function(_this) {
        return function(products) {
          return _this._createProducts(products);
        };
      })(this));
    };

    ProductsApi.prototype.findProductByCode = function(code) {
      var oDataQuery;
      oDataQuery = encodeURIComponent("sku eq '" + code + "'");
      return (this.returnMany(this.client.getAsync("/products/?$filter=" + oDataQuery))).then((function(_this) {
        return function(products) {
          var firstMatch;
          firstMatch = _.first(products);
          return new Product(_this._mapDeprecatedProperties(firstMatch));
        };
      })(this))["catch"]((function(_this) {
        return function() {
          throw "not found";
        };
      })(this));
    };

    ProductsApi.prototype.getMultipleProducts = function(ids) {
      return this["return"](this.client.getAsync("/products?ids=" + ids)).then((function(_this) {
        return function(products) {
          return _this._createProducts(products);
        };
      })(this));
    };

    ProductsApi.prototype.updateVariationStocks = function(productId, adjustments) {
      var url;
      url = "/products/" + productId + "/stocks";
      return this["return"](this.client.putAsync(url, adjustments));
    };

    ProductsApi.prototype.updateVariationPictures = function(productId, pictures) {
      var url;
      url = "/products/" + productId + "/pictures";
      return this["return"](this.client.postAsync(url, pictures));
    };

    ProductsApi.prototype.updateStocks = function(adjustment) {
      var body, url;
      body = _.map(adjustment.stocks, function(it) {
        return {
          variation: it.variation,
          stocks: [
            {
              warehouse: adjustment.warehouse,
              quantity: it.quantity
            }
          ]
        };
      });
      url = "/products/" + adjustment.id + "/stocks";
      return this["return"](this.asyncClient.putAsync(url, body));
    };

    ProductsApi.prototype.updatePrice = function(product, priceList, amount) {
      product.updatePrice(priceList, amount);
      return this.updateProductAsync(product);
    };

    ProductsApi.prototype.updateProduct = function(id, update) {
      return this["return"](this.client.putAsync("/products/" + id, update));
    };

    ProductsApi.prototype.updateProductAsync = function(product) {
      var url;
      url = "/products/" + product.id;
      return this["return"](this.asyncClient.putAsync(url, _.omit(product.toJSON(), ["variations"])));
    };

    ProductsApi.prototype.createProductAsync = function(product) {
      var url;
      url = "/products";
      return this["return"](this.asyncClient.postAsync(url, product));
    };

    ProductsApi.prototype["return"] = function(promise) {
      return promise.spread(function(req, res, obj) {
        return obj;
      });
    };

    ProductsApi.prototype.returnMany = function(promise) {
      return promise.spread(function(req, res, obj) {
        return obj.results;
      });
    };

    ProductsApi.prototype._getProductsPageByPage = function(skip) {
      var TOP;
      if (skip == null) {
        skip = 0;
      }
      TOP = 500;
      return this["return"](this.client.getAsync("/products?$top=" + TOP + "&$skip=" + skip)).then((function(_this) {
        return function(obj) {
          var products;
          products = obj.results;
          if (products.length < TOP) {
            return products;
          }
          return _this._getProductsPageByPage(skip + TOP).then(function(moreProducts) {
            return products.concat(moreProducts);
          });
        };
      })(this));
    };

    ProductsApi.prototype._createProducts = function(products) {
      return products.map(function(it) {
        return new Product(it);
      });
    };

    ProductsApi.prototype._mapDeprecatedProperties = function(product) {
      if (product == null) {
        return;
      }
      if (product.code == null) {
        product.code = firstMatch.sku;
        delete firstMatch.sku;
      }
      if (product.name == null) {
        product.name = firstMatch.description;
        delete firstMatch.description;
      }
      product.variations.forEach(function(variation) {
        if (variation.sku == null) {
          variation.sku = variation.barcode;
          return delete variation.barcode;
        }
      });
      return product;
    };

    return ProductsApi;

  })();

}).call(this);
