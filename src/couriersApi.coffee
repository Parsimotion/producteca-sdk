Client = require "./client"
jwt = require "jwt-simple"

module.exports =

class CouriersApi

  constructor: ({ @productecaToken, @jsonWebTokenSecret, url }) ->
    @client = new Client url, {}

  getZplOf: ({ id: salesOrderId }, { id: shipmentId }) ->
    jwttoken = jwt.encode [ { salesOrderId, shipmentId } ], @jsonWebTokenSecret
    @client.getAsync "/couriers/shipments/label?shipments=#{jwttoken}&type=zpl2&access_token=#{@productecaToken}"
