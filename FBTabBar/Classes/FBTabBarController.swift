//
//  FBTabBarController.swift
//  Baby
//
//  Created by admin on 2021/2/20.
//  Copyright © 2021 OrangeTeam. All rights reserved.
//

import UIKit

public protocol TabBarSubController {
    func shouldDisplay() -> Bool
    func onTabBarItemClicked(_ controller: FBTabBarController)
    func tabBarController(_ controller: FBTabBarController, didSwitchToSelfFrom index: Int)
}

extension TabBarSubController {
    func shouldDisplay() -> Bool {
        return true
    }
    
    func onTabBarItemClicked(_ controller: FBTabBarController) { }
    func tabBarController(_ controller: FBTabBarController, didSwitchToSelfFrom index: Int) { }
}


open class FBTabBarController: UITabBarController, FBTabBarDelegate {
    
    public init(items: [TabBarItem]) {
        self.items = items
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        object_setClass(tabBar, FBUITabBar.classForCoder())
        
        setupSubviews()
        setupSubItems()
    }
    
    
    public func getItemView(at index: Int) -> TabBarItemView? {
        return fb_tabBar.itemView(at: index)
    }
    
    public func setTabBarTopLineColor(_ color: UIColor) {
        fb_tabBar.setTopLineColor(color)
    }
    
    public func setTabBarTopLineView(_ lineView: UIView) {
        fb_tabBar.setTopLineView(lineView)
    }
    
    public func setTabBarBackgroundColor(_ color: UIColor) {
        fb_tabBar.backgroundColor = color
    }
    
    //MARK: FBTabBarDelegate
    func tabBar(_ bar: FBTabBar, didClickedItemAt index: Int) {
        let topVC = topViewControllerForItem(at: index)
        topVC?.onTabBarItemClicked(self)
        
        selectedIndex = index
    }
    
    //MARK: private
    private func setupSubviews() {
        tabBar.isTranslucent = true
        
        guard let bar = tabBar as? FBUITabBar else { return }
        bar.customTabBar = fb_tabBar
    }
    
    private func setupSubItems() {
        //先设置tabbar的Items
        fb_tabBar.setTabBarItems(items)
        tabBar.bringSubview(toFront: fb_tabBar)
        
        //再设置viewControllers，设置viewControllers会触发selectedIndex = 0
        let viewControllers = items.map { $0.viewController }
        self.viewControllers = viewControllers
    }
    
    
    private func shouldSwitchToItem(at index: Int) -> Bool {
        let topVC = topViewControllerForItem(at: index)
        return topVC?.shouldDisplay() ?? true
    }
    
    private func topViewControllerForItem(at index: Int) -> TabBarSubController? {
        guard index < viewControllers?.count ?? 0 else { return nil }
        
        let controller = viewControllers?[index]
        
        if let subVC = controller as? TabBarSubController {
            return subVC
        } else if let nav = controller as? UINavigationController {
            return nav.topViewController as? TabBarSubController
        } else {
            return nil
        }
    }
    //MARK: property
    private var _selectedIndex: Int = NSNotFound
    
    override public var selectedIndex: Int {
        get {
            return _selectedIndex
        }
        set {
            guard newValue != selectedIndex else { return }
            
            guard newValue < viewControllers?.count ?? 0 else {
         
                return
            }
            
            if selectedIndex == NSNotFound {
                
                //首次设置，默认可切到目标Tab，初始化处理
                _selectedIndex = newValue
                fb_tabBar.selectedIndex = newValue
                selectedViewController = viewControllers?[newValue]
                
            } else if shouldSwitchToItem(at: newValue) {
                
                //可以切换Tab
                let oldIndex = selectedIndex
                _selectedIndex = newValue
                
                fb_tabBar.selectedIndex = newValue
                selectedViewController = viewControllers?[newValue]
                
                let topVC = topViewControllerForItem(at: newValue)
                topVC?.tabBarController(self, didSwitchToSelfFrom: oldIndex)
                
            } else {
                //不可切换do nothing
            }
        }
    }
    
    public lazy var fb_tabBar: FBTabBar = {
       let bar = FBTabBar()
        bar.delegate = self
        bar.backgroundColor = UIColor.white
       return bar
    }()
    
    
    private(set) var items: [TabBarItem] = []
}
