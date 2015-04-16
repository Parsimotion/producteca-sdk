Promise = require("bluebird")
Restify = require("restify")
_ = require("lodash")

module.exports =

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

  # Producteca API
  #  endpoint = {
  #    accessToken: User's token
  #    [url]: "Url of the api"
  #  }
  constructor: (endpoint) ->
    @initializeClients endpoint

  #Returns all the products
  getProducts: =>
    @return @client.getAsync "/products"

  #Returns all the sales orders
  getSalesOrders: =>
    @return @client.getAsync "/salesorders"

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

    @asyncClient
      .putAsync "/products/#{adjustment.id}/stocks", body
      .spread (req, res, obj) -> obj

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

    @asyncClient
      .putAsync "/products/#{product.id}", body
      .spread (req, res, obj) -> obj

  #---

  return: (promise) =>
    promise.spread (req, res, obj) -> obj.results

  _makeUrlAsync: (url) =>
    parts = url.split "." ; parts[0] += "-async" ; parts.join "."
