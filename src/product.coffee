_ = require("lodash")
module.exports =

class Product
  constructor: (properties) ->
    _.extend @, properties

  hasVariantes: =>
    _.size @variations > 1

  getVariationForAdjustment: (adjustment) =>
    _.find @variations, (it) => it.barcode is adjustment.identifier

  firstVariation: =>
    _.head @variations
