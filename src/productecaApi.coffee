Promise = require("bluebird")
request = Promise.promisifyAll require("request")

class Client
  constructor: (@url, @accessToken) ->

  getAsync: (path) =>
    @_doRequest "get", path

  postAsync: (path, body) =>
    @_doRequest "post", path, body

  putAsync: (path, body) =>
    @_doRequest "put", path, body

  delAsync: (path) =>
    @_doRequest "del", path

  _doRequest: (verb, path, body) =>
    options =
      url: @_makeUrl path
      auth: bearer: @accessToken
      json: true
      body: body

    request["#{verb}Async"](options).then ([res]) =>
      throw new Error(res.body) if res.statusCode > 400
      res.body

  _makeUrl: (path) =>
    if path? then @url + path else @url

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

  respond: (promise) =>
    promise
    # // TODO: Borrar el @respond de todas las llamadas

  respondMany: (promise) =>
    promise.then (obj) -> obj.results

  _makeUrlAsync: (url) =>
    parts = url.split "." ; parts[0] += "-async" ; parts.join "."
