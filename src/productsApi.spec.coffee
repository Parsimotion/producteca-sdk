should = require("chai").should()
nock = require("nock")
ProductecaApi = require("./productecaApi")
Product = require("./models/product")
PRODUCTECA_API = "http://api.producteca.com"
havePropertiesEqual = require("./helpers/havePropertiesEqual")

createProduct = (id, code, variations = []) ->
  id: id
  sku: code
  variations: variations

describe "ProductsApi", ->
  api = new ProductecaApi(
    accessToken: "TokenSaraza",
    url: PRODUCTECA_API
  ).productsApi

  productWithOneVariations = createProduct 1, "pantalon", [ { sku: "a" } ]
  productWithMoreThanOneVariations = createProduct 2, "remera", [ { sku: "b" }, { sku: "c" }, { sku: "d" } ]
  productWithoutVariations = createProduct 3, "campera"
  anotherProductWithoutVariations = createProduct 4, "calcetines"

  beforeEach ->
    nock.cleanAll()

  describe "getProduct", ->
    it "should return a Product with Id=1", ->
      nock(PRODUCTECA_API)
        .get("/products/1")
          .reply 200, productWithOneVariations

      api.getProduct(1).then (product) ->
        product.should.be.eql productWithOneVariations

  describe "getMultipleProducts", ->
    it "should returns an array of products matched by id", ->
      products = [ productWithMoreThanOneVariations, productWithoutVariations, anotherProductWithoutVariations ]
      nock(PRODUCTECA_API)
        .get("/products?ids=2,3,4")
          .reply 200, products

      api.getMultipleProducts("2,3,4").then (results) ->
        havePropertiesEqual results, products

  describe "findProductByCode", ->
    it.skip "should return a product with code='calcetines'", ->
      oDataQuery = "sku eq 'calcetines'"
      nock(PRODUCTECA_API)
        .get("/products/?$filter=#{encodeURIComponent oDataQuery}")
          .reply 200, anotherProductWithoutVariations

      api.findProductByCode("calcetines").then (product) ->
        product.should.be.eql anotherProductWithoutVariations

  describe "findProductByVariation", ->
    it.skip "should return a product with variation id='c'", ->
      oDataQuery = "variations/any(variation variation/barcode eq 'c')"
      nock(PRODUCTECA_API)
        .get("/products/?$filter=#{encodeURIComponent oDataQuery}")
          .reply 200, productWithMoreThanOneVariations

      api.findProductByCode("pantalon").then (product) ->
        product.should.be.eql productWithMoreThanOneVariations

  describe "createProduct", ->
    it "should create a product", ->
      nock(PRODUCTECA_API)
        .post("/products")
          .reply 200, anotherProductWithoutVariations

      api.createProduct(new Product(anotherProductWithoutVariations)).then (product) ->
        product.should.be.eql anotherProductWithoutVariations

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
