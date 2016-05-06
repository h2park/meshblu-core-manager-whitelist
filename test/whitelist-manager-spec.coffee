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

  describe '->canConfigure', ->
    describe 'when called with a valid toUuid, fromUuid', ->
      beforeEach (done) ->
        device =
          uuid: 'oh boy'
        @datastore.insert device, done

      beforeEach (done) ->
        device =
          uuid: 'great-scott'
          configureWhitelist: ['oh boy']
        @datastore.insert device, done

      beforeEach (done) ->
        @sut.canConfigure fromUuid: 'oh boy', toUuid: 'great-scott', (error, @canConfigure) =>
          done error

      it 'should have a can configure of true', ->
        expect(@canConfigure).to.be.true

    describe 'when toUuid and fromUuid are the same', ->
      beforeEach (done) ->
        device =
          uuid: 'oh boy'
        @datastore.insert device, done

      beforeEach (done) ->
        @sut.canConfigure fromUuid: 'oh boy', toUuid: 'oh boy', (error, @canConfigure) =>
          done error

      it 'should have a can configure of true', ->
        expect(@canConfigure).to.be.true

    describe 'when called with a invalid toUuid, fromUuid', ->
      beforeEach (done) ->
        device =
          uuid: 'ya son'
          configureWhitelist: ['not for real']
        @datastore.insert device, done

      beforeEach (done) ->
        device =
          uuid: 'for real'
        @datastore.insert device, done

      beforeEach (done) ->
        @sut.canConfigure fromUuid: 'ya son', toUuid: 'for real', (error, @canConfigure) =>
          done error

      it 'should have a can configure of false', ->
        expect(@canConfigure).to.be.false

  describe 'when called fromUuid is the owner', ->
    beforeEach (done) ->
      device =
        uuid: 'ya son'
      @datastore.insert device, done

    beforeEach (done) ->
      device =
        uuid: 'for real'
        owner: 'ya son'
      @datastore.insert device, done

    beforeEach (done) ->
      @sut.canConfigure fromUuid: 'ya son', toUuid: 'for real', (error, @canConfigure) =>
        done error

    it 'should have a can configure of true', ->
      expect(@canConfigure).to.be.true

  describe 'when *', ->
    beforeEach (done) ->
      device =
        uuid: 'ya son'
      @datastore.insert device, done

    beforeEach (done) ->
      device =
        uuid: 'for real'
        configureWhitelist: ['*']
      @datastore.insert device, done

    beforeEach (done) ->
      @sut.canConfigure fromUuid: 'ya son', toUuid: 'for real', (error, @canConfigure) =>
        done error

    it 'should have a can configure of true', ->
      expect(@canConfigure).to.be.true

  describe '->canConfigureAs', ->
    describe 'when called with a valid toUuid, fromUuid', ->
      beforeEach (done) ->
        device =
          uuid: 'oh boy'
        @datastore.insert device, done

      beforeEach (done) ->
        device =
          uuid: 'great-scott'
          configureAsWhitelist: ['oh boy']
        @datastore.insert device, done

      beforeEach (done) ->
        @sut.canConfigureAs fromUuid: 'oh boy', toUuid: 'great-scott', (error, @canConfigureAs) =>
          done error

      it 'should have a can configure of true', ->
        expect(@canConfigureAs).to.be.true

    describe 'when called with a invalid toUuid, fromUuid', ->
      beforeEach (done) ->
        device =
          uuid: 'ya son'
          configureAsWhitelist: ['not for real']
        @datastore.insert device, done

      beforeEach (done) ->
        device =
          uuid: 'for real'
        @datastore.insert device, done

      beforeEach (done) ->
        @sut.canConfigureAs fromUuid: 'ya son', toUuid: 'for real', (error, @canConfigureAs) =>
          done error

      it 'should have a can configure of false', ->
        expect(@canConfigureAs).to.be.false

  describe '->canDiscover', ->
    describe 'when called with a valid toUuid, fromUuid', ->
      beforeEach (done) ->
        device =
          uuid: 'oh boy'
        @datastore.insert device, done

      beforeEach (done) ->
        device =
          uuid: 'great-scott'
          discoverWhitelist: ['oh boy']
        @datastore.insert device, done

      beforeEach (done) ->
        @sut.canDiscover fromUuid: 'oh boy', toUuid: 'great-scott', (error, @canDiscover) =>
          done error

      it 'should have a can discover of true', ->
        expect(@canDiscover).to.be.true

    describe 'when called with a invalid toUuid, fromUuid', ->
      beforeEach (done) ->
        device =
          uuid: 'ya son'
          discoverWhitelist: ['not for real']
        @datastore.insert device, done

      beforeEach (done) ->
        device =
          uuid: 'for real'
        @datastore.insert device, done

      beforeEach (done) ->
        @sut.canDiscover fromUuid: 'ya son', toUuid: 'for real', (error, @canDiscover) =>
          done error

      it 'should have a can discover of false', ->
        expect(@canDiscover).to.be.false

  describe '->canDiscoverAs', ->
    describe 'when called with a valid toUuid, fromUuid', ->
      beforeEach (done) ->
        device =
          uuid: 'oh boy'
        @datastore.insert device, done

      beforeEach (done) ->
        device =
          uuid: 'great-scott'
          discoverAsWhitelist: ['oh boy']
        @datastore.insert device, done

      beforeEach (done) ->
        @sut.canDiscoverAs fromUuid: 'oh boy', toUuid: 'great-scott', (error, @canDiscoverAs) =>
          done error

      it 'should have a can discover of true', ->
        expect(@canDiscoverAs).to.be.true

    describe 'when called with a invalid toUuid, fromUuid', ->
      beforeEach (done) ->
        device =
          uuid: 'ya son'
          discoverAsWhitelist: ['not for real']
        @datastore.insert device, done

      beforeEach (done) ->
        device =
          uuid: 'for real'
        @datastore.insert device, done

      beforeEach (done) ->
        @sut.canDiscoverAs fromUuid: 'ya son', toUuid: 'for real', (error, @canDiscoverAs) =>
          done error

      it 'should have a can discover of false', ->
        expect(@canDiscoverAs).to.be.false

  describe '->canReceive', ->
    describe 'when called with a valid toUuid, fromUuid', ->
      beforeEach (done) ->
        device =
          uuid: 'oh boy'
        @datastore.insert device, done

      beforeEach (done) ->
        device =
          uuid: 'great-scott'
          receiveWhitelist: ['oh boy']
        @datastore.insert device, done

      beforeEach (done) ->
        @sut.canReceive fromUuid: 'oh boy', toUuid: 'great-scott', (error, @canReceive) =>
          done error

      it 'should have a can receive of true', ->
        expect(@canReceive).to.be.true

    describe 'when called with a invalid toUuid, fromUuid', ->
      beforeEach (done) ->
        device =
          uuid: 'ya son'
          receiveWhitelist: ['not for real']
        @datastore.insert device, done

      beforeEach (done) ->
        device =
          uuid: 'for real'
        @datastore.insert device, done

      beforeEach (done) ->
        @sut.canReceive fromUuid: 'ya son', toUuid: 'for real', (error, @canReceive) =>
          done error

      it 'should have a can receive of false', ->
        expect(@canReceive).to.be.false

  describe '->canReceiveAs', ->
    describe 'when called with a valid toUuid, fromUuid', ->
      beforeEach (done) ->
        device =
          uuid: 'oh boy'
        @datastore.insert device, done

      beforeEach (done) ->
        device =
          uuid: 'great-scott'
          receiveAsWhitelist: ['oh boy']
        @datastore.insert device, done

      beforeEach (done) ->
        @sut.canReceiveAs fromUuid: 'oh boy', toUuid: 'great-scott', (error, @canReceiveAs) =>
          done error

      it 'should have a can receive of true', ->
        expect(@canReceiveAs).to.be.true

    describe 'when called with a invalid toUuid, fromUuid', ->
      beforeEach (done) ->
        device =
          uuid: 'ya son'
          receiveAsWhitelist: ['not for real']
        @datastore.insert device, done

      beforeEach (done) ->
        device =
          uuid: 'for real'
        @datastore.insert device, done

      beforeEach (done) ->
        @sut.canReceiveAs fromUuid: 'ya son', toUuid: 'for real', (error, @canReceiveAs) =>
          done error

      it 'should have a can receive of false', ->
        expect(@canReceiveAs).to.be.false

  describe '->canSend', ->
    describe 'when called with a valid toUuid, fromUuid', ->
      beforeEach (done) ->
        device =
          uuid: 'oh boy'
        @datastore.insert device, done

      beforeEach (done) ->
        device =
          uuid: 'great-scott'
          sendWhitelist: ['oh boy']
        @datastore.insert device, done

      beforeEach (done) ->
        @sut.canSend fromUuid: 'oh boy', toUuid: 'great-scott', (error, @canSend) =>
          done error

      it 'should have a can send of true', ->
        expect(@canSend).to.be.true

    describe 'when called with a invalid toUuid, fromUuid', ->
      beforeEach (done) ->
        device =
          uuid: 'ya son'
          sendWhitelist: ['not for real']
        @datastore.insert device, done

      beforeEach (done) ->
        device =
          uuid: 'for real'
        @datastore.insert device, done

      beforeEach (done) ->
        @sut.canSend fromUuid: 'ya son', toUuid: 'for real', (error, @canSend) =>
          done error

      it 'should have a can send of false', ->
        expect(@canSend).to.be.false

  describe '->canSendAs', ->
    describe 'when called with a valid toUuid, fromUuid', ->
      beforeEach (done) ->
        device =
          uuid: 'oh boy'
        @datastore.insert device, done

      beforeEach (done) ->
        device =
          uuid: 'great-scott'
          sendAsWhitelist: ['oh boy']
        @datastore.insert device, done

      beforeEach (done) ->
        @sut.canSendAs fromUuid: 'oh boy', toUuid: 'great-scott', (error, @canSendAs) =>
          done error

      it 'should have a can send of true', ->
        expect(@canSendAs).to.be.true

    describe 'when called with a invalid toUuid, fromUuid', ->
      beforeEach (done) ->
        device =
          uuid: 'ya son'
          sendAsWhitelist: ['not for real']
        @datastore.insert device, done

      beforeEach (done) ->
        device =
          uuid: 'for real'
        @datastore.insert device, done

      beforeEach (done) ->
        @sut.canSendAs fromUuid: 'ya son', toUuid: 'for real', (error, @canSendAs) =>
          done error

      it 'should have a can send of false', ->
        expect(@canSendAs).to.be.false
