import SwiftUI

struct AlphaSlider: View {
    @Binding var alpha: Double
    var color: Color

    var body: some View {
        Slider(value: $alpha) {
            CheckerBoardBackground(numberOfRows: 4)
                .overlay {
                    LinearGradient(
                        colors: [
                            color.opacity(0),
                            color,
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                }
                .drawingGroup()
        } thumb: {
            Circle()
                .fill(Color.white)
                .shadow(color: .black.opacity(0.3), radius: 2, y: 1)
                .overlay {
                    Circle()
                        .fill(color.opacity(alpha))
                }
                .overlay {
                    Circle()
                        .strokeBorder(Color.white, lineWidth: 4)
                }
        }
        .frame(height: 20)
    }
}

struct AlphaSlider_Previews: PreviewProvider {
    static var previews: some View {
        AlphaSlider(
            alpha: .constant(0.5),
            color: .red
        )
        .frame(width: 320, height: 32)
    }
}
