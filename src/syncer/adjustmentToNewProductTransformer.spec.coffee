Adjustment = require("./adjustment")
Transformer = require("./adjustmentToNewProductTransformer")

describe "AdjustmentToNewProductTransformer", ->

  it "should create a product with sku when the identifier is set as sku", ->
    adjustments = [
      new Adjustment
        identifier: "915004085101       "
        name: "COLGANTE CLEMENT 3 X E27 MÁX. 23W NEGRO TELA   "
        pictures: [url: "http://pictures.com"]
    ]

    transformer = new Transformer identifier: "sku", priceList: "Default", warehouse: "Default" 

    transformer.transform(adjustments).should.eql
      description: "COLGANTE CLEMENT 3 X E27 MÁX. 23W NEGRO TELA"
      sku: "915004085101"
      prices: [
        priceList: "Default"
        amount: 0
      ]
      variations: [
        pictures: [url: "http://pictures.com"]
        stocks: [
          warehouse: "Default"
          quantity: 0
        ]
        primaryColor: undefined
        secondaryColor: undefined
        size: undefined
      ]

  it "should create a product with barcode when the identifier is set as barcode", ->
    adjustments = [
      new Adjustment
        identifier: "915004085101       "
        name: "COLGANTE CLEMENT 3 X E27 MÁX. 23W NEGRO TELA   "
        pictures: [url: "http://pictures.com"]
    ]

    transformer = new Transformer identifier: "barcode", priceList: "Default", warehouse: "Default" 

    transformer.transform(adjustments).should.eql
      description: "COLGANTE CLEMENT 3 X E27 MÁX. 23W NEGRO TELA"
      sku: undefined
      prices: [
        priceList: "Default"
        amount: 0
      ]
      variations: [
        barcode: "915004085101"
        pictures: [url: "http://pictures.com"]
        stocks: [
          warehouse: "Default"
          quantity: 0
        ] 
        primaryColor: undefined
        secondaryColor: undefined
        size: undefined
      ]

  it "should create a product with prices", ->
    adjustments = [
      new Adjustment
        identifier: "915004085101       "
        name: "COLGANTE CLEMENT 3 X E27 MÁX. 23W NEGRO TELA   "
        pictures: [url: "http://pictures.com"]
        prices: [
          priceList: "Mayorista"
          value: 50
        ,
          priceList: "Minorista"
          value: 70
        ]
    ]

    transformer = new Transformer identifier: "sku", warehouse: "Default" 

    transformer.transform(adjustments).should.eql
      description: "COLGANTE CLEMENT 3 X E27 MÁX. 23W NEGRO TELA"
      sku: "915004085101"
      prices: [
        priceList: "Mayorista"
        amount: 50
      ,
        priceList: "Minorista"
        amount: 70
      ]
      variations: [
        pictures: [url: "http://pictures.com"]
        stocks: [
          warehouse: "Default"
          quantity: 0
        ]
        primaryColor: undefined
        secondaryColor: undefined
        size: undefined
      ]


  it "can create a product definition with variations", ->
    adjustments = [
      new Adjustment
        code: "12345"
        identifier: "915004085101       "
        name: "COLGANTE CLEMENT 3 X E27 MÁX. 23W NEGRO TELA   "
        pictures: [url: "http://picture1.com"]
        prices: [
          priceList: "Mayorista"
          value: 50
        ,
          priceList: "Minorista"
          value: 70
        ]
        stocks: [
          warehouse: "Default"
          quantity: 3
        ] 
    ,
      new Adjustment
        code: "12345"
        identifier: "915004085102       "
        name: "COLGANTE CLEMENT 3 X E27 MÁX. 23W NEGRO TELA   "
        pictures: [url: "http://picture2.com"]
        prices: [
          priceList: "Mayorista"
          value: 50
        ,
          priceList: "Minorista"
          value: 70
        ]
        stocks: [
          warehouse: "Default"
          quantity: 4
        ] 
    ]

    transformer = new Transformer identifier: "barcode", warehouse: "Default" 

    product = transformer.transform(adjustments)
    console.log product
    product.should.eql
      description: "COLGANTE CLEMENT 3 X E27 MÁX. 23W NEGRO TELA"
      sku: "12345"
      prices: [
        priceList: "Mayorista"
        amount: 50
      ,
        priceList: "Minorista"
        amount: 70
      ]
      variations: [
        pictures: [url: "http://picture1.com"]
        stocks: [
          warehouse: "Default"
          quantity: 3
        ] 
        barcode: "915004085101"
        primaryColor: undefined
        secondaryColor: undefined
        size: undefined
      ,
        pictures: [url: "http://picture2.com"]
        stocks: [
          warehouse: "Default"
          quantity: 4
        ] 
        barcode: "915004085102"
        primaryColor: undefined
        secondaryColor: undefined
        size: undefined
      ]
