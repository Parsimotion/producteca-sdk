should = require("chai").should()
nock = require("nock")
ProductecaApi = require("./productecaApi")
Product = require("./models/product")
PRODUCTECA_API = "http://api.producteca.com"

describe "ProductsApi", ->
  api = new ProductecaApi(
    accessToken: "TokenSaraza",
    url: PRODUCTECA_API
  ).productsApi

  beforeEach ->
    nock.cleanAll()

  describe "getProduct", ->

    it.only "should return a Product with Id=1 when ask for getProduct(1)", ->
      productOne = new Product
        id: 1,
        variations: [ 
          sku: "a"
        ]

      nock(PRODUCTECA_API)
        .get("/products/1")
          .reply 200, productOne

      api.getProduct(1).then (result) =>
        result.should.be.eql productOne.toJSON()

  describe "Deprecated names of properties", ->
    deprecatedProduct =
      description: "Cosa"
      sku: "COSA"
      variations: [
        {
          barcode: "COSAVERDE"
          primaryColor: "Verde"
        }
      ]

    newProduct =
      name: "Cosa"
      code: "COSA"
      variations: [
        {
          sku: "COSAVERDE"
          primaryColor: "Verde"
        }
      ]

    describe "_convertDeprecatedToNew", ->
      it "should map the properties ok", ->
        api._convertDeprecatedToNew(deprecatedProduct)
          .should.eql newProduct

    describe "_convertNewToDeprecated", ->
      it "should map the properties ok", ->
        api._convertNewToDeprecated(newProduct)
          .should.eql deprecatedProduct
