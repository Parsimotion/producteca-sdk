ProductecaApi = require("./productecaApi")
Product = require("./models/product")
_ = require("lodash")
module.exports =

class ProductsApi extends ProductecaApi
  constructor: (endpoint) ->
    @resource = "products"
    super endpoint

  # Returns a product by id
  get: (id) =>
    (@client.getAsync("/products/#{id}")).then @_convertJsonToProduct

  # Returns all the products
  getAll: =>
    @_getPageByPage().then @_convertJsonToProducts

  # Returns multiple products by their comma separated ids
  getMany: (ids) =>
    (@client.getAsync("/products?ids=#{ids}")).then @_convertJsonToProducts

  # Find products by code
  findByCode: (code, $select) =>
    @_findMany "code eq '#{code}'", $select

  # Find products by a variation SKU
  findByVariationSku: (sku) =>
    (@client.getAsync("/products/bysku?sku=#{encodeURIComponent(sku)}")).then @_convertJsonToProducts

  # Creates a product
  create: (product) =>
    @client.postAsync "/products", product

  # Creates one or more variations of a product definition
  createVariations: (productId, variations) =>
    url = "/products/#{productId}/variations"
    @client.postAsync url, variations

  # Updates one or more variations of a product definition
  updateVariation: (productId, variations) =>
    url = "/products/#{productId}/variations"
    @client.putAsync url, variations

  # Updates the stocks of one or more variations
  updateVariationStocks: (productId, adjustments) =>
    url = "/products/#{productId}/stocks"
    @client.putAsync url, adjustments

  # Add the pictures of one or more variations
  addVariationPictures: (productId, pictures) =>
    url = "/products/#{productId}/pictures"
    @client.postAsync url, pictures

  # Updates the pictures of one or more variations
  updateVariationPictures: (productId, pictures) =>
    url = "/products/#{productId}/pictures"
    @client.putAsync url, pictures

  # Updates product prices
  updatePrices: (id, update) =>
    @client.putAsync "/products/#{id}/prices", update

  # Updates basic product properties
  simpleUpdate: (id, update) =>
    @client.putAsync "/products/#{id}/simple", update

  # Updates a product
  update: (id, update) =>
    @client.putAsync "/products/#{id}", update

  # Creates a warehouse
  createWarehouse: (name) =>
    @client.postAsync "/warehouses", { name }

  # Creates a full warehouse
  createWarehouseWithIntegration: (warehouse) =>
    @client.postAsync "/warehouses", warehouse

  # Retrieves all the pricelists
  getPricelists: =>
    @client.getAsync "/pricelists"

  # Retrieves all the warehouses
  getWarehouses: =>
    @client.getAsync "/warehouses"

  # Retrieves a chunk of skus
  getSkus: (skip = 0, top = 20, moreQueryString = "") =>
    @client.getAsync "/products/skus?$top=#{top}&$skip=#{skip}&#{moreQueryString}"

  _findMany: ($filter, $select = "") =>
    query = "?$filter=#{encodeURIComponent $filter}"

    if $select isnt ""
      query += "&$select=#{encodeURIComponent $select}"

    (@respondMany @client.getAsync "/products/#{query}").then @_convertJsonToProducts

  _convertJsonToProducts: (products) =>
    products.map @_convertJsonToProduct

  _convertJsonToProduct: (json) =>
    new Product json
