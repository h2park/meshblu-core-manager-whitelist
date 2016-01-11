CheckWhitelist = require './check-whitelist'

class WhitelistManager
  constructor: ({@datastore,@uuidAliasResolver}) ->
    @checkWhitelist = new CheckWhitelist {@uuidAliasResolver}

  _check: ({method, toUuid, fromUuid}, callback) =>
    @uuidAliasResolver.resolve toUuid, (error, toUuid) =>
      return callback error if error?
      @datastore.findOne uuid: toUuid, (error, toDevice) =>
        return callback error if error?
        @uuidAliasResolver.resolve fromUuid, (error, fromUuid) =>
          return callback error if error?
          @datastore.findOne uuid: fromUuid, (error, fromDevice) =>
            return callback error if error?
            @checkWhitelist[method] fromDevice, toDevice, (error, verified) =>
              callback null, verified

  canConfigure: ({fromUuid, toUuid}, callback) =>
    @_check {method: 'canConfigure', fromUuid, toUuid}, callback

  canConfigureAs: ({fromUuid, toUuid}, callback) =>
    @_check {method: 'canConfigureAs', fromUuid, toUuid}, callback

  canDiscover: ({fromUuid, toUuid}, callback) =>
    @_check {method: 'canDiscover', fromUuid, toUuid}, callback

  canDiscoverAs: ({fromUuid, toUuid}, callback) =>
    @_check {method: 'canDiscoverAs', fromUuid, toUuid}, callback

  canReceive: ({fromUuid, toUuid}, callback) =>
    @_check {method: 'canReceive', fromUuid, toUuid}, callback

  canReceiveAs: ({fromUuid, toUuid}, callback) =>
    @_check {method: 'canReceiveAs', fromUuid, toUuid}, callback

  canSend: ({fromUuid, toUuid}, callback) =>
    @_check {method: 'canSend', fromUuid, toUuid}, callback

  canSendAs: ({fromUuid, toUuid}, callback) =>
    @_check {method: 'canSendAs', fromUuid, toUuid}, callback

module.exports = WhitelistManager
