//
//  Marin+ViewController.swift
//  VerifyCode
//
//  Created by soliduSystem on 13/03/23.
//

import UIKit
import PusherSwift

class VicWell_ViewController: UIViewController {
    
    //MARK: - Override func
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewPointsCollections.forEach({ $0.layer.cornerRadius = $0.frame.width / 2})
        
        self.destinationViewController.delegate = self
        self.pusherViewModel.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.pusherViewModel.setUp()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    
    //MARK: - Private Var / Let
    private var indexPosition : Int = 0
    private var isURLVPN : Bool = false
    
    private var token: String?
    private var email: String?
    private var role: String?
    
    //MARK: - Public Var / Let
    
    @IBAction func StartScannQR(_ sender: UIButton) {
        self.StartScannQR()
    }
    
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
    let pusherViewModel = PusherViewModel(
        pusher: Pusher(
            options:  PusherClientOptions(host: .cluster("mt1"))
        ))
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
    
    private func StartScannQR() -> Void {
        self.present(self.destinationViewController, animated: true)
    }
    
}
//MARK: - Services
extension VicWell_ViewController {
    
    
    
}
//MARK: - Other
extension VicWell_ViewController {
    private func PostVerify(code : String){
        self.showViewControllerLoaderHotel()
        
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
                    
                    
                }
                
            }
        }.resume()
        
    }
    
    private func PostVerifyQR(_ body: DataVerifyQR){
        self.showViewControllerLoaderHotel()
        
        
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = try! JSONEncoder().encode(body)
        
        print(request.url!)
        print(request.httpBody!)
        
        URLSession(configuration: .default).dataTask(with: request) { Data, URLResponse, Error in
            DispatchQueue.main.async {
                self.dismissViewControllerLoaderHotel()
                
                
                if Error != nil {
                    print("ERORR API \(Error!.localizedDescription)")
                    return
                }
                
                
                if (URLResponse as! HTTPURLResponse).statusCode == 200 {
                    let jsonResponse = String(data: Data!, encoding: .utf8)
                    print(String(describing: jsonResponse))
                }
                
            }
        }.resume()
        
    }
}


extension VicWell_ViewController: ScannerViewDelegate {
    func didscanned(code: String) {
        
        if self.email == nil {
            
            let ac = UIAlertController(title: "Token empty", message: "", preferredStyle: .alert)
                
            ac.addAction(UIAlertAction(title: "Ok", style: .destructive))
        
            self.present(ac, animated: true)
            
            return
        }
        
        
//        let bodyData = VerifyQR(data: DataVerifyQR(token: self.token!, rol: self.role!, email: self.email!))
        let bodyData = DataVerifyQR(token: self.token!, rol: self.role!, email: self.email!)

        print("BodyData: \(bodyData)")
        
//        let jsonResponse = try! JSONDecoder().decode(VerifyQR.self, from: code.data(using: .utf8)!)
        
        self.PostVerifyQR(bodyData)
        
    }
}

extension VicWell_ViewController: PusherBindEventDelegate {
    func didPusherDidEvent(event: PusherEvent) {
        if self.destinationViewController.isModalInPresentation {
            return
        }
        
        guard let data = event.data?.data(using: .utf8) else { return }
        
       print("Data: \(data)")
        
        do {
            let dataJSON = try JSONDecoder().decode(VerifyQR.self, from: data)
            
            self.email = dataJSON.data.email
            self.token = dataJSON.data.token
            self.role = dataJSON.data.rol

            print("DataJSON: \(dataJSON)")
            print("email: \(String(describing: self.email))")
            print("token: \(String(describing: self.token))")
            print("role: \(String(describing: self.role))")

            self.destinationViewController.modalPresentationStyle = .fullScreen
            self.present(self.destinationViewController, animated: true)
            
        } catch {
            print(error.localizedDescription)
        }
        
        
    }
}

struct RequestBodyCodeMobile: Codable {
    let code_mobile: String
}

struct ResponseCodeMobile: Codable {
    let code_one: String
}

struct DataVerifyQR: Codable {
    let token: String
    let rol: String
    let email: String
}

struct VerifyQR: Codable {
    let data: DataVerifyQR
}
