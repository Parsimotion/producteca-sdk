ProductecaApi = require("./productecaApi")
module.exports =

class ContactsApi extends ProductecaApi
  # Creates a contact
  create: (contact) =>
    @respond @client.postAsync "/contacts", contact

  # Updates a contact by name
  update: (contact) =>
    @respond @client.putAsync "/contacts", contact
