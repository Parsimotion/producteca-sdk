Promise = require("bluebird")
request = require("request")
Promise.promisifyAll request

module.exports =

class Client
  constructor: (@url, @authMethod) ->

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
      auth: @authMethod
      json: true
      body: body

    request["#{verb}Async"](options).then (res) ->
      throw res.body if res.statusCode > 400
      res.body

  _makeUrl: (path) =>
    if path? then @url + path else @url
