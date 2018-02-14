//
//  MDCollectionViewDataSource.swift
//  Mediator
//
//  Created by VuVince on 6/30/17.
//  Copyright © 2017 VuVince. All rights reserved.
//

import UIKit

@objc protocol MDCollectionViewDataSourceProtocol: UICollectionViewDelegateFlowLayout {

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
    
}

//MARK: UICollectionViewDelegateFlowLayout
extension MDCollectionViewDataSource: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return owner.collectionView!(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if let size = owner.collectionView?(collectionView, layout: collectionViewLayout, referenceSizeForHeaderInSection: section) {
            return size
        }
        return CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if let size = owner.collectionView?(collectionView, layout: collectionViewLayout, referenceSizeForFooterInSection: section) {
            return size
        }
        return CGSize.zero
    }
    
    override func responds(to aSelector: Selector!) -> Bool {
        if owner.responds(to: aSelector) {
            return true
        }
        return super.responds(to: aSelector)
    }
    
    override func forwardingTarget(for aSelector: Selector!) -> Any? {
        if owner.responds(to: aSelector) {
            return owner
        }
        return super.forwardingTarget(for: aSelector)
    }
    
}
