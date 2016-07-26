//
//  LensesViewController.swift
//  Zocus
//
//  Created by Akram Hussein on 26/07/2016.
//  Copyright © 2016 Akram Hussein. All rights reserved.
//

import UIKit
import RealmSwift
import CocoaLumberjack

protocol LensesViewControllerDelegate
{
    func addLensButtonPressed(viewController: LensesViewController)
    
    func lensSelected(viewController: LensesViewController, lens: Lens)
    
    func lensDeleted(viewController: LensesViewController, lens: Lens)
    
    func lensEdited(viewController: LensesViewController, lens: Lens)
}

class LensesViewController: UIViewController
{
    // MARK: - UI Outlets
    
    @IBOutlet weak var addLensButton: UIButton! {
        didSet {
            self.addLensButton.setTitle("AddLens.Button".localized, forState: .Normal)
            self.addLensButton.setTitleColor(.appGray(), forState: .Normal)
            self.addLensButton.titleLabel?.font = UIFont.boldSystemFontOfSize(13.0)
        }
    }
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            self.tableView.delegate = self
            self.tableView.dataSource = self
            self.tableView.separatorStyle = .SingleLine
            self.tableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
            self.tableView.tableFooterView = UIView(frame: .zero)
            self.tableView.allowsMultipleSelection = false
        }
    }
    
    // TableView Properties
    let LensCellIdentifier = "LensCellIdentifier"
    
    // MARK: - Data
    var realm : Realm!
    var lenses : Results<Lens> {
        get {
            return self.realm!.objects(Lens).sorted("name")
        }
    }
    
    // MARK: - Delegate
    var delegate : LensesViewControllerDelegate?
    
    // MARK: - View Controller Lifecycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Remove space between tableview and top
        self.automaticallyAdjustsScrollViewInsets = false
        
        // Compensate for hidden nav bar by extending the scroll view
        self.edgesForExtendedLayout = .All
    }
    
    // MARK: - UI Actions
    @IBAction func addLensButtonPressed(sender: AnyObject)
    {
        DDLogInfo("Add lens button pressed")
        self.delegate?.addLensButtonPressed(self)
    }
}
