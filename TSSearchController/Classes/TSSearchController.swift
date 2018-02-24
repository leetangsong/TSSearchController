//
//  TSSearchController.swift
//  LTSSearchController
//
//  Created by 李棠松 on 2018/2/4.
//  Copyright © 2018年 李棠松. All rights reserved.
//

import UIKit

fileprivate var kNaviBarStatusBarHeight: CGFloat{
    return kiPhoneX ? 88:64
}
fileprivate var kStatusBarHeight: CGFloat{
    return kiPhoneX ? 44:20
}
fileprivate var kiPhoneX: Bool{
    return UIScreen.main.bounds.size.height == 812 && UIScreen.main.bounds.size.width == 375
}
@objc public protocol TSSearchControllerDelegate:NSObjectProtocol {
    @objc optional func willPresentSearchController(searchController: TSSearchController)
    @objc optional func didPresentSearchController(searchController: TSSearchController)
    @objc optional func willDismissSearchController(searchController: TSSearchController)
    @objc optional func didDismissSearchController(searchController: TSSearchController)
}
@objc public protocol TSSearchControllerhResultsUpdating: NSObjectProtocol {
    func updateSearchResultsForSearchController(searchController: TSSearchController)
    @objc optional func updateSearchResultsTextChangeForSearchController(searchController: TSSearchController)
}
open class TSSearchController: UIViewController {
    public var hidesNavigationBarDuringPresentation: Bool = true
    public var isShow: Bool = false
    public lazy var searchBar: TSSearchBar = {
        let temp = TSSearchBar()
        temp.frame = CGRect.init(x: 0, y: kStatusBarHeight+55, width: kScreenW, height: 55)
        temp.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(tapSearchBarAction)))
        temp.cancelAction = {[weak self] in
            self?.endSearch()
        }
        temp.searchReturnAction = {[weak self] text in
            self?.searchResultsUpdater?.updateSearchResultsForSearchController(searchController: self!)
            self?.view.endEditing(true)
        }
        temp.addObserver(self, forKeyPath: "text", options: .new, context: nil)
        return temp
    }()
    private var beginFrame: CGRect?
    private var frameInSuperView:CGRect?
    private weak var searchSuperView: UIView?
    public weak var delegate: TSSearchControllerDelegate?
    public weak var searchResultsUpdater: TSSearchControllerhResultsUpdating?
    public  private(set) weak var searchResultsController: UIViewController?
    var searchContentView: UIView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: kScreenW, height: kStatusBarHeight+55))
    lazy var bgView: UIVisualEffectView = {
        
        let effectView = UIVisualEffectView.init(effect: UIBlurEffect.init(style: .light))
        effectView.frame = CGRect.init(x: 0, y: kStatusBarHeight+55, width: kScreenW, height: kScreenH-(kStatusBarHeight+55))
        let temp = UIView.init(frame: effectView.bounds)
        temp.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        effectView.contentView.addSubview(temp)
        return effectView
    }()
    public init(searchResultsController: UIViewController?) {
        super.init(nibName: nil, bundle: nil)
        if searchResultsController != nil{
            self.addChildViewController(searchResultsController!)
        }
        
        self.searchResultsController = searchResultsController
    }
    weak var navi: UINavigationController?
    override open func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(searchContentView)
        view.addSubview(bgView)
        self.searchResultsController?.view.frame = bgView.bounds
        if let vc = searchResultsController {
            bgView.contentView.addSubview(vc.view)
            vc.view.backgroundColor = .clear
        }
        // Do any additional setup after loading the view.
    }
    
    @objc func tapSearchBarAction(){
        if self.searchBar.isEditing{
            return
        }
        isShow = true
        if self.searchSuperView == nil {
            self.searchSuperView = searchBar.superview
            self.beginFrame = searchBar.convert(searchBar.bounds, to: nil)
            self.frameInSuperView = searchBar.frame
        }
        self.delegate?.willPresentSearchController?(searchController: self)
        
        if let parentVC = self.searchBar.ts_viewController?.parent, parentVC.isKind(of: UINavigationController.self),hidesNavigationBarDuringPresentation{
            navi = parentVC as? UINavigationController
            navi?.topViewController?.view.addSubview(self.view)
            
            if navi?.topViewController?.childViewControllers.contains(self) == false{
                navi?.topViewController?.addChildViewController(self)
            }
            navi?.setNavigationBarHidden(true, animated: true)
        }else if let parentVC = self.searchBar.ts_viewController{
            parentVC.view.addSubview(self.view)
            if parentVC.childViewControllers.contains(self) == false{
                parentVC.addChildViewController(self)
            }
        }
        view.addSubview(searchBar)
        searchBar.frame = self.beginFrame!
        searchContentView.backgroundColor = searchBar.backgroundColor
        self.searchContentView.alpha = 1
        UIView.animate(withDuration: 0.25, animations: {
            self.bgView.alpha = 1
            if self.hidesNavigationBarDuringPresentation{
                self.searchBar.frame = CGRect.init(x: 0, y: kStatusBarHeight, width: kScreenW, height: 55)
                self.searchBar.textFieldContentView.ts_width = self.searchBar.frame.width-16-50
                self.searchBar.cancelButton?.ts_x = kScreenW-50
                self.searchContentView.backgroundColor = self.searchBar.barTintColor
            }
            self.delegate?.didPresentSearchController?(searchController: self)
        })
        searchBar.isEditing = true
        
        
    }
    
    public func endSearch(){
        isShow = false
        self.delegate?.willDismissSearchController?(searchController: self)
        self.searchBar.isEditing = false
        navi?.setNavigationBarHidden(false, animated: true)
        if self.searchSuperView?.isKind(of: UIScrollView.self) == true{
            self.searchBar.frame = self.frameInSuperView!
            self.searchSuperView?.addSubview(self.searchBar)
            self.view.removeFromSuperview()
            return
        }
        
        UIView.animate(withDuration: 0.2, animations: {
            self.bgView.alpha = 0
            self.searchContentView.alpha = 0
            self.delegate?.didDismissSearchController?(searchController: self)
            
            if self.hidesNavigationBarDuringPresentation, self.beginFrame != nil{
                self.searchBar.frame = self.beginFrame!
            }
        }) { _ in
            self.searchBar.frame = self.frameInSuperView!
            self.searchSuperView?.addSubview(self.searchBar)
            self.view.removeFromSuperview()
        }
    }
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
       self.searchResultsUpdater?.updateSearchResultsTextChangeForSearchController?(searchController: self)
    }
    deinit {
        self.searchBar.removeObserver(self, forKeyPath: "text")
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

