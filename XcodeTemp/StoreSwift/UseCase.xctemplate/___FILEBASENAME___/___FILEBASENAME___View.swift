import StoreSwift
import SwiftUI

struct ___VARIABLE_useCaseName___View: View {
    @StateObject var store: Store<___VARIABLE_useCaseName___UseCase>

    var body: some View {
        ZStack {
            Text("Loading \(store.isLoading.description)")
        }
        .onAppear(perform: store.action(.viewAppear))
    }
}

struct ___VARIABLE_useCaseName___Preview: PreviewProvider {
    static var state: ___VARIABLE_useCaseName___UseCase.State {
        UseCase.State()
    }

    static var previews: some View {
        ___VARIABLE_useCaseName___View(store: Store(
            useCase: .preview,
            state: state
        ))
    }
}
