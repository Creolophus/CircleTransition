//
//  NavigationControllerDelegate.swift
//  CircleTransition
//
//  Created by Creolophus on 3/12/15.
//  Copyright (c) 2015 Creolophus. All rights reserved.
//

import UIKit

class NavigationControllerDelegate: NSObject, UINavigationControllerDelegate {
   
    @IBOutlet weak var navigationController: UINavigationController?
    
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CircleTransitionAnimator()
    }
    
    var interactionContreoller: UIPercentDrivenInteractiveTransition?
    
    func navigationController(navigationController: UINavigationController, interactionControllerForAnimationController animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.interactionContreoller
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        var panGesture = UIPanGestureRecognizer(target: self, action: Selector("panned:"))
        self.navigationController!.view.addGestureRecognizer(panGesture)
    }
    
    func panned(gestureRecognizer: UIPanGestureRecognizer){
        switch gestureRecognizer.state{
        case .Began:
            self.interactionContreoller = UIPercentDrivenInteractiveTransition()
            if self.navigationController?.viewControllers.count > 1{
                self.navigationController?.popViewControllerAnimated(true)
            }else{
                self.navigationController?.topViewController.performSegueWithIdentifier("PushSegue", sender: nil)
            }
            //2
        case .Changed:
            var traslation = gestureRecognizer.translationInView(self.navigationController!.view)
            var completionProgress = traslation.x / CGRectGetWidth(self.navigationController!.view.bounds)
            self.interactionContreoller?.updateInteractiveTransition(completionProgress)
            
            //3
        case .Ended:
            var a = 1
            if gestureRecognizer.velocityInView(self.navigationController!.view).x > 0{
                self.interactionContreoller?.finishInteractiveTransition()
            }else{
                self.interactionContreoller?.cancelInteractiveTransition()
            }
            self.interactionContreoller = nil
            //4
        default:
            self.interactionContreoller = nil
        }
    }
}
