chai = require("chai")
should = chai.should()
chai.use(require("chai-as-promised"))
nock = require("nock")
ProductsApi = require("./productsApi")
Product = require("./models/product")
PRODUCTECA_API_URL = "http://api.producteca.com"
havePropertiesEqual = require("./helpers/havePropertiesEqual")
nockProductecaApi = require("./helpers/nockProductecaApi")

createProduct = (id, code, variations = []) ->
  id: id
  variations: variations
  code: code

variations = [ { sku: "b" }, { sku: "c" }, { sku: "d" } ]

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
      get = nockProductecaApi "/products/1", productWithOneVariations
      api.get(1).then ->
        get.done()

  describe "when getMany is called", ->
    it "should send a GET to the api with the given string of ids", ->
      products = [ productWithMoreThanOneVariations, productWithoutVariations, anotherProductWithoutVariations ]
      nockProductecaApi "/products?ids=2,3,4", products
      get = api.getMany("2,3,4").then ->
        get.done()

  describe "when findByCode is called", ->
    get = null
    products = null

    describe "without $select", ->
      beforeEach ->
        oDataQuery = "code eq 'calcetines'"

        get = nockProductecaApi "/products/?$filter=#{encodeURIComponent oDataQuery}", results: [ anotherProductWithoutVariations ]
        api.findByCode("calcetines").then (result) ->
          products = result

      it "should send a GET to the api with an oData query to filter products with code='calcetines'", ->
        get.done()

      it "should return the products", ->
        havePropertiesEqual products, [anotherProductWithoutVariations]
        products[0].should.be.an.instanceof Product

    describe "with $select", ->
      beforeEach ->
        $filter = "code eq 'calcetines'"
        $select = "id"
        get = nockProductecaApi "/products/?$filter=#{encodeURIComponent $filter}&$select=#{encodeURIComponent $select}", results: [ anotherProductWithoutVariations ]
        api.findByCode "calcetines", $select

      it "should send a GET to the api with an oData query to filter products with code='calcetines' and the $select's projections", ->
        get.done()

  describe "when findByVariationSku is called", ->
    get = null
    products = null

    describe "when the product exists", ->

      beforeEach ->
        nockProductecaApi "/products/bysku?sku=c", [productWithMoreThanOneVariations]
        get = api.findByVariationSku("c").then (result) ->
          products = result

      it "should send a GET to the api", ->
        get.done()

      it "should return the products", ->
        havePropertiesEqual products, [productWithMoreThanOneVariations]
        products[0].should.be.an.instanceof Product

    describe "when the product doesn't exist", ->

      it "should throw if no product was found", ->
        nockProductecaApi "/products/bysku?sku=c", []
        api.findByVariationSku("c").then (products) -> products.should.be.eql []

    it "should send a GET to the api urlEncoding the SKU", ->
      nockProductecaApi "/products/bysku?sku=with%20spaces", [productWithMoreThanOneVariations]
      get = api.findByVariationSku("with spaces").then (result) ->
        products = result

      get.done()

  describe "when create is called", ->
    it "should create a product", ->
      req = nockProductecaApi "/products", {}, "post", anotherProductWithoutVariations
      api.create(new Product(anotherProductWithoutVariations)).then ->
        req.done()

  describe "when createVariations is called", ->
    it "should create variations", ->
      req = nockProductecaApi "/products/3/variations", {}, "post", variations
      api.createVariations(3, variations).then ->
        req.done()

  describe "when updateVariationStocks is called", ->
    it "should update stock from variation", ->
      stocks = [ { warehouse: "Default", quantity: 2 } ]
      req = nockProductecaApi "/products/1/stocks", {}, "put", stocks
      api.updateVariationStocks(1, stocks).then ->
        req.done()

    describe "when addVariationPictures is called", ->
      it "should update pictures from variation", ->
        pictures = [ { url: "mediaTostada.jpg" } ]
        req = nockProductecaApi "/products/1/pictures", {}, "post", pictures
        api.addVariationPictures(1, pictures).then ->
          req.done()

    describe "when updateVariationPictures is called", ->
      it "should update pictures from variation", ->
        pictures = [ { url: "mediaTostada.jpg" } ]
        req = nockProductecaApi "/products/1/pictures", {}, "put", pictures
        api.updateVariationPictures(1, pictures).then ->
          req.done()

    describe "when update is called", ->
      it "should update a product", ->
        product = notes: "actualizo la nota!"
        req = nockProductecaApi "/products/1", {}, "put", product
        api.update(1, product).then ->
          req.done()

    describe "when getPricelists is called", ->
      it "should send a get to /pricelists", ->
        req = nockProductecaApi "/pricelists"
        api.getPricelists().then ->
          req.done()

    describe "when getWarehouses is called", ->
      it "should send a get to /warehouses", ->
        req = nockProductecaApi "/warehouses"
        api.getWarehouses().then ->
          req.done()

    describe "when createWarehouse is called", ->
      it "should send a post to /warehouses with the name", ->
        req = nockProductecaApi "/warehouses", {}, "post", { name: "piola" }
        api.createWarehouse("piola").then ->
          req.done()
