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

  describe '->checkMessageFrom', ->
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
                from: [{uuid: 'ohBoy'}]
        @datastore.insert device, done

      beforeEach (done) ->
        @sut.checkMessageFrom emitter: 'ohBoy', subscriber: 'great-scott' , (error, @checkMessageFrom) =>
          done error

      it 'should have a checkMessageFrom sent of true', ->
        expect(@checkMessageFrom).to.be.true

    describe 'when subscriber and emitter are the same', ->
      beforeEach (done) ->
        device =
          uuid: 'ohBoy'
        @datastore.insert device, done

      beforeEach (done) ->
        @sut.checkMessageFrom subscriber: 'ohBoy', emitter: 'ohBoy', (error, @checkMessageFrom) =>
          done error

      it 'should have a checkMessageFrom sent of true', ->
        expect(@checkMessageFrom).to.be.true

    describe 'when called with a invalid subscriber, emitter', ->
      beforeEach (done) ->
        device =
          uuid: 'ya son'
          meshblu:
            version: '2.0.0'
            whitelists:
              message:
                from: [{uuid: 'ohBoy'}]

        @datastore.insert device, done

      beforeEach (done) ->
        device =
          uuid: 'for real'
        @datastore.insert device, done

      beforeEach (done) ->
        @sut.checkMessageFrom subscriber: 'ya son', emitter: 'for real', (error, @checkMessageFrom) =>
          done error

      it 'should have a checkMessageFrom sent of false', ->
        expect(@checkMessageFrom).to.be.false

    describe 'when subscriber and emitter are the same', ->
      beforeEach (done) ->
        device =
          uuid: 'oh boy'
        @datastore.insert device, done

      beforeEach (done) ->
        @sut.checkMessageFrom emitter: 'oh boy', subscriber: 'oh boy', (error, @checkMessageFrom) =>
          done error

      it 'should have a checkMessageFrom sent of true', ->
        expect(@checkMessageFrom).to.be.true

    describe 'when called with a invalid subscriber, emitter', ->
      beforeEach (done) ->
        device =
          uuid: 'ya son'
          meshblu:
            version: '2.0.0'
            whitelists:
              message:
                from: [{uuid: 'not for real'}]
        @datastore.insert device, done

      beforeEach (done) ->
        device =
          uuid: 'for real'
        @datastore.insert device, done

      beforeEach (done) ->
        @sut.checkMessageFrom emitter: 'ya son', subscriber: 'for real', (error, @checkMessageFrom) =>
          done error

      it 'should have a checkMessageFrom sent of false', ->
        expect(@checkMessageFrom).to.be.false
