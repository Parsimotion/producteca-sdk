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
  createIntegration: (productId, integration, opts) =>
    url = "/products/#{productId}/integrations"
    @client.postAsync url, integration, opts

  # Updates one integration of a product definition
  updateIntegration: (productId, integration, appId, opts) =>
    url = "/products/#{productId}/integrations"
    headers = { "x-app-id" : appId } if appId
    @client.putAsync url, integration, _.merge { headers }, opts

  # Delete one integration of a product definition
  deleteIntegration: (productId, integrationId, { ignoreParentIntegrationId } = {}, opts) =>
    url = "/products/#{productId}/integrations/#{integrationId}"
    ignoreParentIntegrationId ?= true
    @client.deleteAsync url, _.merge { qs: { ignoreParentIntegrationId } }, opts

  # Creates one or more variations of a product definition
  createVariations: (productId, variations, appId, opts) =>
    url = "/products/#{productId}/variations"
    headers = { "x-app-id" : appId } if appId
    @client.postAsync url, variations, _.merge { headers }, opts

  # Deletes one or more variations of a product definition
  deleteVariations: (productId, variationIds, opts) =>
    url = "/products/#{productId}/variations"
    ids = variationIds.join(",");
    @client.deleteAsync url, _.merge { qs: { ids } }, opts

  # Updates one or more variations of a product definition
  updateVariation: (productId, variations, opts) =>
    url = "/products/#{productId}/variations"
    @client.putAsync url, variations, opts

  # Updates the stocks of one or more variations
  updateVariationStocks: (productId, adjustments, opts) =>
    url = "/products/#{productId}/stocks"
    @client.putAsync url, adjustments, opts

  # Add the pictures of one or more variations
  addVariationPictures: (productId, pictures, opts) =>
    url = "/products/#{productId}/pictures"
    @client.postAsync url, pictures, opts

  # Updates the pictures of one or more variations
  updateVariationPictures: (productId, pictures, opts) =>
    url = "/products/#{productId}/pictures"
    @client.putAsync url, pictures, opts

  # Create the variation integration of the correspondent variation
  createVariationIntegration: (productId, variationId, variationIntegration, opts) =>
    url = "/products/#{productId}/variations/#{variationId}/integrations"
    @client.postAsync url, variationIntegration, opts

  # Updates product prices
  updatePrices: (id, update, opts) =>
    @client.putAsync "/products/#{id}/prices", update, opts

  # Updates product attributes
  updateAttributes: (id, update, opts) =>
    @client.putAsync "/products/#{id}/attributes", update, opts

  # Updates product metadata
  updateMetadata: (id, update, opts) =>
    @client.putAsync "/products/#{id}/metadata", update, opts

  # Updates a product
  update: (id, update, opts) =>
    @client.putAsync "/products/#{id}", update, opts

  # Creates a warehouse
  createWarehouse: (name, opts) =>
    @client.postAsync "/warehouses", { name }, opts

  # Creates a full warehouse
  createWarehouseWithIntegration: (warehouse, opts) =>
    @client.postAsync "/warehouses", warehouse, opts

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

  _convertJsonToProducts: (products) =>
    products.map @_convertJsonToProduct

  _findMany: (opts) => 
    super opts
    .then @_convertJsonToProducts

  _convertJsonToProduct: (json) =>
    new Product json
