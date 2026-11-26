chai = require("chai")
chai.use(require("chai-as-promised"))
chai.should()
CouriersApi = require("./couriersApi")
COURIERS_API_URL = "https://apps.producteca.com/couriers"

describe "CouriersApi", ->
  api = new CouriersApi(
    productecaToken: "TokenSaraza"
    url: COURIERS_API_URL
  )

  describe "when getLabelsUrl is called", ->
    it "should return the labels url of the sales order with the token, raw and the pdf type", ->
      api.getLabelsUrl(123).should.eventually.equal(
        "#{COURIERS_API_URL}/couriers/salesorders/123/labels?access_token=TokenSaraza&raw=true&type=pdf"
      )

    it "should use the type when it is given", ->
      api.getLabelsUrl(123, type: "zpl2").should.eventually.equal(
        "#{COURIERS_API_URL}/couriers/salesorders/123/labels?access_token=TokenSaraza&raw=true&type=zpl2"
      )

    it "should add the shipmentId when it is given", ->
      api.getLabelsUrl(123, shipmentId: 456).should.eventually.equal(
        "#{COURIERS_API_URL}/couriers/salesorders/123/labels?access_token=TokenSaraza&raw=true&type=pdf&shipmentId=456"
      )

    it "should use both the type and the shipmentId when they are given", ->
      api.getLabelsUrl(123, type: "zpl2", shipmentId: 456).should.eventually.equal(
        "#{COURIERS_API_URL}/couriers/salesorders/123/labels?access_token=TokenSaraza&raw=true&type=zpl2&shipmentId=456"
      )
