should = require("chai").should()
nock = require("nock")
ContactsApi = require("./contactsApi")
PRODUCTECA_API_URL = "http://api.producteca.com"
havePropertiesEqual = require("./helpers/havePropertiesEqual")

describe "ContactsApi", ->
  api = new ContactsApi(
    accessToken: "TokenSaraza",
    url: PRODUCTECA_API_URL
  )

  contact = { soyUn: "contacto :D" }

  beforeEach ->
    nock.cleanAll()

  describe "when create is called", ->
    it "should send a POST to the api with the given contact", ->
      post = nockProductecaApi "/contacts", {}, "post", contact
      api.create(contact).then ->
        post.done()

  describe "when update is called", ->
    it "should send a PUT to the api", ->
      put = nockProductecaApi "/contacts", {}, "put", contact
      api.update(contact).then ->
        put.done()

nockProductecaApi = (resource, entity, verb = "get", expectedBody) ->
  nock(PRODUCTECA_API_URL)[verb](resource, expectedBody).reply 200, entity
