//
//  GestureManager.swift
//  ZoomSwiftUI
//
//  Created by Daniel Carvajal on 18-05-22.
//
import SwiftUI
import UIKit

//MARK: Wrapper to pinch and pan a SwiftUI View
struct ZoomContainerUIKit: UIViewRepresentable {
    
    @Binding var scale: CGFloat
    @Binding var offset: CGPoint
    @Binding var scaleAnchor: UnitPoint
    
    let view: UIView //SwiftUI View converted which receive the gestures
    
    
    init<Content:View>(scale:Binding<CGFloat>,offset:Binding<CGPoint>,scaleAnchor:Binding<UnitPoint>,@ViewBuilder content: () -> Content) {
        
        let vc = UIHostingController(rootView: content()) //Transform SwiftUI View to "UIKit View"
        
        let view = UIView(frame: .init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)) //UIView container for the View in UIHostingController
        
        vc.view.frame = view.frame // set view frame to swiftUI View frame
        
        view.addSubview(vc.view)
        self.view = view // UIView Container[ (SwiftUI View) ]
        
        self._scale = scale
        self._offset = offset
        self._scaleAnchor = scaleAnchor
        
    }
    
    func makeUIView(context: Context) -> UIView {
        context.coordinator.parent = self
        context.coordinator.addGestures()
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
}

//Delegate to add simultaneous gesture detection
class Coordinator: NSObject, UIGestureRecognizerDelegate{
    
    var parent: ZoomContainerUIKit
    private var initialCenter = CGPoint()
    private var prevScale: CGFloat = 1
    private var isZoomed: Bool {
        parent.scale > 1
    }
    
    init(_ parent: ZoomContainerUIKit){
        self.parent = parent
    }
    
    //Simultaneously gesture detection
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
    
    //Called in the makeUIView(context:) method to add the gestures to the view to be zoomed, etc. Configure the gestures.
    func addGestures(){
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGesture(gesture:)))
        let zoomGesture = UIPinchGestureRecognizer(target: self, action: #selector(zoomGesture(gesture:)))
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGesture(gesture:)))
        
        tapGesture.numberOfTapsRequired = 2 //Configure tap gesture for double tap
        
        //A delegate is assigned for simultaneous gestures
        panGesture.delegate = self
        zoomGesture.delegate = self
        tapGesture.delegate = self
        
        //Attaches the gestures
        parent.view.addGestureRecognizer(zoomGesture)
        parent.view.addGestureRecognizer(panGesture)
        parent.view.addGestureRecognizer(tapGesture)
        
    }
}

//MARK: Gestures definition
extension Coordinator{
    
    //MARK: Tap gesture function
    @objc
    func tapGesture(gesture: UITapGestureRecognizer){
        
        if gesture.state == .ended{
            
            if isZoomed == false {
                
                //the anchor is calculated
                parent.scaleAnchor = UnitPoint(x: gesture.location(in: nil).x/UIScreen.main.bounds.width, y: gesture.location(in: nil).y/UIScreen.main.bounds.height)
                
                withAnimation(.default) {
                    //set zoom to 2x
                    parent.scale = 2
                    prevScale = 2
                }
                
            }else{
                //if the user double tapped when the scale (zoom) != 1
                resetZoomPosition()
            }
        }
    }
    
    //MARK: Zoom gesture function
    @objc
    func zoomGesture(gesture: UIPinchGestureRecognizer){
        
        if gesture.state == .began {
            let location = gesture.location(in:  nil) //initial zoom location
            
            let newAnchor = UnitPoint(x: location.x / UIScreen.main.bounds.width, y: location.y / UIScreen.main.bounds.height)
            
            parent.scaleAnchor = newAnchor
            
        }
        //update the scale (zoom)
        if gesture.state == .changed {
            
            let newScale = prevScale*gesture.scale
            
            if newScale >= 5 {
                withAnimation(.default) {
                    parent.scale = 5
                }
            }else{
                withAnimation(.default) {
                    parent.scale = newScale
                    
                }
            }
        }
        //when user end the gesture, save the scale or call resetZoomPosition
        if gesture.state == .ended{
            
            if  prevScale*gesture.scale <= 1{
                resetZoomPosition()
                return
            }
            prevScale = parent.scale
        }
        
    }
    
    //MARK: Pan gesture function
    @objc
    func panGesture(gesture: UIPanGestureRecognizer) {
        
        guard parent.scale != 1 else{return} // this is to deny the pan gesture when scale is 1
        let translation = gesture.translation(in: nil)
        
        
        switch gesture.state{
        case .began:
            // Save the view's original position
            initialCenter = parent.offset
            
        case .changed,.possible,.failed, .ended:
            //Update the position
            let newPosition = CGPoint(x: initialCenter.x+translation.x, y: initialCenter.y+translation.y)
            parent.offset = newPosition
        case .cancelled:
            parent.offset = initialCenter
        @unknown default:
            break
        }
        
    }
    //MARK: Reset zoom and position function
    private func resetZoomPosition(){
        
        withAnimation(.default) {
            parent.scale = 1
            prevScale = 1
            parent.offset =  .zero
        }
        
    }
}
