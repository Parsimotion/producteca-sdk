Client = require "./client"
jwt = require "jwt-simple"

module.exports =

class CouriersApi

  constructor: ({ @productecaToken, @jsonWebTokenSecret, url }) ->
    @client = new Client url, {}

  getDownloadLink: ({ id: salesOrderId }, { id: shipmentId }, type = "pdf") ->
    jwttoken = jwt.encode [ { salesOrderId, shipmentId } ], @jsonWebTokenSecret
    "/couriers/shipments/label?shipments=#{jwttoken}&type=#{type}&access_token=#{@productecaToken}"

  getZplOf: (order, shipment) ->
    @client.getAsync @getDownloadLink(order, shipment, "zpl2"), raw: true
