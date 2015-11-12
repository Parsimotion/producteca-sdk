module.exports =
  returnOne: (promise) =>
    promise.spread (req, res, obj) -> obj

  returnMany: (promise) =>
    promise.spread (req, res, obj) -> obj.results
