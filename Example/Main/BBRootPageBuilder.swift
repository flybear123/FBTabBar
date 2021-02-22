//
//  BBRootPageBuilder.swift
//  Baby
//
//  Created by admin on 2021/2/20.
//  Copyright © 2021 OrangeTeam. All rights reserved.
//

import UIKit
import FBTabBar
class BBRootPageBuilder: NSObject {

    public static let shared = BBRootPageBuilder()
    
    func creatRootViewController() -> UITabBarController {
        let tabItems = creatTabBarItems()
        let tabarController = FBTabBarController(items: tabItems)
        return tabarController
    }
    
    func creatTabBarItems() -> [TabBarItem] {
        let home = getHomeRootController()
        let homeItem = FBTabBarItem(viewController: home, title: "首页", imageGetter: { () -> UIImage? in
            return UIImage(named: "tabbar_home_inactive")
        }) { () -> UIImage? in
            return UIImage(named: "tabbar_home_active")
        }

        let profile = getProfileRootController()
        let profileItem = FBTabBarItem(viewController: profile, title: "我的", imageGetter: { () -> UIImage? in
            return UIImage(named: "tabbar_bookmark_inactive")
        }) { () -> UIImage? in
            return UIImage(named: "tabbar_bookmark_active")
        }

        let news = getNewsRootController()
        let newsItem = FBTabBarItem(viewController: news, title: "新闻", imageGetter: { () -> UIImage? in
            
            return UIImage(named: "tabbar_market_inactive")
        }) { () -> UIImage? in
            return UIImage(named: "tabbar_market_active")
        }
        
        return [homeItem, newsItem, profileItem]
        
    }
    
    // 首页
    private func getHomeRootController() -> UIViewController {
        let vc = BBHomePageViewController()
        
        return vc
    }

    // 我的
    private func getProfileRootController() -> UIViewController {
        let vc = BBProfileViewController()
        
        return vc
    }

    // 新闻
    private func getNewsRootController() -> UIViewController {
        let vc = BBKnowledgeViewController()
        
        return vc
    }

}
