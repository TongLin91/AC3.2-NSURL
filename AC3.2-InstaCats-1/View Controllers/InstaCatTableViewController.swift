//
//  InstaCatTableViewController.swift
//  AC3.2-InstaCats-1
//
//  Created by Louis Tur on 10/10/16.
//  Copyright © 2016 C4Q. All rights reserved.
//

import UIKit

struct InstaCat {
    /*
     {
     "cat_id" : "001",
     "name" : "Nala Cat",
     "instagram" : "https://www.instagram.com/nala_cat/?hl=en"
     },
 */
    let id: String
    let name: String
    let instagram: String
    
    init(id: String, name: String, instagram: String) {
        self.id = id
        self.name = name
        self.instagram = instagram
    }
}

class InstaCatTableViewController: UITableViewController {

    internal let InstaCatTableViewCellIdentifier: String = "InstaCatCellIdentifier"
    internal let instaCatJSONFileName: String = "InstaCats.json"
    internal var instaCats: [InstaCat] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let instaCatsURL: URL = self.getResourceURL(from: instaCatJSONFileName),
            let instaCatData: Data = self.getData(from: instaCatsURL), // sorry, this should be Data, not NSData!
            let instaCatsAll: [InstaCat] = self.getInstaCats(from: instaCatData) else {
                return
        }
        
        self.instaCats = instaCatsAll
      
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.instaCats.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InstaCatCellIdentifier", for: indexPath)

        let cat = instaCats[indexPath.row]
        cell.textLabel?.text = cat.name
        cell.detailTextLabel?.text = "Nice to meet you, I am " + cat.name
        return cell
    }
    
    internal func getResourceURL(from fileName: String) -> URL? {
        // 1. There are many ways of doing this parsing, we're going to practice String traversal
        guard let dotRange = fileName.rangeOfCharacter(from: CharacterSet.init(charactersIn: ".")) else {
            return nil
        }
        
        // 2. The upperbound of a range represents the position following the last position in the range, thus we can use it
        // to effectively "skip" the "." for the extension range
        let fileNameComponent: String = fileName.substring(to: dotRange.lowerBound)
        let fileExtenstionComponent: String = fileName.substring(from: dotRange.upperBound)
        
        // 3. Here is where Bundle.main comes into play
        let fileURL: URL? = Bundle.main.url(forResource: fileNameComponent, withExtension: fileExtenstionComponent)
        
        return fileURL
    }
    
    internal func getData(from url: URL) -> Data? {
        // 1. this is a simple handling of a function that can throw. In this case, the code makes for a very short function
        // but it can be much larger if we change how we want to handle errors.
        let fileData: Data? = try? Data(contentsOf: url)
        return fileData
    }
    
    internal func getInstaCats(from jsonData: Data) -> [InstaCat]? {
        // 1. This time around we'll add a do-catch
        do {
            let instaCatJSONData: Any = try JSONSerialization.jsonObject(with: jsonData, options: [])
            
            // 2. Cast from Any into a more suitable data structure and check for the "cats" key
            var catContainer: [InstaCat] = []
            // 3. Check for keys "name", "cat_id", "instagram", making sure to cast values as needed along the way
            if let cats = (instaCatJSONData as AnyObject).value(forKeyPath: "cats") as? [[String:String]]{
                for cat in cats{
                    catContainer.append(InstaCat.init(id: cat["cat_id"]!, name: cat["name"]!, instagram: cat["instagram"]!))
                }
            }else{
                return nil
            }
            // 4. Return something
            dump(catContainer)
            return catContainer
        }
        catch let error as NSError {
            // JSONSerialization doc specficially says an NSError is returned if JSONSerialization.jsonObject(with:options:) fails
            print("Error occurred while parsing data: \(error.localizedDescription)")
        }
        
        return  nil
    }

}
