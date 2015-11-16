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
    it "should return all the opened salesOrders without filters", ->
      oDataQuery = "(IsOpen eq true) and (IsCanceled eq false)"
      nockProductecaApi "/salesorders/?$filter=#{encodeURIComponent oDataQuery}"
      api.getSalesOrders()

    describe "when filtering...", ->
      it "should return all the paid salesOrders", ->
        oDataQuery = "(IsOpen eq true) and (IsCanceled eq false) and (PaymentStatus eq 'Approved')"
        nockProductecaApi "/salesorders/?$filter=#{encodeURIComponent oDataQuery}"
        api.getSalesOrders paid: true

      it "should return all the salesOrders of a brand", ->
        oDataQuery = "(IsOpen eq true) and (IsCanceled eq false) and ((Lines/any(line:line/Variation/Definition/Brand/Id eq 3)) or (Lines/any(line:line/Variation/Definition/Brand/Id eq 4)))"
        nockProductecaApi "/salesorders/?$filter=#{encodeURIComponent oDataQuery}"
        api.getSalesOrders brands: [ 3, 4 ]

      it "should return all the salesOrders of a brand", ->
        oDataQuery = "(IsOpen eq true) and (IsCanceled eq false) and (property/inner eq 'string')"
        nockProductecaApi "/salesorders/?$filter=#{encodeURIComponent oDataQuery}"
        api.getSalesOrders other: "property/inner eq 'string'"

      it "should be able to combine filters", ->
        oDataQuery = "(IsOpen eq true) and (IsCanceled eq false) and (PaymentStatus eq 'Approved') and (property/inner eq 'string')"
        nockProductecaApi "/salesorders/?$filter=#{encodeURIComponent oDataQuery}"
        api.getSalesOrders paid: true, other: "property/inner eq 'string'"

  describe "getSalesOrder", ->
    it "should return a SalesOrder with Id=1", ->
      nockProductecaApi "/salesorders/1", id: 1

      api.getSalesOrder(1).then (salesOrder) ->
        salesOrder.should.be.eql id: 1

  describe "getSalesOrderAndFullProducts", ->
    it "should return the salesOrder and all its products", ->
      product31 = id: 31
      product32 = id: 32

      nockProductecaApi "/salesorders/1", { id: 1, lines: [ { product: product31 }, { product: product32 } ] }
      nockProductecaApi "/products?ids=31,32", [ product31, product32 ]

      api.getSalesOrderAndFullProducts(1).then (salesOrderWithProducts) ->
        havePropertiesEqual salesOrderWithProducts,
          salesOrder: { id: 1, lines: [ { product: product31 }, { product: product32 } ] }
          products: [ product31, product32 ]


nockProductecaApi = (resource, entity, verb = "get") ->
  nock(PRODUCTECA_API_URL)[verb](resource).reply 200, entity