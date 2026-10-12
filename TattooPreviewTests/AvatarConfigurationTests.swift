import Foundation
import Testing
@testable import TattooPreview

struct AvatarConfigurationTests {
    @Test func defaultsAreInsideRanges() {
        let configuration = AvatarConfiguration()

        #expect(AvatarConfiguration.weightRange.contains(configuration.weight))
    }

    @Test func roundTripsThroughJSON() throws {
        let configuration = AvatarConfiguration(weight: -0.4, skinTone: .typeV)

        let data = try JSONEncoder().encode(configuration)

        #expect(try JSONDecoder().decode(AvatarConfiguration.self, from: data) == configuration)
    }
}
