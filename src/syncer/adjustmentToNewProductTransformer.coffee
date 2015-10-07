module.exports =

  class AdjustmentToNewProductTransformer

    constructor: (@settings = {}) ->

    transform: (adjustments) =>
      firstAdjustment = adjustments[0]
      product = firstAdjustment.productData()
      product.description = product.description or firstAdjustment.name
      product.sku = if @settings.identifier is "sku" then firstAdjustment.identifier else firstAdjustment.code
      product.prices = firstAdjustment.forEachPrice (value, priceList = @settings.priceList) =>
        priceList: priceList
        amount: value or 0

      product.variations = adjustments.map (adjustment) =>
        variation = 
          pictures: adjustment.pictures
          stocks: adjustment.forEachStock (stock, warehouse = @settings.warehouse) =>
            quantity: stock
            warehouse: warehouse
          primaryColor: adjustment.primaryColor
          secondaryColor: adjustment.secondaryColor
          size: adjustment.size
        variation.barcode = adjustment.identifier if @settings.identifier is "barcode"
        variation

      product
