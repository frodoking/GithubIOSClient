//
//  RepositoryDetailViewController.swift
//  Github
//
//  Created by frodo on 15/11/7.
//  Copyright © 2015年 frodo. All rights reserved.
//

import UIKit
import Alamofire

class RepositoryDetailViewController: UIViewController ,ViewPagerIndicatorDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var nameBt: UIButton!
    @IBOutlet weak var headImageView: UIImageView!
    @IBOutlet weak var createDateLabel: UILabel!
    @IBOutlet weak var homePageBt: UIButton!
    @IBOutlet weak var descLabel: UILabel!
    
    @IBOutlet weak var viewPagerIndicator: ViewPagerIndicator!
    @IBOutlet weak var tableView: UITableView!
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshAction:", forControlEvents: UIControlEvents.ValueChanged)
        return refreshControl
    }()
    
    
    var viewModule: RepositoryDetailViewModule?
    var tabIndex: Int = 0
    var array: NSArray? {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    var repository: Repository? {
        didSet {
            self.title = repository?.name
        }
    }
    
    private func updateRepositoryInfo () {
        if let _ = repository {
            if let avatar_url = repository?.owner!.avatar_url {
                Alamofire.request(.GET, avatar_url)
                    .responseData { response in
                        NSLog("Fetch: Image: \(avatar_url)")
                        let imageData = UIImage(data: response.data!)
                        self.headImageView?.image = imageData
                }
            }
            
            if let name = repository!.name {
                nameBt.setTitle("\((repository?.owner?.login)!)/\(name)", forState:UIControlState.Normal)
            }
            
            if let homePage = repository!.homepage {
                homePageBt.setTitle(homePage, forState:UIControlState.Normal)
            }
            
            if let created_at = repository!.created_at {
                createDateLabel.text = created_at
            }
            if let desc = repository!.repositoryDescription {
                descLabel.text = desc
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        self.edgesForExtendedLayout = UIRectEdge.None
        self.automaticallyAdjustsScrollViewInsets=false
        self.view.backgroundColor = Theme.WhiteColor
        
        self.navigationController?.navigationBar.backgroundColor = Theme.Color
        
        headImageView.layer.cornerRadius = 10
        headImageView.layer.borderColor = Theme.GrayColor.CGColor
        headImageView.layer.borderWidth = 0.3
        headImageView.layer.masksToBounds=true
        
        viewModule = RepositoryDetailViewModule()
        
        updateRepositoryInfo()
     
        viewPagerIndicator.titles = RepositoryDetailViewModule.Indicator
        //监听ViewPagerIndicator选中项变化
        viewPagerIndicator.delegate = self
        
        viewPagerIndicator.setTitleColorForState(Theme.Color, state: UIControlState.Selected) //选中文字的颜色
        viewPagerIndicator.setTitleColorForState(UIColor.blackColor(), state: UIControlState.Normal) //正常文字颜色
        viewPagerIndicator.tintColor = Theme.Color //指示器和基线的颜色
        viewPagerIndicator.showBottomLine = true //基线是否显示
        viewPagerIndicator.autoAdjustSelectionIndicatorWidth = true//指示器宽度是按照文字内容大小还是按照count数量平分屏幕
        viewPagerIndicator.indicatorDirection = .Bottom//指示器位置
        viewPagerIndicator.titleFont = UIFont.systemFontOfSize(14)
        
        self.tableView.addSubview(self.refreshControl)
        
        self.tableView.estimatedRowHeight = tableView.rowHeight
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        viewPagerIndicator.setSelectedIndex(tabIndex)
        refreshAction(refreshControl)
    }
    
    @IBAction func backAction(sender: UIBarButtonItem) {
        if let prevViewController = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)! - 2] {
            self.navigationController?.popToViewController(prevViewController, animated: true)
        } else {
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
    }
    
    func refreshAction(sender: UIRefreshControl) {
        self.refreshControl.beginRefreshing()
        
        if let _ = repository {
            viewModule?.loadDataFromApiWithIsFirst(true, currentIndex: tabIndex, userName: (repository?.owner?.login)!, repositoryName: (repository?.name)!,
                handler: { array in
                    self.refreshControl.endRefreshing()
                    
                    if array.count > 0 {
                        self.array = array
                    }
            })
        }
    }
}

// MARK: - ViewPagerIndicator
extension RepositoryDetailViewController {
    // 点击顶部选中后回调
    func indicatorChange(indicatorIndex: Int) {
        self.tabIndex = indicatorIndex
        switch indicatorIndex {
        case 0:
            self.array = viewModule!.contributorsDataSource.dsArray
            break
        case 1:
            self.array = viewModule!.forksDataSource.dsArray
            break
        case 2:
            self.array = viewModule!.stargazersDataSource.dsArray
            break
        default:break
        }
        
        self.refreshAction(self.refreshControl)
    }
}

// MARK: - UITableViewDataSource
extension RepositoryDetailViewController {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if array == nil {
            return 0
        }
        return self.array!.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Key.CellReuseIdentifier.UserCell, forIndexPath: indexPath) as! UserTableViewCell
        if let user = self.array![indexPath.section] as? User {
            cell.user = user
        } else if let repository = self.array![indexPath.section] as? Repository {
            cell.user = repository.owner
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return Theme.UserTableViewCellHeight
    }
}
// MARK: - Navigation
extension RepositoryDetailViewController {
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let viewController = segue.destinationViewController
        if let userDetailViewController = viewController as? UserDetailViewController {
            if let cell = sender as? UserTableViewCell {
                let selectedIndex = tableView.indexPathForCell(cell)?.section
                if let index = selectedIndex {
                    userDetailViewController.user = self.array![index] as? User
                }
            }
        }
    }
}



