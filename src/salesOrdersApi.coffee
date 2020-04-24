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

  #Returns a sales order by integration
  getByIntegration: ({ integrationId, app }, overrideApp) =>
    qs = { integrationId }
    if overrideApp then _.assign qs, { app: overrideApp }
    @client.getAsync "/byintegration", qs

  #Returns a sales order by its invoice integration
  getByInvoiceIntegration: ({ invoiceIntegrationId, app }) =>
    qs = { integrationId: invoiceIntegrationId, app }
    @client.getAsync "/byinvoiceintegration", qs


  #Returns a sales order by id and all the products in its lines
  getWithFullProducts: (id) =>
    @get(id)
      .then (salesOrder) =>
        productIds = _.map(salesOrder.lines, "product.id").join ","
        @productsApi.getMany(productIds).then (products) ->
          { salesOrder, products }

  #Creates a sales order
  create: (salesOrder) =>
    @client.postAsync "/salesorders", salesOrder

  #Updates a sales order by id
  update: (id, update) =>
    @client.putAsync "/salesorders/#{id}", update

  #Cancel sales orders by id
  cancel: (ids) =>
    @client.postAsync "/salesorders/cancel?ids=#{ids.join()}"
    
  #Closes a sales order by id
  close: (id) =>
    @client.postAsync "/salesorders/#{id}/close"

  #Closes a sales order's shipments by id
  closeShipments: (id) =>
    @client.postAsync "/salesorders/#{id}/shipments/close"

  getShipment: (salesOrderId, shipmentId) =>
    @client.getAsync "/salesorders/#{salesOrderId}/shipments/#{shipmentId}"

  getMultipleShipments: (shipmentIds) =>
    @client.getAsync "/shipments?ids=#{shipmentIds}"

  createShipment: (salesOrderId, shipment) =>
    @client.postAsync "/salesorders/#{salesOrderId}/shipments", shipment

  updateShipment: (salesOrderId, shipmentId, shipmentUpdate) =>
    @client.putAsync "/salesorders/#{salesOrderId}/shipments/#{shipmentId}", shipmentUpdate

  deleteShipment: (salesOrderId, shipmentId) =>
    @client.deleteAsync "/salesorders/#{salesOrderId}/shipments/#{shipmentId}"

  createPayment: (salesOrderId, payment) =>
    @client.postAsync "/salesorders/#{salesOrderId}/payments", payment

  updatePayment: (salesOrderId, paymentId, paymentUpdate) =>
    @client.putAsync "/salesorders/#{salesOrderId}/payments/#{paymentId}", paymentUpdate

  deletePayment: (salesOrderId, paymentId) =>
    @client.deleteAsync "/salesorders/#{salesOrderId}/payments/#{paymentId}"

  salesOrderCreated: (salesOrderId) =>
    @client.postAsync "/salesorders/#{salesOrderId}/created"

