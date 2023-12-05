//
//  HomeView.swift
//  EnvisionTech
//
//  Created by Justin Hudacsko on 12/4/23.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack {
            HStack(spacing: 20){
                Image("logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                
                Text("EnvisionTech Courses")
                    .font(.largeTitle)
                    .bold()
            }
            
            Grid {
                ForEach(1..<4) { row in
                    GridRow {
                        ForEach(1..<3) { _ in
                            RoundedRectangle(cornerRadius: 25.0)
                                .aspectRatio(contentMode: .fit)
                                .foregroundStyle(.red)
                        }
                    }
                    .padding()
                    .border(.white)
                }
            }
            .padding()
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    HomeView()
}
