(function() {
  var ProductecaApi, Promise, Restify,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  Promise = require("bluebird");

  Restify = require("restify");

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
      if (endpoint == null) {
        endpoint = {};
      }
      this._makeUrlAsync = __bind(this._makeUrlAsync, this);
      this.respondMany = __bind(this.respondMany, this);
      this.respond = __bind(this.respond, this);
      this.initializeClients = __bind(this.initializeClients, this);
      this.initializeClients(endpoint);
    }

    ProductecaApi.prototype.respond = function(promise) {
      return promise.spread(function(req, res, obj) {
        return obj;
      });
    };

    ProductecaApi.prototype.respondMany = function(promise) {
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
