CheckWhitelist = require './check-whitelist'

class WhitelistManager
  constructor: (dependencies={}) ->
    {@devices} = dependencies.database
    @checkWhitelist = new CheckWhitelist

  canConfigure: (toUuid, fromUuid, callback) =>
    @devices.findOne uuid: toUuid, (error, toDevice) =>
      return callback error if error?
      @devices.findOne uuid: fromUuid, (error, fromDevice) =>
        return callback error if error?
        @checkWhitelist.canConfigure fromDevice, toDevice, (error, canConfigure) =>
          callback null, canConfigure

module.exports = WhitelistManager
