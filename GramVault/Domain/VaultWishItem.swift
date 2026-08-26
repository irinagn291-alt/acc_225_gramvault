// Role: VIPER entity. A barcode-unique intended purchase.

import Foundation

struct VaultWishItem: Sendable, Hashable, Identifiable {
    var product: VaultProduct
    var added: Date

    var id: String { product.barcode }
}
