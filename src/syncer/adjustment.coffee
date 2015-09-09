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

    if @prices?
      @prices.forEach (it) =>
        it.value = @_adaptPrice it.value
    else
      @price = @_adaptPrice @price

    if @stocks?
      @stocks?.forEach (it) =>
        it.quantity = @_adaptStock it.quantity
    else
      @stock = @_adaptStock @stock

  # Executes a function(value, priceList) for each price in the adjustment
  forEachPrice: (fn) =>
    if not @prices? then return fn @price
    @prices.forEach ({ value, priceList }) => fn value, priceList

  # Executes a function(quantity, warehouse) for each stock in the adjustment
  forEachStock: (fn) =>
    if not @stocks? then return fn @stock
    @stocks.forEach ({ quantity, warehouse }) => fn quantity, warehouse

  _adaptPrice: (price) => smartParseFloat price
  _adaptStock: (stock) => _.max [0, smartParseInt stock]

  productData: => _.omit _.omit(@, ['price', 'prices', 'stock', 'stocks', 'identifier', 'sku']), _.isFunction
