//
//  Node+Head.swift
//  
//
//  Created by Povilas Staskus on 1/26/20.
//

import Plot
import Publish

extension Node where Context == HTML.DocumentContext {
    static func head(for site: Blog, item: Item<Blog>? = nil) -> Node {
        return Node.head(
            self.seoTitle(for: site, item: item),
            self.metaDesc(for: site, item: item),
            self.metaImage(for: site, item: item),
            self.twitterCardType(for: site, item: item),
            .meta(
                .charset(.utf8),
                .name("viewport"),
                .content("width=device-width, initial-scale=1")
            ),
            .link(
                .rel(.stylesheet),
                .href("https://unpkg.com/purecss@1.0.1/build/pure-min.css"),
                .init(name: "integrity", value: "sha384-oAOxQR6DkCoMliIh8yFnu25d7Eq/PHS21PClpwjOTeU2jRSq11vu66rf90/cZr47"),
                .init(name: "crossorigin", value: "anonymous")
            ),
            .link(
                .rel(.stylesheet),
                .href("https://unpkg.com/purecss@1.0.1/build/grids-responsive-min.css")
            ),
            .link(
                .rel(.stylesheet),
                .href("https://unpkg.com/github-markdown-css@5.0.0/github-markdown-light.css")
            ),
            .link(
                .rel(.stylesheet),
                .href("https://unpkg.com/applause-button/dist/applause-button.css")
            ),
            .script(
                .src("https://unpkg.com/applause-button/dist/applause-button.js")
            ),
            .link(
                .rel(.stylesheet),
                .href("/Pure/styles-v2.css")
            ),
            .link(
                .rel(.stylesheet),
                .href("/all.css")
            )
        )
    }

    private static func metaDesc(for site: Blog, item: Item<Blog>? = nil) -> Node<HTML.HeadContext> {
        guard let item = item else {
            return .empty
        }
        return .description(item.metadata.excerpt)
    }

    private static func metaImage(for site: Blog, item: Item<Blog>? = nil) -> Node<HTML.HeadContext> {
        guard let item = item, let image = item.metadata.socialImageLink else {
            return .empty
        }
        return .socialImageLink(site.url.appendingPathComponent(image))
    }

    private static func twitterCardType(for site: Blog, item: Item<Blog>? = nil) -> Node<HTML.HeadContext> {
        guard let item = item, let cardType = item.metadata.twitterCardType else {
            return .empty
        }
        return .twitterCardType(cardType)
    }

    private static func seoTitle(for site: Blog, item: Item<Blog>? = nil) -> Node<HTML.HeadContext> {
        guard let item = item else {
            return .title(site.seoTitle)
        }
        return .title(item.title)
    }
}
