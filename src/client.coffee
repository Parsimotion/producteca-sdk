_ = require("lodash")
Promise = require("bluebird")
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

  delAsync: (path) =>
    @_doRequest { verb: "DELETE", path }

  _doRequest: ({ verb, path, body }, { qs, raw = false } = {}) =>
    options = {
      method: verb
      url: @_makeUrl path
      body
      qs
    }

    _.assign options, auth: @authMethod unless _.isEmpty @authMethod
    _.assign options, json: true unless raw

    request(options).promise()

  _makeUrl: (path) =>
    if path? then @url + path else @url
