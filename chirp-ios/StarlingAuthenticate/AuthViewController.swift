//
//  AuthViewController.swift
//  StarlingAuthenticate
//
//  Created by Carlos Purves on 07/04/2017.
//  Copyright © 2017 carlospurves. All rights reserved.
//

import UIKit
import LocalAuthentication
import Alamofire

class AuthViewController: UIViewController {
    @IBOutlet weak var background_im: UIImageView!
    @IBOutlet weak var PulseLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var ActivityMonitor: UIActivityIndicatorView!
    
    var gl_fbid:String = ""
    var gl_msg:String = ""
    
    override func viewDidAppear(_ animated: Bool) {
        ActivityMonitor.isHidden = false
        ActivityMonitor.startAnimating()
        animationPulseEffect(view: PulseLabel, animationTime: 1.2)
    }
    
    func animationPulseEffect(view:UIView,animationTime:Float){
        UIView.animate(withDuration: TimeInterval(animationTime), delay:0, options: [.repeat, .autoreverse], animations: {
            view.alpha = 0.2
        },completion:{completion in
            UIView.animate(withDuration: TimeInterval(animationTime), animations: { () -> Void in
                view.alpha = 1
            })
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        background_im.image = UIImage(named: "st_bgs")
        background_im.contentMode = UIViewContentMode.scaleAspectFill
        
        if LoginSettings.useSJ {
            gl_fbid = LoginSettings.fbid
            gl_msg = LoginSettings.msg
            LoginSettings.useSJ = false
        }
        
        
            let ctx = LAContext()
            var err:NSError?
            guard ctx.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &err) else {
                print ("Failed, no TouchID")
                return
            }
            ctx.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                               localizedReason: "We only ever reveal your sensitive data though Messenger.",
                               reply: {(success, error) -> Void in
                                if (success){
                                    self.ActivityMonitor.isHidden = false
                                    self.ActivityMonitor.startAnimating()
                                    let parameters: Parameters = [
                                        "uuid":self.gl_fbid ,
                                        "msg":self.gl_msg
                                    ]
                                    Alamofire.request("https://pyri.co/api/push_return", method: .post, parameters: parameters).responseJSON(completionHandler: {
                                        response in
                                        
                                        self.ActivityMonitor.isHidden = true
                                        self.ActivityMonitor.stopAnimating()
                                        
                                        switch(response.result){
                                            case .success(let r):
                                                let fbM = URL(string:"fb-messenger://")
                                                UIApplication.shared.open(fbM!, options: [:], completionHandler: { a in
                                                self.dismiss(animated: true, completion: nil)
                                                })
                                            
                                            case .failure(let err):
                                                self.infoLabel.text = response.result.value as! String?
                                        }
                                        
                                    })
                                }else{
                                    if let error = error {
                                        
                                        if (error.localizedDescription == "Canceled by user."){
                                            self.dismiss(animated: true, completion: nil)
                                        }else{
                                            /*
                                            let refreshAlert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                                            
                                            refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                                                print("Handle Ok logic here")
                                            }))
 
                                            
                                            self.present(refreshAlert, animated: true, completion: nil)
                                            */
                                            
                                            self.dismiss(animated: true, completion: nil)
                                        }
                                        
                                        
                                    }
                                }})

        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
