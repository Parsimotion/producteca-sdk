Producto = require("./producto")

describe "Un producto", ->
  describe "sabe obtener una variante a partir de un ajuste", ->
    settings = null

    beforeEach ->
      settings =
        colors: [
          original: "Rojo pasion"
          parsimotion: "Rojo"
        ,
          original: "Azul especial"
          parsimotion: "Azul"
        ]

        sizes: [
          original: "Mediano"
          parsimotion: "M"
        ,
          original: "Largo"
          parsimotion: "L"
        ]

    describe "cuando tiene color y talle", ->
      it "con letras", ->
        conVariantes = new Producto
          variations: [
            id: 28
            primaryColor: "Rojo"
            size: "M"
          ,
            id: 29
            primaryColor: "Rojo"
            size: "L"
          ]

        ajuste =
          stock: 32
          color: "Rojo pasion"
          talle: "Largo"

        (conVariantes.getVarianteParaAjuste ajuste, settings).id.should.equal 29

      it "numerico", ->
        conVariantes = new Producto
          variations: [
            id: 28
            primaryColor: "Rojo"
            size: "28"
          ,
            id: 29
            primaryColor: "Rojo"
            size: "29"
          ]

        ajuste =
          stock: 32
          color: "Rojo pasion"
          talle: "29"

        (conVariantes.getVarianteParaAjuste ajuste, settings).id.should.equal 29

    it "cuando no tiene color ni talle", ->
      sinVariantes = new Producto
        variations: [ id: 28 ]

      ajuste =
        stock: 32

      (sinVariantes.getVarianteParaAjuste ajuste, settings).id.should.equal 28
