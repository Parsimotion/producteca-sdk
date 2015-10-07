Q = require("q")
_ = require("lodash")
AdjustmentToNewProductTransformer = require("./adjustmentToNewProductTransformer")

module.exports =

# Synchronizer of prices and stocks
#  productecaApi = An instance of *ProductecaApi*
#  settings = {
#    synchro: {
#      prices: true or false
#      stocks: true or false
#      data: true or false
#    }
#    priceList: Name of the default price list (used when the adjustment doesn't have one)
#    warehouse: Name of the default warehouse (used when the adjustment doesn't have one)
#    identifier: "sku" or "barcode"
#    createProducts: true or false
#  }
#  products = Array of *Product*
class Syncer
  constructor: (@productecaApi, @settings, @products) ->

  # Executes the sync with *adjustments*.
  # Returns a promise with a summary of the results
  execute: (adjustments) =>
    adjustmentsAndProducts = @_joinAdjustmentsAndProducts adjustments
    promises = @_sync adjustmentsAndProducts

    if @settings.createProducts
        promises = promises.concat @_createProducts adjustmentsAndProducts.unlinked

    (Q.allSettled promises).then (results) =>
      _.mapValues adjustmentsAndProducts, (adjustmentsAndProducts) =>
        adjustmentsAndProducts.map (it) => _.pick it.adjustment, "identifier"

  _joinAdjustmentsAndProducts: (adjustments) =>
    join = _(adjustments)
    .filter "identifier"
    .groupBy "identifier"
    .map (adjustments) =>
      adjustment = _.head adjustments

      adjustment: adjustment
      products: @_getProductsForAdjustments adjustment
    .value()

    hasProducts = (it) => not _.isEmpty it.products

    linked: _.filter join, hasProducts
    unlinked: _.reject join, hasProducts

  _sync: (adjustmentsAndProducts) =>
    syncProducts = @_shouldSyncProductData()
    syncStocks = @settings.synchro.stocks

    adjustmentsAndProducts.linked.map (it) =>
      products = it.products

      updateIf = (condition, update) =>
        if condition then products.map update else []

      Q.all _.flatten [
        updateIf syncProducts, (p) => @_updateProduct it.adjustment, p
        updateIf syncStocks, (p) => @_updateStock it.adjustment, p
      ]
      .then =>
        ids: _.map products, "id"
        identifier: it.adjustment.identifier

  _updateProduct: (adjustment, product) =>
    if @settings.synchro.prices
      adjustment.forEachPrice (price, priceList = @settings.priceList) =>
        console.log "Updating price of ~#{adjustment.identifier}(#{product.id}) in priceList #{priceList} with value $#{price}..."
        product.updatePrice priceList, price

    if @settings.synchro.data
      product.updateWith adjustment.productData()

    @productecaApi.updateProduct product

  _updateStock: (adjustment, product) =>
    variationId = @_getVariation(product, adjustment).id

    adjustment.forEachStock (stock, warehouse = @settings.warehouse) =>
      console.log "Updating stock of ~#{adjustment.identifier}(#{product.id}, #{variationId}) in warehouse #{warehouse} with quantity #{stock}..."
      @productecaApi.updateStocks
        id: product.id
        warehouse: warehouse
        stocks: [
          variation: variationId
          quantity: stock
        ]

  _getStock: (product) =>
    stock = _.find (@_getVariation product).stocks, warehouse: @settings.warehouse
    if stock? then stock.quantity else 0

  _getVariation: (product, adjustment) =>
    product.getVariationForAdjustment(adjustment) || product.firstVariation()

  _getProductsForAdjustments: (adjustment) =>
    findBySku = => _.filter @products, sku: adjustment.identifier
    return findBySku() if @settings.identifier is "sku"

    matches = _(@products)
      .filter (it) => it.getVariationForAdjustment(adjustment)?
      .value()

    if _.isEmpty matches then findBySku()
    else matches

  _shouldSyncProductData: =>
    @settings.synchro.prices or @settings.synchro.data

  _createProducts: (unlinkeds) =>
    transformer = new AdjustmentToNewProductTransformer @settings
    adjustments = unlinkeds.map (it) -> it.adjustment
    groupedAdjustmentsObj = _.groupBy adjustments, 'code'
    noCodeAdjustments = groupedAdjustmentsObj[undefined]?.map (it) -> [it]
    withCodeAdjustments = _.values _.omit groupedAdjustmentsObj, (it) -> it is undefined

    withCodeAdjustments.concat(noCodeAdjustments or []).map (adjustments) =>
      @productecaApi.createProduct transformer.transform adjustments

