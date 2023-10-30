Client = require("./client")
_ = require("lodash")

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
    endpoint.url = endpoint.url || "https://apps.producteca.com/api"
    @client = new Client(endpoint.url, @_buildAuthMethod(endpoint), endpoint.logtecaApi)
    @asyncClient = new Client(@_makeUrlAsync endpoint.url, @_buildAuthMethod(endpoint), endpoint.logtecaApi)

  respondMany: (promise) =>
    promise.then ({ results }) -> results

  # Retrieves a chunk of products
  getBatch: (skip = 0, top = 20, moreQueryString = "") =>
    @respondMany @client.getAsync "/#{@resource}?$top=#{top}&$skip=#{skip}&#{moreQueryString}"

  _makeUrlAsync: (url) =>
    parts = url.split "." ; parts[0] += "-async" ; parts.join "."

  _buildAuthMethod: ({ accessToken, basicAuth }) =>
    if accessToken?
      bearer: accessToken
    else if basicAuth?
      user: basicAuth.companyId.toString()
      pass: basicAuth.masterToken

  _getPageByPage: (skip = 0, moreQueryString = "") =>
    TOP = 500
    @getBatch(skip, TOP, moreQueryString).then (items) =>
      return items if items.length < TOP
      @_getPageByPage(skip + TOP, moreQueryString).then (moreItems) ->
        items.concat moreItems

  _findMany: ({ url, qs = {}, $select, opts = {} }) =>
    _.assign qs, { $select: $select?.join() }
    _.assign opts, { qs }
    (@client.getAsync(url, opts))

