Promise = require("bluebird")
Restify = require("restify")
_ = require("lodash")
Product = require("./product")
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

  constructor: (endpoint) ->
    @initializeClients endpoint

  #Returns a product by id
  getProduct: (id) =>
    @return @client.getAsync "/products/#{id}"

  #Returns all the products
  getProducts: =>
    @returnMany(@client.getAsync "/products").then (products) =>
      @_createProducts products

  #Returns multiple products by their comma separated ids
  getMultipleProducts: (ids) =>
    @returnMany(@client.getAsync "/products?ids=#{ids}").then (products) =>
      @_createProducts products

  _createProducts: (products) =>
    products.map (it) -> new Product it

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
    @return @client.getAsync "/salesorders/#{id}"

  #Updates a sales order by id
  updateSalesOrder: (id, update) =>
    @return @client.putAsync "/salesorders/#{id}", update

  #Updates the stocks with an *adjustment*.
  #  adjustment = {
  #    id: Id of the product
  #    warehouse: Warehouse to edit
  #    stocks: [
  #      variation: Id of the variation
  #      quantity: The new stock
  #    ]
  #  }
  updateStocks: (adjustment) =>
    body = _.map adjustment.stocks, (it) ->
      variation: it.variation
      stocks: [
        warehouse: adjustment.warehouse
        quantity: it.quantity
      ]

    url = "/products/#{adjustment.id}/stocks"
    @return @asyncClient.putAsync url, body

  #Updates the price of a product:
  #  product = The product obtained in *getProducts*
  #  priceList = Price list to edit
  #  amount = The new price
  updatePrice: (product, priceList, amount) =>
    body =
      prices:
        _(product.prices)
          .reject priceList: priceList
          .concat
            priceList: priceList
            amount: amount
        .value()

    url = "/products/#{product.id}"
    @return @asyncClient.putAsync url, body

  createShipment: (salesOrderId, shipment) =>
    @return @client.postAsync "/salesorders/#{salesOrderId}/shipments", shipment

  #---

  return: (promise) =>
    promise.spread (req, res, obj) -> obj

  returnMany: (promise) =>
    promise.spread (req, res, obj) -> obj.results

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
