import Foundation

public var LogHandler: ((String) -> Void)? = { value in
    #if DEBUG
    print(String(repeating: "_", count: 85))
    print(value)
    print(String(repeating: "_", count: 85))
    #endif
}
