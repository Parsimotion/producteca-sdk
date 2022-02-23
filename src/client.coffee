_ = require("lodash")
Promise = require("bluebird")
debug = require("debug")("producteca-sdk:client")
debugResponse = require("debug")("producteca-sdk:client:response")
request = require("request-promise")

module.exports =

class Client
  constructor: (@url, @authMethod) ->

  getAsync: (path, opts) =>
    @_doRequest { verb: "GET", path }, opts

  postAsync: (path, body, opts) =>
    @_doRequest { verb: "POST", path, body }, opts

  putAsync: (path, body, opts) =>
    @_doRequest { verb: "PUT", path, body }, opts

  deleteAsync: (path, opts) =>
    @_doRequest { verb: "DELETE", path }, opts

  _doRequest: ({ verb, path, body }, { qs, raw = false, headers } = {}) =>
    options = {
      method: verb
      url: @_makeUrl path
      body
      qs
      headers
    }
    _.assign options, auth: @authMethod unless _.isEmpty @authMethod
    _.assign options, json: true unless raw
    debug(JSON.stringify(options))
    request(options).promise()
    .tap((response) => debugResponse(response))
    .tapCatch((err) => debugResponse(err))

  _makeUrl: (path) =>
    if path? then @url + path else @url
