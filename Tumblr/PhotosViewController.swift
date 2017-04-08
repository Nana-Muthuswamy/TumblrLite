//
//  PhotosViewController.swift
//  Tumblr
//
//  Created by Curtis Wilcox on 3/29/17.
//  Copyright © 2017 DevFountain LLC. All rights reserved.
//

import UIKit
import Foundation
import AFNetworking

class PhotosViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var posts: [NSDictionary] = []
    @IBOutlet weak var photosTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(control:)), for: UIControlEvents.valueChanged)
        photosTableView.insertSubview(refreshControl, at: 0)

        // Fetch remote data
        fetchPhotoData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Network APIs

    func fetchPhotoData() -> Void {

        let url = URL(string:"https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/posts/photo?api_key=Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV")
        let request = URLRequest(url: url!)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )

        let task : URLSessionDataTask = session.dataTask(
            with: request as URLRequest,
            completionHandler: { (data, response, error) in
                if let data = data {
                    if let responseDictionary = try! JSONSerialization.jsonObject(
                        with: data, options:[]) as? NSDictionary {
                        //print("responseDictionary: \(responseDictionary)")

                        // Recall there are two fields in the response dictionary, 'meta' and 'response'.
                        // This is how we get the 'response' field
                        let responseFieldDictionary = responseDictionary["response"] as! NSDictionary

                        if let photosFetched = responseFieldDictionary["posts"] as? [NSDictionary] {
                            self.posts = photosFetched
                        }

                        self.photosTableView.reloadData()

                        // This is where you will store the returned array of posts in your posts property
                        // self.feeds = responseFieldDictionary["posts"] as! [NSDictionary]
                    }
                }
        });
        task.resume()

    }

    func refreshControlAction(control refreshControl: UIRefreshControl) -> Void {

        // Workaround to temp empty the table view
        self.posts = []
        photosTableView.reloadData()

        let url = URL(string:"https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/posts/photo?api_key=Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV")
        let request = URLRequest(url: url!)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )

        let task : URLSessionDataTask = session.dataTask(
            with: request as URLRequest,
            completionHandler: { (data, response, error) in
                if let data = data {
                    if let responseDictionary = try! JSONSerialization.jsonObject(
                        with: data, options:[]) as? NSDictionary {
                        //print("responseDictionary: \(responseDictionary)")

                        // Recall there are two fields in the response dictionary, 'meta' and 'response'.
                        // This is how we get the 'response' field
                        let responseFieldDictionary = responseDictionary["response"] as! NSDictionary

                        if let photosFetched = responseFieldDictionary["posts"] as? [NSDictionary] {
                            self.posts = photosFetched
                        }

                        self.photosTableView.reloadData()

                        refreshControl.endRefreshing()

                        // This is where you will store the returned array of posts in your posts property
                        // self.feeds = responseFieldDictionary["posts"] as! [NSDictionary]
                    }
                }
        });
        task.resume()
    }

    // MARK: Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoCell") as! PhotoCell

        let post = posts[indexPath.row]

        if let photos = post.value(forKeyPath: "photos") as? [NSDictionary] {

             let imageUrlString = photos[0].value(forKeyPath: "original_size.url") as? String

            if let imageUrl = URL(string: imageUrlString!) {

                cell.photoImageView.setImageWith(imageUrl)
            }

        }

        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        headerView.backgroundColor = UIColor(white: 1, alpha: 0.9)

        let profileView = UIImageView(frame: CGRect(x: 10, y: 10, width: 30, height: 30))
        profileView.clipsToBounds = true
        profileView.layer.cornerRadius = 15;
        profileView.layer.borderColor = UIColor(white: 0.7, alpha: 0.8).cgColor
        profileView.layer.borderWidth = 1;

        // set the avatar
        profileView.setImageWith(URL(string:"https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/avatar")!)
        headerView.addSubview(profileView)

        // Add a UILabel for the date here
        // Use the section number to get the right URL
        let textToDisplay = posts[section]["date"] as! String
        let labelField = UILabel(frame: CGRect(x: 50, y: 10, width: 100, height: 30))
        labelField.text = textToDisplay

        headerView.addSubview(labelField)

        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "PhotoFullScreen" {

            let vc = segue.destination as! PhotoDetailsViewController
            let indexPath = photosTableView.indexPath(for: sender as! PhotoCell)!

            let post = posts[indexPath.row]

            if let photos = post.value(forKeyPath: "photos") as? [NSDictionary] {

                let imageUrlString = photos[0].value(forKeyPath: "original_size.url") as? String

                if let imageUrl = URL(string: imageUrlString!) {
                    vc.photoURL = imageUrl
                }
            }

        }
    }

}
