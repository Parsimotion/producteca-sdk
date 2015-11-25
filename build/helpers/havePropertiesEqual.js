(function() {
  var clean, expect, havePropertiesEqual, _;

  _ = require("lodash");

  expect = require("chai").expect;

  clean = function(it) {
    return JSON.stringify(it);
  };

  havePropertiesEqual = function(oldObject, newObject) {
    var keys;
    if ((oldObject == null) && (newObject != null)) {
      return false;
    }
    if ((oldObject != null) && (newObject == null)) {
      return false;
    }
    keys = _.keys(newObject);
    return _.every(keys, function(key) {
      var value;
      value = newObject[key];
      if (_.isPlainObject(value) || _.isArray(value)) {
        return havePropertiesEqual(oldObject[key], value);
      }
      return expect(clean(oldObject[key])).to.eql(clean(value));
    });
  };

  module.exports = havePropertiesEqual;

}).call(this);
