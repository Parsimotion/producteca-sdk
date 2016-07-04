(function() {
  var BrandsApi, ProductecaApi,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  ProductecaApi = require("./productecaApi");

  module.exports = BrandsApi = (function(_super) {
    __extends(BrandsApi, _super);

    function BrandsApi() {
      this["delete"] = __bind(this["delete"], this);
      this.createByName = __bind(this.createByName, this);
      this.getAll = __bind(this.getAll, this);
      this.get = __bind(this.get, this);
      return BrandsApi.__super__.constructor.apply(this, arguments);
    }

    BrandsApi.prototype.get = function(id) {
      return this.client.getAsync("/brands/" + id);
    };

    BrandsApi.prototype.getAll = function() {
      return this.client.getAsync("/brands");
    };

    BrandsApi.prototype.createByName = function(brandName) {
      return this.client.postAsync("/brands", {
        name: brandName
      });
    };

    BrandsApi.prototype["delete"] = function(id) {
      return this.client.delAsync("/brands/" + id);
    };

    return BrandsApi;

  })(ProductecaApi);

}).call(this);
