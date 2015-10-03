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
  adjustments = null

  beforeEach ->
    client =
      updateStocks: sinon.stub().returns Q()
      updateProduct: sinon.stub().returns Q()
      createProduct: sinon.stub().returns Q()

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
      synchro: prices: true, stocks: true, data: true
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

    adjustments = [
      new Adjustment(
        identifier: "CamperaRompeNocheNegra",
        prices: [
          { priceList: "Precios Cuidados", value: "30" }
          { priceList: "Con Tarjeta de Crédito", value: "90" }
        ]
        stocks: [
          { warehouse: "Villa Lugano", quantity: 20 }
        ]
        description: "Saraza"
        notes: "Lalala"
      )
      new Adjustment(
        identifier: "CamperaRompeNocheBlanca",
        prices: [
          { priceList: "Default", value: "99" }
        ]
        stocks: [
          { warehouse: "Palermo", quantity: 38 }
        ]
      )
    ]
# ----------
  describe "los precios y los datos son independientes,", ->
    it "cuando actualizo solo los datos los precios no se modifican", ->
      syncer.settings.identifier = "barcode"
      syncer.settings.synchro = prices: false, data: true

      syncer.execute [
        new Adjustment
          identifier: "CamperaRompeNocheNegra",
          prices: []
          notes: "Lalala"
      ]
      client.updateProduct.getCall(0).args[0].toJSON().should.not.have.property 'prices'
      client.updateProduct.getCall(0).args[0].toJSON().should.have.property 'notes', 'Lalala'

    it "cuando actualizo solo los precios los datos no se modifican", ->
      syncer.settings.identifier = "barcode"
      syncer.settings.synchro = prices: true, data: false

      syncer.execute [
        new Adjustment
          identifier: "CamperaRompeNocheNegra",
          prices: [
            { priceList: "Default", value: "99" }
          ]
          notes: "Lalala"
      ]
      client.updateProduct.getCall(0).args[0].toJSON().prices.should.eql [{priceList: "Default", amount: 99}]
      client.updateProduct.getCall(0).args[0].toJSON().should.not.have.property 'notes'

  describe "en el caso más completo (variantes - multi listaDePrecios / depósito)...", ->
    beforeEach ->
      syncer.settings.identifier = "barcode"
      syncer.execute adjustments

    it "actualiza los precios y los datos", ->
      client.updateProduct.should.have.callCount 2
      json =
        id: 1
        sku: "123456"
        description: "Campera De Cuero Para Romper La Noche En Muchos Colores"
        prices: [
          { priceList: "Precios Cuidados", amount: 30 }
          { priceList: "Con Tarjeta de Crédito", amount: 90 }
          { priceList: "Default", amount: 99 }
        ]
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
        description: "Saraza"
        notes: "Lalala"

      client.updateProduct.getCall(0).args[0].toJSON().should.eql json

    it "actualiza los stocks", ->
      client.updateStocks.should.have.callCount 2
      client.updateStocks.should.have.been.calledWith
        id: 1
        warehouse: "Villa Lugano"
        stocks: [
          variation: 2
          quantity: 20
        ]
      client.updateStocks.should.have.been.calledWith
        id: 1
        warehouse: "Palermo"
        stocks: [
          variation: 4
          quantity: 38
        ]

  describe "si hay adjustments de productos nuevos", ->
    beforeEach ->
      syncer.settings.identifier = "barcode"

      adjustments.push new Adjustment
        identifier: "NuevoProducto",
        name: "Campera de lana para losers"
        prices: [
          { priceList: "Default", value: "555" }
        ]
        stocks: [
          { warehouse: "Palermo", quantity: 11 }
        ]

    it "no crea productos si createProduct es false", ->
      syncer.settings.createProducts = false
      syncer.execute adjustments
      client.createProduct.should.not.have.been.called

    it "crea productos si createProduct es true", ->
      syncer.settings.createProducts = true
      syncer.execute adjustments
      client.createProduct.should.have.been.calledWith
        description: "Campera de lana para losers"
        sku: undefined
        prices: [
          { priceList: "Default", amount: 555 }
        ]
        variations: [
          barcode: "NuevoProducto"
          pictures: undefined
          stocks: [
            { warehouse: "Palermo", quantity: 11 }
          ]
          primaryColor: undefined
          secondaryColor: undefined
          size: undefined
        ]

        
  describe "cuando los productos no tienen variantes...", ->
    ajuste = new Adjustment
      identifier: "123456"
      price: 25
      stock: 40

    it "se ignoran los productos cuyo sku es vacio", ->
      syncer.execute [
        identifier: ""
        stock: 40
      ]

      client.updateStocks.called.should.be.false

    it "_joinAdjustmentsAndProducts linkea ajustes con productos de Producteca", ->
      ajustes = syncer._joinAdjustmentsAndProducts [ajuste]
      clean = (o) => JSON.parse JSON.stringify o

      clean(ajustes.linked[0]).should.eql clean
        adjustment: identifier: "123456", price: 25, stock: 40
        products: [campera, camperaVariable]

    describe "al ejecutar dispara una request a Producteca matcheando el id segun sku", ->
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
        client.updateProduct.should.have.been.calledWith campera

    it "actualiza el producto si en las settings digo que quiero sincronizar precios", ->
      syncer.settings.synchro = prices: true
      syncer.execute [ajuste]
      client.updateProduct.called.should.be.true

    it "actualiza el producto si en las settings digo que quiero sincronizar datos", ->
      syncer.settings.synchro = data: true
      syncer.execute [ajuste]
      client.updateProduct.called.should.be.true

    it "si en las settings digo que no quiero sincronizar precios, no lo hace", ->
      syncer.settings.synchro = prices: false, stocks: true
      syncer.execute [ajuste]
      client.updateProduct.called.should.be.false
      client.updateStocks.called.should.be.true

    it "si en las settings digo que no quiero sincronizar datos, no lo hace", ->
      syncer.settings.synchro = data: false, stocks: true
      syncer.execute [ajuste]
      client.updateProduct.called.should.be.false
      client.updateStocks.called.should.be.true

    it "si en las settings digo que no quiero sincronizar stocks, no lo hace", ->
      syncer.settings.synchro = prices: true, stocks: false
      syncer.execute [ajuste]
      client.updateProduct.called.should.be.true
      client.updateStocks.called.should.be.false

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

  describe "resultado de la sincronización...", ->
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
