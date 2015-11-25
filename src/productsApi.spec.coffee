should = require("chai").should()
nock = require("nock")
ProductsApi = require("./productsApi")
Product = require("./models/product")
PRODUCTECA_API_URL = "http://api.producteca.com"
havePropertiesEqual = require("./helpers/havePropertiesEqual")

createProduct = (id, code, variations = []) ->
  old:
    id: id
    sku: code
    variations: variations.map (it) -> barcode: it.sku
  new:
    id: id
    variations: variations
    code: code

describe "ProductsApi", ->
  api = new ProductsApi(
    accessToken: "TokenSaraza",
    url: PRODUCTECA_API_URL
  )

  productWithOneVariations = createProduct 1, "pantalon", [ { sku: "a" } ]
  productWithMoreThanOneVariations = createProduct 2, "remera", [ { sku: "b" }, { sku: "c" }, { sku: "d" } ]
  productWithoutVariations = createProduct 3, "campera"
  anotherproductWithoutVariations = createProduct 4, "calcetines"

  beforeEach ->
    nock.cleanAll()

  describe "when getProduct is called", ->
    it "should send a GET to the api with the given id", ->
      get = nockProductecaApi "/products/1", productWithOneVariations.old
      api.getProduct(1).then ->
        get.done()

  describe "when getMultipleProducts is called", ->
    it "should send a GET to the api with the given string of ids", ->
      products = [ productWithMoreThanOneVariations.old, productWithoutVariations.old, anotherproductWithoutVariations.old ]
      nockProductecaApi "/products?ids=2,3,4", products
      get = api.getMultipleProducts("2,3,4").then ->
        get.done()

  describe "when findProductByCode is called", ->
    get = null
    product = null

    beforeEach ->
      oDataQuery = "sku eq 'calcetines'"
      get = nockProductecaApi "/products/?$filter=#{encodeURIComponent oDataQuery}", results: [ anotherproductWithoutVariations.old ]
      api.findProductByCode("calcetines").then (result) ->
        product = result
    
    it "should send a GET to the api with an oData query to filter products with code='calcetines'", ->
      get.done()

    it "should return the first product", ->
      havePropertiesEqual product, anotherproductWithoutVariations.new
      product.should.be.an.instanceof Product

  describe "when findProductByVariationSku is called", ->
    get = null
    product = null

    beforeEach ->
      oDataQuery = "variations/any(variation variation/barcode eq 'c')"
      nockProductecaApi "/products/?$filter=#{encodeURIComponent oDataQuery}", results: [ productWithMoreThanOneVariations.old ]
      get = api.findProductByVariationSku("c").then (result) ->
        product = result

    it "should send a GET to the api with an oData query to filter products containing a variation with sku='c'", ->
      get.done()

    it "should return the first product", ->
      havePropertiesEqual product, productWithMoreThanOneVariations.new
      product.should.be.an.instanceof Product

  describe "when createProduct is called", ->
    it "should create a product", ->
      nockProductecaApi "/products", anotherproductWithoutVariations.old, "post"
      api.createProduct new Product(anotherproductWithoutVariations.old)

  describe "when createVariations is called", ->
    it "should create variations", ->
      variations = [ { sku: "b" }, { sku: "c" }, { sku: "d" } ]
      nockProductecaApi "/products/3/variations", variations, "post"

      api.createVariations 3, variations

  describe "when updateVariationStocks is called", ->
    it "should update stock from variation", ->
      stocks = [ { warehouse: "Default", quantity: 2 } ]
      nockProductecaApi "/products/1/stocks", stocks, "put"

      api.updateVariationStocks 1, stocks

    describe "when updateVariationPictures is called", ->
      it "should update pictures from variation", ->
        pictures = [ { url: "mediaTostada.jpg" } ]
        nockProductecaApi "/products/1/pictures", pictures, "post"

        api.updateVariationPictures 1, pictures

    describe "when updateProduct is called", ->
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
