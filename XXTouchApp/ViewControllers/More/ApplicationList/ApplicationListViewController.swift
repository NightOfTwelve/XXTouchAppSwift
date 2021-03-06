//
//  ApplicationListViewController.swift
//  XXTouchApp
//
//  Created by mcy on 16/6/21.
//  Copyright © 2016年 mcy. All rights reserved.
//

import UIKit

class ApplicationListViewController: UIViewController {
  private let tableView = UITableView(frame: CGRectZero, style: .Grouped)
  private var appList = [ApplicationListModel]()
  var funcCompletionHandler: FuncCompletionHandler
  private let type: FuncListType
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    if let indexPath = tableView.indexPathForSelectedRow {
      tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
  }
  
  init(type: FuncListType, funcCompletionHandler: FuncCompletionHandler = FuncCompletionHandler()) {
    self.type = type
    self.funcCompletionHandler = funcCompletionHandler
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    makeConstriants()
    setupAction()
    bind()
    fetchBundles()
  }
  
  private func setupUI() {
    view.backgroundColor = UIColor.whiteColor()
    navigationItem.title = "应用列表"
    
    tableView.delegate  = self
    tableView.dataSource = self
    tableView.registerClass(ApplicationListCell.self, forCellReuseIdentifier: NSStringFromClass(ApplicationListCell))
    tableView.backgroundColor = UIColor.whiteColor()
    
    view.addSubview(tableView)
  }
  
  private func makeConstriants() {
    tableView.snp_makeConstraints { (make) in
      make.edges.equalTo(view)
    }
  }
  
  private func setupAction() {
    
  }
  
  private func bind() {
    self.type == .Bid ? (navigationItem.title = self.funcCompletionHandler.titleNames.first) : (navigationItem.title = "应用列表")
  }
}

// 请求
extension ApplicationListViewController {
  private func fetchBundles() {
    self.view.showHUD(text: Constants.Text.reloading)
    Service.fetchBundlesList { [weak self] (data, _, error) in
      guard let `self` = self else { return }
      if let data = data where JSON(data: data) != nil {
        let json = JSON(data: data)
        self.view.dismissHUD()
        switch json["code"].intValue {
        case 0:
          let list = json["data"]
          for item in list.dictionaryValue {
            let model = ApplicationListModel(item.1, packageName: item.0)
            self.appList.append(model)
          }
        default:break
        }
        self.tableView.reloadData()
      }
      if error != nil {
        self.view.updateHUD(Constants.Error.failure)
        MixC.sharedManager.restart { (_) in
          self.fetchBundles()
        }
      }
    }
  }
}

extension ApplicationListViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return appList.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(ApplicationListCell), forIndexPath: indexPath) as! ApplicationListCell
    cell.bind(appList[indexPath.row])
    
    return cell
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if self.type == .Bid {
      let bid = appList[indexPath.row].packageName
      let string = JsManager.sharedManager.getCustomFunction(self.funcCompletionHandler.id, models: [[ : ]], bid: bid)
      self.funcCompletionHandler.completionHandler?(string)
      self.dismissViewControllerAnimated(true, completion: nil)
    } else {
      let applicationDetailViewController = ApplicationDetailViewController(model: appList[indexPath.row])
      self.navigationController?.pushViewController(applicationDetailViewController, animated: true)
    }
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return Sizer.valueForDevice(phone: 50, pad: 70)
  }
  
  func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 0.01
  }
  
  func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 0.01
  }
}
