PRODUCTECA_API_URL = "http://api.producteca.com"
nock = require("nock")

module.exports = (resource, entity, verb = "get", expectedBody, statusCode = 200) ->
  resource = resource.replace /'/g, "%27" # `request` overrides the single quotes
  nock(PRODUCTECA_API_URL)[verb](resource, expectedBody).reply statusCode, entity
