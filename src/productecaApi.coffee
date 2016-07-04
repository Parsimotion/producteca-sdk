Client = require("./client")

module.exports =

# Producteca API
#  endpoint = {
#    accessToken: User's token
#    [url]: "Url of the api"
#  }
class ProductecaApi
  constructor: (endpoint = {}) ->
    @initializeClients endpoint

  initializeClients: (endpoint) =>
    endpoint.url = endpoint.url || "http://api.producteca.com"

    @client = new Client(endpoint.url, endpoint.accessToken)
    @asyncClient = new Client(@_makeUrlAsync endpoint.url, endpoint.accessToken)

  respondMany: (promise) =>
    promise.then ({ results }) -> results

  _makeUrlAsync: (url) =>
    parts = url.split "." ; parts[0] += "-async" ; parts.join "."
