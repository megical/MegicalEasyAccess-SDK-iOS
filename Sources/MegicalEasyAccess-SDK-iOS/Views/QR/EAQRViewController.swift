//
//  EAQRViewController.swift
//  
//
//  Created by Antti Köliö on 5.3.2021.
//

import UIKit
import SwiftyBeaver

@objc
public class EAQRViewController: UIViewController {
    let log = SwiftyBeaver.self
    
    @objc public var loginCode: String = ""
    @objc public var authCallback: String = ""
    @objc public var onError: ((_ error: Error) -> Void)?
    
    lazy var filter = CIFilter(name: "CIQRCodeGenerator")
    lazy var qrImageView = UIImageView()
    let bLoginCode = UIButton(type: .custom)
    
    public override func viewDidLoad() {
        let eaQRMessage = EAURL.eaAppPath(loginCode: self.loginCode)
        
        let cCenter = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        let cEdge = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.4)
        
        let backgroundLayer = CAGradientLayer()
        backgroundLayer.frame = self.view.bounds
        backgroundLayer.colors = [cEdge.cgColor, cCenter.cgColor, cCenter.cgColor, cEdge.cgColor]
        backgroundLayer.locations = [0, 0.1, 0.9, 1]
        self.view.layer.addSublayer(backgroundLayer)
        
        self.qrImageView.image = generateQRCode(eaQRMessage)
        self.view.addSubview(self.qrImageView)
        self.qrImageView.translatesAutoresizingMaskIntoConstraints = false
        self.qrImageView.widthAnchor.constraint(equalToConstant: 200.0).isActive = true
        self.qrImageView.heightAnchor.constraint(equalToConstant: 200.0).isActive = true
        self.qrImageView.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        self.qrImageView.centerYAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        
        self.bLoginCode.setTitle(self.loginCode, for: .normal)
        self.bLoginCode.setTitleColor(.systemBlue, for: .normal)
        self.bLoginCode.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        self.bLoginCode.addTarget(self, action: #selector(self.onLoginButtonPressed(sender:)), for: .touchUpInside)
        self.view.addSubview(self.bLoginCode)
        self.bLoginCode.translatesAutoresizingMaskIntoConstraints = false
        self.bLoginCode.topAnchor.constraint(equalTo: self.qrImageView.bottomAnchor, constant: 30).isActive = true
        self.bLoginCode.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor).isActive = true
    }
    
    func generateQRCode(_ string: String) -> UIImage? {
        guard let filter = filter,
          let data = string.data(using: .isoLatin1, allowLossyConversion: false) else {
          return nil
        }

        filter.setValue(data, forKey: "inputMessage")

        guard let ciImage = filter.outputImage else {
          return nil
        }

        return UIImage(ciImage: ciImage, scale: 2.0, orientation: .up)
    }
    
    @objc func onLoginButtonPressed(sender: UIButton) {
        guard let eaUrl = URL(string: EAURL.eaAppPath(loginCode: self.loginCode, authCallback: self.authCallback)) else {
            log.error("Failed to switch to easy access")
            self.onError?(EAErrorUtil.error(domain: "MegAuthFlow", code: -1, underlyingError: nil, description: "Failed to switch to easy access"))
            return
        }
        
        DispatchQueue.main.async {
            UIApplication.shared.open(eaUrl)
        }
    }
}
