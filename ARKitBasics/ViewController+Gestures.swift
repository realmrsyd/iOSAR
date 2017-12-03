//
//  ViewController+Gestures.swift
//  ARKitBasics
//
//  Created by Abhinav Prakash on 16/11/17.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit
import ARKit
import CoreData

extension ViewController: UIGestureRecognizerDelegate {
    
    /// Experimental - //
    
    @objc
    func insertObject(_ newObject: SCNNode) {
        // Database udpate - overridden in subclass
    }
    
    //    private func distanceFromCamera() {
    //        return sceneView.
    //    }
    
    private func action(on node: SCNNode, for key: String) {
        let actionJump = SCNAction.sequence([SCNAction.scale(to: 0.7, duration: 0.1), SCNAction.scale(to: 1, duration: 0.05)])
        let actionVanish = SCNAction.scale(to: 0.5, duration: 0.1)
        switch key {
        case "vanish":
            DispatchQueue.global(qos: .userInteractive).async {
                //                self.sound.playSound(named: "swoosh") // Probably not needed since textToSpeech included
                self.speech.say(text: self.speech.randomAccolade)
                self.speech.say(text: "Let's move to the next.")
                
                // Remove existing objects, restart the game.
                DispatchQueue.main.async {
                    self.inStateOfPlay(playing: false)
                }
            }
            node.runAction(actionVanish)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) { [weak self] in
                node.parent?.removeFromParentNode()
                self?.segueButton.setBackgroundImage(UIImage(named: "cube-blue"), for: .normal)
            }
        case "jump":
            DispatchQueue.global(qos: .userInteractive).async {
                //                self.sound.playSound(named: "jump") // Probably not needed since textToSpeech included
                self.speech.sayWithInterruption(text: self.speech.randomNegation)
            }
            node.parent?.runAction(actionJump)
        default: break
        }
    }
    
    // MARK: - Gesture Methods
    
    @objc
    func collectObject(_ gestureRecognize: UITapGestureRecognizer) {
        if !inStateOfPlayForGestureControl {
            return
        }
        let p = gestureRecognize.location(in: sceneView)
        let hitResults = sceneView.hitTest(p, options: [:])
        if hitResults.count > 0 && hitResults.first?.node.name != "anchorPlane" {
            let result = hitResults.first!
            segueButton.isHidden = false
            
            if (result.node.parent?.name) != nil {
                if let anchorNode = result.node.parent?.parent?.parent?.childNode(withName: "anchorNode", recursively: true) {
                    anchorNode.isHidden = false
                }
                
                let nodeToBeRemoved = result.node.parent!
                //                print(nodeToBeRemoved.worldPosition)
                //                print(sceneView.session.currentFrame?.camera.transform)
                //                print(sceneView.scene.rootNode.worldPosition)
                
                if let nodeWithAttributes = chosenScenarioForChallenge {
                    switch nodeToBeRemoved.name {
                    case nodeWithAttributes.shape? :
                        switch virtualObjectInstance.findColor(of: nodeToBeRemoved.childNodes.last!) {
                        case nodeWithAttributes.color :
                            action(on: nodeToBeRemoved, for: "vanish")
                            
                        default:
                            action(on: nodeToBeRemoved, for: "jump")
                            // This actually is a non-hygienic way - think of alternative
                            // Queuing is not proper - at times one statement is spoken first
                            // and others - other one. @TODO
                            DispatchQueue.global(qos: .userInteractive).async {
                                self.speech.sayNegativeExplanation(
                                    color: self.virtualObjectInstance.findColor(of: nodeToBeRemoved.childNodes.last!),
                                    shape: nodeToBeRemoved.name!)
                            }
                            
                        }
                    default:
                        action(on: nodeToBeRemoved, for: "jump")
                        // This actually is a non-hygienic way - think of alternative
                        DispatchQueue.global(qos: .userInteractive).async {
                            self.speech.sayNegativeExplanation(
                                color: self.virtualObjectInstance.findColor(of: nodeToBeRemoved.childNodes.last!),
                                shape: nodeToBeRemoved.name!)
                        }
                    }
                }
            }
        }
    }
    
}






