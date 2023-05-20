import StoreSwift
import SwiftUI

struct ___VARIABLE_featureName___View: View {
    @StateObject var store: Store<___VARIABLE_featureName___Feature>

    var body: some View {
        ZStack {
            Text("Loading \(store.isLoading.description)")
        }
        .onAppear(perform: store.action(.viewAppear))
    }
}

struct ___VARIABLE_featureName___Preview: PreviewProvider {
    typealias Feature = ___VARIABLE_featureName___Feature

    static var state: Feature.State {
        Feature.State()
    }

    static var store: Store<Feature> {
        Store<Feature>(
            initialState: state,
            context: .preview,
            middleware: Feature.middleware,
            reducer: Feature.reducer
        )
    }

    static var previews: some View {
        ___VARIABLE_featureName___View(store: store)
    }
}
