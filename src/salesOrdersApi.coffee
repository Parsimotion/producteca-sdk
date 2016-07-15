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
    @client.getAsync("/salesorders/#{id}").then (salesOrder) =>
      salesOrder.lines?.map (it) =>
        # HORRIBLE HACKS FOR DEPRECATION
        it.product = @_convertDeprecatedToNew it.product
        @_convert it.variation, "barcode", "sku" if it.variation?
        it
      salesOrder

  #Returns a sales order by integration
  getByIntegration: ({ integrationId, app }) =>
    oDataQuery = encodeURIComponent "integrations/any(integration integration/integrationId eq #{integrationId} and integration/app eq #{app})"
    (@respondMany @client.getAsync "/salesorders?$filter=#{oDataQuery}").then (results) =>
      if _.isEmpty results
        throw new Error("The sales orders with integrationId: #{integrationId} and app: #{app} wasn't found.")
      _.first results

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

  getShipment: (salesOrderId, shipmentId) =>
    @client.getAsync "/salesorders/#{salesOrderId}/shipments/#{shipmentId}"

  getMultipleShipments: (shipmentIds) =>
    @client.getAsync "/shipments?ids=#{shipmentIds}"

  createShipment: (salesOrderId, shipment) =>
    @client.postAsync "/salesorders/#{salesOrderId}/shipments", shipment

  updateShipment: (salesOrderId, shipmentId, shipmentUpdate) =>
    @client.putAsync "/salesorders/#{salesOrderId}/shipments/#{shipmentId}", shipmentUpdate

  updateShipmentStatus: (salesOrderId, shipmentId, statusDto) =>
    @client.putAsync "/salesorders/#{salesOrderId}/shipments/#{shipmentId}/status", statusDto

  updateShipmentStatusById: (shipmentId, statusDto) =>
    @client.putAsync "/shipments/#{shipmentId}/status", statusDto

  createPayment: (salesOrderId, payment) =>
    @client.postAsync "/salesorders/#{salesOrderId}/payments", payment

  deleteShipment: (salesOrderId, shipmentId) =>
    @client.delAsync "/salesorders/#{salesOrderId}/shipments/#{shipmentId}"

  deletePayment: (salesOrderId, paymentId) =>
    @client.delAsync "/salesorders/#{salesOrderId}/payments/#{paymentId}"

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

  # ---
  # DEPRECATED PROPERTIES
  # ---

  _convertDeprecatedToNew: (product) =>
    if not product? then return
    product = _.cloneDeep product

    @_convert product, "sku", "code"
    @_convert product, "description", "name"

    product.variations?.forEach (variation) =>
      @_convert variation, "barcode", "sku"

    product

  _convertNewToDeprecated: (product) =>
    if not product? then return
    product = _.cloneDeep product

    @_convert product, "code", "sku"
    @_convert product, "name", "description"

    product.variations?.forEach (variation) =>
      @_convert variation, "sku", "barcode"

    product

  _convert: (obj, oldProperty, newProperty) =>
    if not obj[newProperty]? and obj[oldProperty]
      obj[newProperty] = obj[oldProperty]
      delete obj[oldProperty]
