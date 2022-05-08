//
//  Created by Антон Лобанов on 03.05.2022.
//

import Foundation

public enum StoreError: Error {
	case error(Error)
	case text(String)
}

extension StoreError: LocalizedError {
	public var errorDescription: String? {
		switch self {
		case let .error(error): return error.localizedDescription
		case let .text(text): return text
		}
	}
}
