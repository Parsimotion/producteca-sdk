ProductecaApi = require("./productecaApi")
module.exports =

class ContactsApi extends ProductecaApi
  # Creates a contact
  create: (contact) =>
    @client.postAsync "/contacts", contact

  # Updates a contact by name
  update: (contact) =>
    @client.putAsync "/contacts", contact

  # Gets a contact by app and integrationId
  getByAppAndIntegrationId: (app, integrationId) =>
    @client.getAsync "/contacts", { $filter: "profile/integrationId eq #{integrationId}&profile/app eq #{app}" }
