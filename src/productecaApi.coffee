Promise = require("bluebird")
request = Promise.promisifyAll require("request")

class Client
  constructor: (@url, @accessToken) ->

  getAsync: (path) =>
    @_doRequest("get", path)

  postAsync: (path, body) =>
    @_doRequest("post", path, body)

  putAsync: (path, body) =>
    @_doRequest("put", path, body)

  delAsync: (path) =>
    @_doRequest("del", path)

  _doRequest: (verb, path, body) =>
    options =
      url: @_makeUrl(path)
      auth: bearer: @accessToken
      json: true
      body: body if body?

    request["#{verb}Async"](options).then ([res]) =>
      throw new Error(res.body) if res.statusCode > 400
      [null, null, res.body]

  _makeUrl: (path) =>
    if path? then @url + path else @url


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
