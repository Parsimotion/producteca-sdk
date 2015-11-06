Product = require("./product")
_ = require("lodash")
module.exports =

class ProductsApi
  constructor: ({ @client, @asyncClient }) ->

  #Returns a product by id
  getProduct: (id) =>
    @return @client.getAsync "/products/#{id}"

  #Returns all the products
  getProducts: =>
    @_getProductsPageByPage().then (products) =>
      @_createProducts products

  # Find a product by code (currently "sku" - it needs to be changed)
  findProductByCode: (code) =>
    oDataQuery = encodeURIComponent "sku eq '#{code}'"

    (@returnMany @client.getAsync "/products/?$filter=#{oDataQuery}").then (products) =>
      firstMatch = _.first products
      @_mapDeprecatedProperties firstMatch
    .catch =>
      throw "not found"

  #Returns multiple products by their comma separated ids
  getMultipleProducts: (ids) =>
    @return(@client.getAsync "/products?ids=#{ids}").then (products) =>
      @_createProducts products

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
    product.updatePrice priceList, amount
    @updateProductAsync product

  #Updates a product
  updateProduct: (id, update) =>
    @return @client.putAsync "/products/#{id}", update

  #Updates a product (async)
  updateProductAsync: (product) =>
    url = "/products/#{product.id}"
    @return @asyncClient.putAsync url, _.omit product.toJSON(), ["variations"]

  #Creates a product (async)
  createProductAsync: (product) =>
    url = "/products"
    @return @asyncClient.postAsync url, product

  return: (promise) =>
    promise.spread (req, res, obj) -> obj

  returnMany: (promise) =>
    promise.spread (req, res, obj) -> obj.results

  _getProductsPageByPage: (skip = 0) =>
    TOP = 500
    @return(@client.getAsync "/products?$top=#{TOP}&$skip=#{skip}").then (obj) =>
      products = obj.results
      return products if products.length < TOP
      @_getProductsPageByPage(skip + TOP).then (moreProducts) ->
        products.concat moreProducts

  _createProducts: (products) =>
    products.map (it) -> new Product it

  # ---
  # DEPRECATED PROPERTIES
  # ---

  _mapDeprecatedProperties: (product) =>
    if not product? then return

    if not product.code?
      product.code = firstMatch.sku
      delete firstMatch.sku

    if not product.name?
      product.name = firstMatch.description
      delete firstMatch.description

    product.variations.forEach (variation) ->
      if not variation.sku?
        variation.sku = variation.barcode
        delete variation.barcode

    product
