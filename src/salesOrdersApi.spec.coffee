should = require("chai").should()
nock = require("nock")
SalesOrdersApi = require("./salesOrdersApi")
Product = require("./models/product")
PRODUCTECA_API_URL = "http://api.producteca.com"
havePropertiesEqual = require("./helpers/havePropertiesEqual")

describe "SalesOrders", ->
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

      it "should return all the salesOrders for a property/inner", ->
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
      product31 = id: 31 ; product32 = id: 32
      products = [ product31, product32 ]
      salesOrder =
        id: 1
        lines: [{ product: product31 }, { product: product32 } ]

      nockProductecaApi "/salesorders/1", salesOrder
      nockProductecaApi "/products?ids=31,32", products

      api.getSalesOrderAndFullProducts(1).then (salesOrderWithProducts) ->
        havePropertiesEqual salesOrderWithProducts, { salesOrder, products }

  describe "updateSalesOrder", ->
    it "should update a salesOrder", ->
      nockProductecaApi "/salesorders/1", { id: 1 }, "put"
      api.updateSalesOrder 1, { id: 1}

  describe "getShipment", ->
    it "should return a shipment with id=42 from the orderSales with id=1", ->
      nockProductecaApi "/salesorders/1/shipments/42"
      api.getShipment 1, 42

  describe "createShipment", ->
    it "should create a shipment for the salesOrder with id=1", ->
      nockProductecaApi "/salesorders/1/shipments", { id: 30 }, "post"
      api.createShipment 1, { id: 30 }

  describe "updateShipment", ->
    it "should update shipment with id=42 from the salesOrder with id=1", ->
      nockProductecaApi "/salesorders/1/shipments/42", { Date: "14/07/2016 11:15:00" }, "put"
      api.updateShipment 1, 42, { Date: "14/07/2016 11:15:00" }

  describe "updateShipmentStatus", ->
    it "should update shipment(id=42) status from the salesOrder with id=1", ->
      nockProductecaApi "/salesorders/1/shipments/42/status", { status: "arrived" }, "put"
      api.updateShipmentStatus 1, 42, { status: "arrived" }


nockProductecaApi = (resource, entity, verb = "get") ->
  nock(PRODUCTECA_API_URL)[verb](resource).reply 200, entity
