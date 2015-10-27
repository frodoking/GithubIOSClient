//
//  UserDetailViewController.swift
//  Github
//
//  Created by frodo on 15/10/25.
//  Copyright © 2015年 frodo. All rights reserved.
//

import UIKit
import Alamofire

class UserDetailViewController: UIViewController, ViewPagerIndicatorDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var titleImageView: UIImageView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var emaiButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var blogButton: UIButton!
    @IBOutlet weak var companyLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var createLabel: UILabel!
    
    
    @IBOutlet weak var viewPagerIndicator: ViewPagerIndicator!
    @IBOutlet weak var tableView: UITableView!
    
    
    var viewModule: UserDetailViewModule?
    var array: NSArray? {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    var user: User? {
        didSet {
            self.title = user?.login
        }
    }
    
    private func updateUserInfo () {
        Alamofire.request(.GET, (user?.avatar_url)!)
            .responseData { response in
                NSLog("Fetch: Image: \(self.user!.avatar_url)")
                let imageData = UIImage(data: response.data!)
                self.titleImageView?.image = imageData
        }
        
        if let login = user!.login {
            loginButton.setTitle(login, forState:UIControlState.Normal)
        }
        
        if let email = user!.email {
            emaiButton.setTitle(email, forState:UIControlState.Normal)
        }
        
        if let name = user!.name {
            nameLabel.text = name
        }
        
        if let blog = user!.blog {
            blogButton.setTitle(blog, forState:UIControlState.Normal)
        }
        
        if let company = user!.company {
            companyLabel.text = company
        }
        
        if let location = user!.location {
            locationLabel.text = location
        }
        
        if let created_at = user!.created_at {
            createLabel.text = created_at
        }
    }
    
    @IBAction func backAction(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUserInfo()
        
        viewModule = UserDetailViewModule()
        
        viewPagerIndicator.titles = UserDetailViewModule.Indicator
        //监听ViewPagerIndicator选中项变化
        viewPagerIndicator.delegate = self
        
        viewPagerIndicator.setTitleColorForState(Theme.Color, state: UIControlState.Selected) //选中文字的颜色
        viewPagerIndicator.setTitleColorForState(UIColor.blackColor(), state: UIControlState.Normal) //正常文字颜色
        viewPagerIndicator.tintColor = Theme.Color //指示器和基线的颜色
        viewPagerIndicator.showBottomLine = true //基线是否显示
        viewPagerIndicator.autoAdjustSelectionIndicatorWidth = true//指示器宽度是按照文字内容大小还是按照count数量平分屏幕
        viewPagerIndicator.indicatorDirection = .Bottom//指示器位置
 
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        self.navigationController?.navigationBar.backgroundColor = Theme.Color
    

        // Do any additional setup after loading the view.
    }
}

// MARK: - ViewPagerIndicator
extension UserDetailViewController {
    // 点击顶部选中后回调
    func indicatorChange(indicatorIndex: Int) {
        viewModule?.loadDataFromApiWithIsFirst(true, currentIndex: indicatorIndex, userName: (user?.login)!,
            handler: { array in
                if array.count > 0 {
                    self.array = array
                }
        })
    }
}

// MARK: - UITableViewDataSource
extension UserDetailViewController {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return self.array!.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Key.CellReuseIdentifier.UserRankDetailCell, forIndexPath: indexPath)
        
//        if cell == nil {
//            let repositoriesCell = cell as! RankTableViewCell
//            repositoriesCell.user = self.array[indexPath.section]
//        }
        
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension UserDetailViewController {
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the specified item to be editable.
    return true
    }
    */
    
    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
    // Delete the row from the data source
    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    } else if editingStyle == .Insert {
    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    }
    */
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    
    }
    */
    
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the item to be re-orderable.
    return true
    }
    */
}

// MARK: - Navigation
extension UserDetailViewController {
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}


