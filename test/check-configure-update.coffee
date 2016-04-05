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

  describe '->checkConfigureUpdate', ->
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
                update:
                  ohBoy: {}
        @datastore.insert device, done

      beforeEach (done) ->
        @sut.checkConfigureUpdate emitter: 'ohBoy', subscriber: 'great-scott' , (error, @checkConfigureUpdate) =>
          done error

      it 'should have a checkConfigureUpdate sent of true', ->
        expect(@checkConfigureUpdate).to.be.true

    describe 'when subscriber and emitter are the same', ->
      beforeEach (done) ->
        device =
          uuid: 'ohBoy'
        @datastore.insert device, done

      beforeEach (done) ->
        @sut.checkConfigureUpdate subscriber: 'ohBoy', emitter: 'ohBoy', (error, @checkConfigureUpdate) =>
          done error

      it 'should have a checkConfigureUpdate sent of true', ->
        expect(@checkConfigureUpdate).to.be.true

    describe 'when called with a invalid subscriber, emitter', ->
      beforeEach (done) ->
        device =
          uuid: 'ya son'
          meshblu:
            version: '2.0.0'
            whitelists:
              configure:
                update:
                  ohBoy: {}

        @datastore.insert device, done

      beforeEach (done) ->
        device =
          uuid: 'for real'
        @datastore.insert device, done

      beforeEach (done) ->
        @sut.checkConfigureUpdate subscriber: 'ya son', emitter: 'for real', (error, @checkConfigureUpdate) =>
          done error

      it 'should have a checkConfigureUpdate sent of false', ->
        expect(@checkConfigureUpdate).to.be.false

    describe 'when subscriber and emitter are the same', ->
      beforeEach (done) ->
        device =
          uuid: 'oh boy'
        @datastore.insert device, done

      beforeEach (done) ->
        @sut.checkConfigureUpdate emitter: 'oh boy', subscriber: 'oh boy', (error, @checkConfigureUpdate) =>
          done error

      it 'should have a checkConfigureUpdate sent of true', ->
        expect(@checkConfigureUpdate).to.be.true

    describe 'when called with a invalid subscriber, emitter', ->
      beforeEach (done) ->
        device =
          uuid: 'ya son'
          meshblu:
            version: '2.0.0'
            whitelists:
              configure:
                update:
                  'not for real': true
        @datastore.insert device, done

      beforeEach (done) ->
        device =
          uuid: 'for real'
        @datastore.insert device, done

      beforeEach (done) ->
        @sut.checkConfigureUpdate emitter: 'ya son', subscriber: 'for real', (error, @checkConfigureUpdate) =>
          done error

      it 'should have a checkConfigureUpdate sent of false', ->
        expect(@checkConfigureUpdate).to.be.false
