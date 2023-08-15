import StoreSwift
import SwiftUI

struct ___VARIABLE_moduleName___View: View {
    @ObservedObject var store: Store<___VARIABLE_moduleName___UseCase>

    var body: some View {
        Text("Hello, World! \(store.isLoading.description)")
    }
}

struct ___VARIABLE_moduleName___Preview: PreviewProvider {
    static var previews: some View {
        ___VARIABLE_moduleName___View(store: Store(
            ___VARIABLE_moduleName___UseCase.State(),
            useCase: ___VARIABLE_moduleName___UseCase()
        ))
    }
}
