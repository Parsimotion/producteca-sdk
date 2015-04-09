(function() {
  var Producto, _,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  _ = require("lodash");

  module.exports = Producto = (function() {
    function Producto(properties) {
      this._find = __bind(this._find, this);
      this.getVariantePorColorYTalle = __bind(this.getVariantePorColorYTalle, this);
      this.getVarianteParaAjuste = __bind(this.getVarianteParaAjuste, this);
      this.hasVariantes = __bind(this.hasVariantes, this);
      _.extend(this, properties);
    }

    Producto.prototype.hasVariantes = function() {
      return _.size(this.variations > 1);
    };

    Producto.prototype.getVarianteParaAjuste = function(ajuste, settings) {
      var talle;
      if (ajuste.color == null) {
        return _.head(this.variations);
      }
      talle = isNaN(ajuste.talle) ? this._find(settings.sizes, ajuste.talle) : ajuste.talle;
      return this.getVariantePorColorYTalle(this._find(settings.colors, ajuste.color), talle);
    };

    Producto.prototype.getVariantePorColorYTalle = function(color, talle) {
      return _.find(this.variations, function(it) {
        return it.primaryColor === color && it.size === talle;
      });
    };

    Producto.prototype._find = function(valores, buscado) {
      var mapping;
      mapping = _.find(valores, {
        original: buscado
      });
      if (mapping == null) {
        throw new Error("No hay mapping para " + buscado + " en " + (JSON.stringify(valores)));
      } else {
        return mapping.parsimotion;
      }
    };

    return Producto;

  })();

}).call(this);

(function() {
  var Producto;

  Producto = require("./producto");

  describe("Un producto", function() {
    return describe("sabe obtener una variante a partir de un ajuste", function() {
      var settings;
      settings = null;
      beforeEach(function() {
        return settings = {
          colors: [
            {
              original: "Rojo pasion",
              parsimotion: "Rojo"
            }, {
              original: "Azul especial",
              parsimotion: "Azul"
            }
          ],
          sizes: [
            {
              original: "Mediano",
              parsimotion: "M"
            }, {
              original: "Largo",
              parsimotion: "L"
            }
          ]
        };
      });
      describe("cuando tiene color y talle", function() {
        it("con letras", function() {
          var ajuste, conVariantes;
          conVariantes = new Producto({
            variations: [
              {
                id: 28,
                primaryColor: "Rojo",
                size: "M"
              }, {
                id: 29,
                primaryColor: "Rojo",
                size: "L"
              }
            ]
          });
          ajuste = {
            stock: 32,
            color: "Rojo pasion",
            talle: "Largo"
          };
          return (conVariantes.getVarianteParaAjuste(ajuste, settings)).id.should.equal(29);
        });
        return it("numerico", function() {
          var ajuste, conVariantes;
          conVariantes = new Producto({
            variations: [
              {
                id: 28,
                primaryColor: "Rojo",
                size: "28"
              }, {
                id: 29,
                primaryColor: "Rojo",
                size: "29"
              }
            ]
          });
          ajuste = {
            stock: 32,
            color: "Rojo pasion",
            talle: "29"
          };
          return (conVariantes.getVarianteParaAjuste(ajuste, settings)).id.should.equal(29);
        });
      });
      return it("cuando no tiene color ni talle", function() {
        var ajuste, sinVariantes;
        sinVariantes = new Producto({
          variations: [
            {
              id: 28
            }
          ]
        });
        ajuste = {
          stock: 32
        };
        return (sinVariantes.getVarianteParaAjuste(ajuste, settings)).id.should.equal(28);
      });
    });
  });

}).call(this);
