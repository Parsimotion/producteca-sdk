Promise = require("bluebird")
request = Promise.promisify require("request")

module.exports =

class Client
  constructor: (@url, @authMethod) ->

  getAsync: (path) =>
    @_doRequest "GET", path

  postAsync: (path, body) =>
    @_doRequest "POST", path, body

  putAsync: (path, body) =>
    @_doRequest "PUT", path, body

  delAsync: (path) =>
    @_doRequest "DELETE", path

  _doRequest: (verb, path, body) =>
    options =
      method: verb
      url: @_makeUrl path
      auth: @authMethod
      json: true
      body: body

    request(options).then (res) ->
      throw res.body if res.statusCode > 400
      res.body

  _makeUrl: (path) =>
    if path? then @url + path else @url
