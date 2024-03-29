//
//  ViewController.swift
//  TestAR
//
//  Created by Tomislav Luketic on 9/3/19.
//  Copyright © 2019 lux. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController {

    @IBOutlet var sceneView: ARSCNView!
    
    var faceNode = SCNNode()
    var leftEye = SCNNode()
    var rightEye = SCNNode()
    
    //-----------------------
    // MARK: - View LifeCycle
    //-----------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //1. Set Up Face Tracking
        guard ARFaceTrackingConfiguration.isSupported else { return }
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        sceneView.delegate = self
        sceneView.showsStatistics = true
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        
        //2. Setup The Eye Nodes
        setupEyeNode()
    }
    
    override func viewWillAppear(_ animated: Bool) { super.viewWillAppear(animated) }
    
    //-----------------------
    // MARK: - Eye Node Setup
    //-----------------------
    
    /// Creates To SCNSpheres To Loosely Represent The Eyes
    func setupEyeNode(){
        
        //1. Create A Node To Represent The Eye
        let eyeGeometry = SCNSphere(radius: 0.005)
        eyeGeometry.materials.first?.diffuse.contents = UIColor.cyan
        eyeGeometry.materials.first?.transparency = 1
        
        //2. Create A Holder Node & Rotate It So The Gemoetry Points Towards The Device
        let node = SCNNode()
        node.geometry = eyeGeometry
        node.eulerAngles.x = -.pi / 2
        node.position.z = 0.1
        
        //3. Create The Left & Right Eyes
        leftEye = node.clone()
        rightEye = node.clone()
    }


}


//------------------------------
// MARK: - SCNVector3 Extensions
//------------------------------

extension SCNVector3{
    
    ///Get The Length Of Our Vector
    func length() -> Float { return sqrtf(x * x + y * y + z * z) }
    
    ///Allow Us To Subtract Two SCNVector3's
    static func - (l: SCNVector3, r: SCNVector3) -> SCNVector3 { return SCNVector3Make(l.x - r.x, l.y - r.y, l.z - r.z) }
}

//--------------------------
// MARK: - ARSCNViewDelegate
//--------------------------

extension ViewController: ARSCNViewDelegate{
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        //1. Setup The FaceNode & Add The Eyes
        faceNode = node
        faceNode.addChildNode(leftEye)
        faceNode.addChildNode(rightEye)
        faceNode.transform = node.transform
        
        //2. Get The Distance Of The Eyes From The Camera
        trackDistance()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
        faceNode.transform = node.transform
        
        //2. Check We Have A Valid ARFaceAnchor
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
        
        //3. Update The Transform Of The Left & Right Eyes From The Anchor Transform
        leftEye.simdTransform = faceAnchor.leftEyeTransform
        rightEye.simdTransform = faceAnchor.rightEyeTransform
        
        //4. Get The Distance Of The Eyes From The Camera
        trackDistance()
    }
    
    
    /// Tracks The Distance Of The Eyes From The Camera
    func trackDistance(){
        
        DispatchQueue.main.async {
            
            //4. Get The Distance Of The Eyes From The Camera
            let leftEyeDistanceFromCamera = self.leftEye.worldPosition - SCNVector3Zero
            let rightEyeDistanceFromCamera = self.rightEye.worldPosition - SCNVector3Zero
            
            //5. Calculate The Average Distance Of The Eyes To The Camera
            let averageDistance = (leftEyeDistanceFromCamera.length() + rightEyeDistanceFromCamera.length()) / 2
            let averageDistanceCM = (Int(round(averageDistance * 100)))
            print("Approximate Distance Of Face From Camera = \(averageDistanceCM)")
        }
    }
}


