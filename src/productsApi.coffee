ProductecaApi = require("./productecaApi")
Product = require("./models/product")
_ = require("lodash")
module.exports =

class ProductsApi extends ProductecaApi
  # Returns a product by id
  get: (id) =>
    (@respond @client.getAsync("/products/#{id}")).then @_convertJsonToProduct

  # Returns all the products
  getAll: =>
    @_getProductsPageByPage().then @_convertJsonToProducts

  # Returns multiple products by their comma separated ids
  getMany: (ids) =>
    (@respond @client.getAsync("/products?ids=#{ids}")).then @_convertJsonToProducts

  # Find a product by code (currently "sku" - IT NEEDS TO BE CHANGED)
  findByCode: (code, $select) =>
    @_findOne("sku eq '#{code}'", $select)
      .catch => throw new Error("The product with code=#{code} wasn't found")

  # Find products by a variation SKU (currently "barcode" - IT NEEDS TO BE CHANGED)
  findByVariationSku: (sku) =>
    (@respond @client.getAsync("/products/bysku/#{sku}")).then @_convertJsonToProducts

  # Creates a product
  create: (product) =>
    @respond @client.postAsync "/products", @_convertNewToDeprecated(product)

  # Creates one or more variations of a product definition
  createVariations: (productId, variations) =>
    url = "/products/#{productId}/variations"

    variations = (@_convertNewToDeprecated { variations }).variations
    @respond @client.postAsync url, variations

  # Updates the stocks of one or more variations
  updateVariationStocks: (productId, adjustments) =>
    url = "/products/#{productId}/stocks"
    @respond @client.putAsync url, adjustments

  # Updates the pictures of one or more variations
  updateVariationPictures: (productId, pictures) =>
    url = "/products/#{productId}/pictures"
    @respond @client.postAsync url, pictures

  # Updates a product
  update: (id, update) =>
    @respond @client.putAsync "/products/#{id}", @_convertNewToDeprecated(update)

  _getProductsPageByPage: (skip = 0) =>
    TOP = 500
    @respond(@client.getAsync "/products?$top=#{TOP}&$skip=#{skip}").then (obj) =>
      products = obj.results
      return products if products.length < TOP
      @_getProductsPageByPage(skip + TOP).then (moreProducts) ->
        products.concat moreProducts

  _findOne: ($filter, $select = "") =>
    query = "?$filter=#{encodeURIComponent $filter}"

    if $select isnt ""
      query += "&$select=#{encodeURIComponent $select}"

    (@respondMany @client.getAsync "/products/#{query}")
      .then (products) =>
        throw new Error("product not found") if _.isEmpty products
        firstMatch = _.first products
        @_convertJsonToProduct firstMatch

  _convertJsonToProducts: (products) =>
    products.map @_convertJsonToProduct

  _convertJsonToProduct: (json) =>
    new Product @_convertDeprecatedToNew json

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
