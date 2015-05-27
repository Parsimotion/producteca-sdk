AjusteStock = require("./adjustment")

describe "Ajustment", ->
  it "does trim to the basic properties", ->
    ajusteStock = new AjusteStock(identifier: "915004085101       ", name: "COLGANTE CLEMENT 3 X E27 MÁX. 23W NEGRO TELA   ")
    ajusteStock.identifier.should.equal "915004085101"
    ajusteStock.name.should.equal "COLGANTE CLEMENT 3 X E27 MÁX. 23W NEGRO TELA"

  describe "parsing price to float...", ->
    it "thousands separator: ','; decimals separator: '.'", ->
      new AjusteStock(price: "4,160.99").price.should.equal 4160.99

    it "thousands separator: '.'; decimals separator: ','", ->
      new AjusteStock(price: "4.160,99").price.should.equal 4160.99

    it "without thousands separator", ->
      new AjusteStock(price: "4160.99").price.should.equal 4160.99

    it "without thousands and decimals separator", ->
      new AjusteStock(price: "4160").price.should.equal 4160

  it "parses the stock to int", ->
    new AjusteStock(stock: "2.00").stock.should.equal 2

  it "intializes the stock in 0 when the provided is lower", ->
    new AjusteStock(stock: "-4.00").stock.should.equal 0
