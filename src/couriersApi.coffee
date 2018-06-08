Client = require "./client"
jwt = require "jwt-simple"

module.exports =

class CouriersApi

  constructor: ({ @productecaToken, @jsonWebTokenSecret, @url }) ->
    @client = new Client @url, {}

  getFullDownloadLink: (salesOrder, shipment, type) =>
    "#{@url}#{@getDownloadLink(salesOrder, shipment, type)}"

  getDownloadLink: ({ id: salesOrderId }, { id: shipmentId }, type = "pdf", raw = false) =>
    jwttoken = jwt.encode [ { salesOrderId, shipmentId } ], @jsonWebTokenSecret
    "/couriers/shipments/label?shipments=#{jwttoken}&type=#{type}&access_token=#{@productecaToken}&raw=#{raw}"

  getZplOf: (order, shipment, { raw  } = {}) =>
    @client.getAsync @getDownloadLink(order, shipment, "zpl2", raw), raw: true
