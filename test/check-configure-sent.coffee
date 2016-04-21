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

  describe '->checkConfigureSent', ->
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
                sent: [{uuid: 'ohBoy'}]
        @datastore.insert device, done

      beforeEach (done) ->
        @sut.checkConfigureSent emitter: 'great-scott', subscriber: 'ohBoy' , (error, @checkConfigureSent) =>
          done error

      it 'should have a checkConfigureSent sent of true', ->
        expect(@checkConfigureSent).to.be.true

    describe 'when subscriber and emitter are the same', ->
      beforeEach (done) ->
        device =
          uuid: 'ohBoy'
        @datastore.insert device, done

      beforeEach (done) ->
        @sut.checkConfigureSent subscriber: 'ohBoy', emitter: 'ohBoy', (error, @checkConfigureSent) =>
          done error

      it 'should have a checkConfigureSent sent of true', ->
        expect(@checkConfigureSent).to.be.true

    describe 'when called with a invalid subscriber, emitter', ->
      beforeEach (done) ->
        device =
          uuid: 'ya son'
          meshblu:
            version: '2.0.0'
            whitelists:
              configure:
                sent: [{uuid: 'ohBoy'}]

        @datastore.insert device, done

      beforeEach (done) ->
        device =
          uuid: 'for real'
        @datastore.insert device, done

      beforeEach (done) ->
        @sut.checkConfigureSent subscriber: 'ya son', emitter: 'for real', (error, @checkConfigureSent) =>
          done error

      it 'should have a checkConfigureSent sent of false', ->
        expect(@checkConfigureSent).to.be.false

    describe 'when subscriber and emitter are the same', ->
      beforeEach (done) ->
        device =
          uuid: 'oh boy'
        @datastore.insert device, done

      beforeEach (done) ->
        @sut.checkConfigureSent emitter: 'oh boy', subscriber: 'oh boy', (error, @checkConfigureSent) =>
          done error

      it 'should have a checkConfigureSent sent of true', ->
        expect(@checkConfigureSent).to.be.true

    describe 'when called with a invalid subscriber, emitter', ->
      beforeEach (done) ->
        device =
          uuid: 'ya son'
          meshblu:
            version: '2.0.0'
            whitelists:
              configure:
                sent: [{uuid: 'not for real'}]
        @datastore.insert device, done

      beforeEach (done) ->
        device =
          uuid: 'for real'
        @datastore.insert device, done

      beforeEach (done) ->
        @sut.checkConfigureSent emitter: 'ya son', subscriber: 'for real', (error, @checkConfigureSent) =>
          done error

      it 'should have a checkConfigureSent sent of false', ->
        expect(@checkConfigureSent).to.be.false
