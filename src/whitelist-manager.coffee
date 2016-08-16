_                     = require 'lodash'
async                 = require 'async'
ListChecker           = require 'meshblu-list-checker'
DeviceTransmogrifier  = require 'meshblu-device-transmogrifier'
debug                 = require("debug")("meshblu-core-manager-whitelist")

class WhitelistManager
  constructor: ({@datastore,@uuidAliasResolver}) ->

  _check: ({toUuid, fromUuid, whitelist}, callback) =>
    projection =
      configureWhitelist: true
      configureAsWhitelist: true
      discoverWhitelist: true
      discoverAsWhitelist: true
      receiveWhitelist: true
      receiveAsWhitelist: true
      sendWhitelist: true
      sendAsWhitelist: true
      'meshblu.whitelists': true
      'meshblu.version': true
      owner: true
      uuid: true

    debug "checking if #{fromUuid} can #{whitelist} to #{toUuid}"
    @uuidAliasResolver.resolve toUuid, (error, toUuid) =>
      return callback error if error?
      @datastore.findOne {uuid: toUuid}, projection, (error, toDevice) =>
        return callback error if error?
        return callback null, false if !toDevice?

        @uuidAliasResolver.resolve fromUuid, (error, fromUuid) =>
          return callback error if error?
          return callback null, true if toUuid == fromUuid

          transmogrifier = new DeviceTransmogrifier toDevice
          transmogrifiedDevice = transmogrifier.transmogrify()

          list = _.get transmogrifiedDevice, "meshblu.whitelists.#{whitelist}"
          @_resolveList list, (error, resolvedList) =>
            listChecker = new ListChecker resolvedList
            callback null, listChecker.check fromUuid

  canBroadcastAs: ({fromUuid, toUuid}, callback) =>
    @_check {fromUuid, toUuid, whitelist: 'broadcast.as'}, callback

  canConfigure: ({fromUuid, toUuid}, callback) =>
    @_check {fromUuid, toUuid, whitelist: 'configure.update'}, callback

  canConfigureAs: ({fromUuid, toUuid}, callback) =>
    @_check {fromUuid, toUuid, whitelist: 'configure.as'}, callback

  canDiscover: ({fromUuid, toUuid}, callback) =>
    @_check {fromUuid, toUuid, whitelist: 'discover.view'}, callback

  canDiscoverAs: ({fromUuid, toUuid}, callback) =>
    @_check {fromUuid, toUuid, whitelist: 'discover.as'}, callback

  canReceive: ({fromUuid, toUuid}, callback) =>
    @_check {fromUuid, toUuid, whitelist: 'broadcast.sent'}, callback

  canReceiveAs: ({fromUuid, toUuid}, callback) =>
    @_check {fromUuid, toUuid, whitelist: 'message.received'}, callback

  canSend: ({fromUuid, toUuid}, callback) =>
    @_check {fromUuid, toUuid, whitelist: 'message.from'}, callback

  canSendAs: ({fromUuid, toUuid}, callback) =>
    @_check {fromUuid, toUuid, whitelist: 'message.as'}, callback

  checkBroadcastAs: ({emitter, subscriber}, callback) =>
    @_check {toUuid: emitter, fromUuid: subscriber, whitelist: 'broadcast.as'}, callback

  checkBroadcastSent: ({emitter, subscriber}, callback) =>
    @_check {toUuid: emitter, fromUuid: subscriber, whitelist: 'broadcast.sent'}, callback

  checkBroadcastReceived: ({emitter, subscriber}, callback) =>
    @_check {toUuid: emitter, fromUuid: subscriber, whitelist: 'broadcast.received'}, callback

  checkDiscoverView: ({emitter, subscriber}, callback) =>
    @_check {toUuid: subscriber, fromUuid: emitter, whitelist: 'discover.view'}, callback

  checkDiscoverAs: ({emitter, subscriber}, callback) =>
    @_check {toUuid: emitter, fromUuid: subscriber, whitelist: 'discover.as'}, callback

  checkConfigureUpdate: ({emitter, subscriber}, callback) =>
    @_check {toUuid: subscriber, fromUuid: emitter, whitelist: 'configure.update'}, callback

  checkConfigureAs: ({emitter, subscriber}, callback) =>
    @_check {toUuid: emitter, fromUuid: subscriber, whitelist: 'configure.as'}, callback

  checkConfigureSent: ({emitter, subscriber}, callback) =>
    @_check {toUuid: emitter, fromUuid: subscriber, whitelist: 'configure.sent'}, callback

  checkConfigureReceived: ({emitter, subscriber}, callback) =>
    @_check {toUuid: emitter, fromUuid: subscriber, whitelist: 'configure.received'}, callback

  checkMessageFrom: ({emitter, subscriber}, callback) =>
    @_check {toUuid: subscriber, fromUuid: emitter, whitelist: 'message.from'}, callback

  checkMessageAs: ({emitter, subscriber}, callback) =>
    @_check {toUuid: emitter, fromUuid: subscriber, whitelist: 'message.as'}, callback

  checkMessageSent: ({emitter, subscriber}, callback) =>
    @_check {toUuid: emitter, fromUuid: subscriber, whitelist: 'message.sent'}, callback

  checkMessageReceived: ({emitter, subscriber}, callback) =>
    @_check {toUuid: emitter, fromUuid: subscriber, whitelist: 'message.received'}, callback

  _resolveList: (list, callback) =>
    async.each list, (item, next) =>
      @uuidAliasResolver.resolve item.uuid, (error, resolvedUuid) =>
        return next error if error?
        item.uuid = resolvedUuid
        next()
    , (error) =>
      return callback error if error?
      callback null, list

module.exports = WhitelistManager
