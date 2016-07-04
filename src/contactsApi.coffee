ProductecaApi = require("./productecaApi")
module.exports =

class ContactsApi extends ProductecaApi
  # Creates a contact
  create: (contact) =>
    @client.postAsync "/contacts", contact

  # Updates a contact by name
  update: (contact) =>
    @client.putAsync "/contacts", contact
