mongojs = require 'mongojs'
Datastore = require 'meshblu-core-datastore'
WhitelistManager = require '../src/whitelist-manager'

describe 'WhitelistManager', ->
  beforeEach (done) ->
    @datastore = new Datastore
      database: mongojs('test-whitelist-manager')
      collection: 'devices'
    @datastore.remove => done()

  beforeEach ->
    @uuidAliasResolver = resolve: (uuid, callback) => callback(null, uuid)

    @sut = new WhitelistManager {@datastore, @uuidAliasResolver}

  describe '->checkBroadcastReceived', ->
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
                received:
                  ohBoy: {}
        @datastore.insert device, done

      beforeEach (done) ->
        @sut.checkBroadcastReceived emitter: 'great-scott', subscriber: 'ohBoy' , (error, @checkBroadcastReceived) =>
          done error

      it 'should have a checkBroadcastReceived sent of true', ->
        expect(@checkBroadcastReceived).to.be.true

    describe 'when subscriber and emitter are the same', ->
      beforeEach (done) ->
        device =
          uuid: 'ohBoy'
        @datastore.insert device, done

      beforeEach (done) ->
        @sut.checkBroadcastReceived subscriber: 'ohBoy', emitter: 'ohBoy', (error, @checkBroadcastReceived) =>
          done error

      it 'should have a checkBroadcastReceived sent of true', ->
        expect(@checkBroadcastReceived).to.be.true

    describe 'when called with a invalid subscriber, emitter', ->
      beforeEach (done) ->
        device =
          uuid: 'ya son'
          meshblu:
            version: '2.0.0'
            whitelists:
              broadcast:
                received:
                  ohBoy: {}

        @datastore.insert device, done

      beforeEach (done) ->
        device =
          uuid: 'for real'
        @datastore.insert device, done

      beforeEach (done) ->
        @sut.checkBroadcastReceived subscriber: 'ya son', emitter: 'for real', (error, @checkBroadcastReceived) =>
          done error

      it 'should have a checkBroadcastReceived sent of false', ->
        expect(@checkBroadcastReceived).to.be.false

    describe 'when subscriber and emitter are the same', ->
      beforeEach (done) ->
        device =
          uuid: 'oh boy'
        @datastore.insert device, done

      beforeEach (done) ->
        @sut.checkBroadcastReceived emitter: 'oh boy', subscriber: 'oh boy', (error, @checkBroadcastReceived) =>
          done error

      it 'should have a checkBroadcastReceived sent of true', ->
        expect(@checkBroadcastReceived).to.be.true

    describe 'when called with a invalid subscriber, emitter', ->
      beforeEach (done) ->
        device =
          uuid: 'ya son'
          meshblu:
            version: '2.0.0'
            whitelists:
              broadcast:
                received:
                  'not for real': true
        @datastore.insert device, done

      beforeEach (done) ->
        device =
          uuid: 'for real'
        @datastore.insert device, done

      beforeEach (done) ->
        @sut.checkBroadcastReceived emitter: 'ya son', subscriber: 'for real', (error, @checkBroadcastReceived) =>
          done error

      it 'should have a checkBroadcastReceived sent of false', ->
        expect(@checkBroadcastReceived).to.be.false
