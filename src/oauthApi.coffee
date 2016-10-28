Promise = require("bluebird")
request = Promise.promisifyAll require("request")

class OAuthApi
  constructor: ({ @accessToken, @url }) ->
  me: =>
    request.getAsync
      url: @url
      json: true
      auth: bearer: @accessToken
    .tap (res) -> throw new Error(res.body) if res.statusCode > 400
    .then ({ body }) -> body

module.exports = OAuthApi
