_ = require "lodash"

module.exports =
class ProductecaRequestError extends Error
  constructor: (err) ->
    super err?.message
    @name = "ProductecaRequestError"
    @statusCode = err?.statusCode or 502
    @body =
      err: err
      code: "producteca_request_error",
      message: _.get err, "message", "There was an error while making a request to an external server"
      payload: JSON.stringify _.omit err, ["response", "request", "config", "options.headers", "options.auth"]
