ProductecaApi = require("./productecaApi")
Product = require("./models/product")
_ = require("lodash")
module.exports =

class ProductsApi extends ProductecaApi
  constructor: (endpoint) ->
    @resource = "products"
    super endpoint

  # Returns a product by id
  get: (id, opts) =>
    (@client.getAsync("/products/#{id}", opts)).then @_convertJsonToProduct

  # Returns multiple products by their comma separated ids
  getMany: (ids, opts) =>
    @_findMany { url: "/products/multi", qs: { ids }, opts }

  # Find products by code and optionally sku
  findByCode: (code, sku, $select, opts) =>
    @_findMany { url: "/products/bycode", qs: { code, sku }, $select, opts }

  # Find products by integrationId
  findByIntegrationId: (app, integrationId) =>
    @client.getAsync "/products/byintegration", { qs: { app, integrationId } }
    .then @_convertJsonToProduct

  # Find products by a variation SKU
  findByVariationSku: (sku, $select, opts) =>
    @_findMany { url: "/products/bysku", qs: { sku }, $select, opts }

  # Find products by a variation integrationId
  findByVariationIntegrationId: (integrationId, $select, opts) =>
    @_findMany { url: "/products/byvariationintegration", qs: { integrationId }, $select, opts }

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

  # Delete one integration of a product definition
  deleteIntegration: (productId, integrationId, { ignoreParentIntegrationId } = {}) =>
    url = "/products/#{productId}/integrations/#{integrationId}"
    ignoreParentIntegrationId ?= false
    @client.deleteAsync url, { qs: { ignoreParentIntegrationId } }

  # Creates one or more variations of a product definition
  createVariations: (productId, variations, appId) =>
    url = "/products/#{productId}/variations"
    headers = { "x-app-id" : appId } if appId
    @client.postAsync url, variations, { headers }

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

  # Gets a warehouse by its integration
  getWarehouseByIntegration: (integrationId, app) =>
    @client.getAsync "/warehouses/byIntegration", { qs: { integrationId, app } }

  # Retrieves all the warehouses
  getWarehouses: =>
    @client.getAsync "/warehouses"

  # Retrieves a warehouse by id
  getWarehouse: (id) =>
    @client.getAsync "/warehouses/#{id}"

  # Retrieves all the pricelists
  getPricelists: =>
    @client.getAsync "/pricelists"

  _findMany: ({ url, qs = {}, $select, opts = {} }) =>
    _.assign qs, { $select: $select?.join() }
    _.assign opts, { qs }
    (@client.getAsync(url, opts)).then @_convertJsonToProducts

  _convertJsonToProducts: (products) =>
    products.map @_convertJsonToProduct

  _convertJsonToProduct: (json) =>
    new Product json
