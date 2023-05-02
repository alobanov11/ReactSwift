//
//  Created by ___FULLUSERNAME___ on ___DATE___
//

import StoreSwift
import SwiftUI

struct ___VARIABLE_featureName___View: View {

    @StateObject var store: Store<___VARIABLE_featureName___Feature>

    var body: some View {
        Text("Loading \(store.isLoading)")
    }
}
