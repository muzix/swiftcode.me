import Foundation
import Publish
import Plot

// This type acts as the configuration for your website.
struct SwiftcodeMe: Website {
    enum SectionID: String, WebsiteSectionID {
        // Add the sections that you want your website to contain here:
        case posts
    }

    struct ItemMetadata: WebsiteItemMetadata {
        // Add any site-specific metadata that you want to use here.
    }

    // Update these properties to configure your website:
    var url = URL(string: "https://swiftcode.me")!
    var name = "swiftcode.me"
    var description = "I love writing swift code 📱"
    var language: Language { .english }
    var imagePath: Path? { nil }
}

// This will generate your website using the built-in Foundation theme:
try SwiftcodeMe().publish(withTheme: .marshall)
