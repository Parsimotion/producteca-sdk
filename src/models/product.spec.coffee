global.chai = require("chai")

chai.Should()
chai.use require("sinon-chai")

Product = require("./product")

describe.only "Product", ->

  describe "hasVariations", ->

    it "should be ok if product has more than one variation", ->
      product = createProductWithVariations { id: 2 }, { id: 3 }
      product.hasVariations().should.be.ok

    it "should not ok if product has only one variation", ->
      product = createProductWithVariations { id: 2 }
      product.hasVariations().should.be.not.ok

  describe "findVariationBySku", ->

    it "should return the variation where the sku is equal", ->
      product = createProductWithVariations { sku: "A" }, { sku: "B" }
      product.findVariationBySku("A").should.be.eql { sku: "A" }

    it "should return the only variation it has without checking the parameter because it's a single product", ->
      product = createProductWithVariations { sku: "A" }
      product.findVariationBySku("C").should.be.eql { sku: "A" }

    it "should return undefined when product has variation and the variation was not found", ->
      product = createProductWithVariations { sku: "A" }, { sku: "B" }
      chai.expect(product.findVariationBySku("C")).to.be.undefined

  describe "firstVariation", ->

    it "should return the first variation", ->
      product = createProductWithVariations { sku: "A" }, { sku: "B" }
      product.firstVariation().should.be.eql { sku: "A" }

  describe "hasAllDimensions", ->

    it "should return true if the product has all the dimensions", ->
      product = new Product
        dimensions:
          width: 1
          height: 2
          length: 3
          weight: 4
      product.hasAllDimensions().should.be.ok

    it "should return false if the product hasnt all the dimensions", ->
      product = new Product
        dimensions:
          width: 1
          weight: 4
      product.hasAllDimensions().should.not.be.ok

  describe "updatePrice", ->

    it "should update a single price", ->
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

createProductWithVariations = (variations...) =>
  new Product { variations }
