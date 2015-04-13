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

  it "puede hacer update de los stocks", ->
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

  it "puede hacer update del precio especificado", ->
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