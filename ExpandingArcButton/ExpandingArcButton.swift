//
//  ExpandingArcButton.swift
//  ExpandingArcButton
//
//  Created by John Jin Woong Kim on 2/13/18.
//  Copyright © 2018 John Jin Woong Kim. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift
import RxGesture

class ExpandingArcButton: UIView, CAAnimationDelegate{
    
    var mainButton: UIButton!
    // these are no longer buttons but rather cgrect allotments since
    //   CaShapeLayer is being a cod
    var expandButtons = [SubArcButton]()
    var titleLayers = [CATextLayer]()
    
    var borderColor: CGColor = UIColor.black.cgColor
    var fillColor: CGColor = UIColor.lightGray.cgColor
    var centralBorderColor: CGColor = UIColor.white.cgColor
    var centralFillColor: CGColor = UIColor.darkGray.cgColor
    var state = 0
    let disposeBag = DisposeBag()
    var expandedFrame : CGRect!
    var orgFrame:CGRect!
    var textHeight: CGFloat!
    
    var animationOffset: CGFloat = 0.0
    
    var titles = [String]()
    
    init(frame:CGRect, titles :[String]) {
        super.init(frame: frame)
        self.titles = titles
        let keyFrame = UIScreen.main.bounds
        // storing of two frame states, expanded and contracted
        orgFrame = frame
        expandedFrame = CGRect(origin: .zero, size: CGSize(width: keyFrame.width, height: keyFrame.width))
        
        self.textHeight = 30
        
        // buttons
        centerButtonSetup()
        
        initializeSubLayers()
        
        setButtonActions()
     
        self.animationOffset = 0.1
    }
    
    func centerButtonSetup(){
        self.mainButton = UIButton(frame: CGRect(origin: .zero, size: frame.size) )
        self.mainButton.layer.cornerRadius = frame.width/2
        self.mainButton.layer.borderWidth = 4
        self.mainButton.layer.borderColor = centralBorderColor
        self.mainButton.layer.backgroundColor = centralFillColor
        self.mainButton.translatesAutoresizingMaskIntoConstraints = false
        self.mainButton.layer.zPosition = 3
        
        self.addSubview(mainButton)
        self.addConstraint(NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: NSLayoutRelation(rawValue: 0)!, toItem: mainButton, attribute: .centerX, multiplier: 1, constant: 0) )
        self.addConstraint(NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: NSLayoutRelation(rawValue: 0)!, toItem: mainButton, attribute: .centerY, multiplier: 1, constant: 0) )
        self.addConstraintsWithFormat("V:[v0(\(frame.width))]", views: mainButton)
        self.addConstraintsWithFormat("H:[v0(\(frame.width))]", views: mainButton)
    }
    
    func initializeSubLayers(){
        for (index,t) in self.titles.enumerated(){
            let b = SubArcButton(frame: CGRect(origin: .zero, size: frame.size),
                                 index: index,
                                 title: t,
                                 total: titles.count,
                                 arcCenter: CGPoint(x: expandedFrame.width/2, y: expandedFrame.width/2 ),
                                 radius: expandedFrame.width/2)
            b.calculateWidth(height: self.textHeight, title: t)
            self.expandButtons.append(b)
        }
    }
    
    func setButtonActions(){
        mainButton.rx.tapGesture()
            .when( UIGestureRecognizerState.recognized )
            .subscribe(onNext: { gesture in
                if self.state == 0{
                    self.mainButton.isUserInteractionEnabled = false
                    self.isUserInteractionEnabled = false
                    self.delay(Double(self.calculateExpandAnimDuration()), closure: {
                        self.mainButton.isUserInteractionEnabled = true
                        self.isUserInteractionEnabled = true
                        self.state = 1
                    })
                    self.frame = self.expandedFrame
                    var i:CGFloat = 0.0
                    for b in self.expandButtons{
                        self.delay(Double(i), closure: {
                            // set the CATextLayer to the cente rof the now bigger and expanded view
                            self.layer.addSublayer(b.shapeLayer)
                            self.layer.addSublayer(b.textLayer)
                            b.applyShapeLayer(flag: 0 )
                            b.applyTextLayer(flag: 0)
                        })
                        i += self.animationOffset
                    }
                    
                }else{

                    self.mainButton.isUserInteractionEnabled = false
                    self.isUserInteractionEnabled = false
                    self.delay(Double(self.expandButtons[0].animDuration), closure: {
                        self.mainButton.isUserInteractionEnabled = true
                        self.isUserInteractionEnabled = true
                    })
                    self.frame = self.orgFrame
                    for b in self.expandButtons{
                        b.applyTextLayer(flag: 1)
                        b.applyShapeLayer(flag: 1)
                    }
                    self.state = 0
                }
            }).disposed(by: disposeBag)
        
        self.rx.tapGesture()
            .when(UIGestureRecognizerState.recognized)
            .asLocation(in: TargetView.this(self))
            .subscribe(onNext: { location in

                for b in self.expandButtons{
                    if !self.mainButton.frame.contains(location) &&
                        b.postExpandedPath.contains(location){
                        // setting onSelected highlight colors for the button.  I have
                        //  it set up where you need to set it here before applyTextLayer/applyShapeLayer
                        //  every time rather than initializing variables
                        //  since im still prototyping.
                        b.onTapFillColor = UIColor.darkGray.cgColor
                        b.onTapBorderColor = UIColor.lightGray.cgColor
                        b.onTapTextColor = UIColor.white.cgColor
                        
                        
                        self.mainButton.isUserInteractionEnabled = false
                        self.isUserInteractionEnabled = false
                        self.frame = self.orgFrame
                        for b in self.expandButtons{
                            b.applyTextLayer(flag: 1)
                            b.applyShapeLayer(flag: 1)
                        }
                        self.state = 0
                        self.delay(Double(self.expandButtons[0].animDuration), closure: {
                            self.mainButton.isUserInteractionEnabled = true
                            self.isUserInteractionEnabled = true
                            // here is probably where you want to do your action based off of
                            //  which subbutton was pressed since here is where all the animations
                            //  have completed.
                        })
                        break
                    }
                }
                
            }).disposed(by: disposeBag)
    }
    
    
    func calculateExpandAnimDuration()->Double{
        var dur: Double = Double(self.animationOffset * CGFloat(self.expandButtons.count))
        dur += Double(self.expandButtons[0].animDuration)
        return dur
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func animationDidStart(_ anim: CAAnimation) {

    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {

    }
    
}





