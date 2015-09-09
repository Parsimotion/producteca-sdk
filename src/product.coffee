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

  updatePrice: (priceList, amount) =>
    @prices =
      _(@prices)
        .reject priceList: priceList
        .concat
          priceList: priceList
          amount: amount
      .value()

  toJSON: =>
    _.omit @, _.isFunction