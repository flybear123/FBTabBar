//
//  FBTabBarItem.swift
//  Baby
//
//  Created by admin on 2021/2/20.
//  Copyright © 2021 OrangeTeam. All rights reserved.
//

import UIKit
import SnapKit

public enum FBTabBarItemState {
    case normal, selected
}

public protocol TabBarItem {
    func itemView() -> TabBarItemView
    var viewController: UIViewController { get }
}

public protocol TabBarItemViewProtocol {
    var itemState: FBTabBarItemState { get set }
    var badgeValue: String { get set }
    var clickAction: (() -> ())? { get set }
}

public typealias TabBarItemView = UIView & TabBarItemViewProtocol

public typealias ImageGetter = () -> UIImage?
public class FBTabBarItem: TabBarItem {
    
    public init(viewController: UIViewController,
                title: String? = nil,
                imageGetter: ImageGetter? = nil,
                selectedImageGetter: ImageGetter? = nil) {
        
        self.viewController = viewController
        self.title = title
        self.imageGetter = imageGetter
        self.selectedImageGetter = selectedImageGetter
        self.image = imageGetter?()
        self.selectedImage = selectedImageGetter?()
    }
    
    public func itemView() -> TabBarItemView {
        return FBTabBarItemView(item: self)
    }
    
    func updateImage() {
        self.image = imageGetter?()
        self.selectedImage = selectedImageGetter?()
    }
    
    public func setTextAttributes(_ attributes: [NSAttributedString.Key: Any], for state: FBTabBarItemState) {
        textAttributed[state] = attributes
    }
    
    //MARK: properties
    public let viewController: UIViewController
    
    public var layoutter: ((UIImageView, UILabel) -> ())?
    
    public var topMargin: CGFloat = 4.0
    public var itemPadding: CGFloat = 5.0
    public var imageSize: CGSize = CGSize(width: 24.0, height: 24.0)
    
    internal var image: UIImage?
    internal var selectedImage: UIImage?
    internal var title: String?
    public var imageGetter: ImageGetter?
    public var selectedImageGetter: ImageGetter?
    internal var textAttributed: [FBTabBarItemState: [NSAttributedString.Key: Any]] = [:]
}

public class FBTabBarItemView: UIControl, TabBarItemViewProtocol {
    
    public init(item: FBTabBarItem) {
        self.item = item
        super.init(frame: .zero)
        
        addTarget(self, action: #selector(onClickedSelf(_:)), for: .touchUpInside)
        
        refresh()
        setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func onClickedSelf(_ sender: Any) {
        clickAction?()
    }
    
    //MARK: private
    private func setupSubviews() {
        addSubview(iconView)
        addSubview(titleLabel)
        
        iconView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(item.topMargin)
            make.size.equalTo(item.imageSize)
            make.centerX.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(iconView.snp.bottom).offset(item.itemPadding)
            make.left.right.equalToSuperview().inset(5)
        }
        
    }
    
    public func refresh() {
        
        if itemState == .normal {
            iconView.image = item.image
        } else if itemState == .selected {
            iconView.image = item.selectedImage
        } else {
            //TODO: do nothing
        }
        
        guard let text = item.title else { return }
        let attributes = item.textAttributed[itemState]
        titleLabel.attributedText = NSAttributedString(string: text, attributes: attributes)
    }
    
    //MARK: properties
    public var itemState: FBTabBarItemState = .normal {
        didSet {
            guard itemState != oldValue else { return }
            refresh()
        }
    }
    
    public var badgeValue: String = ""   //TODO: 实现badge的功能
    
    public var clickAction: (() -> ())?
    
    public var item: FBTabBarItem
    
    lazy var iconView: UIImageView = {
        let v = UIImageView()
        v.clipsToBounds = true
        v.contentMode = .scaleAspectFill
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    lazy var titleLabel: UILabel = {
        let v = UILabel()
        v.font = UIFont.systemFont(ofSize: 10)
        v.textColor = UIColor.darkGray
        v.textAlignment = .center
        v.adjustsFontSizeToFitWidth = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
}
