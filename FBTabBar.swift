//
//  FBTabBar.swift
//  Baby
//
//  Created by admin on 2021/2/20.
//  Copyright © 2021 OrangeTeam. All rights reserved.
//

import UIKit

protocol FBTabBarDelegate: class {
    func tabBar(_ bar: FBTabBar, didClickedItemAt index: Int)
}

public class FBTabBar: UIView {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setTabBarItems(_ items: [TabBarItem]) {
        itemViews = items.map({ $0.itemView() })
        refresh()
    }
    
    func insertTabBarItem(_ item: TabBarItem, at index: Int) {
        let itemView = item.itemView()
        if index >= 0 && index <= itemViews.endIndex {
            itemViews.insert(itemView, at: index)
        } else {
            itemViews.append(itemView)
        }
        
        refresh()
        
    }
    
    func setTopLineColor(_ color: UIColor) {
        topLineView.backgroundColor = color
        topLineView.subviews.forEach { $0.removeFromSuperview() }
    }
    
    func setTopLineView(_ lineView: UIView) {
        topLineView.subviews.forEach { $0.removeFromSuperview() }
        lineView.translatesAutoresizingMaskIntoConstraints = false
        topLineView.addSubview(lineView)
        
        let viewDict: [String: UIView] = ["line": lineView]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[line]|", options: [], metrics: nil, views: viewDict))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[line]|", options: [], metrics: nil, views: viewDict))
    }
    
    func itemView(at index: Int) -> TabBarItemView? {
        guard index < itemViews.count else {
            return nil
        }
        return itemViews[index]
    }
    
    func setupSubviews() {
        addSubview(contentView)
        addSubview(topLineView)
        
        let viewDic: [String: UIView] = ["content": contentView, "topLine": topLineView]
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[topLine]|", options: [], metrics: nil, views: viewDic))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0.5-[topLine(0.5)]", options: [], metrics: nil, views: viewDic))
        
        if #available(iOS 11, *) {
            
            contentView.topAnchor.constraint(equalTo: topAnchor).isActive = true
            contentView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[content]|", options: [], metrics: nil, views: viewDic))
            
        } else {
            
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[content]|", options: [], metrics: nil, views: viewDic))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[content]|", options: [], metrics: nil, views: viewDic))
        }
    }
    
    private func refresh() {
        for index in 0..<itemViews.endIndex {
            
            itemViews[index].clickAction = { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.onItemViewClicked(index)
            }
            
            itemViews[index].removeFromSuperview()
            itemViews[index].translatesAutoresizingMaskIntoConstraints = false
        }
        
        layoutItemViews()
    }
    
    
    private func layoutItemViews() {
        guard !itemViews.isEmpty else { return }
        
        var lastView: UIView? = nil
        let widthFactor: CGFloat = 1.0 / CGFloat(itemViews.count)
        
        for itemView in itemViews {
            let viewDic: [String: UIView] = ["item": itemView]
            contentView.addSubview(itemView)
            
            contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[item]|", options: [], metrics: nil, views: viewDic))
            contentView.addConstraint(NSLayoutConstraint(item: itemView,
                                                         attribute: .width,
                                                         relatedBy: .equal,
                                                         toItem: contentView,
                                                         attribute: .width,
                                                         multiplier: widthFactor,
                                                         constant: 0))
            
            if let lastV = lastView {
                contentView.addConstraint(NSLayoutConstraint(item: itemView,
                                                             attribute: .leading,
                                                             relatedBy: .equal,
                                                             toItem: lastV,
                                                             attribute: .trailing,
                                                             multiplier: 1.0,
                                                             constant: 0))
            } else {
                contentView.addConstraint(NSLayoutConstraint(item: itemView,
                                                             attribute: .leading,
                                                             relatedBy: .equal,
                                                             toItem: contentView,
                                                             attribute: .leading,
                                                             multiplier: 1.0,
                                                             constant: 0))
            }
            
            lastView = itemView
        }
    }
    
    private func onItemViewClicked(_ index: Int) {
        delegate?.tabBar(self, didClickedItemAt: index)
    }
    
//    func setTabBarItems(_ items: [Tab])
    //MARK: property
    weak var delegate: FBTabBarDelegate?
    
    var selectedIndex: Int = 0 {
        didSet {
            for i in 0..<itemViews.endIndex {
                itemViews[i].itemState = i == selectedIndex ? .selected : .normal
            }
        }
    }
    
    var selectedItemView: TabBarItemView? {
        guard selectedIndex < itemViews.count else { return nil }
        return itemViews[selectedIndex]
    }
    
    private lazy var topLineView: UIView = {
        let line = UIView()
        line.backgroundColor = UIColor(red: 212.0 / 255.0, green: 212.0 / 255.0, blue: 212.0 / 255.0, alpha: 1)
        line.translatesAutoresizingMaskIntoConstraints = false
        return line
    }()
    
    public var itemViews: [TabBarItemView] = []
    private lazy var contentView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
}

private var kCustomTabBarKey: UInt = 0

class FBUITabBar: UITabBar {
    deinit {
        customTabBar = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        removeOtherSubViews()
    }
    
    func removeOtherSubViews() {
        subviews.forEach {
            if $0 != customTabBar {
                $0.removeFromSuperview()
            }
        }
    }
    
    private func addCustomizedTabBar() {
        guard let bar = customTabBar else { return }
        addSubview(bar)
        bar.frame = bounds
        bar.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    var customTabBar: FBTabBar? {
        get {
            return objc_getAssociatedObject(self, &kCustomTabBarKey) as? FBTabBar
        }
        
        set {
            objc_setAssociatedObject(self, &kCustomTabBarKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            addCustomizedTabBar()
        }
    }
}
