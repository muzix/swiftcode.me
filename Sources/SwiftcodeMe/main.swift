import Foundation
import Publish
import Plot
import SplashPublishPlugin

extension TwitterCardType: Decodable {}

// This type acts as the configuration for your website.
struct Blog: Website {
    enum SectionID: String, WebsiteSectionID {
        // Add the sections that you want your website to contain here:
        case posts
    }

    struct ItemMetadata: WebsiteItemMetadata {
        // Add any site-specific metadata that you want to use here.
        var excerpt: String
        var socialImageLink: String?
        var twitterCardType: TwitterCardType?
    }

    // Update these properties to configure your website:
    var url = URL(string: "https://swiftcode.me")!
    var title = "📱 ☕️ 🍜"
    var seoTitle = "swiftcode.me"
    var name = "Hoang Pham"
    var description = "iOS Developer"
    var language: Language { .english }
    var imagePath: Path? { nil }
    var socialMediaLinks: [SocialMediaLink] {
        [
            .location,
            .email,
            .linkedIn,
            .github,
            .twitter
        ]
    }
}

// This will generate your website using the built-in Foundation theme:
try Blog().publish(
    withTheme: .blog,
    plugins: [.splash(withClassPrefix: "")]
)
