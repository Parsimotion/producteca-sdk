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
      this._convertJsonToProduct = __bind(this._convertJsonToProduct, this);
      this._convertJsonToProducts = __bind(this._convertJsonToProducts, this);
      this._findOne = __bind(this._findOne, this);
      this._getProductsPageByPage = __bind(this._getProductsPageByPage, this);
      this.update = __bind(this.update, this);
      this.updateVariationPictures = __bind(this.updateVariationPictures, this);
      this.updateVariationStocks = __bind(this.updateVariationStocks, this);
      this.createVariations = __bind(this.createVariations, this);
      this.create = __bind(this.create, this);
      this.findByVariationSku = __bind(this.findByVariationSku, this);
      this.findByCode = __bind(this.findByCode, this);
      this.getMany = __bind(this.getMany, this);
      this.getAll = __bind(this.getAll, this);
      this.get = __bind(this.get, this);
      return ProductsApi.__super__.constructor.apply(this, arguments);
    }

    ProductsApi.prototype.get = function(id) {
      return (this.respond(this.client.getAsync("/products/" + id))).then(this._convertJsonToProduct);
    };

    ProductsApi.prototype.getAll = function() {
      return this._getProductsPageByPage().then(this._convertJsonToProducts);
    };

    ProductsApi.prototype.getMany = function(ids) {
      return (this.respond(this.client.getAsync("/products?ids=" + ids))).then(this._convertJsonToProducts);
    };

    ProductsApi.prototype.findByCode = function(code, $select) {
      return this._findOne("sku eq '" + code + "'", $select)["catch"]((function(_this) {
        return function() {
          throw new Error("The product with code=" + code + " wasn't found");
        };
      })(this));
    };

    ProductsApi.prototype.findByVariationSku = function(sku) {
      return (this.respond(this.client.getAsync("/products/bysku/" + sku))).then(this._convertJsonToProducts);
    };

    ProductsApi.prototype.create = function(product) {
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

    ProductsApi.prototype.update = function(id, update) {
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

    ProductsApi.prototype._findOne = function($filter, $select) {
      var query;
      if ($select == null) {
        $select = "";
      }
      query = "?$filter=" + (encodeURIComponent($filter));
      if ($select !== "") {
        query += "&$select=" + (encodeURIComponent($select));
      }
      return (this.respondMany(this.client.getAsync("/products/" + query))).then((function(_this) {
        return function(products) {
          var firstMatch;
          if (_.isEmpty(products)) {
            throw new Error("product not found");
          }
          firstMatch = _.first(products);
          return _this._convertJsonToProduct(firstMatch);
        };
      })(this));
    };

    ProductsApi.prototype._convertJsonToProducts = function(products) {
      return products.map(this._convertJsonToProduct);
    };

    ProductsApi.prototype._convertJsonToProduct = function(json) {
      return new Product(this._convertDeprecatedToNew(json));
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
