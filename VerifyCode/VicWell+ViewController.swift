//
//  Marin+ViewController.swift
//  VerifyCode
//
//  Created by soliduSystem on 13/03/23.
//

import UIKit

class VicWell_ViewController: UIViewController {
    
    //MARK: - Override func
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewPointsCollections.forEach({ $0.layer.cornerRadius = $0.frame.width / 2})
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    
    
    private var isURLVPN : Bool = false
    
    
    //MARK: - Private Var / Let
    private var indexPosition : Int = 0
    
    //MARK: - Public Var / Let
    
    @IBAction func reloadForm(_ sender: UIButton) {
        print("ENTRO")
        self.indexPosition = 0
        self.viewPointsCollections.forEach({$0.alpha = 1})
        self.btnCollections.forEach({$0.isEnabled = true})
        self.lblResponseCode.isHidden = true
    }
    
    @IBAction func changeURL(_ sender: UIButton) {
        if self.isURLVPN {
            self.isURLVPN = false
            UIView.animate(withDuration: 0.5) {
                self.viewWebVpn[0].backgroundColor = .green
                self.viewWebVpn[1].backgroundColor = UIColor(named: "ColorDos")
            }
            return
        }
        
        UIView.animate(withDuration: 0.5) {
            self.viewWebVpn[0].backgroundColor = UIColor(named: "ColorDos")
            self.viewWebVpn[1].backgroundColor = .green
        }
        self.isURLVPN = true
    }
    
    //MARK: - @IBOutlet
    @IBOutlet var viewPointsCollections: [UIView]!
    @IBOutlet var lablesNumbresCollections: [UILabel]!
    @IBOutlet weak var lblResponseCode: UILabel!
    @IBOutlet var btnCollections: [UIButton]!
    @IBOutlet var viewWebVpn: [UIView]!
    @IBOutlet var lblWebVpn: [UILabel]!
    
    let destinationViewController = ScannerViewController()
}


//MARK: - @IBAction
extension VicWell_ViewController {
    @IBAction func onClickNumberAction(_ sender: UIButton) {
        print("Index \(indexPosition) Tag \(sender.tag)")
        
        if sender.tag > 9 {
            
            UIView.animate(withDuration: 0.5) {
                self.viewPointsCollections[self.indexPosition].alpha = 1
            }
            
            if indexPosition != 0 {
                indexPosition -= 1
            }
            
            return
        }
        
        
        self.lablesNumbresCollections[self.indexPosition].text = "\(sender.tag)"
        
        UIView.animate(withDuration: 0.5) {
            self.viewPointsCollections[self.indexPosition].alpha = 0
        } completion: { Bool in
            self.lablesNumbresCollections[self.indexPosition].alpha = 0
            UIView.animate(withDuration: 0.5) {
                self.lablesNumbresCollections[self.indexPosition].alpha = 1
            }
        }
        
        
        if indexPosition != 4 {
            indexPosition += 1
        } else {
            self.showViewControllerLoaderHotel()
            self.btnCollections.forEach({$0.isEnabled = false})
            
            var code : String = ""
            
            self.lablesNumbresCollections.forEach({code += $0.text!})
            
            print(code)
            
            self.PostVerify(code: code)
        }
    }
}
//MARK: - public func
extension VicWell_ViewController {
    
    
}
//MARK: - Private func
extension VicWell_ViewController {
    
}
//MARK: - Services
extension VicWell_ViewController {
    
    
    
}
//MARK: - Other
extension VicWell_ViewController {
    private func PostVerify(code : String){
        
        var request = URLRequest(url: URL(string: self.isURLVPN ? "http://10.10.10.3/api/auth/codemobile" : "https://menonitas-kangri.me/api/auth/codemobile")!)
        
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = try! JSONEncoder().encode(RequestBodyCodeMobile(code_mobile: code))
        
        URLSession(configuration: .default).dataTask(with: request) { Data, URLResponse, Error in
            DispatchQueue.main.async {
                self.dismissViewControllerLoaderHotel()
            
            
            if Error != nil {
                print("ERORR API \(Error!.localizedDescription)")
                return
            }
            
            
            if (URLResponse as! HTTPURLResponse).statusCode == 200 {
                let dataResponse = try! JSONDecoder().decode(ResponseCodeMobile.self, from: Data!)
                
                self.lblResponseCode.text = dataResponse.code_one
                self.lblResponseCode.isHidden = false
                
                self.destinationViewController.modalPresentationStyle = .fullScreen
                self.present(self.destinationViewController, animated: true)
            }
                
            }
        }.resume()
        
    }
}


extension VicWell_ViewController: ScannerViewDelegate {
    func didscanned(code: String) {
        
    }
}

struct RequestBodyCodeMobile: Codable {
    let code_mobile: String
}

struct ResponseCodeMobile: Codable {
    let code_one: String
}








