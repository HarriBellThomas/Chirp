//
//  ViewController.swift
//  StarlingAuthenticate
//
//  Created by Carlos Purves on 07/04/2017.
//  Copyright © 2017 carlospurves. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var background_im: UIImageView!
    @IBOutlet weak var background_prox: UIImageView!
    @IBOutlet weak var MainLabel: UILabel!
    @IBOutlet weak var AllowButton: UIButton!
    @IBAction func GoForceAuth(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AuthenticateScreen") as! AuthViewController
        self.present(vc, animated: true, completion: nil)
    }
    
    func goAuth(){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AuthenticateScreen") as! AuthViewController
        self.present(vc, animated: true, completion: nil)
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(goAuth), name: Notification.Name("goAuth"), object: nil)
        
        
        background_im.image = UIImage(named: "st_bgs")
        background_im.contentMode = UIViewContentMode.scaleAspectFill
        background_prox.image = UIImage(named: "st_bgs_2")
        background_prox.contentMode = UIViewContentMode.scaleAspectFill
        
        background_im.alpha = 0.3
        background_prox.alpha = 0
        
        var a:CGFloat = 0.0;
        
        UIView.animate(withDuration: TimeInterval(14), delay:0, options: [.repeat, .autoreverse], animations: {
            self.background_im.alpha = 0.1
        },completion:{completion in
            UIView.animate(withDuration: TimeInterval(5), animations: { () -> Void in
                self.background_im.alpha = 0.4
            })
        })
        
        UIView.animate(withDuration: TimeInterval(8.9), delay:0, options: [.repeat, .autoreverse], animations: {
            a = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
            self.background_prox.alpha = 0.5
            self.background_prox.transform = CGAffineTransform(scaleX:1+a, y: 1+a)
        },completion:{completion in
            UIView.animate(withDuration: TimeInterval(4.2), animations: { () -> Void in
                self.background_prox.alpha = 0.05
                self.background_prox.transform = CGAffineTransform(scaleX: 1-a, y: 1-a)
            })
        })
        
        self.setNeedsStatusBarAppearanceUpdate()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        AllowButton.isHidden = true
        
        let defaults = UserDefaults.standard
        if (LoginSettings.useSJ){
            
            defaults.set(LoginSettings.fbid, forKey: "fbid")
            defaults.set(true, forKey: "fb_used")
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "AuthenticateScreen") as! AuthViewController
            present(vc, animated: true, completion: nil)
        }else{
            if let y = defaults.object(forKey: "fb_used") as! Bool? {
                if y {
                    LoginSettings.useSJ = true
                    LoginSettings.fbid = defaults.object(forKey: "fbid") as! String
                    AllowButton.isHidden = false
                }
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}

