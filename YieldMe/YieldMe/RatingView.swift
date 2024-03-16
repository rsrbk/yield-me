//
//  RatingView.swift
//  YieldMe
//
//  Created by Ruslan Serebriakov on 16/03/2024.
//

import SwiftUI

struct RatingView: View {
    var rating: Double // Expecting a value between 0 and 100
    
    private var needleRotation: Angle {
        // Map the rating to an angle (0° for 0, 180° for 100)
        Angle(degrees: (rating / 100.0) * 180.0 - 90.0)
    }
    
    var body: some View {
        ZStack {
            // Gauge background
            GaugeShape()
                .stroke(lineWidth: 20)
                .fill(LinearGradient(gradient: Gradient(colors: [.orange, .yellow, .green]), startPoint: .leading, endPoint: .trailing))
                .frame(width: 300, height: 150)
            
            // Needle (arrow)
            NeedleShape()
                .fill(Color.gray)
                .frame(width: 2, height: 100)
                .offset(y: -50) // Shift the needle up by half its height
                .rotationEffect(needleRotation) // Rotate around its top
                .overlay(
                    Circle() // The needle's pivot
                        .fill(Color.white)
                        .frame(width: 15, height: 15)
                        .overlay(
                            Text("₿") // Representing Bitcoin symbol
                                .foregroundColor(.gray)
                        )
                )
                .padding(.top, 50) // Space from the top of the gauge

            // Number inside a circle
            Circle()
                .fill(Color.white)
                .frame(width: 40, height: 40)
                .overlay(
                    Text("\(Int(rating))")
                        .foregroundColor(.green)
                        .font(.title2)
                )
                .offset(x: (300 / 2) * CGFloat(rating / 100.0), y: 75) // Position based on the rating
        }
    }
}

struct GaugeShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.addArc(center: CGPoint(x: rect.midX, y: rect.maxY),
                    radius: rect.width / 2,
                    startAngle: Angle(degrees: 180),
                    endAngle: Angle(degrees: 0),
                    clockwise: false)
        
        return path
    }
}

struct NeedleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Define the needle with a simple line for this example
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        
        return path
    }
}
