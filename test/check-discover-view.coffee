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

  describe '->checkDiscoverView', ->
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
              discover:
                view: [{uuid: 'ohBoy'}]
        @datastore.insert device, done

      beforeEach (done) ->
        @sut.checkDiscoverView emitter: 'ohBoy', subscriber: 'great-scott' , (error, @checkDiscoverView) =>
          done error

      it 'should have a checkDiscoverView sent of true', ->
        expect(@checkDiscoverView).to.be.true

    describe 'when subscriber and emitter are the same', ->
      beforeEach (done) ->
        device =
          uuid: 'ohBoy'
        @datastore.insert device, done

      beforeEach (done) ->
        @sut.checkDiscoverView subscriber: 'ohBoy', emitter: 'ohBoy', (error, @checkDiscoverView) =>
          done error

      it 'should have a checkDiscoverView sent of true', ->
        expect(@checkDiscoverView).to.be.true

    describe 'when called with a invalid subscriber, emitter', ->
      beforeEach (done) ->
        device =
          uuid: 'ya son'
          meshblu:
            version: '2.0.0'
            whitelists:
              discover:
                view: [{uuid: 'ohBoy'}]

        @datastore.insert device, done

      beforeEach (done) ->
        device =
          uuid: 'for real'
        @datastore.insert device, done

      beforeEach (done) ->
        @sut.checkDiscoverView subscriber: 'ya son', emitter: 'for real', (error, @checkDiscoverView) =>
          done error

      it 'should have a checkDiscoverView sent of false', ->
        expect(@checkDiscoverView).to.be.false

    describe 'when subscriber and emitter are the same', ->
      beforeEach (done) ->
        device =
          uuid: 'oh boy'
        @datastore.insert device, done

      beforeEach (done) ->
        @sut.checkDiscoverView emitter: 'oh boy', subscriber: 'oh boy', (error, @checkDiscoverView) =>
          done error

      it 'should have a checkDiscoverView sent of true', ->
        expect(@checkDiscoverView).to.be.true

    describe 'when called with a invalid subscriber, emitter', ->
      beforeEach (done) ->
        device =
          uuid: 'ya son'
          meshblu:
            version: '2.0.0'
            whitelists:
              discover:
                view: [{uuid: 'not for real'}]
        @datastore.insert device, done

      beforeEach (done) ->
        device =
          uuid: 'for real'
        @datastore.insert device, done

      beforeEach (done) ->
        @sut.checkDiscoverView emitter: 'ya son', subscriber: 'for real', (error, @checkDiscoverView) =>
          done error

      it 'should have a checkDiscoverView sent of false', ->
        expect(@checkDiscoverView).to.be.false
