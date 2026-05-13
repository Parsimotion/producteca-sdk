Promise = require("bluebird")
axios = require("axios")

class OAuthApi
  constructor: ({ @accessToken, @url }) ->
  me: =>
    Promise.resolve axios
      url: @url
      method: "GET"
      validateStatus: -> true
      headers:
        "Authorization": "Bearer #{@accessToken}"
    .tap (res) -> throw new Error(res.data) if res.status > 400
    .then ({ data }) -> data

module.exports = OAuthApi
