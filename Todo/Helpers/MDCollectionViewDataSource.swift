//
//  MDCollectionViewDataSource.swift
//  Mediator
//
//  Created by VuVince on 6/30/17.
//  Copyright © 2017 VuVince. All rights reserved.
//

import UIKit

@objc protocol MDCollectionViewDataSourceProtocol: NSObjectProtocol {
    //Data source
    @objc optional func collectionView(_ collectionView: UICollectionView, referenceSizeForHeaderInSection section: Int) -> CGSize
    @objc optional func collectionView(_ collectionView: UICollectionView, referenceSizeForFooterInSection section: Int) -> CGSize
    @objc optional func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView
    func collectionView(_ collectionView: UICollectionView, itemSizeAt indexPath: IndexPath) -> CGSize
    //collection View delegates
    @objc optional func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    @objc optional func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath)
    @objc optional func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath)
    @objc optional func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath)
    @objc optional func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    @objc optional func scrollViewDidScroll(_ scrollView: UIScrollView)
}

//MARK: Initialization
class MDCollectionViewDataSource: NSObject {
    weak var collectionView: UICollectionView!
    weak var owner: MDCollectionViewDataSourceProtocol!
    weak var dataProvider: MDListProviderProtocol!
    var reusedCellID: String!
    
    init(collectionView: UICollectionView, owner: MDCollectionViewDataSourceProtocol, dataProvider: MDListProviderProtocol, cellID: String) {
        super.init()
        self.collectionView = collectionView
        self.owner = owner
        self.dataProvider = dataProvider
        self.reusedCellID = cellID
        setup()
    }
    
    func setup() {
        collectionView.dataSource = self
        collectionView.delegate = self
        dataProvider.updatesNotification = {[weak self] deletions, insertions, modifications in
            self?.collectionView.performBatchUpdates({[weak self] in
                self?.collectionView.insertItems(at: insertions)
                self?.collectionView.deleteItems(at: deletions)
                self?.collectionView.reloadItems(at: modifications)
            }, completion: nil)
        }
        dataProvider.reloadNotification = {[weak self] in
            self?.collectionView.reloadData()
        }
    }
    
}

//MARK: UICollectionViewDataSource
extension MDCollectionViewDataSource: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataProvider.numberOfSections()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataProvider.numberOfItems(in: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reusedCellID, for: indexPath) as! UICollectionViewCell & MDModelViewProtocol
        let model = dataProvider.model(at: indexPath)
        cell.setup(with: model)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let reusableView = owner.collectionView!(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
        return reusableView
    }
}

//MARK: UICollectionViewDelegateFlowLayout
extension MDCollectionViewDataSource: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return owner.collectionView(collectionView, itemSizeAt: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if let size = owner.collectionView?(collectionView, referenceSizeForHeaderInSection: section) {
            return size
        }
        return CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if let size = owner.collectionView?(collectionView, referenceSizeForFooterInSection: section) {
            return size
        }
        return CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        owner.collectionView?(collectionView, didSelectItemAt: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        owner.collectionView?(collectionView, didDeselectItemAt: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        owner.collectionView?(collectionView, willDisplay: cell, forItemAt: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        owner.collectionView?(collectionView, didEndDisplaying: cell, forItemAt: indexPath)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        owner.scrollViewDidEndDecelerating?(scrollView)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        owner.scrollViewDidScroll?(scrollView)
    }
    
}
