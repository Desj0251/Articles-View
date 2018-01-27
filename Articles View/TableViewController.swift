//
//  TableViewController.swift
//  Articles View
//
//  Created by John Desjardins on 2018-01-25.
//  Copyright © 2018 John Desjardins. All rights reserved.
//

import UIKit

extension String {
    var replacingHTMLEntities: String? {
        do {
            return try NSAttributedString(data: Data(utf8), options: [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue
                ], documentAttributes: nil).string
        } catch {
            return nil
        }
    }
}

class TableViewController: UITableViewController {

    var jsonArray: [[String:Any]]?
    

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
                    jsonArray = try JSONSerialization.jsonObject(with: myData, options: []) as? [[String:Any]]
                } catch let convertError {
                    print(convertError.localizedDescription)
                }
            }
        }
        DispatchQueue.main.async() {
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let requestUrl: URL = URL(string: "http://algonquintimes.com/wp-json/wp/v2/posts")!
        let myRequest: URLRequest = URLRequest(url: requestUrl)
        let mySession: URLSession = URLSession.shared
        let myTask = mySession.dataTask(with: myRequest, completionHandler: requestTask)
        myTask.resume()
        
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleCell", for: indexPath)
        if let eventInfo = jsonArray?[indexPath.row] {
//            cell.textLabel!.text = eventInfo["slug"]! as? String
            
            let coordinatesJSON = eventInfo["title"] as? [String: Any]
            let latitude = coordinatesJSON?["rendered"] as? String
            cell.textLabel!.text = latitude!.replacingHTMLEntities!
            
            //cell.detailTextLabel!.text = eventInfo["addressEN"]! as? String
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let events = jsonArray?.count {
            return events
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            jsonArray?.remove(at:indexPath.item)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "showArticle" {
            let eventVC = segue.destination as? ArticleViewController
            guard let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) else {
                return
            }
            eventVC?.article = jsonArray?[indexPath.row]
        }
    }

}
