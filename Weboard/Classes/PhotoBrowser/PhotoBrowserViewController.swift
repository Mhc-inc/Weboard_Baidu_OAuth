//
//  PhotoBrowserViewController.swift
//  MHC微博
//
//  Created by mhc team on 2022/11/29.
//

import Foundation
import Photos
import UIKit
import SVProgressHUD
private let PhotoBrowserCellId = "PhotoBrowserCellId"
class PhotoBrowserViewController: UIViewController, UICollectionViewDataSource {
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.scrollToItem(at: current, at: .centeredHorizontally, animated: false)
    }
    private class PhotoBrowserViewLayout: UICollectionViewFlowLayout {
        override func prepare() {
            super.prepare()
            itemSize = collectionView!.bounds.size
            minimumLineSpacing = 0
            minimumInteritemSpacing = 0
            scrollDirection = .horizontal
            collectionView?.isPagingEnabled = true
            collectionView?.bounces = false
            collectionView?.showsHorizontalScrollIndicator = false
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return urls.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoBrowserCellId, for: indexPath) as! PhotoBrowserCell
        cell.backgroundColor = .black
        cell.imageURL = urls[indexPath.item]
        cell.photoDelegate = self
        return cell
    }
    
    private var urls: [URL]
    private func prepare() {
        collectionView.register(PhotoBrowserCell.self, forCellWithReuseIdentifier: PhotoBrowserCellId)
        collectionView.dataSource = self
    }
    private var current: IndexPath
    init(urls: [URL], indexPath: IndexPath) {
        self.urls = urls
        self.current = indexPath
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func loadView() {
        var rect = UIScreen.main.bounds
        rect.size.width += 20
        view = UIView(frame: rect)
        setupUI()
    }
    lazy var collectionView: UICollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: PhotoBrowserViewLayout())
    private lazy var closeButton: UIButton = UIButton(title: "关闭", fontSize: 14, color: UIColor.white, imageName: nil, backColor: UIColor.darkGray)
    private lazy var saveButton: UIButton = UIButton(title: "保存", fontSize: 14, color: UIColor.white, imageName: nil, backColor: UIColor.darkGray)
    private func setupUI() {
        view.addSubview(collectionView)
        view.addSubview(closeButton)
        view.addSubview(saveButton)
        collectionView.frame = view.bounds
        closeButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.snp.bottom).offset(-8)
            make.left.equalTo(view.snp.left).offset(28)
            make.size.equalTo(CGSize(width: 100, height: 36))
        }
        saveButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.snp.bottom).offset(-8)
            make.right.equalTo(view.snp.right).offset(-28)
            make.size.equalTo(CGSize(width: 100, height: 36))
        }
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(save), for: .touchUpInside)
        prepare()
    }
    @objc private func close() {
        dismiss(animated: true)
    }
    @objc private func save() {
        do {
            let image = try UIImage(data: Data(contentsOf: PhotoBrowserCell().bmiddleURL(url: UserAccountViewModel.sharedUserAccount.portraitURL!)))
            UIImageWriteToSavedPhotosAlbum(image!, self, #selector(self.image(image:didFinishSavingWithError:contextInfo:)), nil)
        } catch {
            SVProgressHUD.showInfo(withStatus: "保存失败")
        }
    }
    @objc private func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: Any?) {
        let message = (error == nil) ? "保存成功" : "保存失败"
        SVProgressHUD.showInfo(withStatus: message)
    }
}
extension PhotoBrowserViewController: PhotoBrowserCellDelegate {
    func photoBrowserCellDidTapImage() {
        imageViewForDimiss()
        close()
    }
}
extension PhotoBrowserViewController: PhotoBrowserDismissDelegate {
    func imageViewForDimiss() -> UIImageView {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        let cell = collectionView.visibleCells[0] as! PhotoBrowserCell
        iv.image = cell.imageView.image
        iv.frame = cell.scrollView.convert(cell.imageView.frame, to: UIApplication.shared.keyWindow!)
        //UIApplication.shared.keyWindow!.addSubview(iv)
        return iv
    }
    
    func indexPathForDimiss() -> IndexPath {
        return collectionView.indexPathsForVisibleItems[0]
    }
    
    
}
