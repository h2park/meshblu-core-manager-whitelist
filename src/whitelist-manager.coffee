CheckWhitelist = require './check-whitelist'

class WhitelistManager
  constructor: ({@datastore}) ->
    @checkWhitelist = new CheckWhitelist

  canConfigure: (toUuid, fromUuid, callback) =>
    @datastore.findOne uuid: toUuid, (error, toDevice) =>
      return callback error if error?
      @datastore.findOne uuid: fromUuid, (error, fromDevice) =>
        return callback error if error?
        @checkWhitelist.canConfigure fromDevice, toDevice, (error, canConfigure) =>
          callback null, canConfigure

module.exports = WhitelistManager
