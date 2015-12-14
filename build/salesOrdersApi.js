(function() {
  var ProductecaApi, ProductsApi, SalesOrdersApi, _,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  ProductecaApi = require("./productecaApi");

  ProductsApi = require("./productsApi");

  _ = require("lodash");

  module.exports = SalesOrdersApi = (function(_super) {
    __extends(SalesOrdersApi, _super);

    function SalesOrdersApi(endpoint) {
      this._buildSalesOrdersFilters = __bind(this._buildSalesOrdersFilters, this);
      this.updateShipmentStatus = __bind(this.updateShipmentStatus, this);
      this.updateShipment = __bind(this.updateShipment, this);
      this.createShipment = __bind(this.createShipment, this);
      this.getShipment = __bind(this.getShipment, this);
      this.updateSalesOrder = __bind(this.updateSalesOrder, this);
      this.getSalesOrderAndFullProducts = __bind(this.getSalesOrderAndFullProducts, this);
      this.getSalesOrder = __bind(this.getSalesOrder, this);
      this.getSalesOrders = __bind(this.getSalesOrders, this);
      this.productsApi = new ProductsApi(endpoint);
      SalesOrdersApi.__super__.constructor.call(this, endpoint);
    }

    SalesOrdersApi.prototype.getSalesOrders = function(filters) {
      var querystring;
      if (filters == null) {
        filters = {};
      }
      querystring = this._buildSalesOrdersFilters(filters);
      return this.respondMany(this.client.getAsync("/salesorders/?$filter=" + querystring));
    };

    SalesOrdersApi.prototype.getSalesOrder = function(id) {
      return this.respond(this.client.getAsync("/salesorders/" + id));
    };

    SalesOrdersApi.prototype.getSalesOrderAndFullProducts = function(id) {
      return this.getSalesOrder(id).then((function(_this) {
        return function(salesOrder) {
          var productIds;
          productIds = _.map(salesOrder.lines, "product.id").join(",");
          return _this.productsApi.getMultipleProducts(productIds).then(function(products) {
            return {
              salesOrder: salesOrder,
              products: products
            };
          });
        };
      })(this));
    };

    SalesOrdersApi.prototype.updateSalesOrder = function(id, update) {
      return this.respond(this.client.putAsync("/salesorders/" + id, update));
    };

    SalesOrdersApi.prototype.getShipment = function(salesOrderId, shipmentId) {
      return this.respond(this.client.getAsync("/salesorders/" + salesOrderId + "/shipments/" + shipmentId));
    };

    SalesOrdersApi.prototype.createShipment = function(salesOrderId, shipment) {
      return this.respond(this.client.postAsync("/salesorders/" + salesOrderId + "/shipments", shipment));
    };

    SalesOrdersApi.prototype.updateShipment = function(salesOrderId, shipmentId, shipmentUpdate) {
      return this.respond(this.client.putAsync("/salesorders/" + salesOrderId + "/shipments/" + shipmentId, shipmentUpdate));
    };

    SalesOrdersApi.prototype.updateShipmentStatus = function(salesOrderId, shipmentId, statusDto) {
      return this.respond(this.client.putAsync("/salesorders/" + salesOrderId + "/shipments/" + shipmentId + "/status", statusDto));
    };

    SalesOrdersApi.prototype._buildSalesOrdersFilters = function(filters) {
      var addAnd, brandsFilter, querystring;
      querystring = "(IsOpen eq true) and (IsCanceled eq false)";
      addAnd = (function(_this) {
        return function(condition) {
          return querystring += " and (" + condition + ")";
        };
      })(this);
      brandsFilter = (function(_this) {
        return function(brandIds) {
          return brandIds.map(function(id) {
            return "(Lines/any(line:line/Variation/Definition/Brand/Id eq " + id + "))";
          }).join(" or ");
        };
      })(this);
      if (filters.paid != null) {
        addAnd("PaymentStatus eq 'Approved'");
      }
      if (filters.brands != null) {
        addAnd(brandsFilter(filters.brands));
      }
      if (filters.other != null) {
        addAnd(filters.other);
      }
      return encodeURIComponent(querystring);
    };

    return SalesOrdersApi;

  })(ProductecaApi);

}).call(this);