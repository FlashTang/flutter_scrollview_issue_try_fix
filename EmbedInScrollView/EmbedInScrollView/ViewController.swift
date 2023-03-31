//
//  ViewController.swift
//  EmbedInScrollView
//
//  Created by Tang on 2023/3/30.
//

import UIKit
import Flutter
class ViewController: UIViewController {
    
    var flutterViewController:MyFlutterViewController!
    var scrollView:MyUIScrollView!
    var contentView:UIView! //container for flutterViewController.view
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let flutterEngine = (UIApplication.shared.delegate as! AppDelegate).flutterEngine
        flutterViewController = MyFlutterViewController(engine: flutterEngine, nibName: nil, bundle: nil)
        self.addChild(flutterViewController)
 
        scrollView = MyUIScrollView()
        view.addSubview(scrollView)
        scrollView.backgroundColor = .yellow
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView = UIView(frame: CGRect(x: 0, y: 0, width: 1000, height: 1000))
        contentView.backgroundColor = .green
        scrollView.addSubview(contentView)
        
        contentView.addSubview(flutterViewController.view)
        flutterViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            flutterViewController.view.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            flutterViewController.view.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            flutterViewController.view.topAnchor.constraint(equalTo: contentView.topAnchor),
            flutterViewController.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
        scrollView.contentSize = CGSize(width: 1000, height: 1000)
        
    }
}


class MyUIScrollView:UIScrollView,UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let _view = touch.view{
            if(NSStringFromClass(_view.classForCoder) == "FlutterView"){
                return false
            }
        }
        return true
    }
}


class MyFlutterViewController:FlutterViewController{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.touchesBegan()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        let touch:UITouch = touches.first!
        self.touchMoveWithTouch(touch: touch)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.touchEnd();
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        self.touchEnd();
    }
   
    func touchesBegan() {
        if let superView:UIScrollView  = self.view.superview as? UIScrollView{
            superView.panGestureRecognizer.isEnabled = false;
        }
    }
    
    func touchMoveWithTouch(touch:UITouch) {
        let previoursLocation:CGPoint  = touch.previousLocation(in: self.view)
        let location:CGPoint  = touch.location(in: self.view)
        let deltax:CGFloat  = abs(location.x - previoursLocation.x)
        let deltay:CGFloat  = abs(location.y - previoursLocation.y)
        if let superView:UIScrollView = self.view.superview as? UIScrollView{
            if (deltax > 2 && deltay <= 5) {
                let offset:CGPoint = superView.contentOffset
                superView.panGestureRecognizer.isEnabled = true
                superView.delegate?.scrollViewWillBeginDragging?(superView)
                superView.setContentOffset(CGPointMake(offset.x - (location.x - previoursLocation.x), offset.y), animated: true) //mark animated true or false
            } else {
                superView.panGestureRecognizer.isEnabled = false
            }
        }
    }
    
    func touchEnd() {
        if let superView:UIScrollView = self.view.superview as? UIScrollView {
            superView.panGestureRecognizer.isEnabled = true;
            let offset:CGPoint = superView.contentOffset;
            var offsetX:CGFloat = offset.x;
            if (offsetX > (1 * self.view.frame.size.width + self.view.frame.size.width * 1 / 3)) {
                superView.setContentOffset(CGPointMake(2 * self.view.frame.size.width, offset.y), animated:true);
            } else if (offsetX <= self.view.frame.size.width * 2 / 3) {
                superView.setContentOffset(CGPointMake(0, offset.y), animated: true)
            } else {
                superView.setContentOffset(CGPointMake(self.view.frame.size.width, offset.y), animated: true)
            }
            superView.delegate?.scrollViewDidEndDecelerating?(superView)
        }
    }
   
}
