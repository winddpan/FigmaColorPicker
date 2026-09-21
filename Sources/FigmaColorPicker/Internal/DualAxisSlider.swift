import SwiftUI

struct DualAxisSlider<Background, Cursor>: View where Background: View,
    Cursor: View
{
    @Binding var horizontal: Double
    @Binding var vertical: Double
    @ViewBuilder var background: Background
    @ViewBuilder var cursor: Cursor

    var body: some View {
        GeometryReader { geometry in
            background
                // The rounded corners belong to the color surface only.
                // Clipping has to happen here instead of on the parent,
                // otherwise the cursor gets cut in half at the edges.
                .clipShape(RoundedRectangle(cornerRadius: 6))
                // Without `.drawingGroup()`, if I use the color sampler to pick
                // a color on the gradient background, the cursor won't land
                // exactly where the mouse is.
                // Not sure why but the colors aren't accurate unless
                // we composite the layers of the gradient background
                // into a single bitmap
                .drawingGroup()
                .overlay(alignment: .bottomLeading) {
                    cursor
                        .frame(width: 20, height: 20)
                        .offset(x: -10, y: 10)
                        .offset(
                            x: horizontal * geometry.size.width,
                            y: -vertical * geometry.size.height
                        )
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            horizontal = (
                                value.location.x / geometry.size
                                    .width
                            )
                            .clamped(to: 0 ... 1)
                            vertical = 1 -
                                (value.location.y / geometry.size.height)
                                .clamped(to: 0 ... 1)
                        }
                )
        }
    }
}

struct DualAxisSlider_Previews: PreviewProvider {
    static var previews: some View {
        DualAxisSlider(
            horizontal: .constant(1),
            vertical: .constant(1)
        ) {} cursor: {}
    }
}
