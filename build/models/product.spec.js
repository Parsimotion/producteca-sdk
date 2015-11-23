(function() {
  var Product, chai, createProductWithVariations, should,
    __slice = [].slice;

  chai = require("chai");

  should = chai.should();

  Product = require("./product");

  describe("Product", function() {
    describe("when hasVariations is called", function() {
      it("should be ok if product has more than one variation", function() {
        var product;
        product = createProductWithVariations({
          id: 2
        }, {
          id: 3
        });
        return product.hasVariations().should.be.ok;
      });
      return it("should not be ok if product has only one variation", function() {
        var product;
        product = createProductWithVariations({
          id: 2
        });
        return product.hasVariations().should.be.not.ok;
      });
    });
    describe("when findVariationBySku is called", function() {
      it("should return the variation where the sku is equal", function() {
        var product;
        product = createProductWithVariations({
          sku: "A"
        }, {
          sku: "B"
        });
        return product.findVariationBySku("A").should.be.eql({
          sku: "A"
        });
      });
      it("should return the only variation it has without checking the parameter because it's a single product", function() {
        var product;
        product = createProductWithVariations({
          sku: "A"
        });
        return product.findVariationBySku("C").should.be.eql({
          sku: "A"
        });
      });
      return it("should return undefined when product has variation and the variation was not found", function() {
        var product;
        product = createProductWithVariations({
          sku: "A"
        }, {
          sku: "B"
        });
        return chai.expect(product.findVariationBySku("C")).to.be.undefined;
      });
    });
    describe("when firstVariation is called", function() {
      return it("should return the first variation", function() {
        var product;
        product = createProductWithVariations({
          sku: "A"
        }, {
          sku: "B"
        });
        return product.firstVariation().should.be.eql({
          sku: "A"
        });
      });
    });
    describe("when hasAllDimensions is called", function() {
      it("should return true if the product has all the dimensions", function() {
        var product;
        product = new Product({
          dimensions: {
            width: 1,
            height: 2,
            length: 3,
            weight: 4
          }
        });
        return product.hasAllDimensions().should.be.ok;
      });
      return it("should return false if the product hasnt all the dimensions", function() {
        var product;
        product = new Product({
          dimensions: {
            width: 1,
            weight: 4
          }
        });
        return product.hasAllDimensions().should.not.be.ok;
      });
    });
    return describe("when updatePrice is called", function() {
      return it("should update a single price", function() {
        var product;
        product = new Product({
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
        });
        product.updatePrice("Meli", 270);
        return product.prices.should.eql([
          {
            priceList: "Default",
            amount: 180
          }, {
            priceList: "Meli",
            amount: 270
          }
        ]);
      });
    });
  });

  createProductWithVariations = (function(_this) {
    return function() {
      var variations;
      variations = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return new Product({
        variations: variations
      });
    };
  })(this);

}).call(this);
