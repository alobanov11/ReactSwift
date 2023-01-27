//
//  Created by Антон Лобанов on 21.04.2022.
//

import Foundation

public enum StoreLogger {
	public static var isEnabled = true

	public static var handler: ([Any?], String) -> Void = { values, _ in
		#if DEBUG
		print(String(repeating: "_", count: 85))
		for value in values {
			if let value = value {
				print(value)
			}
		}
		print(String(repeating: "_", count: 85))
		#endif
	}

	static func log(
		_ values: [Any?],
		_ module: String
	) {
		guard self.isEnabled else { return }
		self.handler(values, module)
	}
}
