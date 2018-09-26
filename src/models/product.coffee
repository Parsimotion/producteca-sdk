_ = require("lodash")
module.exports =

class Product
  constructor: (properties) ->
    _.extend @, properties

  hasVariations: =>
    _.size(@variations) > 1

  findVariationBySku: (sku) =>
    _.find @variations, (variation) -> variation.sku?.toUpperCase().trim() is sku?.toUpperCase().trim()

  firstVariation: =>
    _.head @variations

  hasAllDimensions: =>
    ["width", "height", "length", "weight"].every (it) => @dimensions[it]?

  updatePrice: (priceList, amount) =>
    @prices =
      _(@prices)
        .reject priceList: priceList
        .concat { priceList, amount }
      .value()
