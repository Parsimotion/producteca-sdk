_ = require("lodash")
module.exports =

class Product
  constructor: (properties) ->
    _.extend @, properties

  hasVariations: =>
    _.size @variations > 1

  findVariationBySku: (sku) =>
    if not @hasVariations()
      return @firstVariation()

    _.find @variations, {sku}

  firstVariation: =>
    _.head @variations

  hasAllDimensions: =>
    ["width", "height", "length", "weight"].every (it) => @dimensions[it]?

  toJSON: =>
    _.omit @, _.isFunction

  updateWith: (obj) =>
    _.assign @, obj

  # ---
  # RETROCOMPATIBILITY
  # ---

  hasVariantes: => @hasVariations()

  getVariationForAdjustment: (adjustment) =>
    _.find @variations, (it) => it.barcode is adjustment.identifier

  updatePrice: (priceList, amount) =>
    @prices =
      _(@prices)
        .reject priceList: priceList
        .concat { priceList, amount }
      .value()
