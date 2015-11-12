Product = require("./models/product")
{ returnOne, returnMany } = require("./helpers/return")
_ = require("lodash")
module.exports =

class ProductsApi
  constructor: ({ @client }) ->

  # Returns a product by id
  getProduct: (id) =>
    @returnOne @client.getAsync "/products/#{id}"

  # Returns all the products
  getProducts: =>
    @_getProductsPageByPage()
      .then @_convertJsonToProducts

  # Returns multiple products by their comma separated ids
  getMultipleProducts: (ids) =>
    @returnOne(@client.getAsync "/products?ids=#{ids}")
      .then @_convertJsonToProducts

  # Find a product by code (currently "sku" - IT NEEDS TO BE CHANGED)
  findProductByCode: (code) =>
    @_findOne("sku eq '#{code}'")
      .catch => throw new Error("The product with code=#{code} wasn't found")

  # Find a product by the variation SKU (currently "barcode" - IT NEEDS TO BE CHANGED)
  findProductByVariationSku: (sku) =>
    @_findOne("variations/any(variation variation/barcode eq '#{sku}')")
      .catch => throw new Error("The product with sku=#{sku} wasn't found")

  # Creates a product
  createProduct: (product) =>
    @returnOne @client.postAsync "/products", @_convertNewToDeprecated(product)

  # Creates one or more variations of a product definition
  createVariations: (productId, variations) =>
    url = "/products/#{productId}/variations"

    variations = (@_convertNewToDeprecated { variations }).variations
    @returnOne @client.postAsync url, variations

  # Updates the stocks of one or more variations
  updateVariationStocks: (productId, adjustments) =>
    url = "/products/#{productId}/stocks"
    @returnOne @client.putAsync url, adjustments

  # Updates the pictures of one or more variations
  updateVariationPictures: (productId, pictures) =>
    url = "/products/#{productId}/pictures"
    @returnOne @client.postAsync url, pictures

  # Updates a product
  updateProduct: (id, update) =>
    @returnOne @client.putAsync "/products/#{id}", @_convertNewToDeprecated(update)

  _getProductsPageByPage: (skip = 0) =>
    TOP = 500
    @returnOne(@client.getAsync "/products?$top=#{TOP}&$skip=#{skip}").then (obj) =>
      products = obj.results
      return products if products.length < TOP
      @_getProductsPageByPage(skip + TOP).then (moreProducts) ->
        products.concat moreProducts

  _findOne: (oDataQuery) =>
    (@returnMany @client.getAsync "/products/?$filter=#{encodeURIComponent oDataQuery}")
      .then (products) =>
        firstMatch = _.first products
        new Product(firstMatch)

  _convertJsonToProducts: (products) =>
    products.map (it) -> new Product it

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
