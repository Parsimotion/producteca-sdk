(function() {
  var ParsimotionClient, Producto, Promise, azure, restify, _,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  Promise = require("bluebird");

  restify = require("restify");

  _ = require("lodash");

  azure = require("azure-storage");

  Producto = require("./producto");

  module.exports = ParsimotionClient = (function() {
    ParsimotionClient.prototype.initializeClient = function(accessToken) {
      var client, queue;
      client = Promise.promisifyAll(restify.createJSONClient({
        url: config.parsimotion.uri,
        agent: false,
        headers: {
          Authorization: "Bearer " + accessToken
        }
      }));
      queue = azure.createQueueService(process.env.PRODUCTECA_QUEUE_NAME, process.env.PRODUCTECA_QUEUE_KEY);
      client.enqueue = (function(_this) {
        return function(message) {
          return queue.createMessage("requests", message, function() {});
        };
      })(this);
      client.user = client.getAsync("/user/me");
      return client;
    };

    function ParsimotionClient(accessToken, client) {
      this.client = client != null ? client : this.initializeClient(accessToken);
      this._sendUpdateToQueue = __bind(this._sendUpdateToQueue, this);
      this.updatePrice = __bind(this.updatePrice, this);
      this.updateStocks = __bind(this.updateStocks, this);
      this.getProductos = __bind(this.getProductos, this);
    }

    ParsimotionClient.prototype.getProductos = function() {
      return this.client.getAsync("/products").spread(function(req, res, obj) {
        return obj.results;
      }).map(function(json) {
        return new Producto(json);
      });
    };

    ParsimotionClient.prototype.updateStocks = function(adjustment) {
      var body;
      body = _.map(adjustment.stocks, function(it) {
        return {
          variation: it.variation,
          stocks: [
            {
              warehouse: adjustment.warehouse,
              quantity: it.quantity
            }
          ]
        };
      });
      return this._sendUpdateToQueue("products/" + adjustment.id + "/stocks", body);
    };

    ParsimotionClient.prototype.updatePrice = function(product, priceList, amount) {
      var body;
      body = {
        prices: _(product.prices).reject({
          priceList: priceList
        }).concat({
          priceList: priceList,
          amount: amount
        }).value()
      };
      return this._sendUpdateToQueue("products/" + product.id, body);
    };

    ParsimotionClient.prototype._sendUpdateToQueue = function(resource, body) {
      return this.client.user.spread((function(_this) {
        return function(_, __, user) {
          var message;
          message = JSON.stringify({
            method: "PUT",
            companyId: user.company.id,
            resource: resource,
            body: body
          });
          return _this.client.enqueue(message);
        };
      })(this));
    };

    return ParsimotionClient;

  })();

}).call(this);

(function() {
  var ProductecaApi, Promise, sinon;

  sinon = require("sinon");

  Promise = require("bluebird");

  global.chai = require("chai");

  chai.Should();

  chai.use(require("sinon-chai"));

  ProductecaApi = require("./productecaApi");

  ProductecaApi.prototype.initializeClient = (function(_this) {
    return function() {
      return {};
    };
  })(this);

  describe("Producteca API", function() {
    var client, productecaApi;
    client = null;
    productecaApi = null;
    beforeEach(function() {
      var fastPromise;
      fastPromise = function(value) {
        return new Promise(function(resolve) {
          return resolve([null, null, value]);
        });
      };
      client = {
        getAsync: sinon.stub().returns(fastPromise()),
        user: fastPromise({
          company: {
            id: 2
          }
        }),
        enqueue: sinon.stub()
      };
      return productecaApi = new ProductecaApi("", client);
    });
    it("puede hacer update de los stocks", function(done) {
      productecaApi.updateStocks({
        id: 23,
        warehouse: "Almagro",
        stocks: [
          {
            variation: 24,
            quantity: 8
          }
        ]
      });
      return client.getAsync().then((function(_this) {
        return function() {
          client.enqueue.should.have.been.calledWith(JSON.stringify({
            method: "PUT",
            companyId: 2,
            resource: "products/23/stocks",
            body: [
              {
                variation: 24,
                stocks: [
                  {
                    warehouse: "Almagro",
                    quantity: 8
                  }
                ]
              }
            ]
          }));
          return done();
        };
      })(this));
    });
    return it("puede hacer update del precio especificado", function(done) {
      productecaApi.updatePrice({
        id: 25,
        prices: [
          {
            priceList: "Default",
            amount: 180
          }, {
            priceList: "Meli",
            amount: 210
          }
        ]
      }, "Meli", 270);
      return client.getAsync().then((function(_this) {
        return function() {
          client.enqueue.should.have.been.calledWith(JSON.stringify({
            method: "PUT",
            companyId: 2,
            resource: "products/25",
            body: {
              prices: [
                {
                  priceList: "Default",
                  amount: 180
                }, {
                  priceList: "Meli",
                  amount: 270
                }
              ]
            }
          }));
          return done();
        };
      })(this));
    });
  });

}).call(this);
