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

  beforeEach ->
    nock.cleanAll()

  describe "when getAll is called", ->
    it "should return all the opened salesOrders without filters", ->
      oDataQuery = "(IsOpen eq true) and (IsCanceled eq false)"
      req = nockProductecaApi "/salesorders/?$filter=#{encodeURIComponent oDataQuery}", results: []
      api.getAll().then ->
        req.done()

    describe "when filtering...", ->
      it "should return all the paid salesOrders", ->
        oDataQuery = "(IsOpen eq true) and (IsCanceled eq false) and (PaymentStatus eq 'Approved')"
        req = nockProductecaApi "/salesorders/?$filter=#{encodeURIComponent oDataQuery}", results: []
        api.getAll(paid: true).then ->
          req.done()

      it "should return all the salesOrders of a brand", ->
        oDataQuery = "(IsOpen eq true) and (IsCanceled eq false) and ((Lines/any(line:line/Variation/Definition/Brand/Id eq 3)) or (Lines/any(line:line/Variation/Definition/Brand/Id eq 4)))"
        req = nockProductecaApi "/salesorders/?$filter=#{encodeURIComponent oDataQuery}", results: []
        api.getAll(brands: [ 3, 4 ]).then ->
          req.done()

      it "should return all the salesOrders for a property/inner", ->
        oDataQuery = "(IsOpen eq true) and (IsCanceled eq false) and (property/inner eq 'string')"
        req = nockProductecaApi "/salesorders/?$filter=#{encodeURIComponent oDataQuery}", results: []
        api.getAll(other: "property/inner eq 'string'").then ->
          req.done()

      it "should be able to combine filters", ->
        oDataQuery = "(IsOpen eq true) and (IsCanceled eq false) and (PaymentStatus eq 'Approved') and (property/inner eq 'string')"
        req = nockProductecaApi "/salesorders/?$filter=#{encodeURIComponent oDataQuery}", results: []
        api.getAll(paid: true, other: "property/inner eq 'string'").then ->
          req.done()

  describe "when get is called", ->
    it "should return a SalesOrder with Id=1", ->
      nockProductecaApi "/salesorders/1", id: 1

      api.get(1).then (salesOrder) ->
        salesOrder.should.be.eql id: 1

  describe "when getByIntegration is called", ->
    it "should return the sales order that matches", ->
      oDataQuery = encodeURIComponent "integrations/any(integration integration/integrationId eq 123 and integration/app eq 2)"
      nockProductecaApi "/salesorders?$filter=#{oDataQuery}",
        count: 1
        results: [una_orden: true]

      api.getByIntegration({ integrationId: 123, app: 2 }).then (salesOrder) ->
        salesOrder.should.eql una_orden: true

    it "should throw an error if no sales orders match", (done) ->
      oDataQuery = encodeURIComponent "integrations/any(integration integration/integrationId eq 123 and integration/app eq 2)"
      nockProductecaApi "/salesorders?$filter=#{oDataQuery}",
        count: 0
        results: []

      api.getByIntegration({ integrationId: 123, app: 2 }).catch (error) =>
        error.message.should.eql "The sales orders with integrationId: 123 and app: 2 wasn't found."
        done()

  describe "when getByInvoiceIntegration is called", ->
    it "should return the sales order that matches", ->
      oDataQuery = encodeURIComponent "invoiceIntegration/integrationId eq 8787 and invoiceIntegration/app eq 8)"
      nockProductecaApi "/salesorders?$filter=#{oDataQuery}",
        count: 1
        results: [una_orden: true]

      api.getByInvoiceIntegration({ invoiceIntegrationId: 8787, app: 8 }).then (salesOrder) ->
        salesOrder.should.eql una_orden: true

    it "should throw an error if no sales orders match", (done) ->
      oDataQuery = encodeURIComponent "invoiceIntegration/integrationId eq 8787 and invoiceIntegration/app eq 8)"
      nockProductecaApi "/salesorders?$filter=#{oDataQuery}",
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
      nockProductecaApi "/products?ids=31,32", products

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

  describe "when updateShipmentStatus is called", ->
    it "should update shipment(id=42) status from the salesOrder with id=1", ->
      req = nockProductecaApi "/salesorders/1/shipments/42/status", {}, "put", { status: "arrived" }
      api.updateShipmentStatus(1, 42, { status: "arrived" }).then ->
        req.done()

  describe "when updateShipmentStatusById is called", ->
    it "should update shipment(id=42) status", ->
      req = nockProductecaApi "/shipments/42/status", {}, "put", { status: "arrived" }
      api.updateShipmentStatusById(42, { status: "arrived" }).then ->
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
