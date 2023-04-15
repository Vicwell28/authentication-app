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
        let session = URLSession(configuration: .default)
        
        var request = URLRequest(url: URL(string: "https://menonitas-kangri.me/api/auth/codemobile")!)

        if self.isURLVPN {
            request = URLRequest(url: URL(string: "http://10.10.10.3/api/auth/codemobile")!)
        }
        
        print(request.url!)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: ["code": code], options: [])
            request.httpBody = jsonData
        } catch {
            print("Error al serializar los datos: \(error.localizedDescription)")
        }
        
        
        URLSession(configuration: .default).dataTask(with: request) { Data, URLResponse, Error in
            DispatchQueue.main.async {
                self.dismissViewControllerLoaderHotel()
            }

            if Error != nil {
                print("ERORR API \(Error!.localizedDescription)")
                return
            }
            
            DispatchQueue.main.async {
                let dataResponse = String(data: Data!, encoding: .utf8)
                print(dataResponse!)
                self.lblResponseCode.text = dataResponse!
                self.lblResponseCode.isHidden = false
            }
        }.resume()
        
    }
}
