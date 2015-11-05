util    = require './util'
_       = require 'lodash'

class CheckWhitelist
  asyncCallback : (error, result, callback) =>
    _.defer => callback error, result

  checkLists: (fromDevice, toDevice, whitelist, blacklist, openByDefault) =>
    return false if !fromDevice || !toDevice

    return true if toDevice.uuid == fromDevice.uuid

    return true if _.contains whitelist, '*'

    return  _.contains(whitelist, fromDevice.uuid) if whitelist?

    return !_.contains(blacklist, fromDevice.uuid) if blacklist?

    openByDefault

  canConfigure: (fromDevice, toDevice, message, callback) =>
    if _.isFunction message
      callback = message
      message = null

    return @asyncCallback(null, true, callback) if @checkLists fromDevice, toDevice, toDevice?.configureWhitelist, toDevice?.configureBlacklist, false

    return @asyncCallback(null, false, callback) if !fromDevice || !toDevice

    return @asyncCallback(null, true, callback) if fromDevice.uuid == toDevice.uuid

    if toDevice.owner?
      return @asyncCallback(null, true, callback) if toDevice.owner == fromDevice.uuid
    else
      return @asyncCallback(null, true, callback) if util.sameLAN(fromDevice.ipAddress, toDevice.ipAddress)

    return @asyncCallback(null, false, callback)

  canConfigureAs: (fromDevice, toDevice, message, callback) =>
    if _.isFunction message
      callback = message
      message = null

    configureAsWhitelist = _.cloneDeep toDevice?.configureAsWhitelist
    unless configureAsWhitelist
      configureAsWhitelist = []
      configureAsWhitelist.push toDevice.owner if toDevice?.owner

    result = @checkLists fromDevice, toDevice, configureAsWhitelist, toDevice?.configureAsBlacklist, true
    @asyncCallback(null, result, callback)

  canDiscover: (fromDevice, toDevice, message, callback) =>
    if _.isFunction message
      callback = message
      message = null

    return @asyncCallback(null, true, callback) if @checkLists fromDevice, toDevice, toDevice?.discoverWhitelist, toDevice?.discoverBlacklist, true

    return @asyncCallback(null, false, callback)

  canDiscoverAs: (fromDevice, toDevice, message, callback) =>
    if _.isFunction message
      callback = message
      message = null

    discoverAsWhitelist = _.cloneDeep toDevice?.discoverAsWhitelist
    unless discoverAsWhitelist
      discoverAsWhitelist = []
      discoverAsWhitelist.push toDevice.owner if toDevice?.owner

    result = @checkLists fromDevice, toDevice, discoverAsWhitelist, toDevice?.discoverAsBlacklist, true
    @asyncCallback(null, result, callback)

  canReceive: (fromDevice, toDevice, message, callback) =>
    if _.isFunction message
      callback = message
      message = null

    result = @checkLists fromDevice, toDevice, toDevice?.receiveWhitelist, toDevice?.receiveBlacklist, true
    @asyncCallback(null, result, callback)

  canReceiveAs: (fromDevice, toDevice, message, callback) =>
    if _.isFunction message
      callback = message
      message = null

    receiveAsWhitelist = _.cloneDeep toDevice?.receiveAsWhitelist
    unless receiveAsWhitelist
      receiveAsWhitelist = []
      receiveAsWhitelist.push toDevice.owner if toDevice?.owner

    result = @checkLists fromDevice, toDevice, receiveAsWhitelist, toDevice?.receiveAsBlacklist, true
    @asyncCallback(null, result, callback)

  canSend: (fromDevice, toDevice, message, callback) =>
    if _.isFunction message
      callback = message
      message = null

    result = @checkLists fromDevice, toDevice, toDevice?.sendWhitelist, toDevice?.sendBlacklist, true
    @asyncCallback(null, result, callback)

  canSendAs: (fromDevice, toDevice, message, callback) =>
    if _.isFunction message
      callback = message
      message = null

    sendAsWhitelist = _.cloneDeep toDevice?.sendAsWhitelist
    unless sendAsWhitelist
      sendAsWhitelist = []
      sendAsWhitelist.push toDevice.owner if toDevice?.owner

    result = @checkLists fromDevice, toDevice, sendAsWhitelist, toDevice?.sendAsBlacklist, true
    @asyncCallback(null, result, callback)


module.exports = CheckWhitelist
