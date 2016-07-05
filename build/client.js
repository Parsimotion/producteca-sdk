(function() {
  var Client, Promise, RESPONSE_ELEMENT, request,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  Promise = require("bluebird");

  request = require("request");

  Promise.promisifyAll(request, {
    multiArgs: true
  });

  RESPONSE_ELEMENT = 0;

  module.exports = Client = (function() {
    function Client(url, accessToken) {
      this.url = url;
      this.accessToken = accessToken;
      this._makeUrl = __bind(this._makeUrl, this);
      this._doRequest = __bind(this._doRequest, this);
      this.delAsync = __bind(this.delAsync, this);
      this.putAsync = __bind(this.putAsync, this);
      this.postAsync = __bind(this.postAsync, this);
      this.getAsync = __bind(this.getAsync, this);
    }

    Client.prototype.getAsync = function(path) {
      return this._doRequest("get", path);
    };

    Client.prototype.postAsync = function(path, body) {
      return this._doRequest("post", path, body);
    };

    Client.prototype.putAsync = function(path, body) {
      return this._doRequest("put", path, body);
    };

    Client.prototype.delAsync = function(path) {
      return this._doRequest("del", path);
    };

    Client.prototype._doRequest = function(verb, path, body) {
      var options;
      options = {
        url: this._makeUrl(path),
        auth: {
          bearer: this.accessToken
        },
        json: true,
        body: body
      };
      return request["" + verb + "Async"](options).get(RESPONSE_ELEMENT).then(function(res) {
        if (res.statusCode > 400) {
          throw new Error(res.body);
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
