//
//  LensesViewController.swift
//  Zocus
//
//  Created by Akram Hussein on 26/07/2016.
//  Copyright © 2016 Akram Hussein. All rights reserved.
//

import UIKit
import RealmSwift

protocol LensesViewControllerDelegate
{
    func addLensButtonPressed(_ viewController: LensesViewController)
    
    func lensSelected(_ viewController: LensesViewController, lens: Lens)
    
    func lensDeleted(_ viewController: LensesViewController, lens: Lens)
    
    func lensEdited(_ viewController: LensesViewController, lens: Lens)
}

class LensesViewController: UIViewController
{
    // MARK: - UI Outlets
    
    @IBOutlet weak var addLensButton: UIButton! {
        didSet {
            self.addLensButton.setTitle("AddLens.Button".localized, for: UIControlState())
            self.addLensButton.setTitleColor(.appGray(), for: UIControlState())
            self.addLensButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13.0)
        }
    }
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            self.tableView.delegate = self
            self.tableView.dataSource = self
            self.tableView.separatorStyle = .singleLine
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
            return self.realm!.objects(Lens.self).sorted(byProperty: "name")
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
        self.edgesForExtendedLayout = .all
    }
    
    // MARK: - UI Actions
    @IBAction func addLensButtonPressed(_ sender: AnyObject)
    {
        log.info("Add lens button pressed")
        self.delegate?.addLensButtonPressed(self)
    }
}
