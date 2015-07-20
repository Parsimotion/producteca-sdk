_ = require("lodash")
sinon = require("sinon")
Q = require("q")

Syncer = require("./syncer")
Product = require("../product")
Adjustment = require("./adjustment")

chai = require("chai")
chai.Should()
chai.use require("sinon-chai")

describe "Syncer", ->
  client = null
  syncer = null
  campera = null
  camperaVariable = null

  beforeEach ->
    client =
      updateStocks: sinon.stub().returns Q()
      updatePrice: sinon.stub().returns Q()

    campera = new Product
      id: 1
      sku: "123456"
      description: "Campera De Cuero Para Romper La Noche"
      variations: [
        id: 2
        stocks: [
          warehouse: "Villa Crespo"
          quantity: 12
        ]
      ]

    camperaVariable = new Product
      id: 1
      sku: "123456"
      description: "Campera De Cuero Para Romper La Noche En Muchos Colores"
      variations: [
        id: 2
        barcode: "CamperaRompeNocheNegra"
        stocks: [
          warehouse: "Villa Crespo"
          quantity: 12
        ]
      ,
        id: 4
        barcode: "CamperaRompeNocheBlanca"
        stocks: [
          warehouse: "Villa Crespo"
          quantity: 16
        ]
      ]

    settings =
      identifier: "sku"
      synchro: prices: true, stocks: true
      warehouse: "Villa Crespo"
      priceList: "Meli"

    syncer = new Syncer client, settings, [
      campera,
      camperaVariable,
      new Product
        id: 2
        sku: ""
        variations: [
          id: 3
          stocks: [
            warehouse: "Villa Crespo"
          ]
        ]
    ]

  it "se ignoran los productos cuyo sku es vacio", ->
    syncer.execute [
      identifier: ""
      stock: 40
    ]

    client.updateStocks.called.should.be.false

  describe "cuando los productos no tienen variantes...", ->
    ajuste = new Adjustment
      identifier: "123456"
      price: 25
      stock: 40

    it "_joinAdjustmentsAndProducts linkea ajustes con productos de Producteca", ->
      ajustes = syncer._joinAdjustmentsAndProducts [ajuste]
      clean = (o) => JSON.parse JSON.stringify o

      clean(ajustes.linked[0]).should.eql clean
        adjustment: identifier: "123456", price: 25, stock: 40
        products: [campera, camperaVariable]

    describe "al ejecutar dispara una request a Parsimotion matcheando el id segun sku", ->
      beforeEach ->
        syncer.execute [ajuste]

      it "para actualizar stocks", ->
        client.updateStocks.should.have.been.calledWith
          id: 1
          warehouse: "Villa Crespo"
          stocks: [
            variation: 2
            quantity: 40
          ]

      it "para actualizar el precio", ->
        client.updatePrice.should.have.been.calledWith campera, "Meli", 25

    it "si en las settings digo que no quiero sincronizar precios, no lo hace", ->
      syncer.settings.synchro = prices: false, stocks: true
      syncer.execute [ajuste]
      client.updatePrice.called.should.be.false
      client.updateStocks.called.should.be.true

    it "si en las settings digo que no quiero sincronizar stocks, no lo hace", ->
      syncer.settings.synchro = prices: true, stocks: false
      syncer.execute [ajuste]
      client.updatePrice.called.should.be.true
      client.updateStocks.called.should.be.false

  describe "ejecutar devuelve un objeto con el resultado de la sincronizacion:", ->
    resultadoShouldHaveProperty = null

    beforeEach ->
      resultado = syncer.execute([
        new Adjustment(identifier: "123456", stock: 28)
      ,
        new Adjustment(identifier: "55555", stock: 70)
      ])

      resultadoShouldHaveProperty = (name, value) ->
        resultado.then (actualizados) -> actualizados[name].should.eql value

    it "los unlinked", ->
      resultadoShouldHaveProperty "unlinked", [ identifier: "55555" ]

    it "los linked", ->
      resultadoShouldHaveProperty "linked", [ identifier: "123456" ]

  describe "cuando los productos sí tienen variantes...", ->
    it "cuando sincronizo por sku: no sincroniza las variantes", ->
      ajustes = [
        new Adjustment(identifier: "CamperaRompeNocheNegra", price: 11, stock: 23)
      ,
        new Adjustment(identifier: "CamperaRompeNocheBlanca", price: 12, stock: 24)
      ,
        new Adjustment(identifier: "123456")
      ]

      syncer.execute(ajustes).then (result) =>
        result.should.eql
          linked: [ identifier: "123456" ]
          unlinked: [
            { identifier: "CamperaRompeNocheNegra" }, { identifier: "CamperaRompeNocheBlanca" }
          ]

    it "cuando sincronizo por barcode: usa el barcode y sku cuando no puede", ->
      syncer.settings.identifier = "barcode"

      ajustes = [
        new Adjustment(identifier: "CamperaRompeNocheNegra", price: 11, stock: 23)
        new Adjustment(identifier: "CamperaRompeNocheBlanca", price: 12, stock: 24)
        new Adjustment(identifier: "123456")
      ]

      syncer.execute(ajustes).then (result) =>
        result.should.eql
          linked: [
            { identifier: "123456" }
            { identifier: "CamperaRompeNocheNegra" }
            { identifier: "CamperaRompeNocheBlanca" }
          ]
          unlinked: []
