sinon = require("sinon")
Promise = require("bluebird")

global.chai = require("chai")

chai.Should()
chai.use require("sinon-chai")

ProductecaApi = require("./productecaApi")

describe "Producteca API", ->
  client = null ; asyncClient = null
  productecaApi = null

  beforeEach ->
    dummyPromise = (value) -> new Promise (resolve) -> resolve [null, null, value]

    client =
      getAsync: sinon.stub().returns dummyPromise()
    asyncClient =
      putAsync: sinon.stub().returns dummyPromise()

    ProductecaApi::initializeClients = ->
      @client = client ; @asyncClient = asyncClient

    productecaApi = new ProductecaApi ""

  it "can update stocks", ->
    productecaApi.updateStocks
      id: 23
      warehouse: "Almagro"
      stocks: [
        variation: 24
        quantity: 8
      ]

    asyncClient.putAsync.should.have.been.calledWith "/products/23/stocks", [
      variation: 24
      stocks: [
        warehouse: "Almagro"
        quantity: 8
      ]
    ]

  it "can update the price", ->
    productecaApi.updatePrice
      id: 25
      prices: [
        priceList: "Default"
        amount: 180
      ,
        priceList: "Meli"
        amount: 210
      ],
      "Meli",
      270

    asyncClient.putAsync.should.have.been.calledWith "/products/25",
      prices: [
        amount: 180
        priceList: "Default"
      ,
        amount: 270
        priceList: "Meli"
      ]

  it "builds a querystring with the sales orders filters", ->
    querystring = productecaApi._buildSalesOrdersFilters
      paid: true
      brands: [2, 4, 9]

    querystring.should.eql "?$filter=(IsOpen%20eq%20true)%20and%20(IsCanceled%20eq%20false)%20and%20(PaymentStatus%20eq%20%27Done%27)%20and%20((Lines/any(line:line/Variation/Definition/Brand/Id eq 2)) or (Lines/any(line:line/Variation/Definition/Brand/Id eq 4)) or (Lines/any(line:line/Variation/Definition/Brand/Id eq 9)))"
