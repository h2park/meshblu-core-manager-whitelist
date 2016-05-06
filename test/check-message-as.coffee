mongojs = require 'mongojs'
Datastore = require 'meshblu-core-datastore'
WhitelistManager = require '../src/whitelist-manager'

describe 'WhitelistManager', ->
  beforeEach (done) ->
    database = mongojs 'test-whitelist-manager', ['devices']
    @datastore = new Datastore
      database: database
      collection: 'devices'
    database.devices.remove => done()

  beforeEach ->
    @uuidAliasResolver = resolve: (uuid, callback) => callback(null, uuid)

    @sut = new WhitelistManager {@datastore, @uuidAliasResolver}

  describe '->checkMessageAs', ->
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
                as: [{uuid: 'ohBoy'}]
        @datastore.insert device, done

      beforeEach (done) ->
        @sut.checkMessageAs emitter: 'great-scott', subscriber: 'ohBoy' , (error, @checkMessageAs) =>
          done error

      it 'should have a checkMessageAs sent of true', ->
        expect(@checkMessageAs).to.be.true

    describe 'when subscriber and emitter are the same', ->
      beforeEach (done) ->
        device =
          uuid: 'ohBoy'
        @datastore.insert device, done

      beforeEach (done) ->
        @sut.checkMessageAs subscriber: 'ohBoy', emitter: 'ohBoy', (error, @checkMessageAs) =>
          done error

      it 'should have a checkMessageAs sent of true', ->
        expect(@checkMessageAs).to.be.true

    describe 'when called with a invalid subscriber, emitter', ->
      beforeEach (done) ->
        device =
          uuid: 'ya son'
          meshblu:
            version: '2.0.0'
            whitelists:
              message:
                as: [{uuid: 'ohBoy'}]

        @datastore.insert device, done

      beforeEach (done) ->
        device =
          uuid: 'for real'
        @datastore.insert device, done

      beforeEach (done) ->
        @sut.checkMessageAs subscriber: 'ya son', emitter: 'for real', (error, @checkMessageAs) =>
          done error

      it 'should have a checkMessageAs sent of false', ->
        expect(@checkMessageAs).to.be.false

    describe 'when subscriber and emitter are the same', ->
      beforeEach (done) ->
        device =
          uuid: 'oh boy'
        @datastore.insert device, done

      beforeEach (done) ->
        @sut.checkMessageAs emitter: 'oh boy', subscriber: 'oh boy', (error, @checkMessageAs) =>
          done error

      it 'should have a checkMessageAs sent of true', ->
        expect(@checkMessageAs).to.be.true

    describe 'when called with a invalid subscriber, emitter', ->
      beforeEach (done) ->
        device =
          uuid: 'ya son'
          meshblu:
            version: '2.0.0'
            whitelists:
              message:
                as: [{uuid: 'not for real'}]
        @datastore.insert device, done

      beforeEach (done) ->
        device =
          uuid: 'for real'
        @datastore.insert device, done

      beforeEach (done) ->
        @sut.checkMessageAs emitter: 'ya son', subscriber: 'for real', (error, @checkMessageAs) =>
          done error

      it 'should have a checkMessageAs sent of false', ->
        expect(@checkMessageAs).to.be.false
