Promise = require("bluebird")
Restify = require("restify")
ProductsApi = require("./productsApi")
_ = require("lodash")
{ returnOne, returnMany } = require("./helpers/return")
module.exports =

# Producteca API
#  endpoint = {
#    accessToken: User's token
#    [url]: "Url of the api"
#  }
class ProductecaApi
  initializeClients: (endpoint) =>
    endpoint.url = endpoint.url || "http://api.producteca.com"

    createClient = (url) =>
      Promise.promisifyAll Restify.createJSONClient
        url: url
        agent: false
        headers:
          Authorization: "Bearer #{endpoint.accessToken}"

    @client = createClient endpoint.url
    @asyncClient = createClient @_makeUrlAsync endpoint.url

  constructor: (endpoint = {}) ->
    @initializeClients endpoint

    @productsApi = new ProductsApi
      client: @client
      asyncClient: @asyncClient

  # TODO: Mover esto a una API de SalesOrders

  #Returns all the opened the sales orders
  # filters = {
  #  paid: true or false,
  #  brand: [id1, id2, id3]
  #  other: "property/inner eq 'string'"
  # }
  getSalesOrders: (filters = {}) =>
    querystring = @_buildSalesOrdersFilters filters
    @returnMany @client.getAsync "/salesorders#{querystring}"

  #Returns a sales order by id
  getSalesOrder: (id) =>
    @returnOne @client.getAsync "/salesorders/#{id}"

  #Returns a sales order by id and all the products in its lines
  getSalesOrderAndFullProducts: (id) =>
    @getSalesOrder(id)
      .then (salesOrder) =>
        productIds = _.map(salesOrder.lines, "product.id").join ","
        @getMultipleProducts(productIds).then (products) ->
          { salesOrder, products }

  #Updates a sales order by id
  updateSalesOrder: (id, update) =>
    @returnOne @client.putAsync "/salesorders/#{id}", update

  getShipment: (salesOrderId, shipmentId) =>
    @returnOne @client.getAsync "/salesorders/#{salesOrderId}/shipments/#{shipmentId}"

  createShipment: (salesOrderId, shipment) =>
    @returnOne @client.postAsync "/salesorders/#{salesOrderId}/shipments", shipment

  updateShipment: (salesOrderId, shipmentId, shipmentUpdate) =>
    @returnOne @client.putAsync "/salesorders/#{salesOrderId}/shipments/#{shipmentId}", shipmentUpdate

  updateShipmentStatus: (salesOrderId, shipmentId, statusDto) =>
    @returnOne @client.putAsync "/salesorders/#{salesOrderId}/shipments/#{shipmentId}/status", statusDto

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

  _makeUrlAsync: (url) =>
    parts = url.split "." ; parts[0] += "-async" ; parts.join "."

  # ---
  # RETROCOMPATIBILITY
  # ---

  getProduct: (id) =>
    @productsApi.getProduct id

  getProducts: =>
    @productsApi.getProducts()

  getMultipleProducts: (ids) =>
    @productsApi.getMultipleProducts ids

  updateStocks: (adjustment) =>
    @productsApi.updateStocks adjustment

  updatePrice: (product, priceList, amount) =>
    @productsApi.updatePrice product, priceList, amount

  updateProduct: (product) =>
    @productsApi.updateProductAsync product

  createProduct: (product) =>
    @productsApi.createProductAsync product
