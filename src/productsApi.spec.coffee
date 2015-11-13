should = require("chai").should()
nock = require("nock")
ProductecaApi = require("./productecaApi")
Product = require("./models/product")
PRODUCTECA_API = "http://api.producteca.com"
havePropertiesEqual = require("./helpers/havePropertiesEqual")

createProduct = (id, variations = []) =>
  new Product
    id: id,
    variations: variations

describe "ProductsApi", ->
  api = new ProductecaApi(
    accessToken: "TokenSaraza",
    url: PRODUCTECA_API
  ).productsApi

  productWithOneVariations = createProduct id: 1, [ { sku: "a" } ]
  productWithMoreThanOneVariations = createProduct id: 2, [ { sku: "b" }, { sku: "c" }, { sku: "d" } ]
  productWithoutVariations = createProduct id: 3
  anotherProductWithoutVariations = createProduct id: 4

  beforeEach ->
    nock.cleanAll()

  describe "getProduct", ->
    it "should return a Product with Id=1 when ask for getProduct(1)", ->
      nock(PRODUCTECA_API)
        .get("/products/1")
          .reply 200, productWithOneVariations

      api.getProduct(1).then (result) =>
        result.should.be.eql productWithOneVariations.toJSON()

  describe "getMultipleProducts", ->
    it "should returns an array of products matched by id", ->
      products = [ productWithMoreThanOneVariations.toJSON(), productWithoutVariations.toJSON(), anotherProductWithoutVariations.toJSON() ]
      nock(PRODUCTECA_API)
        .get("/products?ids=2,3,4")
          .reply 200, products

      api.getMultipleProducts("2,3,4").then (results) =>
        havePropertiesEqual results, products

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