//
//  ContentView.swift
//  TemperatureConverter
//
//  Created by 李熙欣 on 2024/11/12.
//

import SwiftUI

struct ContentView: View {
    @State private var inputTemperature: Double = 0.0
    @State private var selectedScale: TemperatureScale = .celsius
    @State private var isEditing: Bool = false

    var body: some View {
        ZStack {
            gradientBackground
                .ignoresSafeArea()

            VStack(spacing: 20) {
                HStack {
                    Text("Temperature Converter")
                        .font(.largeTitle)
                        .multilineTextAlignment(.trailing)
                        .fontWeight(.bold)
                        .padding(.top)
                    Image(systemName: "thermometer.sun")
                        .font(.system(size: 50))
                        .offset(y: 10)
                }
                .shadow(radius: 10)

                // Picker to change scale by tapping
                Picker("Select Scale", selection: $selectedScale) {
                    ForEach(TemperatureScale.allCases, id: \ .self) { scale in
                        Text(scale.rawValue)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                // TabView to change scale by swiping
                TabView(selection: $selectedScale) {
                    ForEach(TemperatureScale.allCases, id: \ .self) { scale in
                        TemperatureScaleView(
                            inputTemperature: $inputTemperature,
                            selectedScale: scale,
                            isEditing: $isEditing
                        )
                        .tag(scale)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))

                Spacer()
            }
            .padding()
            .onTapGesture {
                hideKeyboard()
            }
        }
    }

    private var gradientBackground: LinearGradient {
        // Normalize temperature to range from 0 to 1
        let celsius = convertToCelsius(from: inputTemperature, scale: selectedScale)
        let normalizedTemp = normalizeTemperature(celsius: celsius)

        // Define the gradient colors
        let blue = Color.blue
        let white = Color.white
        let yellow = Color.yellow
        let red = Color.red

        // Interpolate colors based on normalized temperature
        let startColor = interpolateColor(from: blue, to: white, ratio: normalizedTemp)
        let midColor = interpolateColor(from: white, to: yellow, ratio: normalizedTemp)
        let endColor = interpolateColor(from: yellow, to: red, ratio: normalizedTemp)

        return LinearGradient(
            gradient: Gradient(colors: [startColor, midColor, endColor]),
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private func interpolateColor(from startColor: Color, to endColor: Color, ratio: CGFloat) -> Color {
        let startComponents = startColor.components
        let endComponents = endColor.components

        //(red, green, blue) based on the ratio
        let red = startComponents.red + (endComponents.red - startComponents.red) * ratio
        let green = startComponents.green + (endComponents.green - startComponents.green) * ratio
        let blue = startComponents.blue + (endComponents.blue - startComponents.blue) * ratio

        return Color(red: red, green: green, blue: blue)
    }

    //for a smooth gradient effect
    private func normalizeTemperature(celsius: Double) -> CGFloat {
        let minTemp: CGFloat = -30
        let maxTemp: CGFloat = 50
        return CGFloat((celsius - minTemp) / (maxTemp - minTemp)).clamped(to: 0...1)
    }

    private func convertToCelsius(from value: Double, scale: TemperatureScale) -> Double {
        switch scale {
        case .celsius:
            return value
        case .fahrenheit:
            return (value - 32) * 5 / 9
        case .kelvin:
            return value - 273.15
        case .rankine:
            return (value - 491.67) * 5 / 9
        }
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        min(max(self, limits.lowerBound), limits.upperBound)
    }
}

// Helper extension to get color components
extension Color {
    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, opacity: CGFloat) {
        #if os(iOS)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var opacity: CGFloat = 0
        UIColor(self).getRed(&red, green: &green, blue: &blue, alpha: &opacity)
        return (red, green, blue, opacity)
        #else
        return (0, 0, 0, 1) // placeholder for macOS
        #endif
    }
}

struct TemperatureScaleView: View {
    @Binding var inputTemperature: Double
    let selectedScale: TemperatureScale
    @Binding var isEditing: Bool

    private var celsius: Double {
        convertToCelsius(from: inputTemperature, scale: selectedScale)
    }

    private var fahrenheit: Double {
        celsius * 9 / 5 + 32
    }

    private var kelvin: Double {
        celsius + 273.15
    }

    private var rankine: Double {
        (celsius + 273.15) * 9 / 5
    }

    var body: some View {
        GeometryReader { geometry in
            VStack {
                //input & slider
                VStack {
                    HStack {
                        Text("\(selectedScale.rawValue):")
                            .font(.system(size: 25))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.5), radius: 4)
                            .padding()

                        TextField("Enter value", value: $inputTemperature, format: .number)
                            .background(Color.clear)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)
                            .frame(width: 100)
                            .font(.system(size:25))
                            .onTapGesture {
                                isEditing = true
                            }

                    }
                    .padding()

                    Slider(value: $inputTemperature, in: selectedScale.sliderRange(), step: 0.1)
                        .padding()
                }

                VStack(spacing: 20) {
                    if selectedScale != .celsius {
                        TemperatureView(label: "Celsius", value: celsius, unit: "°C")
                    }
                    if selectedScale != .fahrenheit {
                        TemperatureView(label: "Fahrenheit", value: fahrenheit, unit: "°F")
                    }
                    if selectedScale != .kelvin {
                        TemperatureView(label: "Kelvin", value: kelvin, unit: "K")
                    }
                    if selectedScale != .rankine {
                        TemperatureView(label: "Rankine", value: rankine, unit: "°R")
                    }
                }
            }
        }
        .padding()
    }

    private func convertToCelsius(from value: Double, scale: TemperatureScale) -> Double {
        switch scale {
        case .celsius:
            return value
        case .fahrenheit:
            return (value - 32) * 5 / 9
        case .kelvin:
            return value - 273.15
        case .rankine:
            return (value - 491.67) * 5 / 9
        }
    }
}

enum TemperatureScale: String, CaseIterable {
    case celsius = "Celsius"
    case fahrenheit = "Fahrenheit"
    case kelvin = "Kelvin"
    case rankine = "Rankine"

    func sliderRange() -> ClosedRange<Double> {
        switch self {
        case .celsius:
            return -100...100
        case .fahrenheit:
            return -148...212
        case .kelvin:
            return 173.15...373.15
        case .rankine:
            return 0...671.67
        }
    }
}

struct TemperatureView: View {
    let label: String
    let value: Double
    let unit: String

    var body: some View {
        HStack {
            Text("\(label):")
                .font(.headline)
            Spacer()
            Text("\(String(format: "%.2f", value)) \(unit)")
                .font(.title3)
        }
        .padding()
        .background(Color.black.opacity(0.1))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
