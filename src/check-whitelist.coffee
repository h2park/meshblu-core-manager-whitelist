async   = require 'async'
_       = require 'lodash'

class CheckWhitelist
  constructor: ({@uuidAliasResolver}) ->

  asyncCallback: (error, result, callback) =>
    _.defer callback, error, result

  _checkLists: (fromDevice, toDevice, whitelist, blacklist, callback) =>
    return callback null, false unless fromDevice? && toDevice?

    @_resolveList whitelist, (error, resolvedWhitelist) =>
      return callback error if error?

      @_resolveList blacklist, (error, resolvedBlacklist) =>
        return callback error if error?

        toDeviceAlias = toDevice.uuid
        fromDeviceAlias = fromDevice.uuid

        @uuidAliasResolver.resolve toDeviceAlias, (error, toDeviceUuid) =>
          return callback error if error?

          @uuidAliasResolver.resolve fromDeviceAlias, (error, fromDeviceUuid) =>
            return callback error if error?

            return callback null, true if toDeviceUuid == fromDeviceUuid
            return callback null, true if toDevice.owner &&  toDevice.owner == fromDeviceUuid

            return callback null, false unless _.isArray resolvedWhitelist

            return callback null, true if _.contains resolvedWhitelist, '*'

            return callback null, _.contains(resolvedWhitelist, fromDeviceUuid) if resolvedWhitelist?

            return callback null, !_.contains(resolvedBlacklist, fromDeviceUuid) if resolvedBlacklist?

            callback null, false

  canConfigure: (fromDevice, toDevice, message, callback) =>
    if _.isFunction message
      callback = message
      message = null

    @_checkLists fromDevice, toDevice, toDevice?.configureWhitelist, toDevice?.configureBlacklist, callback


  canConfigureAs: (fromDevice, toDevice, message, callback) =>
    if _.isFunction message
      callback = message
      message = null

    @_checkLists fromDevice, toDevice, toDevice?.configureAsWhitelist, toDevice?.configureAsBlacklist, callback


  canDiscover: (fromDevice, toDevice, message, callback) =>
    if _.isFunction message
      callback = message
      message = null

    @_checkLists fromDevice, toDevice, toDevice?.discoverWhitelist, toDevice?.discoverBlacklist, callback

  canDiscoverAs: (fromDevice, toDevice, message, callback) =>
    if _.isFunction message
      callback = message
      message = null

    @_checkLists fromDevice, toDevice, toDevice?.discoverAsWhitelist, toDevice?.discoverAsBlacklist, callback

  canReceive: (fromDevice, toDevice, message, callback) =>
    if _.isFunction message
      callback = message
      message = null

    @_checkLists fromDevice, toDevice, toDevice?.receiveWhitelist, toDevice?.receiveBlacklist, callback

  canReceiveAs: (fromDevice, toDevice, message, callback) =>
    if _.isFunction message
      callback = message
      message = null

    @_checkLists fromDevice, toDevice, toDevice?.receiveAsWhitelist, toDevice?.receiveAsBlacklist, callback

  canSend: (fromDevice, toDevice, message, callback) =>
    if _.isFunction message
      callback = message
      message = null

    @_checkLists fromDevice, toDevice, toDevice?.sendWhitelist, toDevice?.sendBlacklist, callback

  canSendAs: (fromDevice, toDevice, message, callback) =>
    if _.isFunction message
      callback = message
      message = null

    @_checkLists fromDevice, toDevice, toDevice?.sendAsWhitelist, toDevice?.sendAsBlacklist, callback

  _resolveList: (list, callback) =>
    return callback null, list unless _.isArray list
    async.map list, @uuidAliasResolver.resolve, callback

module.exports = CheckWhitelist
