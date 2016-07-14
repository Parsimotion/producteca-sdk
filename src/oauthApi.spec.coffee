OAuthApi = require("./oauthApi")
nock = require("nock")
havePropertiesEqual = require("./helpers/havePropertiesEqual")

authURI = "http://auth.producteca.com"
authNock = null

describe "OAuthAPI :", ->
  api = new OAuthApi(
    accessToken: "TokenSaraza",
    url: "#{authURI}/scopes"
  )

  beforeEach ->
    nock.cleanAll()
    authNock = nock(authURI, reqheaders: "Authorization" : "Bearer TokenSaraza")
      .get "/scopes"
      .reply 200, mockedScopes

  it "me() should return statusCode=200 and scopes", (done) ->
    api.me().then (scopes) ->
      havePropertiesEqual scopes, mockedScopes
      authNock.isDone()
      done()

mockedScopes =
  id: 1234
  companyId: 1
  appId: 16
  scopes: "all"
  authorizations: [
    app: "1"
    scopes: "all"
  ]
