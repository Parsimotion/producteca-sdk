should = require("chai").should()
nock = require("nock")
BrandsApi = require("./brandsApi")
PRODUCTECA_API_URL = "http://api.producteca.com"
havePropertiesEqual = require("./helpers/havePropertiesEqual")

describe "BrandsApi", ->
  api = new BrandsApi(
    accessToken: "TokenSaraza",
    url: PRODUCTECA_API_URL
  )

  samsung = name: "Samsung"
  motorola = name: "Motorola"

  beforeEach ->
    nock.cleanAll()

  describe "when get is called", ->
    it "should send a GET to the api with the given id", ->
      get = nockProductecaApi "/brands/1", samsung
      api.get(1).then ->
        get.done()

  describe "when getAll is called", ->
    it "should send a GET to the api", ->
      get = nockProductecaApi "/brands", [samsung, motorola]
      api.getAll().then ->
        get.done()

  describe "when createByName is called", ->
    it "should send a POST to the api with the name", ->
      post = nockProductecaApi "/brands", {}, "post", name: "Apple"
      api.createByName("Apple").then ->
        post.done()

  describe "when delete is called", ->
    it "should send a DELETE to the api with the given id", ->
      deletion = nockProductecaApi "/brands/1", {}, "delete"
      api.delete(1).then ->
        deletion.done()

nockProductecaApi = (resource, entity, verb = "get", expectedBody) ->
  nock(PRODUCTECA_API_URL)[verb](resource, expectedBody).reply 200, entity
