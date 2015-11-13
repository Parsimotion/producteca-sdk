_ = require("lodash")

havePropertiesEqual = (actual, expected) ->
  _.forOwn expected, (value, key) ->
    if _.isPlainObject value
      return havePropertiesEqual actual[key], value
    value.should.be.eql actual[key]

module.exports = havePropertiesEqual
