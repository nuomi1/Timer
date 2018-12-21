//
//  DetailViewController.swift
//  Timer
//
//  Created by nuomi1 on 13/8/18.
//  Copyright © 2018年 nuomi1. All rights reserved.
//

import AVFoundation
import Eureka
import RxCocoa
import RxSwift
import SnapKit
import SVProgressHUD
import SwifterSwift
import SwiftIcons
import Then
import UIKit

class DetailViewController: FormViewController {
    private let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: nil)

    private lazy var barCodeRow = IntRow(R.string.localizable.detailBarcode()) {
        $0.title = $0.tag
        $0.placeholder = R.string.localizable.detailInput() + $0.tag!

        $0.value = model.barcode

        $0.add(rule: RuleRequired(msg: $0.placeholder!))

        ($0.formatter as? NumberFormatter)?.numberStyle = .none
    }
    .cellSetup { [weak self] cell, _ in
        guard let self = self else { return }

        let size = CGSize(width: 30, height: 30)

        let icon = UIImageView().then {
            $0.setIcon(icon: .fontAwesomeSolid(.camera), size: size)
            $0.contentMode = .center

            $0.isUserInteractionEnabled = true
            $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap(sender:))))
        }

        cell.addSubview(icon)

        icon.snp.makeConstraints {
            $0.right.equalToSuperview().inset(15)
            $0.left.equalTo(cell.textField.snp.right).offset(8)
            $0.size.equalTo(size)
            $0.centerY.equalToSuperview()
        }
    }

    private lazy var titleRow = TextRow(R.string.localizable.detailTitle()) {
        $0.title = $0.tag
        $0.placeholder = R.string.localizable.detailInput() + $0.tag!

        $0.value = model.title

        $0.add(rule: RuleRequired(msg: $0.placeholder!))
    }

    private lazy var createTimeRow = DateInlineRow(R.string.localizable.detailCreatetime()) {
        $0.title = $0.tag

        $0.value = model.createTime
    }
    .onChange { [weak self] row in
        guard let value = row.value else { return }
        self?.expireTimeRow.remove(ruleWithIdentifier: R.string.localizable.detailExpiretimeRule())
        self?.expireTimeRow.add(rule: RuleGreaterOrEqualThan(min: value, id: R.string.localizable.detailExpiretimeRule()))
        self?.expireTimeRow.validate()
    }

    private lazy var expireTimeRow = DateInlineRow(R.string.localizable.detailExpiretime()) {
        $0.title = $0.tag

        $0.value = model.expireTime
    }
    .onExpandInlineRow { [weak self] _, inlineRow, _ in
        guard let value = self?.createTimeRow.value else { return }
        inlineRow.remove(ruleWithIdentifier: R.string.localizable.detailExpiretimeRule())
        inlineRow.add(rule: RuleGreaterOrEqualThan(min: value, id: R.string.localizable.detailExpiretimeRule()))
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

    private lazy var noteRow = LabelRow(R.string.localizable.detailNote()) {
        $0.title = $0.tag
    }

    private lazy var noteInputRow = TextAreaRow(R.string.localizable.detailNoteinput()) {
        $0.title = $0.tag
        $0.placeholder = $0.tag

        $0.value = model.note
    }

    private lazy var imagePickerController = UIImagePickerController().then {
        $0.sourceType = .camera
        $0.delegate = self
    }

    private let disposeBag = DisposeBag()

    var model = Detail.default

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
        print(self, Date())
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setFormDefaultMethod()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsetFormDefaultMethod()
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
                    self.model.title = self.titleRow.title!
                    self.model.createTime = self.createTimeRow.value!
                    self.model.expireTime = self.expireTimeRow.value!
                    self.model.url = self.urlRow.value
                    self.model.note = self.noteInputRow.value
                } else {
                    let message = validationErrors.map { $0.msg }.joined(separator: "\n")
                    SVProgressHUD.showError(withStatus: message)
                }
            }
            .disposed(by: disposeBag)
    }

    private func prepareForm() {
        form
            +++ Section()

//                {
//                $0.header = HeaderFooterView<UIView>(.callback { UIView(frame: .zero) })
//                $0.header?.height = { 0 }
//            }

            <<< barCodeRow
            <<< titleRow
            <<< createTimeRow
            <<< expireTimeRow
            <<< typeRow
            <<< urlRow
            <<< noteRow
            <<< noteInputRow

        form.allRows.forEach {
            $0.validationOptions = .validatesOnChange
        }
    }

    private func setFormDefaultMethod() {
        IntRow.defaultCellUpdate = { cell, row in
            if !row.isValid {
                cell.titleLabel?.textColor = .red
            }
        }

        TextRow.defaultCellUpdate = { cell, row in
            if !row.isValid {
                cell.titleLabel?.textColor = .red
            }
        }

        URLRow.defaultCellUpdate = { cell, row in
            if !row.isValid {
                cell.titleLabel?.textColor = .red
            }
        }

        DateInlineRow.defaultCellUpdate = { cell, row in
            if !row.isValid {
                cell.textLabel?.textColor = .red
            }
        }
    }

    private func unsetFormDefaultMethod() {
        IntRow.defaultCellUpdate = nil
        TextRow.defaultCellUpdate = nil
        URLRow.defaultCellUpdate = nil
        DateInlineRow.defaultCellUpdate = nil
    }

    @objc
    private func handleTap(sender: UITapGestureRecognizer) {
        guard checkCamera() else { return }
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else { return }
        guard UIImagePickerController.isCameraDeviceAvailable(.rear) else { return }

        present(imagePickerController, animated: true, completion: nil)
    }

    private func checkCamera() -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { _ in }
            return false
        case .restricted, .denied:
            guard
                let url = URL(string: UIApplication.openSettingsURLString),
                UIApplication.shared.canOpenURL(url)
            else { return false }

            UIApplication.shared.open(url, options: [:], completionHandler: nil)

            return false
        case .authorized:
            return true
        }
    }
}

// MARK: UIImagePickerControllerDelegate

extension DetailViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        defer {
            picker.dismiss(animated: true, completion: nil)
        }

        guard
            let uiImage = info[.originalImage] as? UIImage,
            let ciImage = CIImage(image: uiImage),
            let qrCodeDetector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: nil),
            let qrCodeFeatures = qrCodeDetector.features(in: ciImage) as? [CIQRCodeFeature]
        else { return }

        print(qrCodeFeatures.count)

        for feature in qrCodeFeatures {
            print(feature.messageString ?? "ERROR")
        }
    }
}

// MARK: UINavigationControllerDelegate

extension DetailViewController: UINavigationControllerDelegate {}
