_ = require("lodash")

smartParseFloat = (str) ->
  if !str?
    return NaN

  if _.isNumber(str)
    return str

  values = str.split /\.|,/

  if values.length == 1
    return Number str

  integerPart = (_.initial values).join ""
  decimalPart = _.last values

  Number (integerPart + "." + decimalPart)

smartParseInt = (n) =>
  if _.isNumber n then n
  else parseInt n

module.exports =

# Stock or Price adjustment
#  dto = {
#    identifier: Product's SKU or Barcode
#    [name]: Description of the product
#    price: New price
#    stock: New quantity
#  }
class Adjustment
  constructor: (dto) ->
    dto = _.mapValues dto, (it) ->
      if _.isString it then it.trim() else it

    _.extend @, dto

    @price = smartParseFloat dto.price
    @stock = _.max [0, smartParseInt dto.stock]
