(function() {
  var Product, ProductsApi, _,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  Product = require("./product");

  _ = require("lodash");

  module.exports = ProductsApi = (function() {
    function ProductsApi(_arg) {
      this.client = _arg.client, this.asyncClient = _arg.asyncClient;
      this._convert = __bind(this._convert, this);
      this._convertNewToDeprecated = __bind(this._convertNewToDeprecated, this);
      this._convertDeprecatedToNew = __bind(this._convertDeprecatedToNew, this);
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
      this.createVariations = __bind(this.createVariations, this);
      this.createProduct = __bind(this.createProduct, this);
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
          return new Product(firstMatch);
        };
      })(this))["catch"]((function(_this) {
        return function() {
          throw new Error("The product with code=" + code + " wasn't found");
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

    ProductsApi.prototype.createProduct = function(product) {
      return this["return"](this.client.postAsync("/products", this._convertNewToDeprecated(product)));
    };

    ProductsApi.prototype.createVariations = function(productId, variations) {
      var url;
      url = "/products/" + productId + "/variations";
      variations = (this._convertNewToDeprecated({
        variations: variations
      })).variations;
      return this["return"](this.client.postAsync(url, variations));
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
      return this["return"](this.client.putAsync("/products/" + id, this._convertNewToDeprecated(update)));
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

    ProductsApi.prototype._convertDeprecatedToNew = function(product) {
      var _ref;
      if (product == null) {
        return;
      }
      product = _.cloneDeep(product);
      this._convert(product, "sku", "code");
      this._convert(product, "description", "name");
      if ((_ref = product.variations) != null) {
        _ref.forEach((function(_this) {
          return function(variation) {
            return _this._convert(variation, "barcode", "sku");
          };
        })(this));
      }
      return product;
    };

    ProductsApi.prototype._convertNewToDeprecated = function(product) {
      var _ref;
      if (product == null) {
        return;
      }
      product = _.cloneDeep(product);
      this._convert(product, "code", "sku");
      this._convert(product, "name", "description");
      if ((_ref = product.variations) != null) {
        _ref.forEach((function(_this) {
          return function(variation) {
            return _this._convert(variation, "sku", "barcode");
          };
        })(this));
      }
      return product;
    };

    ProductsApi.prototype._convert = function(obj, oldProperty, newProperty) {
      if ((obj[newProperty] == null) && obj[oldProperty]) {
        obj[newProperty] = obj[oldProperty];
        return delete obj[oldProperty];
      }
    };

    return ProductsApi;

  })();

}).call(this);
