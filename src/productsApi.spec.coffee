should = require("chai").should()
nock = require("nock")
ProductsApi = require("./productsApi")
Product = require("./models/product")
PRODUCTECA_API_URL = "http://api.producteca.com"
havePropertiesEqual = require("./helpers/havePropertiesEqual")

createProduct = (id, code, variations = []) ->
  id: id
  sku: code
  variations: variations

describe.only "ProductsApi", ->
  api = new ProductsApi(
    accessToken: "TokenSaraza",
    url: PRODUCTECA_API_URL
  )

  productWithOneVariations = createProduct 1, "pantalon", [ { sku: "a" } ]
  productWithMoreThanOneVariations = createProduct 2, "remera", [ { sku: "b" }, { sku: "c" }, { sku: "d" } ]
  productWithoutVariations = createProduct 3, "campera"
  anotherProductWithoutVariations = createProduct 4, "calcetines"

  beforeEach ->
    nock.cleanAll()

  describe "getProduct", ->
    it "should return a Product with Id=1", ->
      nockProductecaApi "/products/1", productWithOneVariations

      api.getProduct(1).then (product) ->
        havePropertiesEqual productWithOneVariations

  describe "getMultipleProducts", ->
    it "should returns an array of products matched by id", ->
      products = [ productWithMoreThanOneVariations, productWithoutVariations, anotherProductWithoutVariations ]
      nockProductecaApi "/products?ids=2,3,4", products

      api.getMultipleProducts("2,3,4").then (results) ->
        havePropertiesEqual results, products

  describe "findProductByCode", ->
    it "should return a product with code='calcetines'", ->
      oDataQuery = "sku eq 'calcetines'"
      nockProductecaApi "/products/?$filter=#{encodeURIComponent oDataQuery}", results: [ anotherProductWithoutVariations ]

      api.findProductByCode("calcetines").then (product) ->
        havePropertiesEqual product, anotherProductWithoutVariations

  describe "findProductByVariationSku", ->
    it "should return a product with variation sku='c'", ->
      oDataQuery = "variations/any(variation variation/barcode eq 'c')"
      nockProductecaApi "/products/?$filter=#{encodeURIComponent oDataQuery}", results: [ productWithMoreThanOneVariations ]

      api.findProductByVariationSku("c").then (product) ->
        havePropertiesEqual product, productWithMoreThanOneVariations

  describe "createProduct", ->
    it "should create a product", ->
      nockProductecaApi "/products", anotherProductWithoutVariations, "post"
      api.createProduct new Product(anotherProductWithoutVariations)

  describe "createVariations", ->
    it "should create variations", ->
      variations = [ { sku: "b" }, { sku: "c" }, { sku: "d" } ]
      nockProductecaApi "/products/3/variations", variations, "post"
      
      api.createVariations 3, variations

  describe "updateVariationStocks", ->
    it "should update stock from variation", ->
      stocks = [ { warehouse: "Default", quantity: 2 } ]
      nockProductecaApi "/products/1/stocks", stocks, "put"

      api.updateVariationStocks 1, stocks

    describe "updateVariationPictures", ->
      it "should update pictures from variation", ->
        pictures = [ { url: "mediaTostada.jpg" } ]
        nockProductecaApi "/products/1/pictures", pictures, "post"

        api.updateVariationPictures 1, pictures

    describe "updateProduct", ->
      it "should update a product", ->
        product =
          notes: "actualizo la nota!"
        nockProductecaApi "/products/1", product, "put"

        api.updateProduct 1, product

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

nockProductecaApi = (resource, entity, verb = "get") ->
  nock(PRODUCTECA_API_URL)[verb](resource).reply 200, entity