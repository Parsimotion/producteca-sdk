_ = require("lodash")
Promise = require("bluebird")
request = Promise.promisify require("request")

module.exports =

class Client
  constructor: (@url, @authMethod) ->

  getAsync: (path, opts) =>
    @_doRequest {verb: "GET", path}, opts

  postAsync: (path, body, opts) =>
    @_doRequest {verb: "POST", path, body}, opts

  putAsync: (path, body, opts) =>
    @_doRequest {verb: "PUT", path, body}, opts

  delAsync: (path) =>
    @_doRequest {verb: "DELETE", path}

  _doRequest: ({verb, path, body}, {raw = false} = {}) =>
    options =
      method: verb
      url: @_makeUrl path
      body: body

    _.assign options, auth: @authMethod unless _.isEmpty @authMethod
    _.assign options, json: true unless raw

    request(options).then (res) ->
      throw res.body if res.statusCode > 400
      res.body

  _makeUrl: (path) =>
    if path? then @url + path else @url
