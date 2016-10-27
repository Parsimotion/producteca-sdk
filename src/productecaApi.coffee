Client = require("./client")

module.exports =

# Producteca API
#  endpoint = {
#    accessToken: User's token
#    basicAuth: { companyId, masterToken }
#    [url]: "Url of the api"
#  }
class ProductecaApi
  constructor: (endpoint = {}) ->
    @initializeClients endpoint

  initializeClients: (endpoint) =>
    endpoint.url = endpoint.url || "http://api.producteca.com"

    @client = new Client(endpoint.url, @_buildAuthMethod(endpoint))
    @asyncClient = new Client(@_makeUrlAsync endpoint.url, @_buildAuthMethod(endpoint))

  respondMany: (promise) =>
    promise.then ({ results }) -> results

  _makeUrlAsync: (url) =>
    parts = url.split "." ; parts[0] += "-async" ; parts.join "."

  _buildAuthMethod: ({ accessToken, basicAuth }) =>
    if accessToken?
      bearer: accessToken
    else if basicAuth?
      user: basicAuth.companyId.toString()
      pass: basicAuth.masterToken
