(function() {
  var Product, ProductecaApi, Promise, Restify, _,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  Promise = require("bluebird");

  Restify = require("restify");

  _ = require("lodash");

  Product = require("./product");

  module.exports = ProductecaApi = (function() {
    ProductecaApi.prototype.initializeClients = function(endpoint) {
      var createClient;
      endpoint.url = endpoint.url || "http://api.producteca.com";
      createClient = (function(_this) {
        return function(url) {
          return Promise.promisifyAll(Restify.createJSONClient({
            url: url,
            agent: false,
            headers: {
              Authorization: "Bearer " + endpoint.accessToken
            }
          }));
        };
      })(this);
      this.client = createClient(endpoint.url);
      return this.asyncClient = createClient(this._makeUrlAsync(endpoint.url));
    };

    function ProductecaApi(endpoint) {
      this._makeUrlAsync = __bind(this._makeUrlAsync, this);
      this._buildSalesOrdersFilters = __bind(this._buildSalesOrdersFilters, this);
      this.returnMany = __bind(this.returnMany, this);
      this["return"] = __bind(this["return"], this);
      this.createShipment = __bind(this.createShipment, this);
      this.updatePrice = __bind(this.updatePrice, this);
      this.updateStocks = __bind(this.updateStocks, this);
      this.updateSalesOrder = __bind(this.updateSalesOrder, this);
      this.getSalesOrder = __bind(this.getSalesOrder, this);
      this.getSalesOrders = __bind(this.getSalesOrders, this);
      this._createProducts = __bind(this._createProducts, this);
      this.getMultipleProducts = __bind(this.getMultipleProducts, this);
      this.getProducts = __bind(this.getProducts, this);
      this.getProduct = __bind(this.getProduct, this);
      this.initializeClients = __bind(this.initializeClients, this);
      this.initializeClients(endpoint);
    }

    ProductecaApi.prototype.getProduct = function(id) {
      return this["return"](this.client.getAsync("/products/" + id));
    };

    ProductecaApi.prototype.getProducts = function() {
      return this.returnMany(this.client.getAsync("/products")).then((function(_this) {
        return function(products) {
          return _this._createProducts(products);
        };
      })(this));
    };

    ProductecaApi.prototype.getMultipleProducts = function(ids) {
      return this["return"](this.client.getAsync("/products?ids=" + ids)).then((function(_this) {
        return function(products) {
          return _this._createProducts(products);
        };
      })(this));
    };

    ProductecaApi.prototype._createProducts = function(products) {
      return products.map(function(it) {
        return new Product(it);
      });
    };

    ProductecaApi.prototype.getSalesOrders = function(filters) {
      var querystring;
      if (filters == null) {
        filters = {};
      }
      querystring = this._buildSalesOrdersFilters(filters);
      return this.returnMany(this.client.getAsync("/salesorders" + querystring));
    };

    ProductecaApi.prototype.getSalesOrder = function(id) {
      return this["return"](this.client.getAsync("/salesorders/" + id));
    };

    ProductecaApi.prototype.updateSalesOrder = function(id, update) {
      return this["return"](this.client.putAsync("/salesorders/" + id, update));
    };

    ProductecaApi.prototype.updateStocks = function(adjustment) {
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

    ProductecaApi.prototype.updatePrice = function(product, priceList, amount) {
      var body, url;
      body = {
        prices: _(product.prices).reject({
          priceList: priceList
        }).concat({
          priceList: priceList,
          amount: amount
        }).value()
      };
      url = "/products/" + product.id;
      return this["return"](this.asyncClient.putAsync(url, body));
    };

    ProductecaApi.prototype.createShipment = function(salesOrderId, shipment) {
      return this["return"](this.client.postAsync("/salesorders/" + salesOrderId + "/shipments", shipment));
    };

    ProductecaApi.prototype["return"] = function(promise) {
      return promise.spread(function(req, res, obj) {
        return obj;
      });
    };

    ProductecaApi.prototype.returnMany = function(promise) {
      return promise.spread(function(req, res, obj) {
        return obj.results;
      });
    };

    ProductecaApi.prototype._buildSalesOrdersFilters = function(filters) {
      var addAnd, brandsFilter, querystring;
      querystring = "?$filter=(IsOpen%20eq%20true)%20and%20(IsCanceled%20eq%20false)";
      addAnd = (function(_this) {
        return function(condition) {
          return querystring += "%20and%20(" + condition + ")";
        };
      })(this);
      brandsFilter = (function(_this) {
        return function(brandIds) {
          return brandIds.map(function(id) {
            return "(Lines%2Fany(line%3Aline%2FVariation%2FDefinition%2FBrand%2FId%20eq%20" + id + "))";
          }).join("%20or%20");
        };
      })(this);
      if (filters.paid != null) {
        addAnd("PaymentStatus%20eq%20%27Approved%27");
      }
      if (filters.brands != null) {
        addAnd(brandsFilter(filters.brands));
      }
      if (filters.other != null) {
        addAnd(filters.other);
      }
      return querystring;
    };

    ProductecaApi.prototype._makeUrlAsync = function(url) {
      var parts;
      parts = url.split(".");
      parts[0] += "-async";
      return parts.join(".");
    };

    return ProductecaApi;

  })();

}).call(this);
