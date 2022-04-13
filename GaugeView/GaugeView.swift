//
//  GaugeView.swift
//  AtKaro
//
//  Created by Farshad Macbook M1 Pro on 4/12/22.
//

import SwiftUI

struct GaugeView: View {
    // min 50, max 310
    let size = CGSize(width: 30, height: 130)
    @State var rotate: CGFloat = 50
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let lineWidth: CGFloat = 30
    var speeds: [Int] = [0, 5, 10, 25, 50, 100, 150, 200, 500]
    var body: some View {
        VStack {
            ZStack {
                GeometryReader { geometry in
                    CircleView(center: CGPoint(x: 100, y: 100), radius: 130)
                        .trim(from: (1 - (rotate - 50) / 260), to: 1)
                        .stroke(lineWidth: lineWidth + 20)
                        .fill(
                            AngularGradient(gradient: Gradient(colors: [.clear, Color(hex: "5BC1F8").opacity(0.3)]), center: .center, startAngle: .degrees(120), endAngle: .degrees(360))
                        )
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200, height: 200, alignment: .center)
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    
                    IndicatorShape(size: size)
                        .fill(
                            LinearGradient(gradient: Gradient(colors: [.clear,.white.opacity(0.1), .white.opacity(0.3), .white, .white]), startPoint: .top, endPoint: .bottom)
                        )
                        .frame(width: size.width, height: size.height)
                        .position(x: geometry.size.width / 2, y: (geometry.size.height / 2) + size.height / 4)
                        .rotationEffect(.degrees(rotate))
                        .animation(Animation.linear, value: rotate)
                    
                    CircleView(center: .init(x: geometry.size.width / 2, y: geometry.size.height / 2), radius: 150)
                        .stroke(lineWidth: lineWidth)
                        .fill(Color.white.opacity(0.1))
                        .aspectRatio(contentMode: .fit)
                    
                    CircleView(center: .init(x: geometry.size.width / 2, y: geometry.size.height / 2), radius: 150)
                        .trim(from: (1 - (rotate - 50) / 260), to: 1)
                        .stroke(lineWidth: lineWidth)
                        .fill(Color(hex: "5BC1F8"))
                        .aspectRatio(contentMode: .fit)
                    
                    ForEach(Array(zip(speeds, getCirclePoints(centerPoint: CGPoint(x: geometry.size.width / 2, y: (geometry.size.height / 2)), radius: 110, n: 9))), id: \.0) { index, item in
                        Text("\(index)")
                            .fontWeight(.bold)
                            .position(x: item.x, y: item.y)
                            .foregroundColor(.white)
                    }

                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onReceive(timer) { _ in
                withAnimation {
                    rotate = CGFloat((50...310).randomElement()!)
                    print("Rotate:", rotate, "Filled:", (rotate - 50) / 260)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex: "1A1B2D"))
    }
    
    func getCirclePoints(centerPoint point: CGPoint, radius: CGFloat, n: Int)->[CGPoint] {
        let result: [CGPoint] = stride(from:130.0, to: 420.0, by: Double(320 / n)).map {
            let bearing = CGFloat($0) * .pi / 180
            let x = point.x + radius * cos(bearing)
            let y = point.y + radius * sin(bearing)
            return CGPoint(x: x, y: y)
        }
        return result
    }
}

struct GaugeView_Previews: PreviewProvider {
    static var previews: some View {
        GaugeView()
    }
}

struct IndicatorShape: Shape {
    let size: CGSize
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: size.width, y: 0))
            path.addLine(to: CGPoint(x: (size.width / 2) + 5, y: size.height))
            path.addLine(to: CGPoint(x: (size.width / 2) - 5, y: size.height))
            path.addLine(to: CGPoint(x: 0, y: 0))
        }
    }
}

struct CircleView: Shape {
    let center: CGPoint
    let radius: CGFloat
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.addArc(center: center, radius: radius, startAngle: .degrees(45), endAngle: .degrees(135), clockwise: true)
        }
    }
}


extension CGPoint: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}

extension Color {
    init(hex string: String) {
        var string: String = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if string.hasPrefix("#") {
            _ = string.removeFirst()
        }

        // Double the last value if incomplete hex
        if !string.count.isMultiple(of: 2), let last = string.last {
            string.append(last)
        }

        // Fix invalid values
        if string.count > 8 {
            string = String(string.prefix(8))
        }

        // Scanner creation
        let scanner = Scanner(string: string)

        var color: UInt64 = 0
        scanner.scanHexInt64(&color)

        if string.count == 2 {
            let mask = 0xFF

            let g = Int(color) & mask

            let gray = Double(g) / 255.0

            self.init(.sRGB, red: gray, green: gray, blue: gray, opacity: 1)

        } else if string.count == 4 {
            let mask = 0x00FF

            let g = Int(color >> 8) & mask
            let a = Int(color) & mask

            let gray = Double(g) / 255.0
            let alpha = Double(a) / 255.0

            self.init(.sRGB, red: gray, green: gray, blue: gray, opacity: alpha)

        } else if string.count == 6 {
            let mask = 0x0000FF
            let r = Int(color >> 16) & mask
            let g = Int(color >> 8) & mask
            let b = Int(color) & mask

            let red = Double(r) / 255.0
            let green = Double(g) / 255.0
            let blue = Double(b) / 255.0

            self.init(.sRGB, red: red, green: green, blue: blue, opacity: 1)

        } else if string.count == 8 {
            let mask = 0x000000FF
            let r = Int(color >> 24) & mask
            let g = Int(color >> 16) & mask
            let b = Int(color >> 8) & mask
            let a = Int(color) & mask

            let red = Double(r) / 255.0
            let green = Double(g) / 255.0
            let blue = Double(b) / 255.0
            let alpha = Double(a) / 255.0

            self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)

        } else {
            self.init(.sRGB, red: 1, green: 1, blue: 1, opacity: 1)
        }
    }
    
}
