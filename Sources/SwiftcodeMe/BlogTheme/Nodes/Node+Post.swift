//
//  Node+Post.swift
//  
//
//  Created by Povilas Staskus on 1/26/20.
//

import Foundation
import Plot
import Publish

extension Node where Context == HTML.BodyContext {
    static func post(for item: Item<Blog>, on site: Blog) -> Node {
        return .pageContent(
            .h2(
                .class("post-title"),
                .a(
                    .href(item.path),
                    .text(item.title)
                )
            ),
            .p(
                .class("post-meta"),
                .text(DateFormatter.blog.string(from: item.date))
            ),
            .tagList(for: item, on: site),
            .div(
                .class("markdown-body"),
                .div(
                    .contentBody(item.body)
                )
            ),
            .div(
                .style("display:flex;justify-content:left;"),
                .selfClosedElement(named: "applause-button", attributes: [
                    .attribute(named: "style", value: "width: 58px; height: 58px;margin: 30px 0 0 0;")
                ])
            )
        )
    }
}

