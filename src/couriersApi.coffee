Client = require "./client"
jwt = require "jwt-simple"

module.exports =

class CouriersApi

  constructor: ({ @productecaToken, @jsonWebTokenSecret, url }) ->
    @client = new Client url, {}

  getZplOf: ({ id: salesOrderId }, { id: shipmentId }) ->
    jwttoken = jwt.encode [ { salesOrderId, shipmentId } ], @jsonWebTokenSecret
    url = "/couriers/shipments/label?shipments=#{jwttoken}&type=zpl2&access_token=#{@productecaToken}"
    @client.getAsync url, raw: true
