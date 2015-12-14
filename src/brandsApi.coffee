ProductecaApi = require("./productecaApi")
module.exports =

class BrandsApi extends ProductecaApi
  # Returns a brand by id
  get: (id) =>
    @respond @client.getAsync "/brands/#{id}"

  # Returns all the brands
  getAll: =>
    @respond @client.getAsync "/brands"

  # Creates a brand by name
  createByName: (brandName) =>
    @respond @client.postAsync "/brands", name: brandName

  # Deletes a brand by id
  delete: (id) =>
    @respond @client.delAsync "/brands/#{id}"
