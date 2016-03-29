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

  describe '->canSeeBroadcastsSent', ->
    describe 'when called with a valid broadcaster and subscriber', ->
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
                sent:
                  ohBoy: {}
        @datastore.insert device, done

      beforeEach (done) ->
        @sut.canSeeBroadcastsSent broadcaster: 'great-scott', subscriber: 'ohBoy' , (error, @canSeeBroadcastsSent) =>
          done error

      it 'should have a can broadcast sent of true', ->
        expect(@canSeeBroadcastsSent).to.be.true

    describe 'when subscriber and broadcaster are the same', ->
      beforeEach (done) ->
        device =
          uuid: 'ohBoy'
        @datastore.insert device, done

      beforeEach (done) ->
        @sut.canSeeBroadcastsSent subscriber: 'ohBoy', broadcaster: 'ohBoy', (error, @canSeeBroadcastsSent) =>
          done error

      it 'should have a can broadcast sent of true', ->
        expect(@canSeeBroadcastsSent).to.be.true

    describe 'when called with a invalid subscriber, broadcaster', ->
      beforeEach (done) ->
        device =
          uuid: 'ya son'
          meshblu:
            version: '2.0.0'
            whitelists:
              broadcast:
                sent:
                  ohBoy: {}

        @datastore.insert device, done

      beforeEach (done) ->
        device =
          uuid: 'for real'
        @datastore.insert device, done

      beforeEach (done) ->
        @sut.canSeeBroadcastsSent subscriber: 'ya son', broadcaster: 'for real', (error, @canSeeBroadcastsSent) =>
          done error

      it 'should have a can broadcast sent of false', ->
        expect(@canSeeBroadcastsSent).to.be.false

    describe 'when subscriber and broadcaster are the same', ->
      beforeEach (done) ->
        device =
          uuid: 'oh boy'
        @datastore.insert device, done

      beforeEach (done) ->
        @sut.canSeeBroadcastsSent broadcaster: 'oh boy', subscriber: 'oh boy', (error, @canSeeBroadcastsSent) =>
          done error

      it 'should have a can broadcast sent of true', ->
        expect(@canSeeBroadcastsSent).to.be.true

    describe 'when called with a invalid subscriber, broadcaster', ->
      beforeEach (done) ->
        device =
          uuid: 'ya son'
          meshblu:
            version: '2.0.0'
            whitelists:
              broadcast:
                sent:
                  'not for real': true
        @datastore.insert device, done

      beforeEach (done) ->
        device =
          uuid: 'for real'
        @datastore.insert device, done

      beforeEach (done) ->
        @sut.canSeeBroadcastsSent broadcaster: 'ya son', subscriber: 'for real', (error, @canSeeBroadcastsSent) =>
          done error

      it 'should have a can broadcast sent of false', ->
        expect(@canSeeBroadcastsSent).to.be.false
