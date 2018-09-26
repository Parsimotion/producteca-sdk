chai = require("chai")
should = chai.should()
Product = require("./product")

describe "Product", ->

  describe "when hasVariations is called", ->

    it "should be ok if product has more than one variation", ->
      product = createProductWithVariations { id: 2 }, { id: 3 }
      product.hasVariations().should.be.ok

    it "should not be ok if product has only one variation", ->
      product = createProductWithVariations { id: 2 }
      product.hasVariations().should.be.not.ok

  describe "when findVariationBySku is called", ->

    it "should return the variation where the sku is equal (case and trailing space insensitive)", ->
      product = createProductWithVariations { sku: "A" }, { sku: "B" }
      product.findVariationBySku("a  ").should.be.eql { sku: "A" }

    it "should return undefined when product has variation and the variation was not found", ->
      product = createProductWithVariations { sku: "A" }, { sku: "B" }
      chai.expect(product.findVariationBySku("C")).to.be.undefined

  describe "when firstVariation is called", ->

    it "should return the first variation", ->
      product = createProductWithVariations { sku: "A" }, { sku: "B" }
      product.firstVariation().should.be.eql { sku: "A" }

  describe "when hasAllDimensions is called", ->

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

  describe "when updatePrice is called", ->

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
