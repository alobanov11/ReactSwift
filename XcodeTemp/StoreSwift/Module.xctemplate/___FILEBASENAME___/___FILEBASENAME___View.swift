import StoreSwift
import SwiftUI

struct ___VARIABLE_moduleName___View: View {
    @StateObject var store: Store<___VARIABLE_moduleName___UseCase>

    var body: some View {
        Text("Hello, World! \(store.isLoading.description)")
    }
}

#Preview {
    ___VARIABLE_moduleName___View(store: Store(
        ___VARIABLE_moduleName___UseCase.Props()
    ))
}
