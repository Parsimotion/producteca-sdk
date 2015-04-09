Promise = require("bluebird")
restify = require("restify")
_ = require("lodash")
azure = require("azure-storage")
Producto = require("./producto")

module.exports =

class ParsimotionClient
  initializeClient: (accessToken) ->
    client = Promise.promisifyAll restify.createJSONClient
      url: config.parsimotion.uri
      agent: false
      headers:
        Authorization: "Bearer #{accessToken}"

    queue = azure.createQueueService process.env.PRODUCTECA_QUEUE_NAME, process.env.PRODUCTECA_QUEUE_KEY
    client.enqueue = (message) => queue.createMessage "requests", message, =>
    client.user = client.getAsync "/user/me"
    client

  constructor: (accessToken, @client = @initializeClient accessToken) ->

  getProductos: =>
    @client
    .getAsync "/products"
    .spread (req, res, obj) -> obj.results
    .map (json) -> new Producto json

  updateStocks: (adjustment) =>
    body = _.map adjustment.stocks, (it) ->
      variation: it.variation
      stocks: [
        warehouse: adjustment.warehouse
        quantity: it.quantity
      ]

    @_sendUpdateToQueue "products/#{adjustment.id}/stocks", body

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
