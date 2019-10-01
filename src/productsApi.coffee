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
    @_findMany "/products", { ids }

  # Find products by code and optionally sku
  findByCode: (code, sku, $select) =>
    @_findMany "/products/bycode", { code, sku }, $select

  # Find products by a variation SKU
  findByVariationSku: (sku, $select) =>
    @_findMany "/products/bysku", { sku }, $select

  # Creates a product
  create: (product, opts) =>
    @client.postAsync "/products", product, opts

  # Creates one integration of a product definition
  createIntegration: (productId, integration) =>
    url = "/products/#{productId}/integrations"
    @client.postAsync url, integration

  # Updates one integration of a product definition
  updateIntegration: (productId, integration, appId) =>
    url = "/products/#{productId}/integrations"
    headers = { "x-app-id" : appId } if appId
    @client.putAsync url, integration, { headers }

  # Creates one or more variations of a product definition
  createVariations: (productId, variations, opts) =>
    url = "/products/#{productId}/variations"
    @client.postAsync url, variations, opts

  # Deletes one or more variations of a product definition
  deleteVariations: (productId, variationIds) =>
    url = "/products/#{productId}/variations"
    ids = variationIds.join(",");
    @client.deleteAsync url, { qs: { ids } }

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

  # Updates product attributes
  updateAttributes: (id, update) =>
    @client.putAsync "/products/#{id}/attributes", update

  # Updates product metadata
  updateMetadata: (id, update) =>
    @client.putAsync "/products/#{id}/metadata", update

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

  _findMany: (url, qs = {}, $select) =>
    _.assign qs, { $select: $select?.join() }
    (@client.getAsync(url, { qs })).then @_convertJsonToProducts

  _convertJsonToProducts: (products) =>
    products.map @_convertJsonToProduct

  _convertJsonToProduct: (json) =>
    new Product json
