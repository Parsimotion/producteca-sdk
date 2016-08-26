# Producteca SDK

## Migration guide
### 2.x => 3.x
- Renamed `ProductsApi::updateVariationPictures` to `addVariationPictures`.
- Added `ProductsApi::updateVariationPictures` with the right behavior.

### 1.x => 2.x
- Renames in `Product`:
  - `description` => `name`
  - `sku` => `code`
  - `variations[...].barcode` => `variations[...].sku`

### 0.x => 1.x
- The APIs are now divided in different classes (ContactsApi, ProductsApi, SalesOrdersApi).
