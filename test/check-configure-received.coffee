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

  describe '->checkConfigureReceived', ->
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
              configure:
                received:
                  ohBoy: {}
        @datastore.insert device, done

      beforeEach (done) ->
        @sut.checkConfigureReceived emitter: 'great-scott', subscriber: 'ohBoy' , (error, @checkConfigureReceived) =>
          done error

      it 'should have a checkConfigureReceived sent of true', ->
        expect(@checkConfigureReceived).to.be.true

    describe 'when subscriber and emitter are the same', ->
      beforeEach (done) ->
        device =
          uuid: 'ohBoy'
        @datastore.insert device, done

      beforeEach (done) ->
        @sut.checkConfigureReceived subscriber: 'ohBoy', emitter: 'ohBoy', (error, @checkConfigureReceived) =>
          done error

      it 'should have a checkConfigureReceived sent of true', ->
        expect(@checkConfigureReceived).to.be.true

    describe 'when called with a invalid subscriber, emitter', ->
      beforeEach (done) ->
        device =
          uuid: 'ya son'
          meshblu:
            version: '2.0.0'
            whitelists:
              configure:
                received:
                  ohBoy: {}

        @datastore.insert device, done

      beforeEach (done) ->
        device =
          uuid: 'for real'
        @datastore.insert device, done

      beforeEach (done) ->
        @sut.checkConfigureReceived subscriber: 'ya son', emitter: 'for real', (error, @checkConfigureReceived) =>
          done error

      it 'should have a checkConfigureReceived sent of false', ->
        expect(@checkConfigureReceived).to.be.false

    describe 'when subscriber and emitter are the same', ->
      beforeEach (done) ->
        device =
          uuid: 'oh boy'
        @datastore.insert device, done

      beforeEach (done) ->
        @sut.checkConfigureReceived emitter: 'oh boy', subscriber: 'oh boy', (error, @checkConfigureReceived) =>
          done error

      it 'should have a checkConfigureReceived sent of true', ->
        expect(@checkConfigureReceived).to.be.true

    describe 'when called with a invalid subscriber, emitter', ->
      beforeEach (done) ->
        device =
          uuid: 'ya son'
          meshblu:
            version: '2.0.0'
            whitelists:
              configure:
                received:
                  'not for real': true
        @datastore.insert device, done

      beforeEach (done) ->
        device =
          uuid: 'for real'
        @datastore.insert device, done

      beforeEach (done) ->
        @sut.checkConfigureReceived emitter: 'ya son', subscriber: 'for real', (error, @checkConfigureReceived) =>
          done error

      it 'should have a checkConfigureReceived sent of false', ->
        expect(@checkConfigureReceived).to.be.false
