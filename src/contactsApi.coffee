ProductecaApi = require("./productecaApi")
module.exports =

class ContactsApi extends ProductecaApi
  # Creates a contact
  create: (contact) =>
    @client.postAsync "/contacts", contact

  # Updates a contact by name
  update: (id, contact) =>
    @client.putAsync "/contacts/#{id}", contact

  # Gets a contact by app and integrationId
  getByIntegration: (app, integrationId) =>
    @client.getAsync "/contacts/byintegration", { qs: { integrationId, app } }
