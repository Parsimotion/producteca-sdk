module.exports =

  class AdjustmentToNewProductTransformer

    constructor: (@settings = {}) ->

    transform: (adjustment) =>
      product = adjustment.productData()
      product.description = product.description or adjustment.name
      product.sku = adjustment.identifier if @settings.identifier is "sku"
      product.prices = adjustment.forEachPrice (value, priceList = @settings.priceList) =>
        priceList: priceList
        amount: value or 0
      variation = 
        stocks: adjustment.forEachStock (stock, warehouse = @settings.warehouse) =>
          quantity: stock
          warehouse: warehouse
      variation.barcode = adjustment.identifier if @settings.identifier is "barcode"
      product.variations = [variation]

      product
