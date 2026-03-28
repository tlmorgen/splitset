import SwiftUI

struct CountdownView: View {
    let count: Int

    var body: some View {
        VStack(spacing: 8) {
            if count > 0 {
                Text("\(count)")
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                    .foregroundStyle(.blue)
                    .contentTransition(.numericText(countsDown: true))
                    .animation(.default, value: count)
            } else {
                Text("Go!")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(.green)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
