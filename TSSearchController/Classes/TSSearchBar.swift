//
//  TSSearchBar.swift
//  LTSSearchController
//
//  Created by 李棠松 on 2018/1/31.
//  Copyright © 2018年 李棠松. All rights reserved.
//

import UIKit

func TS_RGB(_ red: CGFloat,_ green: CGFloat,_ blue: CGFloat,_ alpha: CGFloat = 1)->UIColor{
    return UIColor.init(red: red/255, green: green/255, blue: blue/255, alpha: alpha)
}
let kScreenW = UIScreen.main.bounds.size.width
let kScreenH = UIScreen.main.bounds.size.height

@objc public protocol TSSearchBarDelegate: NSObjectProtocol {
    @objc optional func searchBarTextDidBeginEditing(searchBar: TSSearchBar)
    @objc optional func searchBarTextDidEndEditing(searchBar: TSSearchBar)
    @objc optional func searchBar(searchBar: TSSearchBar,textDidChange searchText: String)
}

@objc public protocol TSSearchBarAnimationer{
    @objc optional func searchBarDidBeginEditingAnimation(searchBar: TSSearchBar)
    @objc optional func searchBarDidEndEditingAnimation(searchBar: TSSearchBar)
}
open class TSSearchBar: UIView {
    open var placeholder: String?
    open var text: String?
    open weak var animationer: TSSearchBarAnimationer?
    open weak var delegate: TSSearchBarDelegate?
    private lazy var backgroundImageView: UIImageView = UIImageView()
    lazy var textFieldContentView: UIView = UIView.init(frame: CGRect.init(x: 8, y: 0, width: frame.width-16, height: 35))
    private lazy var textField: TSSearchTextField = {
        let temp = TSSearchTextField()
        temp.frame = CGRect.init(x: 0, y: 0, width: textFieldContentView.frame.width, height: 35)
        temp.center = CGPoint.init(x: frame.width/2, y: frame.height/2)
        temp.layer.cornerRadius = 5
        temp.canTouch = false
        temp.clearButtonMode = .whileEditing
        temp.layer.masksToBounds = true
        temp.backgroundColor = .white
        temp.delegate = self
        temp.returnKeyType = .search
        temp.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        return temp
    }()
    var leftViewMode: UITextFieldViewMode = .never
    var RightViewMode: UITextFieldViewMode = .never
    var rightView: UIView?{
        willSet{
            rightView?.removeFromSuperview()
        }
        didSet{
            setupTextContentFrame()
        }
    }
    var leftView: UIView?{
        willSet{
            leftView?.removeFromSuperview()
        }
        didSet{
            setupTextContentFrame()
        }
    }
    
