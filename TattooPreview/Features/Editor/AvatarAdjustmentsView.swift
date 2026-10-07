import SwiftUI

struct AvatarAdjustmentsView: View {
    @Binding var avatar: AvatarConfiguration

    var body: some View {
        Form {
            Section("Corpo") {
                Slider(value: $avatar.weight, in: AvatarConfiguration.weightRange) {
                    Text("Corpo")
                } minimumValueLabel: {
                    Text("Magro")
                } maximumValueLabel: {
                    Text("Corpulento")
                }
            }

            Section("Tom de pele") {
                HStack {
                    ForEach(SkinTone.allCases, id: \.self) { tone in
                        toneButton(tone)
                    }
                }
            }
        }
    }

    private func toneButton(_ tone: SkinTone) -> some View {
        let isSelected = avatar.skinTone == tone
        return Button {
            avatar.skinTone = tone
        } label: {
            Circle()
                .fill(Color(uiColor: tone.color))
                .overlay {
                    Circle().strokeBorder(isSelected ? Color.accentColor : .secondary.opacity(0.3),
                                          lineWidth: isSelected ? 3 : 1)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 40)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Tom \(tone.romanNumeral)")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    @Previewable @State var avatar = AvatarConfiguration()
    AvatarAdjustmentsView(avatar: $avatar)
}
