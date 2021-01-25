//
//  MasterViewController.swift
//  Timer
//
//  Created by nuomi1 on 13/8/18.
//  Copyright © 2018年 nuomi1. All rights reserved.
//

import MJRefresh
import Reusable
import RxCocoa
import RxSwift
import UIKit

class MasterViewController: UITableViewController {
    private let addButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)

    private let disposeBag = DisposeBag()

    private var page = 1

    private var details = [Detail]() {
        didSet {
            tableView.reloadData()
        }
    }
}

// MARK: - UIViewController

extension MasterViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        prepareNavigationItem()
        prepareTableView()

        try? wcdb.create(table: R.string.localizable.databaseTablenameDetail(), of: Detail.self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tableView.mj_header?.beginRefreshing()
    }

    private func prepareNavigationItem() {
        navigationItem.title = R.string.localizable.masterViewTitle()

//        navigationItem.leftBarButtonItem = editButtonItem
        navigationItem.rightBarButtonItem = addButtonItem

        addButtonItem.rx.tap
            .bind { [weak self] in
                let vc = DetailViewController(model: nil)
                self?.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
    }

    private func prepareTableView() {
        tableView.register(cellType: UITableViewCell.self)

        tableView.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(loadData))
        tableView.mj_footer = MJRefreshBackNormalFooter(refreshingTarget: self, refreshingAction: #selector(loadMoreData))

        tableView.tableFooterView = UIView()
    }

    private func baseLoadData(page: Int, limit: Int = 30) -> [Detail] {
        if let model: [Detail] = try? wcdb.getObjects(fromTable: R.string.localizable.databaseTablenameDetail(), orderBy: [Detail.Properties.createTime.asOrder(by: .ascending)], limit: limit, offset: (page - 1) * limit), !model.isEmpty {
            tableView.mj_header?.endRefreshing()
            tableView.mj_footer?.endRefreshing()
            return model
        } else {
            tableView.mj_header?.endRefreshing()
            tableView.mj_footer?.endRefreshingWithNoMoreData()
            return []
        }
    }

    @objc
    private func loadData() {
        page = 1
        details = baseLoadData(page: page)
    }

    @objc
    private func loadMoreData() {
        page += 1
        details.append(contentsOf: baseLoadData(page: page))
    }
}

// MARK: - UITableViewDataSource

extension MasterViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return details.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: UITableViewCell.reuseIdentifier)
        let detail = details[indexPath.row]

        cell.selectionStyle = .none
        cell.textLabel?.text = detail.title
        cell.detailTextLabel?.text = detail.createTime.description
        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            try? wcdb.delete(fromTable: R.string.localizable.databaseTablenameDetail(), where: Detail.Properties.identify.like(details[indexPath.row].identify.uuidString))
            details.remove(at: indexPath.row)
        default:
            return
        }
    }
}

// MARK: - UITableViewDelegate

extension MasterViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detail = details[indexPath.row]
        let vc = DetailViewController(model: detail)
        navigationController?.pushViewController(vc, animated: true)
    }
}
