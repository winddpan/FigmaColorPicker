import SwiftUI

struct CheckerBoardBackground: View {
    @Environment(\.colorScheme) private var colorScheme
    var numberOfRows: Int

    var body: some View {
        Canvas { context, size in
            context.fill(
                Path(CGRect(origin: .zero, size: size)),
                with: .color(colorScheme == .dark ? Color(white: 0.19) : Color(white: 0.95))
            )

            let cellSize = size.height / Double(numberOfRows)
            let numberOfColumns = Int(round(size.width / cellSize))

            for row in 0 ..< numberOfRows {
                for column in 0 ..< numberOfColumns {
                    let cellRect = CGRect(
                        x: CGFloat(column) * cellSize,
                        y: CGFloat(row) * cellSize,
                        width: cellSize,
                        height: cellSize
                    )

                    if (row + column) % 2 == 0 {
                        context.fill(Path(cellRect), with: .color(
                            colorScheme == .dark ? Color(white: 0.26) : Color(white: 0.8)
                        ))
                    }
                }
            }
        }
    }
}

struct CheckerBoardBackground_Previews: PreviewProvider {
    static var previews: some View {
        CheckerBoardBackground(numberOfRows: 8)
            .frame(width: 200, height: 200)
    }
}
