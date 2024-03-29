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

protocol VideoSearchViewControllerDelegate: AnyObject {
    func didChooseVideo(_ entity: YoutubeEntity, source: Any?)
}

class VideoSearchViewController: UIViewController {
    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var searchTextField: UITextField!

    let disposeBag = DisposeBag()
    let playlistFactory = VideoPlaylistFactory()
    var selectedVideoEntity: YoutubeEntity!
    weak var delegate: VideoSearchViewControllerDelegate?
    var sourceButton: UIButton?
    var source: Any?
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // dark-mode対応
        searchTextField.backgroundColor = UIColor.systemGray5
        searchTextField.attributedPlaceholder = NSAttributedString(string: searchTextField.placeholder ?? "",
                                                                   attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])

        bindData()
        bindUI()
    }
    
    // MARK: - IBActions
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        dismiss(animated: true) {
            DLog("search VC dismissed")
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
                self?.delegate?.didChooseVideo(element, source: self?.source)

                self?.saveSelectedVideoToUserDefaultsIfNeeded(element)

                self?.dismiss(animated: true, completion: {
                    DLog("finish seach and close search VC")
                })
                
            }.disposed(by: disposeBag)
    }
    
    private func fetchPlaylist(by keyword: String?) {
        playlistFactory.search(keyword: keyword)
    }

    private func saveSelectedVideoToUserDefaultsIfNeeded(_ element: YoutubeEntity) {
        let entities = UserDefaultsStore.youtubeEntities

        // insert element into UserDefaults only if the latest (up-to)three elements are not the same
        let count = entities.count < 3 ? entities.count: 3
        guard !entities.prefix(upTo: count).contains(where: { $0 == element }) else { return }

        UserDefaultsStore.youtubeEntities.insert(element, at: 0)
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
