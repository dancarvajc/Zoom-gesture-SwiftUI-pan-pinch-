//
//  ImageView.swift
//  ZoomSwiftUI
//
//  Created by Daniel Carvajal on 18-05-22.
//

import SwiftUI
import NukeUI

struct ImageView: View {
    @State private var scale: CGFloat = 1
    @State private var offset: CGPoint = .zero
    @State private var scaleAnchor: UnitPoint = .center
    @State private var tab: Tab = .uikit
    
    var body: some View {
        
        TabView(selection: $tab) {
            
            //MARK: UIKit TAB
            ZStack{
                Text("UIKit")
                    .font(.title)
                    .bold()
                    .foregroundColor(Color.white)
                    .zIndex(1)
                    .padding(5)
                    .background(RoundedRectangle(cornerRadius: 5)
                        .fill(Color.blue))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                
                //Custom View, this give us the position, scale and anchor.
                ZoomContainerUIKit(scale: $scale, offset: $offset, scaleAnchor: $scaleAnchor){
                    //NukeUI image
                    LazyImage(source: "https://exlibris.azureedge.net/covers/4033/7056/8766/1/4033705687661xxl.jpg", resizingMode: .aspectFit)
                }
                .scaleEffect(scale, anchor: scaleAnchor)
                .offset(x: offset.x, y:offset.y)
                .ignoresSafeArea()
                
            }.tabItem{
                Image(systemName: tab == .uikit ? "star.fill" : "star")
                Text("UIKit")
            }
            .tag(Tab.uikit)
            
            //MARK: SwiftUI TAB
            ZStack{
                Text("SwiftUI")
                    .font(.title)
                    .bold()
                    .foregroundColor(Color.white)
                    .zIndex(1)
                    .padding(5)
                    .background(RoundedRectangle(cornerRadius: 5)
                        .fill(Color.blue))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                
                //NukeUI image
                LazyImage(source: "https://exlibris.azureedge.net/covers/4033/7056/8766/1/4033705687661xxl.jpg", resizingMode: .aspectFit)
                    .zoomable() //Custom SwiftUI modifier
                
            }.tabItem{
                Image(systemName: tab == .swiftui ? "book.fill" : "book")
                Text("SwiftUI")
            }
            .tag(Tab.swiftui)
        }
    }
}


enum Tab{
    case uikit, swiftui
}

struct ImageView_Previews: PreviewProvider {
    static var previews: some View {
        ImageView()
    }
}
