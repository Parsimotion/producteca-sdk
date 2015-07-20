Adjustment = require("./adjustment")

describe "Ajustment", ->
  it "does trim to the basic properties", ->
    adjustment = new Adjustment
      identifier: "915004085101       "
      name: "COLGANTE CLEMENT 3 X E27 MÁX. 23W NEGRO TELA   "
    adjustment.identifier.should.equal "915004085101"
    adjustment.name.should.equal "COLGANTE CLEMENT 3 X E27 MÁX. 23W NEGRO TELA"

  it "does trim to the inner properties in arrays", ->
    new Adjustment(stocks: [ warehouse: "   hola" ]).stocks[0].warehouse.should.equal "hola"

  describe "parsing price to float...", ->
    it "thousands separator: ','; decimals separator: '.'", ->
      new Adjustment(prices: [ value: "4,160.99" ]).prices[0].value.should.equal 4160.99

    it "thousands separator: '.'; decimals separator: ','", ->
      new Adjustment(prices: [ value: "4.160,99" ]).prices[0].value.should.equal 4160.99

    it "without thousands separator", ->
      new Adjustment(prices: [ value: "4160.99" ]).prices[0].value.should.equal 4160.99

    it "without thousands and decimals separator", ->
      new Adjustment(prices: [ value: "4160" ]).prices[0].value.should.equal 4160

    it "don't try to parse the price if it's a Number", ->
      new Adjustment(prices: [ value: 4160 ]).prices[0].value.should.equal 4160

  describe "parsing stocks to int...", ->
    it "parses the stock to int if it's a string", ->
      new Adjustment(stocks: [ quantity: "2.00" ]).stocks[0].quantity.should.equal 2

    it "don't try to parse the stock if it's a Number", ->
      new Adjustment(stocks: [ quantity: 2 ]).stocks[0].quantity.should.equal 2

    it "intializes the stock in 0 when the provided is lower", ->
      new Adjustment(stocks: [ quantity: "-4.00" ]).stocks[0].quantity.should.equal 0
