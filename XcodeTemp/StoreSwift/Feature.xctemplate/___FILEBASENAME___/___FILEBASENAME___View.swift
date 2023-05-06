//
//  Created by ___FULLUSERNAME___ on ___DATE___
//

import StoreSwift
import SwiftUI

struct ___VARIABLE_featureName___View: View {
    @StateObject var store: Store<___VARIABLE_featureName___Feature>

    var body: some View {
        Text("Loading \(store.isLoading.description)")
    }
}

struct ___VARIABLE_featureName___Preview: PreviewProvider {
    typealias Feature = ___VARIABLE_featureName___Feature

    static var state: Feature.State {
        .init()
    }

    static var store: Store<Feature> {
        Store<Feature>(
            initialState: state,
            enviroment: Feature.Enviroment(),
            middleware: Feature.middleware,
            reducer: Feature.reducer
        )
    }

    static var previews: some View {
        ___VARIABLE_featureName___View(store: store)
    }
}
