mongojs = require 'mongojs'
Datastore = require 'meshblu-core-datastore'
WhitelistManager = require '../src/whitelist-manager'

describe 'check Broadcast Sent', ->
  beforeEach (done) ->
    database = mongojs 'test-whitelist-manager', ['devices']
    @datastore = new Datastore
      database: database
      collection: 'devices'
    database.devices.remove => done()

  beforeEach ->
    @uuidAliasResolver = resolve: (uuid, callback) => callback(null, uuid)

    @sut = new WhitelistManager {@datastore, @uuidAliasResolver}

  describe '->checkBroadcastSent', ->
    describe 'when called with a valid emitter and subscriber', ->
      beforeEach (done) ->
        device =
          uuid: 'oh boy'

        @datastore.insert device, done

      beforeEach (done) ->
        device =
          uuid: 'great-scott'
          meshblu:
            version: '2.0.0'
            whitelists:
              broadcast:
                sent: [{uuid: 'ohBoy'}]
        @datastore.insert device, done

      beforeEach (done) ->
        @sut.checkBroadcastSent emitter: 'great-scott', subscriber: 'ohBoy' , (error, @checkBroadcastSent) =>
          done error

      it 'should have a checkBroadcastSent sent of true', ->
        expect(@checkBroadcastSent).to.be.true

    describe 'when subscriber and emitter are the same', ->
      beforeEach (done) ->
        device =
          uuid: 'ohBoy'
        @datastore.insert device, done

      beforeEach (done) ->
        @sut.checkBroadcastSent subscriber: 'ohBoy', emitter: 'ohBoy', (error, @checkBroadcastSent) =>
          done error

      it 'should have a checkBroadcastSent sent of true', ->
        expect(@checkBroadcastSent).to.be.true

    describe 'when called with a invalid subscriber, emitter', ->
      beforeEach (done) ->
        device =
          uuid: 'ya son'
          meshblu:
            version: '2.0.0'
            whitelists:
              broadcast:
                sent: [{uuid: 'ohBoy'}]

        @datastore.insert device, done

      beforeEach (done) ->
        device =
          uuid: 'for real'
        @datastore.insert device, done

      beforeEach (done) ->
        @sut.checkBroadcastSent subscriber: 'ya son', emitter: 'for real', (error, @checkBroadcastSent) =>
          done error

      it 'should have a checkBroadcastSent sent of false', ->
        expect(@checkBroadcastSent).to.be.false

    describe 'when subscriber and emitter are the same', ->
      beforeEach (done) ->
        device =
          uuid: 'oh boy'
        @datastore.insert device, done

      beforeEach (done) ->
        @sut.checkBroadcastSent emitter: 'oh boy', subscriber: 'oh boy', (error, @checkBroadcastSent) =>
          done error

      it 'should have a checkBroadcastSent sent of true', ->
        expect(@checkBroadcastSent).to.be.true

    describe 'when called with a invalid subscriber, emitter', ->
      beforeEach (done) ->
        device =
          uuid: 'ya son'
          meshblu:
            version: '2.0.0'
            whitelists:
              broadcast:
                sent: [{uuid: 'not for real'}]
        @datastore.insert device, done

      beforeEach (done) ->
        device =
          uuid: 'for real'
        @datastore.insert device, done

      beforeEach (done) ->
        @sut.checkBroadcastSent emitter: 'ya son', subscriber: 'for real', (error, @checkBroadcastSent) =>
          done error

      it 'should have a checkBroadcastSent sent of false', ->
        expect(@checkBroadcastSent).to.be.false
