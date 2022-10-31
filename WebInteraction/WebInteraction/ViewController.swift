//
//  ViewController.swift
//  WebInteraction
//
//  Created by Yang Tun-Kai on 2022/10/29.
//

import UIKit
import WebKit

class ViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setWebView()
        // Do any additional setup after loading the view.
    }

    private func setWebView() {
        webView.navigationDelegate = self
        
        webView.configuration.userContentController.add(self, name: "nativeApp")
        
        webView.scrollView.showsVerticalScrollIndicator = false
        
        webView.scrollView.showsHorizontalScrollIndicator = false
        
        guard let url = URL(string: "http://192.168.0.107:8080/") else { return }
        
        webView.load(URLRequest(url: url))
    }

    private func saveImageToAlbum(with base64: String) {
        
        if let image = base64.base64ToImage() {
            
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(openAlert(_:didFinishSavingWithError:contextInfo:)), nil)
        }
    }
    
    @objc private func openAlert(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
    
        let message = error?.localizedDescription ?? "儲存圖片完成"
    
        let alert = UIAlertController(title: "提示", message: message, preferredStyle: .alert)
       
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }
}

extension ViewController : WKNavigationDelegate {
    // MARK: WKNavigationDelegate method
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
        print(#function)
    }
    
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        
        print(#function, error)
    }
    
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        print(#function)
    }
    
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        
        print(#function,"error:",error)
    }
}


extension ViewController : WKScriptMessageHandler {
    
    // MARK: WKScriptMessageHandler method
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        print(message.body)
        
        guard let infos = message.body as? Dictionary<String, AnyObject>,
              let action = infos.keys.first,
              let value = infos.values.first
        else { return }
        
        
        if action == "saveImage" {
            if let base64String = value["data"] as? String {
                
                saveImageToAlbum(with: base64String)
            }
        }
        
        if action == "getAppToken" {
            webView.evaluateJavaScript("setTimeout(function() {getToken('這是一串token')}, 3000)", completionHandler: { (object, error) in
                
                print("completed with object, \(object ?? "")")
                
                print("completed with error, \(String(describing: error))")
            })
        }
    }
}

extension String {
    
    static let empty = ""
        
    func base64ToImage() -> UIImage? {
        
        if let data = Data(base64Encoded: self), let image = UIImage(data: data) {
            
            return image
        }
            
        return nil
    }
}
