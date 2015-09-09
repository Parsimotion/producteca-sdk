global.chai = require("chai")

chai.Should()
chai.use require("sinon-chai")

Product = require("./product")

describe "Product", ->

  it "can update a single price", ->
    product = new Product
      id: 25
      prices: [
        priceList: "Default"
        amount: 180
      ,
        priceList: "Meli"
        amount: 210
      ]

    product.updatePrice "Meli", 270
    product.prices.should.eql [
        priceList: "Default"
        amount: 180
      ,
        priceList: "Meli"
        amount: 270
      ]