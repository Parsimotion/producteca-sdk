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
      this._convertJsonToProduct = __bind(this._convertJsonToProduct, this);
      this._convertJsonToProducts = __bind(this._convertJsonToProducts, this);
      this._findMany = __bind(this._findMany, this);
      this._getProductsPageByPage = __bind(this._getProductsPageByPage, this);
      this.getSkus = __bind(this.getSkus, this);
      this.getBatch = __bind(this.getBatch, this);
      this.getWarehouses = __bind(this.getWarehouses, this);
      this.getPricelists = __bind(this.getPricelists, this);
      this.createWarehouse = __bind(this.createWarehouse, this);
      this.update = __bind(this.update, this);
      this.updateVariationPictures = __bind(this.updateVariationPictures, this);
      this.addVariationPictures = __bind(this.addVariationPictures, this);
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
      return (this.client.getAsync("/products/" + id)).then(this._convertJsonToProduct);
    };

    ProductsApi.prototype.getAll = function() {
      return this._getProductsPageByPage().then(this._convertJsonToProducts);
    };

    ProductsApi.prototype.getMany = function(ids) {
      return (this.client.getAsync("/products?ids=" + ids)).then(this._convertJsonToProducts);
    };

    ProductsApi.prototype.findByCode = function(code, $select) {
      return this._findMany("code eq '" + code + "'", $select);
    };

    ProductsApi.prototype.findByVariationSku = function(sku) {
      return (this.client.getAsync("/products/bysku?sku=" + (encodeURIComponent(sku)))).then(this._convertJsonToProducts);
    };

    ProductsApi.prototype.create = function(product) {
      return this.client.postAsync("/products", product);
    };

    ProductsApi.prototype.createVariations = function(productId, variations) {
      var url;
      url = "/products/" + productId + "/variations";
      return this.client.postAsync(url, variations);
    };

    ProductsApi.prototype.updateVariationStocks = function(productId, adjustments) {
      var url;
      url = "/products/" + productId + "/stocks";
      return this.client.putAsync(url, adjustments);
    };

    ProductsApi.prototype.addVariationPictures = function(productId, pictures) {
      var url;
      url = "/products/" + productId + "/pictures";
      return this.client.postAsync(url, pictures);
    };

    ProductsApi.prototype.updateVariationPictures = function(productId, pictures) {
      var url;
      url = "/products/" + productId + "/pictures";
      return this.client.putAsync(url, pictures);
    };

    ProductsApi.prototype.update = function(id, update) {
      return this.client.putAsync("/products/" + id, update);
    };

    ProductsApi.prototype.createWarehouse = function(name) {
      return this.client.postAsync("/warehouses", {
        name: name
      });
    };

    ProductsApi.prototype.getPricelists = function() {
      return this.client.getAsync("/pricelists");
    };

    ProductsApi.prototype.getWarehouses = function() {
      return this.client.getAsync("/warehouses");
    };

    ProductsApi.prototype.getBatch = function(skip, top, moreQueryString) {
      if (skip == null) {
        skip = 0;
      }
      if (top == null) {
        top = 20;
      }
      if (moreQueryString == null) {
        moreQueryString = "";
      }
      return this.respondMany(this.client.getAsync("/products?$top=" + top + "&$skip=" + skip + "&" + moreQueryString));
    };

    ProductsApi.prototype.getSkus = function(skip, top, moreQueryString) {
      if (skip == null) {
        skip = 0;
      }
      if (top == null) {
        top = 20;
      }
      if (moreQueryString == null) {
        moreQueryString = "";
      }
      return this.respondMany(this.client.getAsync("/products/skus?$top=" + top + "&$skip=" + skip + "&" + moreQueryString));
    };

    ProductsApi.prototype._getProductsPageByPage = function(skip) {
      var TOP;
      if (skip == null) {
        skip = 0;
      }
      TOP = 500;
      return this.getBatch(skip, TOP).then((function(_this) {
        return function(products) {
          if (products.length < TOP) {
            return products;
          }
          return _this._getProductsPageByPage(skip + TOP).then(function(moreProducts) {
            return products.concat(moreProducts);
          });
        };
      })(this));
    };

    ProductsApi.prototype._findMany = function($filter, $select) {
      var query;
      if ($select == null) {
        $select = "";
      }
      query = "?$filter=" + (encodeURIComponent($filter));
      if ($select !== "") {
        query += "&$select=" + (encodeURIComponent($select));
      }
      return (this.respondMany(this.client.getAsync("/products/" + query))).then(this._convertJsonToProducts);
    };

    ProductsApi.prototype._convertJsonToProducts = function(products) {
      return products.map(this._convertJsonToProduct);
    };

    ProductsApi.prototype._convertJsonToProduct = function(json) {
      return new Product(json);
    };

    return ProductsApi;

  })(ProductecaApi);

}).call(this);