    private(set) var cancelButton: UIButton?
    var searchReturnAction: ((_ text: String?)->Void)?
    var cancelAction: (()->Void)?
    var isEditing = false{
        didSet{
            cancelButton?.isHidden = !isEditing
            textField.canTouch = isEditing
          _ = isEditing ? textField.becomeFirstResponder() : textField.resignFirstResponder()
            isEditing ? animationer?.searchBarDidBeginEditingAnimation?(searchBar: self) : animationer?.searchBarDidEndEditingAnimation?(searchBar: self)
            if !isEditing {
                self.textField.text = ""
                self.text = ""
            }
        }
    }
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: 0, y: 0, width: kScreenW, height: 55))
        backgroundColor = TS_RGB(230, 230, 230)
        addSubview(textFieldContentView)
        textFieldContentView.backgroundColor = .white
        textFieldContentView.layer.cornerRadius = 5
        textFieldContentView.addSubview(textField)
        let cancel = UIButton()
        cancel.frame = CGRect.init(x: frame.width, y: 0, width: 40, height: 44)
        cancel.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        cancel.setTitleColor(TS_RGB(85, 183, 55), for: .normal)
        cancel.setTitle("取消  ", for: .normal)
        cancel.isHidden = true
        cancel.addTarget(self, action: #selector(cancelButtonClick), for: .touchUpInside)
        addSubview(cancel)
        self.cancelButton = cancel
        let imageView = UIImageView.init(image: #imageLiteral(resourceName: "enlarge"))
        imageView.frame = CGRect.init(x: 0, y: 0, width: 30, height: 20)
        imageView.contentMode = .scaleAspectFit
        self.leftView = imageView
        self.leftViewMode = .always
        textFieldContentView.addObserver(self, forKeyPath: "frame", options: .new, context: nil)
        
    }
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        setupTextContentFrame()
    }
    private func setupTextContentFrame(){
        if leftView != nil{
            textFieldContentView.addSubview(leftView!)
        }
        if rightView != nil{
            textFieldContentView.addSubview(rightView!)
        }
        textField.frame = textFieldContentView.bounds
        leftView?.ts_x = 0
        leftView?.center = CGPoint.init(x: leftView?.center.x ?? 0, y: textFieldContentView.frame.height/2)
        rightView?.ts_x = textFieldContentView.frame.width-(rightView?.frame.width ?? 0)
       
        switch leftViewMode {
        case .always:
            leftView?.isHidden = false
            break
        case .never:
            leftView?.isHidden = true
            break
        case .unlessEditing:
            leftView?.isHidden = !((textField.text ?? "").count>0)
            break
        case .whileEditing:
            leftView?.isHidden = !self.textField.isFirstResponder
            break
        }
        
        switch RightViewMode {
        case .always:
            rightView?.isHidden = false
            break
        case .never:
            rightView?.isHidden = true
            break
        case .unlessEditing:
            rightView?.isHidden = !((textField.text ?? "").count>0)
            break
        case .whileEditing:
            rightView?.isHidden = !self.textField.isFirstResponder
            break
        }
        
        textField.ts_x = leftView?.isHidden == false ? (leftView?.frame.width ?? 0) : 0
        textField.ts_width = textFieldContentView.frame.width - (leftView?.isHidden == false ? (leftView?.frame.width ?? 0):0) - (rightView?.isHidden == false ? (rightView?.frame.width ?? 0):0)
        cancelButton?.center = CGPoint.init(x: cancelButton!.center.x, y: self.frame.height/2)
        
    }
    
    open override var frame: CGRect{
        didSet{
            textFieldContentView.frame = CGRect.init(x: 8, y: 0, width: frame.width-16, height: 35)
            textFieldContentView.center = CGPoint.init(x: frame.width/2, y: frame.height/2)
            if !isEditing{
                cancelButton?.frame = CGRect.init(x: frame.width, y: 0, width: 40, height: 44)
                cancelButton?.center = CGPoint.init(x: cancelButton!.center.x, y: self.frame.height/2)
            }
            setupTextContentFrame()
        }
    }
    @objc func cancelButtonClick(){
        if cancelAction == nil{
            self.textField.resignFirstResponder()
        }
        cancelAction?()
    }
    @objc func textFieldDidChange(){
        delegate?.searchBar?(searchBar: self, textDidChange: self.textField.text ?? "")
        setupTextContentFrame()
        self.text = self.textField.text
    }
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.textField.placeholder = self.placeholder
        cancelButton?.center = CGPoint.init(x: cancelButton!.center.x, y: self.frame.height/2)
    }
    deinit {
        self.textFieldContentView.removeObserver(self, forKeyPath: "frame")
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
extension TSSearchBar: UITextFieldDelegate{
    
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.searchBarTextDidBeginEditing?(searchBar: self)
        setupTextContentFrame()
        animationer?.searchBarDidBeginEditingAnimation?(searchBar: self)
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.searchReturnAction?(textField.text)
        return true
    }
    public func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.searchBarTextDidEndEditing?(searchBar: self)
        setupTextContentFrame()
        animationer?.searchBarDidEndEditingAnimation?(searchBar: self)

    }
}
