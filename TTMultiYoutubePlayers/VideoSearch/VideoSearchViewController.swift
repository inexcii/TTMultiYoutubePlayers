//
//  VideoSearchViewController.swift
//  TTMultiYoutubePlayers
//
//  Created by Yuan Zhou on 2019/10/07.
//  Copyright © 2019 GEN SHU. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol VideoSearchViewControllerDelegate: class {
    func didChooseVideo(_ entity: YoutubeEntity, source button: UIButton?)
}

class VideoSearchViewController: UIViewController {
    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var searchTextField: UITextField!

    let disposeBag = DisposeBag()
    let playlistFactory = VideoPlaylistFactory()
    var selectedVideoEntity: YoutubeEntity!
    weak var delegate: VideoSearchViewControllerDelegate?
    var sourceButton: UIButton?
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // dark-mode対応
        if #available(iOS 13, *) {
            searchTextField.backgroundColor = UIColor.systemGray5
            searchTextField.attributedPlaceholder = NSAttributedString(string: searchTextField.placeholder ?? "",
                                                                       attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
        }

        bindData()
        bindUI()
    }
    
    // MARK: - IBActions
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        dismiss(animated: true) {
            print("search VC dismissed")
        }
    }
    
    // MARK: - Private
    
    private func bindData() {
        self.playlistFactory
            .result
            .bind(to: self.tableview.rx.items) { tableView, row, element in
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: R.reuseIdentifier.videoSearchTableViewCell,
                    for: IndexPath(row: row, section: 0)) else {
                        return UITableViewCell()
                }
                
                cell.configure(by: element)
                return cell
            }
            .disposed(by: disposeBag)
    }
    
    private func bindUI() {
        self.tableview
            .rx
            .modelSelected(YoutubeEntity.self)
            .bind { [weak self](element) in
                
                self?.selectedVideoEntity = element
                self?.delegate?.didChooseVideo(element, source: self?.sourceButton)
                self?.dismiss(animated: true, completion: {
                    print("finish seach and close search VC")
                })
                
            }.disposed(by: disposeBag)
    }
    
    private func fetchPlaylist(by keyword: String?) {
        playlistFactory.search(keyword: keyword)
    }
    
}

// MARK: - UITextFieldDelegate
extension VideoSearchViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        fetchPlaylist(by: textField.text)
        textField.resignFirstResponder()
        return true
    }
    
}
