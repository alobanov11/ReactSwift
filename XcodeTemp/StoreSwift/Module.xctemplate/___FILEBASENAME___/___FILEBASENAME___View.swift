import StoreSwift
import SwiftUI

struct ___VARIABLE_moduleName___View: View {
    
    typealias Props = ___VARIABLE_moduleName___UseCase.Props

    @StateObject var store: Store<___VARIABLE_moduleName___UseCase>

    var body: some View {
        ZStack {
            Color(.white).ignoresSafeArea()

            Text("Hello, World! \(store.isLoading.description)")
        }
        .onAppear(perform: store.action(.viewAppeared))
    }
}

#Preview {
    ___VARIABLE_moduleName___View(store: Store(
        ___VARIABLE_moduleName___UseCase.Props()
    ))
}
