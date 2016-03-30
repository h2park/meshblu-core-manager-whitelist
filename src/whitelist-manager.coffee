_                    = require 'lodash'
async                = require 'async'
ListChecker          = require 'meshblu-list-checker'
DeviceTransmogrifier = require 'meshblu-device-transmogrifier'

class WhitelistManager
  constructor: ({@datastore,@uuidAliasResolver}) ->

  @FIELD_MAP:
    canConfigure:   'configure.update'
    canConfigureAs: 'configure.as'
    canDiscover:    'discover.view'
    canDiscoverAs:  'discover.as'
    canReceive:     'broadcast.sent'
    canReceiveAs:   'message.received'
    canSend:        'message.from'
    canSendAs:      'message.as'

  _check: ({method, toUuid, fromUuid, whitelist}, callback) =>
    field = whitelist || WhitelistManager.FIELD_MAP[method]
    projection =
      configureWhitelist: true
      configureAsWhitelist: true
      discoverWhitelist: true
      discoverAsWhitelist: true
      receiveWhitelist: true
      receiveAsWhitelist: true
      sendWhitelist: true
      sendAsWhitelist: true
      meshblu: true
      owner: true
      uuid: true

    @uuidAliasResolver.resolve toUuid, (error, toUuid) =>
      return callback error if error?
      @datastore.findOne {uuid: toUuid}, projection, (error, toDevice) =>
        return callback error if error?
        @uuidAliasResolver.resolve fromUuid, (error, fromUuid) =>
          return callback error if error?
          return callback null, true if toUuid == fromUuid
          return callback new Error 'device does not exist' if !toDevice?

          transmogrifier = new DeviceTransmogrifier toDevice
          transmogrifiedDevice = transmogrifier.transmogrify()

          list = _.get transmogrifiedDevice, "meshblu.whitelists.#{field}"
          @_resolveList list, (error, resolvedList) =>
            listChecker = new ListChecker resolvedList
            callback null, listChecker.check fromUuid

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

  checkBroadcastSent: ({emitter, subscriber}, callback) =>
    @_check {toUuid: emitter, fromUuid: subscriber, whitelist: 'broadcast.sent'}, callback

  checkBroadcastReceived: ({emitter, subscriber}, callback) =>
    @_check {toUuid: emitter, fromUuid: subscriber, whitelist: 'broadcast.received'}, callback

  checkDiscoverView: ({emitter, subscriber}, callback) =>
    @_check {toUuid: emitter, fromUuid: subscriber, whitelist: 'discover.view'}, callback

  checkDiscoverAs: ({emitter, subscriber}, callback) =>
    @_check {toUuid: emitter, fromUuid: subscriber, whitelist: 'discover.as'}, callback

  checkConfigureUpdate: ({emitter, subscriber}, callback) =>
    @_check {toUuid: emitter, fromUuid: subscriber, whitelist: 'configure.update'}, callback

  checkConfigureAs: ({emitter, subscriber}, callback) =>
    @_check {toUuid: emitter, fromUuid: subscriber, whitelist: 'configure.as'}, callback

  checkConfigureSent: ({emitter, subscriber}, callback) =>
    @_check {toUuid: emitter, fromUuid: subscriber, whitelist: 'configure.sent'}, callback

  checkConfigureReceived: ({emitter, subscriber}, callback) =>
    @_check {toUuid: emitter, fromUuid: subscriber, whitelist: 'configure.received'}, callback

  checkMessageFrom: ({emitter, subscriber}, callback) =>
    @_check {toUuid: emitter, fromUuid: subscriber, whitelist: 'message.from'}, callback

  checkMessageAs: ({emitter, subscriber}, callback) =>
    @_check {toUuid: emitter, fromUuid: subscriber, whitelist: 'message.as'}, callback

  checkMessageSent: ({emitter, subscriber}, callback) =>
    @_check {toUuid: emitter, fromUuid: subscriber, whitelist: 'message.sent'}, callback

  checkMessageReceived: ({emitter, subscriber}, callback) =>
    @_check {toUuid: emitter, fromUuid: subscriber, whitelist: 'message.received'}, callback

  _resolveList: (list, callback) =>
    resolvedList = {}
    async.each _.keys(list), (uuid, next) =>
      @uuidAliasResolver.resolve uuid, (error, resolvedUuid) =>
        return next error if error?
        resolvedList[resolvedUuid] = list[uuid]
        next()
    , (error) =>
        return callback error if error?
        callback null, resolvedList

module.exports = WhitelistManager
