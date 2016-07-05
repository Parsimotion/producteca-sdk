(function() {
  var ContactsApi, ProductecaApi,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  ProductecaApi = require("./productecaApi");

  module.exports = ContactsApi = (function(_super) {
    __extends(ContactsApi, _super);

    function ContactsApi() {
      this.update = __bind(this.update, this);
      this.create = __bind(this.create, this);
      return ContactsApi.__super__.constructor.apply(this, arguments);
    }

    ContactsApi.prototype.create = function(contact) {
      return this.client.postAsync("/contacts", contact);
    };

    ContactsApi.prototype.update = function(contact) {
      return this.client.putAsync("/contacts", contact);
    };

    return ContactsApi;

  })(ProductecaApi);

}).call(this);