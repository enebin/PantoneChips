//
//  SwiftUIView.swift
//  PantoneChips
//
//  Created by 이영빈 on 2021/10/06.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            PantoneStyleColorChips(red: 50, green: 30, blue: 87)
                .zIndex(1)
            PantoneStyleColorChips(red: 226, green: 77, blue: 108)
                .zIndex(0.5)
                .offset(y: -35)
            PantoneStyleColorChips(red: 90, green: 105, blue: 56)
                .zIndex(0)
                .offset(y: -35*2)
        }
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


struct Colorchip: View {
    let name: String
    let color: Color
    let scale: CGFloat
    
    var body: some View {
        let width: CGFloat = 57*scale
        let height: CGFloat = 90*scale
        
        VStack(alignment: .leading) {
            Spacer()
            HStack {
                VStack(alignment: .leading) {
                    HStack(alignment: .top, spacing: 0) {
                        Text("PANTONE")
                            .font(Font.custom("HelveticaNeue-Bold", size: 7.5*scale))
                        Text("®")
                            .font(Font.custom("HelveticaNeue-Bold", size: 3*scale))
                    }
                    Text(name)
                        .font(Font.custom("HelveticaNeue-Bold", size: 6.5*scale))
                }
                Spacer()
            }
            .padding(.horizontal, 5)
            .frame(width: width - 3 * scale, height: height / 3.5)
            .background(RoundedRectangle(cornerRadius: 5)
                            .fill(Color.white))
            
        }
        .padding(3)
        .frame(width: width, height: height)
        .background(RoundedRectangle(cornerRadius: 5).fill(color))
    }
    
    init(name: String, color: Color, scale: CGFloat) {
        self.name = name
        self.color = color
        self.scale = scale
    }
}

struct PantoneStyleColorChips: View {
    var chipShapes: [Colorchip]
    let zIndexPreset: [Double]
    
    init(red: Int, green: Int, blue: Int) {
        chipShapes = [Colorchip]()
        
        for i in (0..<32) {
            self.chipShapes.append(
                Colorchip(name: String(format: "%d.%d.%d", red + i, green + i*2, blue + i),
                          color: Color(red: Double(red + i) / 255.0, green: Double(green + i*2)/255.0, blue: Double(blue + i)/255.0),
                          scale: 2)
            )
        }
        
        self.zIndexPreset = (1...self.chipShapes.count).map({ value in Double(value) / Double(360) }).reversed()
    }
    
    @State var delta: Double = 0 // Change in angle
    @State var currentAngle: Double = 0
    @State var currentCard: Int = 0 // Currently selected card
    @State var isDragging = false
    
    var body: some View {
        let dragGesture = DragGesture()
            .onChanged{ val in
                isDragging = true
                delta = val.translation.width
                
                // Calculate the cards corresponding to the current location
                // CurrentCard = -round(Current angle(360 ~ -360) / Unit angle).
                let tempCurrentCard = -Int(round(Double(currentAngle + delta) / Double(360 / chipShapes.count))) % chipShapes.count
                
                // If CurrentCard is negative, make it positive.
                withAnimation(.easeInOut(duration: 0.1)) {
                    if tempCurrentCard < 0 {
                        currentCard = tempCurrentCard + chipShapes.count
                    } else {
                        currentCard = tempCurrentCard
                    }
                }
            }
            .onEnded { val in
                isDragging = false
                currentAngle += delta
                currentAngle = Double((Int(currentAngle) % 360)) // Make currentAngle between -360` ~ 360`
            }
        
        
        ZStack {
            // You can add offset if the cards pop out too early
            let angleOffset: Double = -30

            ForEach(0 ..< chipShapes.count) { index in
                // Caculate absolute index relative to 0 degree
                let relativeIndex =
                index - currentCard < 0 ? (index - currentCard + chipShapes.count) : (index - currentCard)
                
                // relativeIndex still can't solve problem.
                // Because the frontmost card has an relativeIndex greater than 0, it is eventually covered by card at 0.
                // correctdRelativeIndex is created to solve the problem
                let correctdRelativeIndex = relativeIndex + chipShapes.count/2 >= chipShapes.count ? relativeIndex + chipShapes.count/2 - chipShapes.count : relativeIndex + chipShapes.count/2
                
                ZStack(alignment: .top) {
                    chipShapes[index]
                        .offset(y: currentCard == index ? 100 : 0) // To pop out
                    
                    ZStack(alignment: .bottomTrailing) {
                        VStack(spacing: 0) {
                            Rectangle()
                                .fill(Color.white)
                                .frame(width: 57*2.5, height: 90*1.5)
                        }
                        Text(String(index+1))
                            .font(Font.custom("HelveticaNeue-Bold", size: 15))
                            .rotationEffect(.degrees(90))
                            .padding(10)
                    }
                    .zIndex(1)
                }
                .rotationEffect(.degrees(-90))
                .rotation3DEffect(
                    .degrees(  // 
                        angleOffset + (Double(360 / chipShapes.count) * Double(index) +
                                       (isDragging ? currentAngle + delta : currentAngle))),
                    axis: (x: 0, y: 1, z: 0),
                    anchor: UnitPoint(x: -2, y: -1.5),
                    perspective: 0.1)
                .zIndex(zIndexPreset[correctdRelativeIndex])
            }
            .shadow(radius: 5, x: 5, y: 0)
            .offset(x: -100) // To prevent the cards from being cut when it pops out
            .gesture(dragGesture)
        }
    }
}
