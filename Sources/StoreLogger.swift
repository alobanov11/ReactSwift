//
//  Created by Антон Лобанов on 21.04.2022.
//

import Foundation

public enum StoreLogger {
	public static var isEnabled = true

	public static var handler: ([Any?], StaticString, StaticString, UInt) -> Void = { values, _, _, _ in
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
		_ file: StaticString = #file,
		_ function: StaticString = #function,
		_ line: UInt = #line
	) {
		guard self.isEnabled else { return }
		self.handler(values, file, function, line)
	}
}
