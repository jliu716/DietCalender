//
//  SlidingTopViewController.swift
//  DietCalender
//
//  Created by Beethoven on 24/12/18.
//  Copyright © 2018 Jiayi Liu. All rights reserved.
//

import UIKit

class SlidingTopViewController: UIViewController {
    
    var freezingOverlay : UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        drawFreezingOverlay()
    }
    
    func drawFreezingOverlay(){
        freezingOverlay = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        freezingOverlay!.backgroundColor = UIColor(white: 0, alpha: 0.0)
        let tap : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleOverlayTap(gesture:)))
        let pan : UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleOverlayPanLeft(gesture:)))
        freezingOverlay!.addGestureRecognizer(tap)
        freezingOverlay!.addGestureRecognizer(pan)
        freezingOverlay!.tag = 0 // hidden
    }
    
    @objc func anchorRight() {
        let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        
        // check if overlay has been initiated
        if freezingOverlay?.tag == 0 {
            self.view.addSubview(freezingOverlay!)
            UIView.animate(withDuration: 0.5, animations: {
                self.freezingOverlay!.backgroundColor = UIColor(white: 0, alpha: 0.25)
            }) { (completed) in
                self.freezingOverlay?.tag = 1
            }
        }else {
            self.freezingOverlay?.tag = 0
            UIView.animate(withDuration: 0.5, animations: {
                self.freezingOverlay!.backgroundColor = UIColor(white: 0, alpha: 0.0)
            }) { (completed) in
                self.freezingOverlay?.removeFromSuperview()
            }
        }
        delegate.anchorRight()
    }
    
    @objc func handleOverlayTap(gesture : UITapGestureRecognizer){
        anchorRight()
    }
    
    @objc func handleOverlayPanLeft(gesture : UIPanGestureRecognizer){
        if gesture.velocity(in: freezingOverlay).x < 0 && freezingOverlay!.tag == 1 {
            anchorRight()
        }
    }
    
}
