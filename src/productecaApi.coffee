Promise = require("bluebird")
Restify = require("restify")
_ = require("lodash")
azure = require("azure-storage")

module.exports =

class ProductecaApi
  initializeClient: (endpoint) ->
    client = Promise.promisifyAll Restify.createJSONClient
      url: endpoint.url || "http://api.producteca.com"
      agent: false
      headers:
        Authorization: "Bearer #{endpoint.accessToken}"

    queue = azure.createQueueService endpoint.queueName, endpoint.queueKey
    client.enqueue = (message) => queue.createMessage "requests", message, =>
    client.user = client.getAsync "/user/me"
    client

  # Producteca API
  #  endpoint = {
  #    accessToken: User's token
  #    queueName: Queue for async requests
  #    queueKey: Access key for the queue
  #    [url]: "Url of the api"
  #  }
  constructor: (endpoint, @client = @initializeClient endpoint) ->

  #Returns all the products
  getProducts: =>
    @client
      .getAsync "/products"
      .spread (req, res, obj) -> obj.results

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

    @_sendUpdateToQueue "products/#{adjustment.id}/stocks", body


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

    @_sendUpdateToQueue "products/#{product.id}", body

  _sendUpdateToQueue: (resource, body) =>
    @client.user.spread (_, __, user) =>
      message = JSON.stringify
        method: "PUT"
        companyId: user.company.id
        resource: resource
        body: body

      @client.enqueue message
