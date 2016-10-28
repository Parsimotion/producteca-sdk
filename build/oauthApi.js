(function() {
  var OAuthApi, Promise, request,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  Promise = require("bluebird");

  request = Promise.promisifyAll(require("request"));

  OAuthApi = (function() {
    function OAuthApi(_arg) {
      this.accessToken = _arg.accessToken, this.url = _arg.url;
      this.me = __bind(this.me, this);
    }

    OAuthApi.prototype.me = function() {
      return request.getAsync({
        url: this.url,
        json: true,
        auth: {
          bearer: this.accessToken
        }
      }).tap(function(res) {
        if (res.statusCode > 400) {
          throw new Error(res.body);
        }
      }).then(function(_arg) {
        var body;
        body = _arg.body;
        return body;
      });
    };

    return OAuthApi;

  })();

  module.exports = OAuthApi;

}).call(this);
