(function() {
  var PRODUCTECA_API_URL, nock;

  PRODUCTECA_API_URL = "http://api.producteca.com";

  nock = require("nock");

  module.exports = function(resource, entity, verb, expectedBody, statusCode) {
    if (verb == null) {
      verb = "get";
    }
    if (statusCode == null) {
      statusCode = 200;
    }
    resource = resource.replace(/'/g, "%27");
    return nock(PRODUCTECA_API_URL)[verb](resource, expectedBody).reply(statusCode, entity);
  };

}).call(this);
