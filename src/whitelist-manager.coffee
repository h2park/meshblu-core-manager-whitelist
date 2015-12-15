CheckWhitelist = require './check-whitelist'

class WhitelistManager
  constructor: ({@datastore,@uuidAliasResolver}) ->
    @checkWhitelist = new CheckWhitelist {@uuidAliasResolver}

  canConfigure: (toUuid, fromUuid, callback) =>
    @uuidAliasResolver.resolve toUuid, (error, toUuid) =>
      return callback error if error?
      @datastore.findOne uuid: toUuid, (error, toDevice) =>
        return callback error if error?
        @uuidAliasResolver.resolve fromUuid, (error, fromUuid) =>
          return callback error if error?
          @datastore.findOne uuid: fromUuid, (error, fromDevice) =>
            return callback error if error?
            @checkWhitelist.canConfigure fromDevice, toDevice, (error, canConfigure) =>
              callback null, canConfigure

  canDiscover: (toUuid, fromUuid, callback) =>
    @uuidAliasResolver.resolve toUuid, (error, toUuid) =>
      return callback error if error?
      @datastore.findOne uuid: toUuid, (error, toDevice) =>
        return callback error if error?
        @uuidAliasResolver.resolve fromUuid, (error, fromUuid) =>
          return callback error if error?
          @datastore.findOne uuid: fromUuid, (error, fromDevice) =>
            return callback error if error?
            @checkWhitelist.canDiscover fromDevice, toDevice, (error, canConfigure) =>
              callback null, canConfigure

  canDiscoverAs: (toUuid, fromUuid, callback) =>
    @uuidAliasResolver.resolve toUuid, (error, toUuid) =>
      return callback error if error?
      @datastore.findOne uuid: toUuid, (error, toDevice) =>
        return callback error if error?
        @uuidAliasResolver.resolve fromUuid, (error, fromUuid) =>
          return callback error if error?
          @datastore.findOne uuid: fromUuid, (error, fromDevice) =>
            return callback error if error?
            @checkWhitelist.canDiscoverAs fromDevice, toDevice, (error, canConfigure) =>
              callback null, canConfigure

module.exports = WhitelistManager
