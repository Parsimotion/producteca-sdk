_ = require("lodash")
Promise = require("bluebird")
debug = require("debug")("producteca-sdk:client")
debugResponse = require("debug")("producteca-sdk:client:response")
debugResponseError = require("debug")("producteca-sdk:client:response:error")
ProductecaRequestError = require('./exceptions/productecaRequestError')
axios = require("axios")

module.exports =

class Client
  constructor: (@url, @authMethod, @logtecaApi) ->
  getAsync: (path, opts) =>
    @_doRequest { verb: "GET", path }, opts

  postAsync: (path, body, opts) =>
    @_doRequest { verb: "POST", path, body }, opts

  putAsync: (path, body, opts) =>
    @_doRequest { verb: "PUT", path, body }, opts

  deleteAsync: (path, opts) =>
    @_doRequest { verb: "DELETE", path }, opts

  _doRequest: ({ verb, path, body }, { qs, raw = false, headers } = {}) =>
    options =
      method: verb
      url: @_makeUrl path
      data: body
      params: qs
      headers: _.assign {}, headers

    if not _.isEmpty @authMethod
      if @authMethod.bearer?
        options.headers["Authorization"] = "Bearer #{@authMethod.bearer}"
      else
        options.auth = { username: @authMethod.user, password: @authMethod.pass }

    if raw
      options.responseType = "text"
      options.transformResponse = [(data) -> data]

    __logWithLogtecaApiIfShould = (value) =>
      if @logtecaApi? && options.method != "GET" then @logtecaApi.log(value)

    debug(JSON.stringify(options))
    Promise.resolve(axios(options))
    .then (res) -> res.data
    .tap (response) ->
      __logWithLogtecaApiIfShould { requestOptions: options, fulfilled: true, response }
      debugResponse(JSON.stringify(response))
    .tapCatch (err) ->
      __logWithLogtecaApiIfShould { requestOptions: options, fulfilled: false, err }
      debugResponseError(JSON.stringify(err.message or err.response?.data or err.code or err))
    .catch ((err) -> err.response?.status >= 500 or not err.response?), (err) ->
      err.statusCode ?= err.response?.status
      throw new ProductecaRequestError(err)
    .catch ((err) -> err.response?), (err) ->
      err.statusCode = err.response.status
      err.body = err.response.data
      throw err

  _makeUrl: (path) =>
    if path? then @url + path else @url
