chai = require("chai")
should = chai.should()
chai.use(require("chai-as-promised"))
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

variations =
  old:
    [ { barcode: "b" }, { barcode: "c" }, { barcode: "d" } ]
  new:
    [ { sku: "b" }, { sku: "c" }, { sku: "d" } ]

describe "ProductsApi", ->
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

  describe "when get is called", ->
    it "should send a GET to the api with the given id", ->
      get = nockProductecaApi "/products/1", productWithOneVariations.old
      api.get(1).then ->
        get.done()

  describe "when getMany is called", ->
    it "should send a GET to the api with the given string of ids", ->
      products = [ productWithMoreThanOneVariations.old, productWithoutVariations.old, anotherProductWithoutVariations.old ]
      nockProductecaApi "/products?ids=2,3,4", products
      get = api.getMany("2,3,4").then ->
        get.done()

  describe "when findByCode is called", ->
    get = null
    products = null

    describe "without $select", ->
      beforeEach ->
        oDataQuery = "sku eq 'calcetines'"
        get = nockProductecaApi "/products/?$filter=#{encodeURIComponent oDataQuery}", results: [ anotherProductWithoutVariations.old ]
        api.findByCode("calcetines").then (result) ->
          products = result

      it "should send a GET to the api with an oData query to filter products with code='calcetines'", ->
        get.done()

      it "should return the products", ->
        havePropertiesEqual products, [anotherProductWithoutVariations.new]
        products[0].should.be.an.instanceof Product

    describe "with $select", ->
      beforeEach ->
        $filter = "sku eq 'calcetines'"
        $select = "id"
        get = nockProductecaApi "/products/?$filter=#{encodeURIComponent $filter}&$select=#{encodeURIComponent $select}", results: [ anotherProductWithoutVariations.old ]
        api.findByCode "calcetines", $select

      it "should send a GET to the api with an oData query to filter products with code='calcetines' and the $select's projections", ->
        get.done()

  describe "when findByVariationSku is called", ->
    get = null
    products = null

    describe "when the product exists", ->

      beforeEach ->
        nockProductecaApi "/products/bysku/c", [productWithMoreThanOneVariations.old]
        get = api.findByVariationSku("c").then (result) ->
          products = result

      it "should send a GET to the api", ->
        get.done()

      it "should return the products", ->
        havePropertiesEqual products, [productWithMoreThanOneVariations.new]
        products[0].should.be.an.instanceof Product

    describe "when the product doesn't exist", ->

      it "should throw if no product was found", ->
        nockProductecaApi "/products/bysku/c", []
        api.findByVariationSku("c").then (products) -> products.should.be.eql []

    it "should send a GET to the api urlEncoding the SKU", ->
      nockProductecaApi "/products/bysku/with%20spaces", [productWithMoreThanOneVariations.old]
      get = api.findByVariationSku("with spaces").then (result) ->
        products = result

      get.done()

  describe "when create is called", ->
    it "should create a product", ->
      req = nockProductecaApi "/products", {}, "post", anotherProductWithoutVariations.old
      api.create new Product(anotherProductWithoutVariations.old)
      req.isDone().should.be.ok

  describe "when createVariations is called", ->
    it "should create variations", ->
      req = nockProductecaApi "/products/3/variations", {}, "post", variations.old
      api.createVariations 3, variations.new
      req.isDone().should.be.ok

  describe "when updateVariationStocks is called", ->
    it "should update stock from variation", ->
      stocks = [ { warehouse: "Default", quantity: 2 } ]
      req = nockProductecaApi "/products/1/stocks", {}, "put", stocks
      api.updateVariationStocks 1, stocks
      req.isDone().should.be.ok

    describe "when updateVariationPictures is called", ->
      it "should update pictures from variation", ->
        pictures = [ { url: "mediaTostada.jpg" } ]
        req = nockProductecaApi "/products/1/pictures", {}, "post", pictures
        api.updateVariationPictures 1, pictures
        req.isDone().should.be.ok

    describe "when update is called", ->
      it "should update a product", ->
        product = notes: "actualizo la nota!"
        req = nockProductecaApi "/products/1", {}, "put", product
        api.update 1, product
        req.isDone().should.be.ok

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

nockProductecaApi = (resource, entity, verb = "get", expectedBody, statusCode = 200) ->
  nock(PRODUCTECA_API_URL)[verb](resource, expectedBody).reply statusCode, entity
