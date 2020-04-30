should = require("chai").should()
nock = require("nock")
ContactsApi = require("./contactsApi")
PRODUCTECA_API_URL = "http://api.producteca.com"
havePropertiesEqual = require("./helpers/havePropertiesEqual")
nockProductecaApi = require("./helpers/nockProductecaApi")

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

  describe "when getByIntegration is called", ->
    it "should send a GET to the api", ->
      app = 5
      integrationId = 123
      qs = { key: "integrationId", value: integrationId.toString() }
      get = nockProductecaApi "/contacts/byintegration?#{qs.key}=#{qs.value}&app=5", contact
      api.getByIntegration(app, integrationId).then ->
        get.done()
