Promise = require("bluebird")
Restify = require("restify")
module.exports =

# Producteca API
#  endpoint = {
#    accessToken: User's token
#    [url]: "Url of the api"
#  }
class ProductecaApi
  initializeClients: (endpoint) =>
    endpoint.url = endpoint.url || "http://api.producteca.com"

    createClient = (url) =>
      Promise.promisifyAll Restify.createJSONClient
        url: url
        agent: false
        headers:
          Authorization: "Bearer #{endpoint.accessToken}"

    @client = createClient endpoint.url
    @asyncClient = createClient @_makeUrlAsync endpoint.url

  constructor: (endpoint = {}) ->
    @initializeClients endpoint

  respond: (promise) =>
    promise.spread (req, res, obj) -> obj

  respondMany: (promise) =>
    promise.spread (req, res, obj) -> obj.results

  _makeUrlAsync: (url) =>
    parts = url.split "." ; parts[0] += "-async" ; parts.join "."
