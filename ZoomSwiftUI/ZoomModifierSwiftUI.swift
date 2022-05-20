//
//  GesturesManagerSwiftUI.swift
//  ZoomSwiftUI
//
//  Created by Daniel Carvajal on 19-05-22.
//

import SwiftUI

struct ZoomModifierSwiftUI: ViewModifier{
    
    @GestureState private var startLocation: CGPoint? = nil
    
    @State private var magnifyBy: CGFloat = 1.0
    @State private var finalMagnify:CGFloat = 1
    @State private var dobleTaped: Bool = false
    @State private var location: CGPoint = .zero
    
    @State private var startFingerPosition: CGPoint = .zero
    @State private var isZoomed: Bool = false
    
    private let minScale: CGFloat = 1.0
    private let maxScale: CGFloat = 5.0
    
    func body(content: Content) -> some View {
        ZStack{
            if isZoomed {
                
                Text("Toca dos veces para hacer zoom")
                    .font(.callout)
                    .bold()
                    .foregroundColor(Color.blue)
                    .padding(15)
                    .background(Color(.systemBackground))
                    .zIndex(1)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
                            withAnimation {
                                isZoomed = false
                            }
                        }
                    }
            }
            content
                .zIndex(0)
                .scaleEffect(magnifyBy, anchor: UnitPoint(x: startFingerPosition.x/(UIScreen.main.bounds.width), y: startFingerPosition.y/(UIScreen.main.bounds.height)))
                .offset(x: location.x, y: location.y)
                .simultaneousGesture(dragGesture)
                .simultaneousGesture(magnification)
                .simultaneousGesture(doubleTapGesture)
        }
        
        
    }
    
    
}

//MARK: Gestos usados en el modificador
extension ZoomModifierSwiftUI{
    private var doubleTapGesture: some Gesture {
        
        TapGesture(count: 2)
            .onEnded { _ in
                withAnimation(.default) {
                    if magnifyBy != 1 {
                        location = .zero
                        magnifyBy = 1
                        dobleTaped = false
                    }else{
                        dobleTaped = true
                        isZoomed = false
                        magnifyBy = 2
                    }
                }
            }
    }
    
    private var dragGesture: some Gesture {
        
        //Se cambia el valor de minimumDistance de acuerdo a si está en zoom o no la imagen. Se asigna 0 para detectar la posición del tap.
        DragGesture(minimumDistance: magnifyBy == 1 ? 0 : 10)
            .onChanged { value in
                
                if magnifyBy == 1 {
                    //Para saber la posición del tap
                    startFingerPosition = value.startLocation
                }else{
                    var newLocation = startLocation ?? location
                    
                    
                    //Se asegura que no exceda el ancho y alto de las imagenes.
                    //Eje X
                    guard (UIScreen.main.bounds.width*0.2...UIScreen.main.bounds.width-UIScreen.main.bounds.width*0.2).contains(value.location.x) else{return}
                    //Eje Y
                    guard (UIScreen.main.bounds.height*0.2...UIScreen.main.bounds.height-UIScreen.main.bounds.height*0.2).contains(value.location.y) else{return}
                    newLocation.x += value.translation.width*1.5
                    newLocation.y += value.translation.height*1.5
                    
                    withAnimation {
                        self.location = newLocation
                    }
                }
                
            }.updating($startLocation) { (value, startLocation, transaction) in
                startLocation = startLocation ?? location
                
            }
            .onEnded { value in
                guard magnifyBy == 1 else{return}
                startFingerPosition = value.startLocation
            }
    }
    
    private var magnification: some Gesture {
        MagnificationGesture()
        
            .onChanged({ value in
          
                guard magnifyBy != 1 else {
                    withAnimation {isZoomed = true}
                    return
                }
                
                var realValue = value/finalMagnify
                realValue *= magnifyBy
                if realValue > maxScale{
                    magnifyBy = maxScale
                }else if realValue < minScale{
                    magnifyBy = minScale
                }else{
                    withAnimation {
                        magnifyBy = realValue
                        finalMagnify = value
                    }
                }
            })
            .onEnded { value in
                finalMagnify = 1.0
            }
    }
}

//MARK: extension for usability
extension View{
  
    func zoomable() -> some View{
        modifier(ZoomModifierSwiftUI())
    }
}
