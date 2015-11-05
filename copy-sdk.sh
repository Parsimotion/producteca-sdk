echo "Copiando producteca-sdk a $1"

rm -rfv $1/node_modules/producteca-sdk/build
cd producteca-sdk
grunt clean:build
grunt coffee
grunt clean:specs
cd ..
cp -rvf producteca-sdk/build $1/node_modules/producteca-sdk