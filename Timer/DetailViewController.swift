//
//  DetailViewController.swift
//  Timer
//
//  Created by nuomi1 on 13/8/18.
//  Copyright © 2018年 nuomi1. All rights reserved.
//

import AVFoundation
import BarcodeScanner
import Eureka
import RxCocoa
import RxSwift
import SnapKit
import SVProgressHUD
import SwifterSwift
import SwiftIcons
import Then
import UIKit
import UserNotifications

class DetailViewController: FormViewController {
    private let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: nil)

    private lazy var section = Section {
        $0.tag = R.string.localizable.detailSection()
    }

    private lazy var barCodeRow = IntRow(R.string.localizable.detailBarcode()) {
        $0.title = $0.tag
        $0.placeholder = R.string.localizable.detailTextRequired($0.tag!)

        $0.value = model.barcode

        $0.add(rule: RuleRequired(msg: $0.placeholder!))

        ($0.formatter as? NumberFormatter)?.numberStyle = .none
    }
    .cellSetup { [weak self] cell, _ in
        guard let self = self else { return }

        let size = CGSize(width: 30, height: 30)

        let icon = UIButton(type: .custom).then {
            $0.setIcon(icon: .fontAwesomeSolid(.camera), forState: .normal)
        }

        icon.rx.tap
            .bind {
                self.handleTap(nil)
            }
            .disposed(by: self.disposeBag)

        cell.addSubview(icon)

        icon.snp.makeConstraints {
            $0.right.equalToSuperview().inset(15)
            $0.left.equalTo(cell.textField.snp.right).offset(8)
            $0.size.equalTo(size)
            $0.centerY.equalToSuperview()
        }
    }
    .cellUpdate { cell, row in
        if !row.isValid {
            cell.titleLabel?.textColor = .red
        }
    }

    private lazy var titleRow = TextRow(R.string.localizable.detailTitle()) {
        $0.title = $0.tag
        $0.placeholder = R.string.localizable.detailTextRequired($0.tag!)

        $0.value = model.title

        $0.add(rule: RuleRequired(msg: $0.placeholder!))
    }
    .cellUpdate { cell, row in
        if !row.isValid {
            cell.titleLabel?.textColor = .red
        }
    }

    private lazy var createTimeRow = DateInlineRow(R.string.localizable.detailCreatetime()) {
        $0.title = $0.tag

        $0.value = model.createTime
    }
    .onChange { [weak self] row in
        guard let value = row.value else { return }
        let dateString = value.dateString(ofStyle: self!.expireTimeRow.dateFormatter!.dateStyle)
        let message = R.string.localizable.detailDateGreaterOrEqualThan(dateString)
        self?.expireTimeRow.remove(ruleWithIdentifier: R.string.localizable.detailExpiretimeRule())
        self?.expireTimeRow.add(rule: RuleGreaterOrEqualThan(min: value, msg: message, id: R.string.localizable.detailExpiretimeRule()))
        self?.expireTimeRow.validate()
    }
    .cellUpdate { cell, row in
        if !row.isValid {
            cell.textLabel?.textColor = .red
        }
    }

    private lazy var expireTimeRow = DateInlineRow(R.string.localizable.detailExpiretime()) {
        $0.title = $0.tag

        $0.value = model.expireTime
    }
    .onExpandInlineRow { [weak self] _, _, _ in
//        guard let value = self?.createTimeRow.value else { return }
//        let dateString = value.dateString(ofStyle: inlineRow.dateFormatter!.dateStyle)
//        let message = R.string.localizable.detailDateGreaterOrEqualThan(dateString)
//        inlineRow.remove(ruleWithIdentifier: R.string.localizable.detailExpiretimeRule())
//        inlineRow.add(rule: RuleGreaterOrEqualThan(min: value, msg: message, id: R.string.localizable.detailExpiretimeRule()))
    }
    .onChange { [weak self] _ in
        self?.notificationRow.evaluateDisabled()
    }
    .cellUpdate { cell, row in
        if !row.isValid {
            cell.textLabel?.textColor = .red
        }
    }

    private lazy var notificationRow = SwitchRow(R.string.localizable.detailNotification()) {
        $0.title = $0.tag

        $0.value = model.notification

//        $0.disabled = .function([]) { [weak self] _ in
//            (self?.expireTimeRow.value ?? Date(timeIntervalSince1970: 0)) < Date()
//        }
    }

    private lazy var typeRow = PickerInlineRow<Category>(R.string.localizable.detailType()) {
        $0.title = $0.tag
        $0.options = Category.allCases

        $0.value = model.type

        $0.displayValueFor = { category in
            guard let category = category else { return nil }

            switch category {
            case .towel:
                return R.string.localizable.detailCategoryTowel()
            case .underwear:
                return R.string.localizable.detailCategoryUnderwear()
            case .toothbrush:
                return R.string.localizable.detailCategoryToothbrush()
            case .none:
                return R.string.localizable.detailCategoryNone()
            }
        }
    }

    private lazy var urlRow = URLRow(R.string.localizable.detailUrl()) {
        $0.title = $0.tag

        $0.value = model.url
    }
    .cellUpdate { cell, row in
        if !row.isValid {
            cell.titleLabel?.textColor = .red
        }
    }

    private lazy var noteRow = LabelRow(R.string.localizable.detailNote()) {
        $0.title = $0.tag
    }

    private lazy var noteInputRow = TextAreaRow(R.string.localizable.detailNoteinput()) {
        $0.title = $0.tag
        $0.placeholder = $0.tag

        $0.value = model.note
    }

    private lazy var barcodeScannerViewController = BarcodeScannerViewController().then {
        $0.codeDelegate = self
        $0.errorDelegate = self
        $0.dismissalDelegate = self
    }

    private let disposeBag = DisposeBag()

    private var model = Detail.default

    init(model: Detail?) {
        if let model = model {
            self.model = model
        }

        super.init(style: .plain)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        debug { print(self, Date()) }
    }
}

