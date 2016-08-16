mongojs = require 'mongojs'
Datastore = require 'meshblu-core-datastore'
WhitelistManager = require '../src/whitelist-manager'

describe 'check Broadcast As', ->
  beforeEach (done) ->
    database = mongojs 'test-whitelist-manager', ['devices']
    @datastore = new Datastore
      database: database
      collection: 'devices'
    database.devices.remove => done()

  beforeEach ->
    @uuidAliasResolver = resolve: (uuid, callback) => callback(null, uuid)

    @sut = new WhitelistManager {@datastore, @uuidAliasResolver}

  describe '->checkBroadcastAs', ->
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
                as: [{uuid: 'ohBoy'}]
        @datastore.insert device, done

      beforeEach (done) ->
        @sut.checkBroadcastAs emitter: 'great-scott', subscriber: 'ohBoy' , (error, @checkBroadcastAs) =>
          done error

      it 'should have a checkBroadcastAs sent of true', ->
        expect(@checkBroadcastAs).to.be.true

    describe 'when subscriber and emitter are the same', ->
      beforeEach (done) ->
        device =
          uuid: 'ohBoy'
        @datastore.insert device, done

      beforeEach (done) ->
        @sut.checkBroadcastAs subscriber: 'ohBoy', emitter: 'ohBoy', (error, @checkBroadcastAs) =>
          done error

      it 'should have a checkBroadcastAs sent of true', ->
        expect(@checkBroadcastAs).to.be.true

    describe 'when called with a invalid subscriber, emitter', ->
      beforeEach (done) ->
        device =
          uuid: 'ya son'
          meshblu:
            version: '2.0.0'
            whitelists:
              broadcast:
                as: [{uuid: 'ohBoy'}]

        @datastore.insert device, done

      beforeEach (done) ->
        device =
          uuid: 'for real'
        @datastore.insert device, done

      beforeEach (done) ->
        @sut.checkBroadcastAs subscriber: 'ya son', emitter: 'for real', (error, @checkBroadcastAs) =>
          done error

      it 'should have a checkBroadcastAs sent of false', ->
        expect(@checkBroadcastAs).to.be.false

    describe 'when subscriber and emitter are the same', ->
      beforeEach (done) ->
        device =
          uuid: 'oh boy'
        @datastore.insert device, done

      beforeEach (done) ->
        @sut.checkBroadcastAs emitter: 'oh boy', subscriber: 'oh boy', (error, @checkBroadcastAs) =>
          done error

      it 'should have a checkBroadcastAs sent of true', ->
        expect(@checkBroadcastAs).to.be.true

    describe 'when called with a invalid subscriber, emitter', ->
      beforeEach (done) ->
        device =
          uuid: 'ya son'
          meshblu:
            version: '2.0.0'
            whitelists:
              broadcast:
                as: [{uuid: 'not for real'}]
        @datastore.insert device, done

      beforeEach (done) ->
        device =
          uuid: 'for real'
        @datastore.insert device, done

      beforeEach (done) ->
        @sut.checkBroadcastAs emitter: 'ya son', subscriber: 'for real', (error, @checkBroadcastAs) =>
          done error

      it 'should have a checkBroadcastAs sent of false', ->
        expect(@checkBroadcastAs).to.be.false
