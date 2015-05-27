_ = require("lodash")

smartParseFloat = (str) ->
  if !str?
    return NaN

  if typeof str == 'number'
    return str

  values = str.split /\.|,/

  if values.length == 1
    return Number str

  integerPart = (_.initial values).join ""
  decimalPart = _.last values

  Number (integerPart + "." + decimalPart)

module.exports =

# Stock or Price adjustment
#  dto = {
#    identifier: Product's SKU or Barcode
#    [name]: Description of the product
#    price: New price
#    stock: New quantity (as string)
#  }
class Adjustment
  constructor: (dto) ->
    dto = _.mapValues dto, (it) -> if it? then it.trim() else it

    _.extend @, dto

    @price = smartParseFloat dto.price
    @stock = _.max [0, parseInt dto.stock]
