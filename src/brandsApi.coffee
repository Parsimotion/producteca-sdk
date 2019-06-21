ProductecaApi = require("./productecaApi")
module.exports =

class BrandsApi extends ProductecaApi
  # Returns a brand by id
  get: (id) =>
    @client.getAsync "/brands/#{id}"

  # Returns all the brands
  getAll: =>
    @client.getAsync "/brands"

  # Creates a brand by name
  createByName: (brandName) =>
    @client.postAsync "/brands", name: brandName

  # Deletes a brand by id
  delete: (id) =>
    @client.deleteAsync "/brands/#{id}"
