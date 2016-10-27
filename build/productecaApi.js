(function() {
  var Client, ProductecaApi,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  Client = require("./client");

  module.exports = ProductecaApi = (function() {
    function ProductecaApi(endpoint) {
      if (endpoint == null) {
        endpoint = {};
      }
      this._buildAuthMethod = __bind(this._buildAuthMethod, this);
      this._makeUrlAsync = __bind(this._makeUrlAsync, this);
      this.respondMany = __bind(this.respondMany, this);
      this.initializeClients = __bind(this.initializeClients, this);
      this.initializeClients(endpoint);
    }

    ProductecaApi.prototype.initializeClients = function(endpoint) {
      endpoint.url = endpoint.url || "http://api.producteca.com";
      this.client = new Client(endpoint.url, this._buildAuthMethod(endpoint));
      return this.asyncClient = new Client(this._makeUrlAsync(endpoint.url, this._buildAuthMethod(endpoint)));
    };

    ProductecaApi.prototype.respondMany = function(promise) {
      return promise.then(function(_arg) {
        var results;
        results = _arg.results;
        return results;
      });
    };

    ProductecaApi.prototype._makeUrlAsync = function(url) {
      var parts;
      parts = url.split(".");
      parts[0] += "-async";
      return parts.join(".");
    };

    ProductecaApi.prototype._buildAuthMethod = function(_arg) {
      var accessToken, basicAuth;
      accessToken = _arg.accessToken, basicAuth = _arg.basicAuth;
      if (accessToken != null) {
        return {
          bearer: accessToken
        };
      } else if (basicAuth != null) {
        return {
          user: basicAuth.companyId.toString(),
          pass: basicAuth.masterToken
        };
      }
    };

    return ProductecaApi;

  })();

}).call(this);
