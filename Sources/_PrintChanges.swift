import Foundation

public var _printChanges: ((Any, String) -> Void)? = { value, feature in
    #if DEBUG
    print(String(repeating: "_", count: 85))
    print(feature, value)
    print(String(repeating: "_", count: 85))
    #endif
}
