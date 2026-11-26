Promise = require "bluebird"
Client = require "./client"
jwt = require "jwt-simple"

module.exports =

class CouriersApi

  constructor: ({ @productecaToken, @jsonWebTokenSecret, @url }) ->
    @client = new Client @url, {}

  getFullDownloadLink: (salesOrder, shipment, type) =>
    "#{@url}#{@getDownloadLink(salesOrder, shipment, type)}"

  getDownloadLink: ({ id: salesOrderId }, { id: shipmentId }, type = "pdf") =>
    jwttoken = jwt.encode [ { salesOrderId, shipmentId } ], @jsonWebTokenSecret
    "/couriers/shipments/label?shipments=#{jwttoken}&type=#{type}&access_token=#{@productecaToken}&raw=true"

  getZplOf: (order, shipment) =>
    @client.getAsync @getDownloadLink(order, shipment, "zpl2"), raw: true

  getLabelsUrl: (salesOrderId, { type = "pdf", shipmentId } = {}) =>
    url = "#{@url}/couriers/salesorders/#{salesOrderId}/labels?access_token=#{@productecaToken}&raw=true&type=#{type}"
    url += "&shipmentId=#{shipmentId}" if shipmentId?
    Promise.resolve url
