import SwiftUI

/// Role: Closed rail silhouette for tonight's well. The only custom Path in the app.
struct RailWellShape: Shape {
    var seated: Int

    var animatableData: CGFloat {
        get { CGFloat(seated) }
        set { seated = Int(newValue.rounded()) }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let inset = WellMeasure.space(1)
        let railHeight = WellMeasure.space(1) + 2
        let railY = rect.maxY - WellMeasure.space(3)
        let rail = CGRect(
            x: rect.minX + inset,
            y: railY,
            width: rect.width - inset * 2,
            height: railHeight
        )
        path.addRoundedRect(in: rail, cornerSize: CGSize(width: WellMeasure.chip, height: WellMeasure.chip))

        let drawn = max(0, min(seated, 8))
        guard drawn > 0 else { return path }

        let usable = rail.width - WellMeasure.space(2)
        let gap = WellMeasure.space(1)
        let bottleWidth = min(WellMeasure.space(3), (usable - gap * CGFloat(drawn - 1)) / CGFloat(drawn))
        let bottleHeight = min(rect.height * 0.62, WellMeasure.space(14))
        var x = rail.minX + WellMeasure.space(1)
        for _ in 0 ..< drawn {
            let body = CGRect(
                x: x,
                y: railY - bottleHeight,
                width: bottleWidth,
                height: bottleHeight
            )
            path.addRoundedRect(
                in: body,
                cornerSize: CGSize(width: WellMeasure.chip, height: WellMeasure.chip)
            )
            let neckWidth = max(WellMeasure.space(1), bottleWidth * 0.35)
            let neck = CGRect(
                x: x + (bottleWidth - neckWidth) / 2,
                y: body.minY - WellMeasure.space(2),
                width: neckWidth,
                height: WellMeasure.space(2)
            )
            path.addRoundedRect(
                in: neck,
                cornerSize: CGSize(width: WellMeasure.chip, height: WellMeasure.chip)
            )
            x += bottleWidth + gap
        }
        return path
    }
}
