(function() {
  module.exports = {
    Api: require("./productecaApi"),
    ProductsApi: require("./productsApi"),
    SalesOrdersApi: require("./salesOrdersApi"),
    ContactsApi: require("./contactsApi"),
    OAuthApi: require("./oauthApi")
  };

}).call(this);
