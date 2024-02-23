//
//  LoadingView.swift
//  newsswipe
//
//  Created by Ansh Mehta on 2/18/24.
//

import SwiftUI

struct LoadingView: View {
    @State private var isAnimating = false
    var body: some View {
        VStack(spacing: 20) {
                  Image(systemName: "arrow.2.circlepath.circle.fill") // Replace with your logo
                      .resizable()
                      .aspectRatio(contentMode: .fit)
                      .frame(width: 50, height: 50)
                      .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                      .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
                      .onAppear() {
                          isAnimating = true
                      }
                  
                  Text("Loading Latest News!")
                      .font(.title)
                      .bold()
                      .foregroundColor(.blue)
                     
              }
              .frame(maxWidth: .infinity, maxHeight: .infinity)
              .background(Color.white.edgesIgnoringSafeArea(.all))
          }
    }


#Preview {
    LoadingView()
}
