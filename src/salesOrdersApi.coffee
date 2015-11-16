ProductsApi = require("./productsApi")
module.exports =

class SalesOrdersApi extends ProductecaApi
  #Returns all the opened the sales orders
  # filters = {
  #  paid: true or false,
  #  brand: [id1, id2, id3]
  #  other: "property/inner eq 'string'"
  # }
  getSalesOrders: (filters = {}) =>
    querystring = @_buildSalesOrdersFilters filters
    @respondMany @client.getAsync "/salesorders#{querystring}"

  #Returns a sales order by id
  getSalesOrder: (id) =>
    @respond @client.getAsync "/salesorders/#{id}"

  #Returns a sales order by id and all the products in its lines
  getSalesOrderAndFullProducts: (id) =>
    @getSalesOrder(id)
      .then (salesOrder) =>
        productIds = _.map(salesOrder.lines, "product.id").join ","
        @getMultipleProducts(productIds).then (products) ->
          { salesOrder, products }

  #Updates a sales order by id
  updateSalesOrder: (id, update) =>
    @respond @client.putAsync "/salesorders/#{id}", update

  getShipment: (salesOrderId, shipmentId) =>
    @respond @client.getAsync "/salesorders/#{salesOrderId}/shipments/#{shipmentId}"

  createShipment: (salesOrderId, shipment) =>
    @respond @client.postAsync "/salesorders/#{salesOrderId}/shipments", shipment

  updateShipment: (salesOrderId, shipmentId, shipmentUpdate) =>
    @respond @client.putAsync "/salesorders/#{salesOrderId}/shipments/#{shipmentId}", shipmentUpdate

  updateShipmentStatus: (salesOrderId, shipmentId, statusDto) =>
    @respond @client.putAsync "/salesorders/#{salesOrderId}/shipments/#{shipmentId}/status", statusDto

  #---

  _buildSalesOrdersFilters: (filters) =>
    querystring = "?$filter=(IsOpen%20eq%20true)%20and%20(IsCanceled%20eq%20false)"
    addAnd = (condition) => querystring += "%20and%20(#{condition})"

    brandsFilter = (brandIds) =>
      brandIds
        .map (id) => "(Lines%2Fany(line%3Aline%2FVariation%2FDefinition%2FBrand%2FId%20eq%20#{id}))"
        .join "%20or%20"

    if filters.paid?
      addAnd "PaymentStatus%20eq%20%27Approved%27"
    if filters.brands?
      addAnd brandsFilter(filters.brands)
    if filters.other?
      addAnd filters.other

    querystring
