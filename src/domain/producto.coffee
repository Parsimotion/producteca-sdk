_ = require("lodash")

module.exports =

class Producto
  constructor: (properties) ->
    _.extend @, properties

  hasVariantes: =>
    _.size @variations > 1

  getVarianteParaAjuste: (ajuste, settings) =>
    if !ajuste.color?
      return _.head @variations

    talle = if isNaN ajuste.talle then (@_find settings.sizes, ajuste.talle) else ajuste.talle
    @getVariantePorColorYTalle (@_find settings.colors, ajuste.color), talle

  getVariantePorColorYTalle: (color, talle) =>
    _.find @variations, (it) -> it.primaryColor == color && it.size == talle

  _find: (valores, buscado) =>
    mapping = _.find valores, original: buscado

    if !mapping?
      throw new Error "No hay mapping para #{buscado} en #{JSON.stringify valores}"
    else
      mapping.parsimotion
