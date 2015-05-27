Q = require("q")
_ = require("lodash")

module.exports =

# Synchronizer of prices and stocks
#  productecaApi = An instance of *ProductecaApi*
#  settings = {
#    synchro: {
#      prices: true or false
#      stocks: true or false
#    }
#    priceList: Name of the price list
#    warehouse: Name of the warehouse
#    identifier: "sku" or "barcode"
#  }
#  products = Array of *Product*
class Syncer
  constructor: (@productecaApi, @settings, @products) ->

  # Executes the sync with *adjustments*.
  # Returns a promise with a summary of the results
  execute: (adjustments) =>
    adjustmentsAndProducts = @_joinAdjustmentsAndProducts adjustments

    (Q.allSettled @_updateStocksAndPrices adjustmentsAndProducts).then (results) =>
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

  _updateStocksAndPrices: (adjustmentsAndProducts) =>
    syncPrices = @settings.synchro.prices
    syncStocks = @settings.synchro.stocks

    adjustmentsAndProducts.linked.map (it) =>
      products = it.products

      updateIf = (condition, update) =>
        if condition then products.map update else []

      Q.all _.flatten [
        updateIf syncPrices, (p) => @_updatePrice it.adjustment, p
        updateIf syncStocks, (p) => @_updateStock it.adjustment, p
      ]
      .then =>
        ids: _.map products, "id"
        identifier: it.adjustment.identifier

  _updatePrice: (adjustment, product) =>
    console.log "Updating price of ~#{adjustment.identifier}(#{product.id}) with value $#{adjustment.price}..."
    @productecaApi.updatePrice product, @settings.priceList, adjustment.price

  _updateStock: (adjustment, product) =>
    variationId = @_getVariation(product, adjustment).id

    console.log "Updating stock of ~#{adjustment.identifier}(#{product.id}, #{variationId}) with quantity #{adjustment.stock}..."
    @productecaApi.updateStocks
      id: product.id
      warehouse: @settings.warehouse
      stocks: [
        variation: variationId
        quantity: adjustment.stock
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
