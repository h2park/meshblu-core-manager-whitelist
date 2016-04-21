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

  describe '->checkMessageReceived', ->
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
              message:
                received: [{uuid: 'ohBoy'}]
        @datastore.insert device, done

      beforeEach (done) ->
        @sut.checkMessageReceived emitter: 'great-scott', subscriber: 'ohBoy' , (error, @checkMessageReceived) =>
          done error

      it 'should have a checkMessageReceived sent of true', ->
        expect(@checkMessageReceived).to.be.true

    describe 'when subscriber and emitter are the same', ->
      beforeEach (done) ->
        device =
          uuid: 'ohBoy'
        @datastore.insert device, done

      beforeEach (done) ->
        @sut.checkMessageReceived subscriber: 'ohBoy', emitter: 'ohBoy', (error, @checkMessageReceived) =>
          done error

      it 'should have a checkMessageReceived sent of true', ->
        expect(@checkMessageReceived).to.be.true

    describe 'when called with a invalid subscriber, emitter', ->
      beforeEach (done) ->
        device =
          uuid: 'ya son'
          meshblu:
            version: '2.0.0'
            whitelists:
              message:
                received: [{uuid: 'ohBoy'}]

        @datastore.insert device, done

      beforeEach (done) ->
        device =
          uuid: 'for real'
        @datastore.insert device, done

      beforeEach (done) ->
        @sut.checkMessageReceived subscriber: 'ya son', emitter: 'for real', (error, @checkMessageReceived) =>
          done error

      it 'should have a checkMessageReceived sent of false', ->
        expect(@checkMessageReceived).to.be.false

    describe 'when subscriber and emitter are the same', ->
      beforeEach (done) ->
        device =
          uuid: 'oh boy'
        @datastore.insert device, done

      beforeEach (done) ->
        @sut.checkMessageReceived emitter: 'oh boy', subscriber: 'oh boy', (error, @checkMessageReceived) =>
          done error

      it 'should have a checkMessageReceived sent of true', ->
        expect(@checkMessageReceived).to.be.true

    describe 'when called with a invalid subscriber, emitter', ->
      beforeEach (done) ->
        device =
          uuid: 'ya son'
          meshblu:
            version: '2.0.0'
            whitelists:
              message:
                received: [{uuid: 'not for real'}]
        @datastore.insert device, done

      beforeEach (done) ->
        device =
          uuid: 'for real'
        @datastore.insert device, done

      beforeEach (done) ->
        @sut.checkMessageReceived emitter: 'ya son', subscriber: 'for real', (error, @checkMessageReceived) =>
          done error

      it 'should have a checkMessageReceived sent of false', ->
        expect(@checkMessageReceived).to.be.false
