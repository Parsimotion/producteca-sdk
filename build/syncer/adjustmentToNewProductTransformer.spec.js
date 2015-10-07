(function() {
  var Adjustment, Transformer;

  Adjustment = require("./adjustment");

  Transformer = require("./adjustmentToNewProductTransformer");

  describe("AdjustmentToNewProductTransformer", function() {
    it("should create a product with sku when the identifier is set as sku", function() {
      var adjustments, transformer;
      adjustments = [
        new Adjustment({
          identifier: "915004085101       ",
          name: "COLGANTE CLEMENT 3 X E27 MÁX. 23W NEGRO TELA   ",
          pictures: [
            {
              url: "http://pictures.com"
            }
          ]
        })
      ];
      transformer = new Transformer({
        identifier: "sku",
        priceList: "Default",
        warehouse: "Default"
      });
      return transformer.transform(adjustments).should.eql({
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
            pictures: [
              {
                url: "http://pictures.com"
              }
            ],
            stocks: [
              {
                warehouse: "Default",
                quantity: 0
              }
            ],
            primaryColor: void 0,
            secondaryColor: void 0,
            size: void 0
          }
        ]
      });
    });
    it("should create a product with barcode when the identifier is set as barcode", function() {
      var adjustments, transformer;
      adjustments = [
        new Adjustment({
          identifier: "915004085101       ",
          name: "COLGANTE CLEMENT 3 X E27 MÁX. 23W NEGRO TELA   ",
          pictures: [
            {
              url: "http://pictures.com"
            }
          ]
        })
      ];
      transformer = new Transformer({
        identifier: "barcode",
        priceList: "Default",
        warehouse: "Default"
      });
      return transformer.transform(adjustments).should.eql({
        description: "COLGANTE CLEMENT 3 X E27 MÁX. 23W NEGRO TELA",
        sku: void 0,
        prices: [
          {
            priceList: "Default",
            amount: 0
          }
        ],
        variations: [
          {
            barcode: "915004085101",
            pictures: [
              {
                url: "http://pictures.com"
              }
            ],
            stocks: [
              {
                warehouse: "Default",
                quantity: 0
              }
            ],
            primaryColor: void 0,
            secondaryColor: void 0,
            size: void 0
          }
        ]
      });
    });
    it("should create a product with prices", function() {
      var adjustments, transformer;
      adjustments = [
        new Adjustment({
          identifier: "915004085101       ",
          name: "COLGANTE CLEMENT 3 X E27 MÁX. 23W NEGRO TELA   ",
          pictures: [
            {
              url: "http://pictures.com"
            }
          ],
          prices: [
            {
              priceList: "Mayorista",
              value: 50
            }, {
              priceList: "Minorista",
              value: 70
            }
          ]
        })
      ];
      transformer = new Transformer({
        identifier: "sku",
        warehouse: "Default"
      });
      return transformer.transform(adjustments).should.eql({
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
            pictures: [
              {
                url: "http://pictures.com"
              }
            ],
            stocks: [
              {
                warehouse: "Default",
                quantity: 0
              }
            ],
            primaryColor: void 0,
            secondaryColor: void 0,
            size: void 0
          }
        ]
      });
    });
    return it("can create a product definition with variations", function() {
      var adjustments, product, transformer;
      adjustments = [
        new Adjustment({
          code: "12345",
          identifier: "915004085101       ",
          name: "COLGANTE CLEMENT 3 X E27 MÁX. 23W NEGRO TELA   ",
          pictures: [
            {
              url: "http://picture1.com"
            }
          ],
          prices: [
            {
              priceList: "Mayorista",
              value: 50
            }, {
              priceList: "Minorista",
              value: 70
            }
          ],
          stocks: [
            {
              warehouse: "Default",
              quantity: 3
            }
          ]
        }), new Adjustment({
          code: "12345",
          identifier: "915004085102       ",
          name: "COLGANTE CLEMENT 3 X E27 MÁX. 23W NEGRO TELA   ",
          pictures: [
            {
              url: "http://picture2.com"
            }
          ],
          prices: [
            {
              priceList: "Mayorista",
              value: 50
            }, {
              priceList: "Minorista",
              value: 70
            }
          ],
          stocks: [
            {
              warehouse: "Default",
              quantity: 4
            }
          ]
        })
      ];
      transformer = new Transformer({
        identifier: "barcode",
        warehouse: "Default"
      });
      product = transformer.transform(adjustments);
      console.log(product);
      return product.should.eql({
        description: "COLGANTE CLEMENT 3 X E27 MÁX. 23W NEGRO TELA",
        sku: "12345",
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
            pictures: [
              {
                url: "http://picture1.com"
              }
            ],
            stocks: [
              {
                warehouse: "Default",
                quantity: 3
              }
            ],
            barcode: "915004085101",
            primaryColor: void 0,
            secondaryColor: void 0,
            size: void 0
          }, {
            pictures: [
              {
                url: "http://picture2.com"
              }
            ],
            stocks: [
              {
                warehouse: "Default",
                quantity: 4
              }
            ],
            barcode: "915004085102",
            primaryColor: void 0,
            secondaryColor: void 0,
            size: void 0
          }
        ]
      });
    });
  });

}).call(this);