// MARK: - UIViewController

extension DetailViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        prepareNavigationItem()
        prepareForm()

        tableView.tableFooterView = UIView()
    }

    private func prepareNavigationItem() {
        navigationItem.title = R.string.localizable.detailViewTitle()

        navigationItem.rightBarButtonItem = doneBarButton

        doneBarButton.rx.tap
            .bind { [weak self] in
                guard let self = self else { return }

                let validationErrors = self.form.validate()

                if validationErrors.isEmpty {
                    self.model.barcode = self.barCodeRow.value!
                    self.model.title = self.titleRow.value!
                    self.model.createTime = self.createTimeRow.value!
                    self.model.expireTime = self.expireTimeRow.value!
                    self.model.notification = self.notificationRow.value ?? false
                    self.model.type = self.typeRow.value ?? Category.none
                    self.model.url = self.urlRow.value
                    self.model.note = self.noteInputRow.value

                    try? wcdb.insertOrReplace(objects: self.model, intoTable: R.string.localizable.databaseTablenameDetail())

                    SVProgressHUD.showSuccess(withStatus: R.string.localizable.detailSaveSuccess())

                    if self.model.notification {
                        self.addNotification(with: self.model)
                    } else {
                        self.removeNotification(with: self.model)
                    }

                    self.navigationController?.popViewController(animated: true)
                } else {
                    let message = validationErrors.map { $0.msg }.joined(separator: "\n")
                    SVProgressHUD.showError(withStatus: message)
                }
            }
            .disposed(by: disposeBag)
    }

    private func prepareForm() {
        form
            +++ section
            <<< barCodeRow
            <<< titleRow
            <<< createTimeRow
            <<< expireTimeRow
            <<< typeRow
            <<< urlRow
            <<< noteRow
            <<< noteInputRow

        UNUserNotificationCenter.current().getNotificationSettings { [weak self] in
            guard let self = self else { return }

            switch $0.authorizationStatus {
            case .authorized, .provisional:
                DispatchQueue.main.async {
                    let section = self.form.sectionBy(tag: R.string.localizable.detailSection())
                    try? section?.insert(row: self.notificationRow, after: self.expireTimeRow)
                }
            case .notDetermined, .denied:
                break
            @unknown default:
                break
            }
        }

        form.allRows.forEach {
            $0.validationOptions = .validatesOnChange
        }
    }

    private func addNotification(with model: Detail) {
        let content = UNMutableNotificationContent()
        content.body = R.string.localizable.notificationBody(model.title)
        content.badge = 1

//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour], from: model.expireTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

        let request = UNNotificationRequest(identifier: model.identify.uuidString, content: content, trigger: trigger)

        removeNotification(with: model)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

    private func removeNotification(with model: Detail) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [model.identify.uuidString])
    }

    private func handleTap(_ sender: UITapGestureRecognizer?) {
        barcodeScannerViewController.reset(animated: false)
        present(barcodeScannerViewController, animated: true, completion: nil)
    }
}

// MARK: - BarcodeScannerCodeDelegate

extension DetailViewController: BarcodeScannerCodeDelegate {
    func scanner(_ controller: BarcodeScannerViewController, didCaptureCode code: String, type: String) {
        guard type == AVMetadataObject.ObjectType.code128.rawValue, let barCode = Int(code) else {
            controller.resetWithError(message: "不是条形码")
            return
        }

        barCodeRow.value = barCode
        barCodeRow.reload()
        controller.dismiss(animated: true, completion: nil)
    }
}

// MARK: - BarcodeScannerErrorDelegate

extension DetailViewController: BarcodeScannerErrorDelegate {
    func scanner(_ controller: BarcodeScannerViewController, didReceiveError error: Error) {
        controller.resetWithError(message: error.localizedDescription)
    }
}

// MARK: - BarcodeScannerDismissalDelegate

extension DetailViewController: BarcodeScannerDismissalDelegate {
    func scannerDidDismiss(_ controller: BarcodeScannerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
