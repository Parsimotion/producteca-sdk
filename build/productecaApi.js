(function() {
  var ProductecaApi, ProductsApi, Promise, Restify, _,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  Promise = require("bluebird");

  Restify = require("restify");

  _ = require("lodash");

  ProductsApi = require("./productsApi");

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
      this.asyncClient = createClient(this._makeUrlAsync(endpoint.url));
      return this.productsApi = new ProductsApi({
        client: this.client,
        asyncClient: this.asyncClient
      });
    };

    function ProductecaApi(endpoint) {
      this.createProduct = __bind(this.createProduct, this);
      this.updateProduct = __bind(this.updateProduct, this);
      this.updatePrice = __bind(this.updatePrice, this);
      this.updateStocks = __bind(this.updateStocks, this);
      this.getMultipleProducts = __bind(this.getMultipleProducts, this);
      this.getProducts = __bind(this.getProducts, this);
      this.getProduct = __bind(this.getProduct, this);
      this._makeUrlAsync = __bind(this._makeUrlAsync, this);
      this._buildSalesOrdersFilters = __bind(this._buildSalesOrdersFilters, this);
      this.returnMany = __bind(this.returnMany, this);
      this["return"] = __bind(this["return"], this);
      this.updateShipmentStatus = __bind(this.updateShipmentStatus, this);
      this.updateShipment = __bind(this.updateShipment, this);
      this.createShipment = __bind(this.createShipment, this);
      this.getShipment = __bind(this.getShipment, this);
      this.updateSalesOrder = __bind(this.updateSalesOrder, this);
      this.getSalesOrderAndFullProducts = __bind(this.getSalesOrderAndFullProducts, this);
      this.getSalesOrder = __bind(this.getSalesOrder, this);
      this.getSalesOrders = __bind(this.getSalesOrders, this);
      this.initializeClients = __bind(this.initializeClients, this);
      this.initializeClients(endpoint);
    }

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

    ProductecaApi.prototype.getSalesOrderAndFullProducts = function(id) {
      return this.getSalesOrder(id).then((function(_this) {
        return function(salesOrder) {
          var productIds;
          productIds = _.map(salesOrder.lines, "product.id").join(",");
          return _this.getMultipleProducts(productIds).then(function(products) {
            return {
              salesOrder: salesOrder,
              products: products
            };
          });
        };
      })(this));
    };

    ProductecaApi.prototype.updateSalesOrder = function(id, update) {
      return this["return"](this.client.putAsync("/salesorders/" + id, update));
    };

    ProductecaApi.prototype.getShipment = function(salesOrderId, shipmentId) {
      return this["return"](this.client.getAsync("/salesorders/" + salesOrderId + "/shipments/" + shipmentId));
    };

    ProductecaApi.prototype.createShipment = function(salesOrderId, shipment) {
      return this["return"](this.client.postAsync("/salesorders/" + salesOrderId + "/shipments", shipment));
    };

    ProductecaApi.prototype.updateShipment = function(salesOrderId, shipmentId, shipmentUpdate) {
      return this["return"](this.client.putAsync("/salesorders/" + salesOrderId + "/shipments/" + shipmentId, shipmentUpdate));
    };

    ProductecaApi.prototype.updateShipmentStatus = function(salesOrderId, shipmentId, statusDto) {
      return this["return"](this.client.putAsync("/salesorders/" + salesOrderId + "/shipments/" + shipmentId + "/status", statusDto));
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

    ProductecaApi.prototype.getProduct = function(id) {
      return this.productsApi.getProduct(id);
    };

    ProductecaApi.prototype.getProducts = function() {
      return this.productsApi.getProducts();
    };

    ProductecaApi.prototype.getMultipleProducts = function(ids) {
      return this.productsApi.getMultipleProducts(ids);
    };

    ProductecaApi.prototype.updateStocks = function(adjustment) {
      return this.productsApi.updateStocks(adjustment);
    };

    ProductecaApi.prototype.updatePrice = function(product, priceList, amount) {
      return this.productsApi.updatePrice(product, priceList, amount);
    };

    ProductecaApi.prototype.updateProduct = function(product) {
      return this.productsApi.updateProductAsync(product);
    };

    ProductecaApi.prototype.createProduct = function(product) {
      return this.productsApi.createProductAsync(product);
    };

    return ProductecaApi;

  })();

}).call(this);
