import Foundation

extension String {
    /// Checks if a string is matching a hex color value like `#FFFFF`
    var isHexColor: Bool {
        let range = NSRange(location: 0, length: utf16.count)
        let regex = try! NSRegularExpression(pattern: "^#(([0-9a-fA-F]{2}){3}|([0-9a-fA-F]){3})$")
        return regex.firstMatch(in: self, options: [], range: range) != nil
    }

    mutating func removingRegexMatches(pattern: String, replaceWith: String = "") {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            let range = NSRange(location: 0, length: count)
            self = regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: replaceWith)
        } catch { return }
    }
}
