ProductecaApi = require("./productecaApi")
ProductsApi = require("./productsApi")
_ = require("lodash")
module.exports =

class SalesOrdersApi extends ProductecaApi
  constructor: (endpoint) ->
    @resource = "salesorders"
    @productsApi = new ProductsApi(endpoint)
    super endpoint

  #Returns a sales order by id
  get: (id, opts) =>
    @client.getAsync "/salesorders/#{id}", opts

  getMany: (ids, opts) =>
    @_findMany { url: "/salesorders/multi", qs: { ids }, opts }

  #Returns a sales order by integration
  getByIntegration: ({ integrationId, app }, overrideApp, opts) =>
    qs = { integrationId }
    if overrideApp then _.assign qs, { app: overrideApp }
    @client.getAsync "/salesorders/byintegration", _.merge({ qs }, opts)

  #Returns a sales order by its invoice integration
  getByInvoiceIntegration: ({ invoiceIntegrationId, app }, opts) =>
    qs = { integrationId: invoiceIntegrationId, app }
    @client.getAsync "/salesorders/byinvoiceintegration", _.merge({ qs }, opts)

  #Returns a sales order by id and all the products in its lines
  getWithFullProducts: (id, opts) =>
    @get(id, opts)
      .then (salesOrder) =>
        productIds = _.map(salesOrder.lines, "product.id").join ","
        @productsApi.getMany(productIds).then (products) ->
          { salesOrder, products }

  #Creates a sales order
  create: (salesOrder, opts) =>
    @client.postAsync "/salesorders", salesOrder, opts

  #Updates a sales order by id
  update: (id, update, opts) =>
    @client.putAsync "/salesorders/#{id}", update, opts

  #Updates an invoice integration by sales order id
  updateInvoiceIntegration: (id, invoiceIntegration, opts) =>
    @client.putAsync "/salesorders/#{id}/invoiceIntegration", invoiceIntegration, opts

  #Cancel sales orders by id
  cancel: (ids, opts) =>
    @client.postAsync "/salesorders/cancel?ids=#{ids.join()}", undefined, opts

  #Closes a sales order by id
  close: (id, opts) =>
    @client.postAsync "/salesorders/#{id}/close", undefined, opts

  #Closes a sales order's shipments by id
  closeShipments: (id, opts) =>
    @client.postAsync "/salesorders/#{id}/shipments/close", undefined, opts

  getShipment: (salesOrderId, shipmentId) =>
    @client.getAsync "/salesorders/#{salesOrderId}/shipments/#{shipmentId}"

  getMultipleShipments: (shipmentIds) =>
    @client.getAsync "/shipments?ids=#{shipmentIds}"

  createShipment: (salesOrderId, shipment, opts) =>
    @client.postAsync "/salesorders/#{salesOrderId}/shipments", shipment, opts

  updateShipment: (salesOrderId, shipmentId, shipmentUpdate, opts) =>
    @client.putAsync "/salesorders/#{salesOrderId}/shipments/#{shipmentId}", shipmentUpdate, opts

  deleteShipment: (salesOrderId, shipmentId, opts) =>
    @client.deleteAsync "/salesorders/#{salesOrderId}/shipments/#{shipmentId}", opts

  createPayment: (salesOrderId, payment, opts) =>
    @client.postAsync "/salesorders/#{salesOrderId}/payments", payment, opts

  updatePayment: (salesOrderId, paymentId, paymentUpdate, opts) =>
    @client.putAsync "/salesorders/#{salesOrderId}/payments/#{paymentId}", paymentUpdate, opts

  deletePayment: (salesOrderId, paymentId, opts) =>
    @client.deleteAsync "/salesorders/#{salesOrderId}/payments/#{paymentId}", undefined, opts

  updateContact: (salesOrderId, contactUpdate, opts) =>
    @client.putAsync "/salesorders/#{salesOrderId}/contact", contactUpdate, opts

  salesOrderCreated: (salesOrderId, opts) =>
    @client.postAsync "/salesorders/#{salesOrderId}/created", undefined, opts

  salesOrderDraft: (salesOrderId, opts) =>
    @client.postAsync "/salesorders/#{salesOrderId}/draft", undefined, opts


