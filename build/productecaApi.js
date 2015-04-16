(function() {
  var ProductecaApi, Promise, Restify, _,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  Promise = require("bluebird");

  Restify = require("restify");

  _ = require("lodash");

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
      this["return"] = __bind(this["return"], this);
      this.updatePrice = __bind(this.updatePrice, this);
      this.updateStocks = __bind(this.updateStocks, this);
      this.getOrders = __bind(this.getOrders, this);
      this.getProducts = __bind(this.getProducts, this);
      this.initializeClients = __bind(this.initializeClients, this);
      this.initializeClients(endpoint);
    }

    ProductecaApi.prototype.getProducts = function() {
      return this["return"](this.client.getAsync("/products"));
    };

    ProductecaApi.prototype.getOrders = function() {
      return this["return"](this.client.getAsync("/orders"));
    };

    ProductecaApi.prototype.updateStocks = function(adjustment) {
      var body;
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
      return this.asyncClient.putAsync("/products/" + adjustment.id + "/stocks", body).spread(function(req, res, obj) {
        return obj;
      });
    };

    ProductecaApi.prototype.updatePrice = function(product, priceList, amount) {
      var body;
      body = {
        prices: _(product.prices).reject({
          priceList: priceList
        }).concat({
          priceList: priceList,
          amount: amount
        }).value()
      };
      return this.asyncClient.putAsync("/products/" + product.id, body).spread(function(req, res, obj) {
        return obj;
      });
    };

    ProductecaApi.prototype["return"] = function(promise) {
      return promise.spread(function(req, res, obj) {
        return obj.results;
      });
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
