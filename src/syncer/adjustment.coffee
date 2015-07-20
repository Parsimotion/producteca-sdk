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

trimIfStr = (str) =>
  if _.isString str then str.trim()
  else str

module.exports =

# Stock or Price adjustment
#  dto = {
#    identifier: Product's SKU or Barcode
#    [name]: Description of the product
#    prices: [
#      { priceList: "A priceList", value: "19909.4991" }
#    ]
#    stocks: [
#      { warehouse: "A warehouse", quantity: "27" }
#    ]
#
#    *mono-pricelist-and-warehouse*:
#    price: New price
#    stock: New quantity
#  }
class Adjustment
  constructor: (dto) ->
    dto = _.mapValues dto, (it) ->
      if _.isArray it
        it.map (val) => _.mapValues val, (inner) => trimIfStr inner
      else trimIfStr it

    _.extend @, dto

    @prices?.forEach (it) =>
      it.value = @_adaptPrice it.value
    @stocks?.forEach (it) =>
      it.quantity = @_adaptStock it.quantity

    @price = @_adaptPrice @price
    @stock = @_adaptStock @stock

  # Executes a function(value, priceList) for each price in the adjustment
  forEachPrice: (fn) =>
    (@prices?.forEach ({ priceList, value }) =>
      fn value, priceList
    ) || fn @price

  # Executes a function(quantity, warehouse) for each stock in the adjustment
  forEachStock: (fn) =>
    (@stocks?.forEach ({ warehouse, quantity }) =>
      fn quantity, warehouse
    ) || fn @stock

  _adaptPrice: (price) => smartParseFloat price
  _adaptStock: (stock) => _.max [0, smartParseInt stock]
