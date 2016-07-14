(function() {
  var BODY, OAuthApi, Promise, request,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  Promise = require("bluebird");

  request = Promise.promisifyAll(require("request"), {
    multiArgs: true
  });

  BODY = 1;

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
      }).tap(function(_arg) {
        var res;
        res = _arg[0];
        if (res.statusCode > 400) {
          throw new Error(res.body);
        }
      }).get(BODY);
    };

    return OAuthApi;

  })();

  module.exports = OAuthApi;

}).call(this);
