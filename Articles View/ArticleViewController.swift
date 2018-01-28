//
//  ArticleViewController.swift
//  Articles View
//
//  Created by John Desjardins on 2018-01-26.
//  Copyright © 2018 John Desjardins. All rights reserved.
//

import UIKit

class ArticleViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    
    var article: [String: Any]?
    var authorInfo: [String:Any]?
    var mediaInfo: [String:Any]?
    
    // Request for authorInfo ------------------
    func requestTask (serverData: Data?, serverResponse: URLResponse?, serverError: Error?) -> Void{
        if serverError != nil {
            self.myCallback(responseString: "", error: serverError?.localizedDescription)
        }else{
            let result = String(data: serverData!, encoding: .utf8)!
            self.myCallback(responseString: result as String, error: nil)
        }
    }
    func myCallback(responseString: String, error: String?) {
        if error != nil {
            print("ERROR is " + error!)
        }else{
            if let myData: Data = responseString.data(using: String.Encoding.utf8) {
                do {
                    authorInfo = try JSONSerialization.jsonObject(with: myData, options: []) as? [String:Any]
                } catch let convertError {
                    print(convertError.localizedDescription)
                }
            }
        }
        DispatchQueue.main.async() {
            if let info = self.authorInfo!["name"]
            {
                print(info)
                self.authorLabel.text = info as? String
            }
        }
    }
    // Request for mediaInfo ------------------
    func requestTask2 (serverData: Data?, serverResponse: URLResponse?, serverError: Error?) -> Void{
        if serverError != nil {
            self.myCallback2(responseString: "", error: serverError?.localizedDescription)
        }else{
            let result = String(data: serverData!, encoding: .utf8)!
            self.myCallback2(responseString: result as String, error: nil)
        }
    }
    func myCallback2(responseString: String, error: String?) {
        if error != nil {
            print("ERROR is " + error!)
        }else{
            if let myData: Data = responseString.data(using: String.Encoding.utf8) {
                do {
                    mediaInfo = try JSONSerialization.jsonObject(with: myData, options: []) as? [String:Any]
                } catch let convertError {
                    print(convertError.localizedDescription)
                }
            }
        }
        DispatchQueue.main.async() {
            //print(self.mediaInfo!["guid"] as Any)
            let guid = self.mediaInfo!["guid"] as? [String: Any]
            let imageUrl = guid?["rendered"] as? String
            print(imageUrl!)
            let url = URL(string: imageUrl!)
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: url!)
                DispatchQueue.main.async {
                    self.imageView.image = UIImage(data: data!)
                }
            }
        }
    }
    
    // OnLoad ------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = article!["date"] as? String
        let articleContent = article!["content"] as? [String: Any]
        let content = articleContent?["rendered"] as? String
        
        textView.text = content!.htmlDecoded
       
        let links = article!["_links"] as? [String: Any]
        if let author = links!["author"] as? [[String: Any]], let authorLink = author.first?["href"] as? String {
            print(authorLink) // Gets URL to author Information
            let requestUrl: URL = URL(string: authorLink)!
            let myRequest: URLRequest = URLRequest(url: requestUrl)
            let mySession: URLSession = URLSession.shared
            let myTask = mySession.dataTask(with: myRequest, completionHandler: requestTask)
            myTask.resume()
        }
        if let media = links!["wp:featuredmedia"] as? [[String: Any]], let mediaLink = media.first?["href"] as? String {
            print(mediaLink) // Gets URL to media Information
            let requestUrl: URL = URL(string: mediaLink)!
            let myRequest: URLRequest = URLRequest(url: requestUrl)
            let mySession: URLSession = URLSession.shared
            let myTask = mySession.dataTask(with: myRequest, completionHandler: requestTask2)
            myTask.resume()
        }
        
    }

}
