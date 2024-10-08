chai = require("chai")
should = chai.should()
chai.use(require("chai-as-promised"))
nock = require("nock")
ProductsApi = require("./productsApi")
Product = require("./models/product")
PRODUCTECA_API_URL = "http://api.producteca.com"
havePropertiesEqual = require("./helpers/havePropertiesEqual")
nockProductecaApi = require("./helpers/nockProductecaApi")
ProductecaRequestError = require('./exceptions/productecaRequestError')
{ StatusCodeError } = require('request-promise/errors')
PRODUCTECA_API_URL = "http://api.producteca.com"

createProduct = (id, code, variations = []) ->
  id: id
  variations: variations
  code: code

variations = [ { sku: "b" }, { sku: "c" }, { sku: "d" } ]
integration = { app: 5, integrationId: 12345, status: "Active" }
variationIntegration = { app: 5, integrationId: "098765", parentIntegrationId: "12345" }

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
      nockProductecaApi "/products/multi?ids=#{encodeURIComponent "2,3,4"}", products
      get = api.getMany("2,3,4").then ->
        get.done()

  describe "when findByCode is called", ->
    get = null
    products = null

    describe "without $select", ->

      describe "with sku", ->
        beforeEach ->
          code = "calcetines"
          sku = "Blanco-L"

          get = nockProductecaApi "/products/bycode?code=#{encodeURIComponent code}&sku=#{encodeURIComponent sku}", [ anotherProductWithoutVariations ]
          api.findByCode(code, sku).then (result) ->
            products = result

        it "should send a GET to the api including code and sku but without $select", ->
          get.done()

        it "should return the products", ->
          havePropertiesEqual products, [anotherProductWithoutVariations]
          products[0].should.be.an.instanceof Product

      describe "without sku", ->
        beforeEach ->
          code = "calcetines"

          get = nockProductecaApi "/products/bycode?code=#{encodeURIComponent code}", [ anotherProductWithoutVariations ]
          api.findByCode(code).then (result) ->
            products = result

        it "should send a GET to the api including code but without sku and $select", ->
          get.done()

    describe "when findByIntegrationId is called", ->
      get = null
      product = null

      beforeEach ->
        integrationId = "calcetines"
        app = "100"

        get = nockProductecaApi "/products/byintegration?app=#{encodeURIComponent app}&integrationId=#{encodeURIComponent integrationId}", anotherProductWithoutVariations
        api.findByIntegrationId(app, integrationId).then (result) ->
          product = result

      it "should send a GET to the api including integrationId and app", ->
        get.done()

      it "should return the reified products", ->
        havePropertiesEqual product, anotherProductWithoutVariations
        products[0].should.be.an.instanceof Product

  describe "when findByVariationSku is called", ->
    get = null
    products = null

    describe "when the product exists", ->

      describe "and $select is not passed", ->
        beforeEach ->
          nockProductecaApi "/products/bysku?sku=c", [productWithMoreThanOneVariations]
          get = api.findByVariationSku("c").then (result) ->
            products = result

        it "should send a GET to the api without $select in querystring", ->
          get.done()

        it "should return the products", ->
          havePropertiesEqual products, [productWithMoreThanOneVariations]
          products[0].should.be.an.instanceof Product

      describe "and $select is passed as an array of properties", ->
        beforeEach ->
          nockProductecaApi "/products/bysku?sku=c&#{encodeURIComponent("$select")}=#{encodeURIComponent("code,sku,stocks")}", [productWithMoreThanOneVariations]
          get = api.findByVariationSku("c", ["code","sku","stocks"]).then (result) ->
            products = result

        it "should send a GET to the api with $select as comma separated values", ->
          get.done()

    describe "when the product doesn't exist", ->

      it "should throw if no product was found", ->
        nockProductecaApi "/products/bysku?sku=c", []
        api.findByVariationSku("c").then (products) -> products.should.be.eql []

    it "should send a GET to the api urlEncoding the SKU", ->
      nockProductecaApi "/products/bysku?sku=with%20spaces", [productWithMoreThanOneVariations]
      get = api.findByVariationSku("with spaces").then (result) ->
        products = result

      get.done()

  describe "when findByVariationIntegrationId is called", ->
    get = null
    products = null

    describe "when the product exists", ->

      describe "and $select is not passed", ->
        beforeEach ->
          nockProductecaApi "/products/byvariationintegration?integrationId=c", [productWithMoreThanOneVariations]
          get = api.findByVariationIntegrationId("c").then (result) ->
            products = result

        it "should send a GET to the api without $select in querystring", ->
          get.done()

        it "should return the products", ->
          havePropertiesEqual products, [productWithMoreThanOneVariations]
          products[0].should.be.an.instanceof Product

      describe "and $select is passed as an array of properties", ->
        beforeEach ->
          nockProductecaApi "/products/byvariationintegration?integrationId=c&#{encodeURIComponent("$select")}=#{encodeURIComponent("code,sku,stocks")}", [productWithMoreThanOneVariations]
          get = api.findByVariationIntegrationId("c", ["code","sku","stocks"]).then (result) ->
            products = result

        it "should send a GET to the api with $select as comma separated values", ->
          get.done()

    describe "when the product doesn't exist", ->

      it "should throw if no product was found", ->
        nockProductecaApi "/products/byvariationintegration?integrationId=c", []
        api.findByVariationIntegrationId("c").then (products) -> products.should.be.eql []

  describe "when create is called", ->
    it "should create a product", ->
      req = nockProductecaApi "/products", {}, "post", anotherProductWithoutVariations
      api.create(new Product(anotherProductWithoutVariations)).then ->
        req.done()

  describe "when createIntegration is called", ->
    it "should create integration", ->
      req = nockProductecaApi "/products/3/integrations", {}, "post", integration
      api.createIntegration(3, integration).then ->
        req.done()

  describe "when updateIntegration is called", ->
    it "should update integration", ->
      updatedIntegration = { status: "Paused" }
      req = nockProductecaApi "/products/1/integrations", {}, "put", updatedIntegration
      api.updateIntegration(1, updatedIntegration).then ->
        req.done()

  describe "when deleteIntegration is called", ->
    it "should delete integration ignoring the variations without the same parentIntegrationId", ->
      req = nockProductecaApi "/products/1/integrations/123456?ignoreParentIntegrationId=true", {}, "delete"
      api.deleteIntegration(1, 123456).then ->
        req.done()

    it "should delete integration and all the variations integrations", ->
      req = nockProductecaApi "/products/1/integrations/123456?ignoreParentIntegrationId=true", {}, "delete"
      api.deleteIntegration(1, 123456, { ignoreParentIntegrationId: true }).then ->
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

    describe "when createVariationIntegration is called", ->
      it "should create variation integration", ->
        req = nockProductecaApi "/products/3/variations/9/integrations", {}, "post", variationIntegration
        api.createVariationIntegration(3, 9, variationIntegration).then ->
          req.done()

    describe "when createVariationIntegration is called", ->
      it "should create variation integration", ->
        req = nockProductecaApi "/products/3/variations/9/integrations?app=5", {}, "post", variationIntegration
        api.createVariationIntegration(3, 9, variationIntegration, qs: app: 5).then ->
          req.done()

    describe "when updatePrices is called", ->
      it "should update a prices", ->
        prices = [{ priceList: "Default", amount: 1500, currency: "Local" }]
        req = nockProductecaApi "/products/1/prices", {}, "put", prices
        api.updatePrices(1, prices).then ->
          req.done()

    describe "when updateAttributes is called", ->
      it "should update a attributes", ->
        attributes = [{ key: "Potencia", value: "1500HP" }]
        req = nockProductecaApi "/products/1/attributes", {}, "put", attributes
        api.updateAttributes(1, attributes).then ->
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

    describe "when getWarehouseByIntegration is called", ->
      it "should send a get to /warehouses/byIntegration?integrationId&app", ->
        req = nockProductecaApi "/warehouses/byIntegration?integrationId=1&app=5"
        api.getWarehouseByIntegration("1", 5).then ->
          req.done()

    describe "when getWarehouse is called", ->
      it "should send a get to /warehouses/${id}", ->
        req = nockProductecaApi "/warehouses/1"
        api.getWarehouse(1).then ->
          req.done()

    describe "when createWarehouse is called", ->
      it "should send a post to /warehouses with the name", ->
        req = nockProductecaApi "/warehouses", {}, "post", { name: "piola" }
        api.createWarehouse("piola").then ->
          req.done()

    describe "when delete is called", ->
      it "should send a delete to /products/${id}", ->
        req = nockProductecaApi "/products/1", {}, "delete"
        api.delete(1).then ->
          req.done()

  describe "when request fails", ->
    context "with a 5xx code", ->
      it "should be rejected with a ProductecaRequestException", ->
        nockProductecaApi "/products/1", productWithOneVariations, "get", undefined, 500
        api.get(1).should.be.rejectedWith(ProductecaRequestError)

    context "with a connection error", ->
      it "should be rejected with a ProductecaRequestError", ->
        nock(PRODUCTECA_API_URL).get("/products/1").replyWithError({ code: 'ETIMEDOUT' })
        api.get(1).should.be.rejectedWith(ProductecaRequestError)

    context "with a 4xx code", ->
      it "should be rejected with a StatusCodeError", ->
        nockProductecaApi "/products/1", productWithOneVariations, "get", undefined, 400
        api.get(1).should.be.rejectedWith(StatusCodeError)
