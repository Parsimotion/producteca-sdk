ProductecaApi = require("./productecaApi")
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
    @respondMany @client.getAsync "/salesorders/?$filter=#{querystring}"

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
    querystring = "(IsOpen eq true) and (IsCanceled eq false)"
    addAnd = (condition) => querystring += " and (#{condition})"

    brandsFilter = (brandIds) =>
      brandIds
        .map (id) => "(Lines/any(line:line/Variation/Definition/Brand/Id eq #{id}))"
        .join " or "

    if filters.paid?
      addAnd "PaymentStatus eq 'Approved'"
    if filters.brands?
      addAnd brandsFilter(filters.brands)
    if filters.other?
      addAnd filters.other

    encodeURIComponent querystring
