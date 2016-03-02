ProductecaApi = require("./productecaApi")
ProductsApi = require("./productsApi")
_ = require("lodash")
module.exports =

class SalesOrdersApi extends ProductecaApi
  constructor: (endpoint) ->
    @productsApi = new ProductsApi(endpoint)
    super endpoint

  #Returns all the opened the sales orders
  # filters = {
  #  paid: true or false,
  #  brand: [id1, id2, id3]
  #  other: "property/inner eq 'string'"
  # }
  getAll: (filters = {}) =>
    querystring = @_buildSalesOrdersFilters filters
    @respondMany @client.getAsync "/salesorders/?$filter=#{querystring}"

  #Returns a sales order by id
  get: (id) =>
    @respond @client.getAsync "/salesorders/#{id}"

  #Returns a sales order by id and all the products in its lines
  getWithFullProducts: (id) =>
    @get(id)
      .then (salesOrder) =>
        productIds = _.map(salesOrder.lines, "product.id").join ","
        @productsApi.getMany(productIds).then (products) ->
          { salesOrder, products }

  #Updates a sales order by id
  update: (id, update) =>
    @respond @client.putAsync "/salesorders/#{id}", update

  getShipment: (salesOrderId, shipmentId) =>
    @respond @client.getAsync "/salesorders/#{salesOrderId}/shipments/#{shipmentId}"

  getMultipleShipments: (shipmentIds) =>
    @respond @client.getAsync "/shipments?ids=#{shipmentIds}"

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
