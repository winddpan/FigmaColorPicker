import SwiftUI

struct NumberInput: View {
    @FocusState private var isFocused: Bool

    private var label: String
    @Binding private var normalizedValue: Double
    private var range: ClosedRange<Int>
    @State private var value: Int

    init(
        _ label: String,
        normalizedValue: Binding<Double>,
        in range: ClosedRange<Int>
    ) {
        self.label = label
        self.range = range
        _normalizedValue = normalizedValue
        value = Self.getValue(
            normalizedValue: normalizedValue.wrappedValue,
            in: range
        )
    }

    var body: some View {
        TextField(label, value: $value, format: RangeIntegerStyle(range: range))
            .focused($isFocused)
            .frame(height: 32)
            .contentShape(Rectangle())
            .onTapGesture {
                isFocused = true
            }
            .onChange(of: normalizedValue) { _, newValue in
                value = Self.getValue(
                    normalizedValue: newValue,
                    in: range
                )
            }
            .onSubmit {
                syncNormalizedValue()
            }
            .onChange(of: isFocused) { _, newValue in
                let hasLostFocus = !newValue

                if hasLostFocus {
                    syncNormalizedValue()
                }
            }
    }

    private func syncNormalizedValue() {
        if value == Self.getValue(normalizedValue: normalizedValue, in: range) {
            return
        }

        normalizedValue = Double(value) /
            Double(range.upperBound - range.lowerBound)
    }

    private static func getValue(
        normalizedValue: Double,
        in range: ClosedRange<Int>
    ) -> Int {
        let value = normalizedValue *
            Double(range.upperBound - range.lowerBound)

        let roundedValue = Int(round(value))

        return roundedValue
    }
}

private struct RangeIntegerStyle: ParseableFormatStyle {
    var parseStrategy: RangeIntegerStrategy

    init(range: ClosedRange<Int>) {
        parseStrategy = RangeIntegerStrategy(range: range)
    }

    func format(_ value: Int) -> String {
        return "\(value)"
    }
}

private struct RangeIntegerStrategy: ParseStrategy {
    private var intParseStrategy =
        IntegerParseStrategy<IntegerFormatStyle<Int>>(format: .number)
    var range: ClosedRange<Int>

    init(range: ClosedRange<Int>) {
        self.range = range
    }

    func parse(_ value: String) throws -> Int {
        let intValue = try intParseStrategy.parse(value)

        return intValue.clamped(to: range)
    }
}

struct PercentageInput: View {
    @FocusState private var isFocused: Bool

    private var label: String
    @Binding private var value: Int

    init(
        _ label: String,
        value: Binding<Int>
    ) {
        self.label = label
        _value = value
    }

    var body: some View {
        HStack(spacing: -4) {
            TextField(
                label,
                value: $value,
                format: RangeIntegerStyle(range: 0 ... 100)
            )
            .focused($isFocused)

            Text("%")
                .foregroundStyle(.secondary)
                .padding(.trailing, 4)
        }
        .frame(width: 50, height: 32)
        .contentShape(Rectangle())
        .onTapGesture {
            isFocused = true
        }
    }
}

extension Binding where Value == Double {
    /// Projects a normalized `0 ... 1` value as a `0 ... 100` percentage.
    var percentage: Binding<Int> {
        Binding<Int> {
            Int((wrappedValue * 100).rounded())
        } set: { newValue in
            wrappedValue = Double(newValue) / 100
        }
    }
}
