should = require("chai").should()
nock = require("nock")
SalesOrdersApi = require("./salesOrdersApi")
Product = require("./models/product")
PRODUCTECA_API_URL = "http://api.producteca.com"
havePropertiesEqual = require("./helpers/havePropertiesEqual")

describe.only "SalesOrders", ->
  api = new SalesOrdersApi(
    accessToken: "TokenSaraza",
    url: PRODUCTECA_API_URL
  )

  beforeEach ->
    nock.cleanAll()

  describe "getSalesOrders", ->
    it "should return all the salesorders", ->
      oDataQuery = "(IsOpen eq true) and (IsCanceled eq false)"
      nockProductecaApi "/salesorders/?$filter=#{encodeURIComponent oDataQuery}", results: [{ id: 1 }, { id: 2 }]

      api.getSalesOrders().then (salesOrders) ->
        salesOrders.should.be.eql [{ id: 1 }, { id: 2 }]

  describe "getSalesOrder", ->
    it "should return a SalesOrder with Id=1", ->
      nockProductecaApi "/salesorders/1", id: 1

      api.getSalesOrder(1).then (salesOrder) ->
        salesOrder.should.be.eql id: 1

nockProductecaApi = (resource, entity, verb = "get") ->
  nock(PRODUCTECA_API_URL)[verb](resource).reply 200, entity