(function() {
  var Client, Promise, request,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  Promise = require("bluebird");

  request = Promise.promisify(require("request"));

  module.exports = Client = (function() {
    function Client(url, authMethod) {
      this.url = url;
      this.authMethod = authMethod;
      this._makeUrl = __bind(this._makeUrl, this);
      this._doRequest = __bind(this._doRequest, this);
      this.delAsync = __bind(this.delAsync, this);
      this.putAsync = __bind(this.putAsync, this);
      this.postAsync = __bind(this.postAsync, this);
      this.getAsync = __bind(this.getAsync, this);
    }

    Client.prototype.getAsync = function(path) {
      return this._doRequest("GET", path);
    };

    Client.prototype.postAsync = function(path, body) {
      return this._doRequest("POST", path, body);
    };

    Client.prototype.putAsync = function(path, body) {
      return this._doRequest("PUT", path, body);
    };

    Client.prototype.delAsync = function(path) {
      return this._doRequest("DELETE", path);
    };

    Client.prototype._doRequest = function(verb, path, body) {
      var options;
      options = {
        method: verb,
        url: this._makeUrl(path),
        auth: this.authMethod,
        json: true,
        body: body
      };
      return request(options).then(function(res) {
        if (res.statusCode > 400) {
          throw res.body;
        }
        return res.body;
      });
    };

    Client.prototype._makeUrl = function(path) {
      if (path != null) {
        return this.url + path;
      } else {
        return this.url;
      }
    };

    return Client;

  })();

}).call(this);
