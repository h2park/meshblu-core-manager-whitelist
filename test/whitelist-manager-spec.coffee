WhitelistManager = require '../src/whitelist-manager'

describe 'WhitelistManager', ->
  beforeEach ->
    @uuidAliasResolver = resolve: (uuid, callback) => callback(null, uuid)

    @datastore =
      findOne: sinon.stub()

    @sut = new WhitelistManager {@datastore, @uuidAliasResolver}

  describe '->canConfigure', ->
    describe 'when called with a valid toUuid, fromUuid', ->
      beforeEach (done) ->
        @datastore
          .findOne
          .withArgs uuid: 'great-scott'
          .yields null,
            uuid: 'oh boy'
            configureWhitelist: ['great-scott']

        @datastore
          .findOne
          .withArgs uuid: 'oh boy'
          .yields null,
            uuid: 'oh boy'

        @sut.canConfigure fromUuid: 'oh boy', toUuid: 'great-scott', (error, @canConfigure) =>
          done error

      it 'should have a can configure of true', ->
        expect(@canConfigure).to.be.true

    describe 'when called with a invalid toUuid, fromUuid', ->
      beforeEach (done) ->
        @datastore
          .findOne
          .withArgs uuid: 'ya son'
          .yields null,
            uuid: 'ya son'
            configureWhitelist: ['not for real']

        @datastore
          .findOne
          .withArgs uuid: 'for real'
          .yields null,
            uuid: 'for real'

        @sut.canConfigure fromUuid: 'ya son', toUuid: 'for real', (error, @canConfigure) =>
          done error

      it 'should have a can configure of false', ->
        expect(@canConfigure).to.be.false

    describe 'when called and toDevice fetch yields an error', ->
      beforeEach (done) ->
        @datastore
          .findOne
          .withArgs uuid: 'quit dreaming'
          .yields new Error("no way")

        @sut.canConfigure fromUuid: 'nobody cares', toUuid: 'quit dreaming', (@error) => done()

      it 'should have an error', ->
        expect(@error.message).to.equal 'no way'

    describe 'when called and fromDevice fetch yields an error', ->
      beforeEach (done) ->
        @datastore
          .findOne
          .withArgs uuid: 'forget about it'
          .yields null,
            uuid: 'forget about it'

        @datastore
          .findOne
          .withArgs uuid: 'sunshine and rainbows'
          .yields new Error("cry me a river")

        @sut.canConfigure fromUuid: 'forget about it', toUuid: 'sunshine and rainbows', (@error) => done()

      it 'should have an error', ->
        expect(@error.message).to.equal 'cry me a river'

  describe '->canDiscover', ->
    describe 'when called with a valid toUuid, fromUuid', ->
      beforeEach (done) ->
        @datastore
          .findOne
          .withArgs uuid: 'great-scott'
          .yields null,
            uuid: 'great-scott'
            discoverWhitelist: ['oh boy']

        @datastore
          .findOne
          .withArgs uuid: 'oh boy'
          .yields null,
            uuid: 'oh boy'

        @sut.canDiscover fromUuid: 'great-scott', toUuid: 'oh boy', (error, @canDiscover) =>
          done error

      it 'should have a can discover of true', ->
        expect(@canDiscover).to.be.true

    describe 'when called with a invalid toUuid, fromUuid', ->
      beforeEach (done) ->
        @datastore
          .findOne
          .withArgs uuid: 'ya son'
          .yields null,
            uuid: 'ya son'
            discoverWhitelist: ['not for real']

        @datastore
          .findOne
          .withArgs uuid: 'for real'
          .yields null,
            uuid: 'for real'

        @sut.canDiscover fromUuid: 'for real', toUuid: 'ya son', (error, @canDiscover) =>
          done error

      it 'should have a can discover of false', ->
        expect(@canDiscover).to.be.false

    describe 'when called and toDevice fetch yields an error', ->
      beforeEach (done) ->
        @datastore
          .findOne
          .withArgs uuid: 'quit dreaming'
          .yields new Error("no way")

        @sut.canDiscover fromUuid: 'nobody cares', toUuid: 'quit dreaming', (@error) => done()

      it 'should have an error', ->
        expect(@error.message).to.equal 'no way'

    describe 'when called and fromDevice fetch yields an error', ->
      beforeEach (done) ->
        @datastore
          .findOne
          .withArgs uuid: 'forget about it'
          .yields null,
            uuid: 'forget about it'

        @datastore
          .findOne
          .withArgs uuid: 'sunshine and rainbows'
          .yields new Error("cry me a river")

        @sut.canDiscover fromUuid: 'forget about it', toUuid: 'sunshine and rainbows', (@error) => done()

      it 'should have an error', ->
        expect(@error.message).to.equal 'cry me a river'

  describe '->canDiscoverAs', ->
    describe 'when called with a valid toUuid, fromUuid', ->
      beforeEach (done) ->
        @datastore
          .findOne
          .withArgs uuid: 'great-scott'
          .yields null,
            uuid: 'great-scott'
            discoverAsWhitelist: ['oh boy']

        @datastore
          .findOne
          .withArgs uuid: 'oh boy'
          .yields null,
            uuid: 'oh boy'

        @sut.canDiscoverAs fromUuid: 'great-scott', toUuid: 'oh boy', (error, @canDiscoverAs) =>
          done error

      it 'should have a can discoverAs of true', ->
        expect(@canDiscoverAs).to.be.false

    describe 'when called with a invalid toUuid, fromUuid', ->
      beforeEach (done) ->
        @datastore
          .findOne
          .withArgs uuid: 'ya son'
          .yields null,
            uuid: 'ya son'
            discoverAsWhitelist: ['not for real']

        @datastore
          .findOne
          .withArgs uuid: 'for real'
          .yields null,
            uuid: 'for real'

        @sut.canDiscoverAs fromUuid: 'for real', toUuid: 'ya son', (error, @canDiscoverAs) =>
          done error

      it 'should have a can configure of false', ->
        expect(@canDiscoverAs).to.be.false

    describe 'when called and toDevice fetch yields an error', ->
      beforeEach (done) ->
        @datastore
          .findOne
          .withArgs uuid: 'quit dreaming'
          .yields new Error("no way")

        @sut.canDiscoverAs fromUuid: 'nobody cares', toUuid: 'quit dreaming', (@error) => done()

      it 'should have an error', ->
        expect(@error.message).to.equal 'no way'

    describe 'when called and fromDevice fetch yields an error', ->
      beforeEach (done) ->
        @datastore
          .findOne
          .withArgs uuid: 'forget about it'
          .yields null,
            uuid: 'forget about it'

        @datastore
          .findOne
          .withArgs uuid: 'sunshine and rainbows'
          .yields new Error("cry me a river")

        @sut.canDiscoverAs fromUuid: 'forget about it', toUuid: 'sunshine and rainbows', (@error) => done()

      it 'should have an error', ->
        expect(@error.message).to.equal 'cry me a river'
