WhitelistManager = require '../src/whitelist-manager'

describe 'WhitelistManager', ->
  beforeEach ->
    @database =
      devices:
        findOne: sinon.stub()

    @sut = new WhitelistManager database: @database

  describe '->canConfigure', ->
    describe 'when called with a valid toUuid, fromUuid', ->
      beforeEach (done) ->
        @database
          .devices
          .findOne
          .withArgs uuid: 'great-scott'
          .yields null,
            uuid: 'great-scott'
            configureWhitelist: ['oh boy']

        @database
          .devices
          .findOne
          .withArgs uuid: 'oh boy'
          .yields null,
            uuid: 'oh boy'

        @sut.canConfigure 'great-scott', 'oh boy', (error, @canConfigure) =>
          done error

      it 'should have a can configure of true', ->
        expect(@canConfigure).to.be.true

    describe 'when called with a invalid toUuid, fromUuid', ->
      beforeEach (done) ->
        @database
          .devices
          .findOne
          .withArgs uuid: 'ya son'
          .yields null,
            uuid: 'ya son'
            configureWhitelist: ['not for real']

        @database
          .devices
          .findOne
          .withArgs uuid: 'for real'
          .yields null,
            uuid: 'for real'

        @sut.canConfigure 'ya son', 'for real', (error, @canConfigure) =>
          done error

      it 'should have a can configure of false', ->
        expect(@canConfigure).to.be.false

    describe 'when called and toDevice fetch yields an error', ->
      beforeEach (done) ->
        @database
          .devices
          .findOne
          .withArgs uuid: 'quit dreaming'
          .yields new Error("no way")

        @sut.canConfigure 'quit dreaming', 'nobody cares', (@error) => done()

      it 'should have an error', ->
        expect(@error.message).to.equal 'no way'

    describe 'when called and fromDevice fetch yields an error', ->
      beforeEach (done) ->
        @database
          .devices
          .findOne
          .withArgs uuid: 'forget about it'
          .yields null,
            uuid: 'forget about it'

        @database
          .devices
          .findOne
          .withArgs uuid: 'sunshine and rainbows'
          .yields new Error("cry me a river")

        @sut.canConfigure 'forget about it', 'sunshine and rainbows', (@error) => done()

      it 'should have an error', ->
        expect(@error.message).to.equal 'cry me a river'
