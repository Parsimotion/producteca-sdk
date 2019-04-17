should = require("chai").should()
nock = require("nock")
SalesOrdersApi = require("./salesOrdersApi")
PRODUCTECA_API_URL = "http://api.producteca.com"
havePropertiesEqual = require("./helpers/havePropertiesEqual")
nockProductecaApi = require("./helpers/nockProductecaApi")

describe "SalesOrders", ->
  api = new SalesOrdersApi(
    accessToken: "TokenSaraza",
    url: PRODUCTECA_API_URL
  )

  nockSalesOrderFilter = (oDataQuery, results) ->
    nockProductecaApi "/salesorders/?$filter=#{encodeURIComponent oDataQuery}", results

  nockGetAll = (oDataQuery, results) ->
    nockProductecaApi "/salesorders?$top=500&$skip=0&$filter=#{encodeURIComponent oDataQuery}", results

  beforeEach ->
    nock.cleanAll()

  describe "when getAll is called", ->
    it "should return all the opened salesOrders without filters", ->
      oDataQuery = "(IsOpen eq true) and (IsCanceled eq false)"
      req = nockGetAll oDataQuery, results: []
      api.getAll().then ->
        req.done()

    describe "when filtering...", ->
      it "should return all the paid salesOrders", ->
        oDataQuery = "(IsOpen eq true) and (IsCanceled eq false) and (PaymentStatus eq 'Approved')"
        req = nockGetAll oDataQuery, results: []
        api.getAll(paid: true).then ->
          req.done()

      it "should return all the salesOrders of a brand", ->
        oDataQuery = "(IsOpen eq true) and (IsCanceled eq false) and ((Lines/any(line:line/Variation/Definition/Brand/Id eq 3)) or (Lines/any(line:line/Variation/Definition/Brand/Id eq 4)))"
        req = nockGetAll oDataQuery, results: []
        api.getAll(brands: [ 3, 4 ]).then ->
          req.done()

      it "should return all the salesOrders for a property/inner", ->
        oDataQuery = "(IsOpen eq true) and (IsCanceled eq false) and (property/inner eq 'string')"
        req = nockGetAll oDataQuery, results: []
        api.getAll(other: "property/inner eq 'string'").then ->
          req.done()

      it "should be able to combine filters", ->
        oDataQuery = "(IsOpen eq true) and (IsCanceled eq false) and (PaymentStatus eq 'Approved') and (property/inner eq 'string')"
        req = nockGetAll oDataQuery, results: []
        api.getAll(paid: true, other: "property/inner eq 'string'").then ->
          req.done()

  describe "when get is called", ->
    it "should return a SalesOrder with Id=1", ->
      nockProductecaApi "/salesorders/1", id: 1

      api.get(1).then (salesOrder) ->
        salesOrder.should.be.eql id: 1

  describe "when getByIntegration is called", ->
    it "should return the sales order that matches", ->
      nockProductecaApi "/integrations/2/salesorders/123", id: 1

      api.getByIntegration({ integrationId: 123, app: 2 }).then (salesOrder) ->
        salesOrder.should.eql id: 1

    it "should throw an error if no sales orders match", (done) ->
      nockProductecaApi "/integrations/2/salesorders/123", "The resource you are looking for has been removed, had its name changed, or is temporarily unavailable.", "get", undefined, 404

      api.getByIntegration({ integrationId: 123, app: 2 }).catch (error) =>
        error.statusCode.should.eql 404
        done()

  describe "when getByInvoiceIntegration is called", ->
    it "should return the sales order that matches", ->
      oDataQuery = "invoiceIntegration/integrationId eq 8787 and invoiceIntegration/app eq 8)"
      nockSalesOrderFilter oDataQuery,
        count: 1
        results: [una_orden: true]

      api.getByInvoiceIntegration({ invoiceIntegrationId: 8787, app: 8 }).then (salesOrder) ->
        salesOrder.should.eql una_orden: true

    it "should throw an error if no sales orders match", (done) ->
      oDataQuery = "invoiceIntegration/integrationId eq 8787 and invoiceIntegration/app eq 8)"
      nockSalesOrderFilter oDataQuery,
        count: 0
        results: []

      api.getByInvoiceIntegration({ invoiceIntegrationId: 8787, app: 8 }).catch (error) =>
        error.message.should.eql "The sales orders with invoiceIntegrationId: 8787 and app: 8 wasn't found."
        done()

  describe "when getWithFullProducts is called", ->
    it "should return the salesOrder and all its products", ->
      product31 = id: 31 ; product32 = id: 32
      products = [ product31, product32 ]
      salesOrder =
        id: 1
        lines: [ { product: product31 }, { product: product32 } ]

      nockProductecaApi "/salesorders/1", salesOrder
      nockProductecaApi "/products?ids=#{encodeURIComponent "31,32"}", products

      api.getWithFullProducts(1).then (salesOrderWithProducts) ->
        havePropertiesEqual salesOrderWithProducts, { salesOrder, products }

  describe "when create is called", ->
    it "should create a salesOrder", ->
      req = nockProductecaApi "/salesorders", {}, "post", { un_json: 1 }
      api.create(un_json: 1).then ->
        req.done()

  describe "when update is called", ->
    it "should update a salesOrder", ->
      req = nockProductecaApi "/salesorders/1", {}, "put", { id: 1 }
      api.update(1, { id: 1 }).then ->
        req.done()

  describe "when getShipment is called", ->
    it "should return a shipment with id=42 from the orderSales with id=1", ->
      req = nockProductecaApi "/salesorders/1/shipments/42"
      api.getShipment(1, 42).then ->
        req.done()

  describe "when getMultipleShipments is called", ->
    it "should return the shipments with the given ids", ->
      req = nockProductecaApi "/shipments?ids=41,42"
      api.getMultipleShipments("41,42").then ->
        req.done()

  describe "when createShipment is called", ->
    it "should create a shipment for the salesOrder with id=1", ->
      req = nockProductecaApi "/salesorders/1/shipments", {}, "post", { id: 30 }
      api.createShipment(1, { id: 30 }).then ->
        req.done()

  describe "when updateShipment is called", ->
    it "should update shipment with id=42 from the salesOrder with id=1", ->
      req = nockProductecaApi "/salesorders/1/shipments/42", {}, "put", { Date: "14/07/2016 11:15:00" }
      api.updateShipment(1, 42, { Date: "14/07/2016 11:15:00" }).then ->
        req.done()

  describe "when createPayment is called", ->
    it "should create a payment for the salesOrder with id=1", ->
      req = nockProductecaApi "/salesorders/1/payments", {}, "post", { id: 30 }
      api.createPayment(1, { id: 30 }).then ->
        req.done()

  describe "when deleteShipment is called", ->
    it "should send a DELETE to the shipment", ->
      req = nockProductecaApi "/salesorders/1/shipments/2", {}, "delete"
      api.deleteShipment(1, 2).then ->
        req.done()

  describe "when deletePayment is called", ->
    it "should send a DELETE to the payment", ->
      req = nockProductecaApi "/salesorders/1/payments/2", {}, "delete"
      api.deletePayment(1, 2).then ->
        req.done()
