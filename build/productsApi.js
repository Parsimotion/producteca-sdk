(function() {
  var Product, ProductecaApi, ProductsApi, _,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  ProductecaApi = require("./productecaApi");

  Product = require("./models/product");

  _ = require("lodash");

  module.exports = ProductsApi = (function(_super) {
    __extends(ProductsApi, _super);

    function ProductsApi() {
      this._convert = __bind(this._convert, this);
      this._convertNewToDeprecated = __bind(this._convertNewToDeprecated, this);
      this._convertDeprecatedToNew = __bind(this._convertDeprecatedToNew, this);
      this._convertJsonToProducts = __bind(this._convertJsonToProducts, this);
      this._findOne = __bind(this._findOne, this);
      this._getProductsPageByPage = __bind(this._getProductsPageByPage, this);
      this.updateProduct = __bind(this.updateProduct, this);
      this.updateVariationPictures = __bind(this.updateVariationPictures, this);
      this.updateVariationStocks = __bind(this.updateVariationStocks, this);
      this.createVariations = __bind(this.createVariations, this);
      this.createProduct = __bind(this.createProduct, this);
      this.findProductByVariationSku = __bind(this.findProductByVariationSku, this);
      this.findProductByCode = __bind(this.findProductByCode, this);
      this.getMultipleProducts = __bind(this.getMultipleProducts, this);
      this.getProducts = __bind(this.getProducts, this);
      this.getProduct = __bind(this.getProduct, this);
      return ProductsApi.__super__.constructor.apply(this, arguments);
    }

    ProductsApi.prototype.getProduct = function(id) {
      return (this.respond(this.client.getAsync("/products/" + id))).then((function(_this) {
        return function(json) {
          return new Product(_this._convertDeprecatedToNew(json));
        };
      })(this));
    };

    ProductsApi.prototype.getProducts = function() {
      return this._getProductsPageByPage().then(this._convertJsonToProducts);
    };

    ProductsApi.prototype.getMultipleProducts = function(ids) {
      return this.respond(this.client.getAsync("/products?ids=" + ids)).then(this._convertJsonToProducts);
    };

    ProductsApi.prototype.findProductByCode = function(code) {
      return this._findOne("sku eq '" + code + "'")["catch"]((function(_this) {
        return function() {
          throw new Error("The product with code=" + code + " wasn't found");
        };
      })(this));
    };

    ProductsApi.prototype.findProductByVariationSku = function(sku) {
      return this._findOne("variations/any(variation variation/barcode eq '" + sku + "')")["catch"]((function(_this) {
        return function() {
          throw new Error("The product with sku=" + sku + " wasn't found");
        };
      })(this));
    };

    ProductsApi.prototype.createProduct = function(product) {
      return this.respond(this.client.postAsync("/products", this._convertNewToDeprecated(product)));
    };

    ProductsApi.prototype.createVariations = function(productId, variations) {
      var url;
      url = "/products/" + productId + "/variations";
      variations = (this._convertNewToDeprecated({
        variations: variations
      })).variations;
      return this.respond(this.client.postAsync(url, variations));
    };

    ProductsApi.prototype.updateVariationStocks = function(productId, adjustments) {
      var url;
      url = "/products/" + productId + "/stocks";
      return this.respond(this.client.putAsync(url, adjustments));
    };

    ProductsApi.prototype.updateVariationPictures = function(productId, pictures) {
      var url;
      url = "/products/" + productId + "/pictures";
      return this.respond(this.client.postAsync(url, pictures));
    };

    ProductsApi.prototype.updateProduct = function(id, update) {
      return this.respond(this.client.putAsync("/products/" + id, this._convertNewToDeprecated(update)));
    };

    ProductsApi.prototype._getProductsPageByPage = function(skip) {
      var TOP;
      if (skip == null) {
        skip = 0;
      }
      TOP = 500;
      return this.respond(this.client.getAsync("/products?$top=" + TOP + "&$skip=" + skip)).then((function(_this) {
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

    ProductsApi.prototype._findOne = function(oDataQuery) {
      return (this.respondMany(this.client.getAsync("/products/?$filter=" + (encodeURIComponent(oDataQuery))))).then((function(_this) {
        return function(products) {
          var firstMatch;
          firstMatch = _.first(products);
          return new Product(_this._convertDeprecatedToNew(firstMatch));
        };
      })(this));
    };

    ProductsApi.prototype._convertJsonToProducts = function(products) {
      return products.map(function(it) {
        return new Product(this._convertDeprecatedToNew(it));
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

  })(ProductecaApi);

}).call(this);
