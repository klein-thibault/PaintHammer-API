//
//  PaintHTMLParser.swift
//  
//
//  Created by Thibault Klein on 3/4/21.
//

import Foundation
import SwiftSoup

struct PaintHTMLParser {
    func parseHTML(_ html: String) -> [Paint] {
        var paints: [Paint] = []

        do {
            let doc: Document = try SwiftSoup.parse(html)
            let brandDiv = try doc.select("article").filter { $0.hasClass("pr") }.first!
            let brandH1 = try brandDiv.select("h1")
            let brand = try brandH1.text()

            let allPaints = try doc.select("article").filter { $0.hasClass("ac") }

            for paint in allPaints {
                let colorLink: Element = try paint.select("a").first()!
                let colorDiv: Element = try colorLink.select("div").first()!
                let paintColor: String = try colorDiv.attr("style").replacingOccurrences(of: "background:", with: "").uppercased()
                // Skip if the paint color is not a valid hex format
                if !paintColor.isHexColor || paintColor.count < 5 {
                    continue
                }

                let paintDiv: Element = try paint.select("div").filter { $0.hasClass("ar") }.first!
                let paintLink: Element = try paintDiv.select("a").first()!
                var paintName: String = try paintLink.text()
                paintName.removingRegexMatches(pattern: "[0-9A-Z]+-[0-9]{2} ")
                paintName.removingRegexMatches(pattern: "[A-Z]{2}-[0-9]{2} ")
                paintName.removingRegexMatches(pattern: " \\([a-zA-Z]+\\)")

                let paint = Paint(name: paintName, brand: brand, color: paintColor)
                paints.append(paint)
            }

            return paints
        } catch Exception.Error(_, let message) {
            print(message)
            return []
        } catch {
            print("error")
            return []
        }
    }
}
