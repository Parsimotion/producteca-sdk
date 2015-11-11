chai = require("chai")
chai.Should()
chai.use require("sinon-chai")

ProductsApi = require("./productsApi")

describe "ProductsApi", ->
  api = new ProductsApi({})

  deprecatedProduct =
    description: "Cosa"
    sku: "COSA"
    variations: [
      {
        barcode: "COSAVERDE"
        primaryColor: "Verde"
      }
    ]

  newProduct =
    name: "Cosa"
    code: "COSA"
    variations: [
      {
        sku: "COSAVERDE"
        primaryColor: "Verde"
      }
    ]

  describe "_convertDeprecatedToNew", ->
    it "should map the properties ok", ->
      api._convertDeprecatedToNew(deprecatedProduct)
        .should.eql newProduct

  describe "_convertNewToDeprecated", ->
    it "should map the properties ok", ->
      api._convertNewToDeprecated(newProduct)
        .should.eql deprecatedProduct
