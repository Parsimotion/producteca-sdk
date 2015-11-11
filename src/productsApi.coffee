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
    @_findOne(encodeURIComponent "sku eq '#{code}'")
    .catch => throw new Error("The product with code=#{code} wasn't found")

  # Find a product by the variation SKU (currently "barcode" - it needs to be changed)
  findProductByVariationSku: (sku) =>
    @_findOne(encodeURIComponent "variations/any(variation variation/barcode eq '#{sku}')")
    .catch => throw new Error("The product with sku=#{sku} wasn't found")

  #Returns multiple products by their comma separated ids
  getMultipleProducts: (ids) =>
    @return(@client.getAsync "/products?ids=#{ids}").then (products) =>
      @_createProducts products

  #Creates a product
  createProduct: (product) =>
    @return @client.postAsync "/products", @_convertNewToDeprecated(product)

  #Creates one or more variations of a product definition
  createVariations: (productId, variations) =>
    url = "/products/#{productId}/variations"

    variations = (@_convertNewToDeprecated { variations }).variations
    @return @client.postAsync url, variations

  #Updates the stocks of one or more variations
  updateVariationStocks: (productId, adjustments) =>
    url = "/products/#{productId}/stocks"
    @return @client.putAsync url, adjustments

  #Updates the pictures of one or more variations
  updateVariationPictures: (productId, pictures) =>
    url = "/products/#{productId}/pictures"
    @return @client.postAsync url, pictures

  # TODO: ESTO A FUTURO VA A VOLAR
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
    @return @client.putAsync "/products/#{id}", @_convertNewToDeprecated(update)

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

  _findOne: (oDataQuery) =>
    (@returnMany @client.getAsync "/products/?$filter=#{oDataQuery}").then (products) =>
      firstMatch = _.first products
      new Product(firstMatch)

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
