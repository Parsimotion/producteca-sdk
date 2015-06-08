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

  #Returns all the products
  getProducts: =>
    @returnMany(@client.getAsync "/products").then (products) =>
      products.map (it) -> new Product it

  #Returns all the opened the sales orders
  # filters = { paid: true or false }
  getSalesOrders: (filters = {}) =>
    querystring =
      if filters.paid? then "%20and%20(PaymentStatus%20eq%20%27Done%27)"
      else ""
    @returnMany @client.getAsync "/salesorders?$filter=(IsOpen%20eq%20true)%20and%20(IsCanceled%20eq%20false)#{querystring}"

  #Return a sales order by id
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

  #---

  return: (promise) =>
    promise.spread (req, res, obj) -> obj

  returnMany: (promise) =>
    promise.spread (req, res, obj) -> obj.results

  _makeUrlAsync: (url) =>
    parts = url.split "." ; parts[0] += "-async" ; parts.join "."
