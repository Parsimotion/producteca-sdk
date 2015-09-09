(function() {
  var Adjustment, Transformer;

  Adjustment = require("./adjustment");

  Transformer = require("./adjustmentToNewProductTransformer");

  describe("AdjustmentToNewProductTransformer", function() {
    it("should create a product with sku when the identifier is set as sku", function() {
      var adjustment, transformer;
      adjustment = new Adjustment({
        identifier: "915004085101       ",
        name: "COLGANTE CLEMENT 3 X E27 MÁX. 23W NEGRO TELA   "
      });
      transformer = new Transformer({
        identifier: "sku",
        priceList: "Default",
        warehouse: "Default"
      });
      return transformer.transform(adjustment).should.eql({
        description: "COLGANTE CLEMENT 3 X E27 MÁX. 23W NEGRO TELA",
        sku: "915004085101",
        prices: [
          {
            priceList: "Default",
            amount: 0
          }
        ],
        variations: [
          {
            stocks: [
              {
                warehouse: "Default",
                quantity: 0
              }
            ]
          }
        ]
      });
    });
    it("should create a product with barcode when the identifier is set as sku", function() {
      var adjustment, transformer;
      adjustment = new Adjustment({
        identifier: "915004085101       ",
        name: "COLGANTE CLEMENT 3 X E27 MÁX. 23W NEGRO TELA   "
      });
      transformer = new Transformer({
        identifier: "barcode",
        priceList: "Default",
        warehouse: "Default"
      });
      return transformer.transform(adjustment).should.eql({
        description: "COLGANTE CLEMENT 3 X E27 MÁX. 23W NEGRO TELA",
        prices: [
          {
            priceList: "Default",
            amount: 0
          }
        ],
        variations: [
          {
            barcode: "915004085101",
            stocks: [
              {
                warehouse: "Default",
                quantity: 0
              }
            ]
          }
        ]
      });
    });
    return it("should create a product with prices", function() {
      var adjustment, transformer;
      adjustment = new Adjustment({
        identifier: "915004085101       ",
        name: "COLGANTE CLEMENT 3 X E27 MÁX. 23W NEGRO TELA   ",
        prices: [
          {
            priceList: "Mayorista",
            value: 50
          }, {
            priceList: "Minorista",
            value: 70
          }
        ]
      });
      transformer = new Transformer({
        identifier: "sku",
        warehouse: "Default"
      });
      return transformer.transform(adjustment).should.eql({
        description: "COLGANTE CLEMENT 3 X E27 MÁX. 23W NEGRO TELA",
        sku: "915004085101",
        prices: [
          {
            priceList: "Mayorista",
            amount: 50
          }, {
            priceList: "Minorista",
            amount: 70
          }
        ],
        variations: [
          {
            stocks: [
              {
                warehouse: "Default",
                quantity: 0
              }
            ]
          }
        ]
      });
    });
  });

}).call(this);
