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
import GoogleAPIClientForREST

protocol VideoSearchViewControllerDelegate: class {
    func didChooseVideo(_ entity: GTLRYouTube_SearchResult, source button: UIButton?)
}

class VideoSearchViewController: UIViewController {
    
    @IBOutlet weak var tableview: UITableView!
    
    let disposeBag = DisposeBag()
    let playlistFactory = VideoPlaylistFactory()
    var selectedVideoEntity: GTLRYouTube_SearchResult!
    weak var delegate: VideoSearchViewControllerDelegate?
    var sourceButton: UIButton?
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
                    for: IndexPath(row: row, section: 0)),
                    let entity: GTLRYouTube_SearchResultSnippet = element.snippet else {
                        return UITableViewCell()
                }
                
                cell.configure(entity: entity)
                return cell
            }
            .disposed(by: disposeBag)
    }
    
    private func bindUI() {
        self.tableview
            .rx
            .modelSelected(GTLRYouTube_SearchResult.self)
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
