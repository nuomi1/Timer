//
//  MasterViewController.swift
//  Timer
//
//  Created by nuomi1 on 13/8/18.
//  Copyright © 2018年 nuomi1. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

class MasterViewController: UITableViewController {
    private let addButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)

    private let disposeBag = DisposeBag()

    var details = [Detail]()
}

// MARK: - UIViewController

extension MasterViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        prepareNavigationItem()
    }

    private func prepareNavigationItem() {
        navigationItem.title = R.string.localizable.masterViewTitle()

        navigationItem.leftBarButtonItem = editButtonItem
        navigationItem.rightBarButtonItem = addButtonItem

        addButtonItem.rx.tap
            .bind { [weak self] in
                let vc = DetailViewController(model: nil)
                self?.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - UITableViewDataSource

extension MasterViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return details.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Master.Cell", for: indexPath)
        let detail = details[indexPath.row]
        let time = Calendar.current.dateComponents([.day], from: Date(), to: Date().addingTimeInterval(10000))

        cell.textLabel?.text = detail.title
        cell.detailTextLabel?.text = time.day?.description
        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            print(#function, "delete")
            details.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        case .insert:
            print(#function, "insert")
        default:
            return
        }
    }
}
