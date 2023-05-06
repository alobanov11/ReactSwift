//
//  Created by Антон Лобанов on 06.05.2023.
//

import Foundation

public var LogHandler: ((Any, String) -> Void)? = { value, feature in
    #if DEBUG
    print(String(repeating: "_", count: 85))
    print(feature, value)
    print(String(repeating: "_", count: 85))
    #endif
}
