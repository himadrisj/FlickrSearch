//
//  ImageGridViewcontroller.swift
//  FlickrSearch
//
//  Created by Himadri Sekhar Jyoti on 17/06/17.
//  Copyright © 2017 Himadri Jyoti. All rights reserved.
//

import UIKit
import BNRCoreDataStack
import SDWebImage

enum ImageGridViewState {
    case showResult
    case intiateSearch
    case loading
    case noresult
    case error
    case loadMore
}

final class ImageGridViewcontroller: UIViewController, UISearchBarDelegate {
    
    let searchBar = UISearchBar()
    var persistanceController: CoreDataStack!
    var imageSearchController: ImageSearchController!
    var imageUrls = [ImageUrls]()
    var isLoading: Bool = false
    
    lazy var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> = {
        var fetchRequest = RecentSearch.fetchRequestForEntity(inContext: self.persistanceController.mainQueueContext)
        let sortDescriptor = NSSortDescriptor(key: "searchTimeStamp", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Initialize Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.persistanceController.mainQueueContext, sectionNameKeyPath: nil, cacheName: nil)
        
        // Configure Fetched Results Controller
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
        }
        
        return fetchedResultsController as! NSFetchedResultsController<NSFetchRequestResult>
    }()
    
    var screenState: ImageGridViewState = .intiateSearch {
        didSet {
            switch screenState {
                
            case .intiateSearch:
                self.recentTextTableView.isHidden = false
                self.collectionView.isHidden = true
                self.loadingView.isHidden = true
                self.noResultLabel.isHidden = true
                self.isLoading = false
                
            case .loading:
                self.recentTextTableView.isHidden = true
                self.collectionView.isHidden = true
                self.loadingView.isHidden = false
                self.noResultLabel.isHidden = true
                self.isLoading = true
                
            case .error:
                self.recentTextTableView.isHidden = true
                self.collectionView.isHidden = true
                self.loadingView.isHidden = true
                self.noResultLabel.isHidden = false
                self.noResultLabel.text = NSLocalizedString("failed.fetch.data", comment: "")
                self.isLoading = false
                
            case .noresult:
                self.recentTextTableView.isHidden = true
                self.collectionView.isHidden = true
                self.loadingView.isHidden = true
                self.noResultLabel.isHidden = false
                self.noResultLabel.text = NSLocalizedString("no.results.found", comment: "")
                self.isLoading = false
                
            case .loadMore:
                self.recentTextTableView.isHidden = true
                self.collectionView.isHidden = false
                self.loadingView.isHidden = true
                self.noResultLabel.isHidden = true
                self.isLoading = true
                
            case .showResult:
                self.recentTextTableView.isHidden = true
                self.collectionView.isHidden = false
                self.loadingView.isHidden = true
                self.noResultLabel.isHidden = true
                self.collectionView.reloadData()
                self.isLoading = false
            }
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.dataSource = self
            collectionView.delegate = self
            collectionView.register(ImageCollectionViewCell.nib, forCellWithReuseIdentifier: "ImageCollectionViewCell")
            collectionView.isHidden  = true
        }
    }
    
    @IBOutlet weak var collectionViewLayout: UICollectionViewFlowLayout! {
        didSet {
            collectionViewLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
            let cellWidth:CGFloat = ((UIScreen.main.bounds.size.width-10)/3)
            collectionViewLayout?.itemSize = CGSize(width: cellWidth, height: cellWidth)
            collectionViewLayout?.minimumLineSpacing = 5
            collectionViewLayout?.minimumInteritemSpacing  = 5
        }
    }
    
    @IBOutlet weak var loadingView: UIView! {
        didSet {
            loadingView.isHidden = true
        }
    }
    
    @IBOutlet weak var noResultLabel: UILabel! {
        didSet {
            noResultLabel.isHidden = true
        }
    }
    
    @IBOutlet weak var recentTextTableView: UITableView! {
        didSet {
            recentTextTableView.delegate = self
            recentTextTableView.dataSource = self
            recentTextTableView.tableFooterView = UIView()
            recentTextTableView.rowHeight = 50
            recentTextTableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0)
            recentTextTableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "recentCell")
        }
    }
    
    init() {
        super.init(nibName: "ImageGridViewcontroller", bundle: nil)
    }
    
    convenience init(imageSearchController: ImageSearchController, persistanceController: CoreDataStack!) {
        self.init()
        
        self.imageSearchController = imageSearchController
        self.persistanceController = persistanceController
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        createSearchBar()
    }
    
    
    private func createSearchBar() {
        searchBar.showsCancelButton = false
        searchBar.placeholder = NSLocalizedString("search.placeholder", comment: "")
        searchBar.delegate = self
        self.navigationItem.titleView = searchBar
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: UISearchBarDelegate
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else {
            assert(false, "This should not happen")
        }
        
        searchBar.endEditing(true)
        
        //Clear the existing data source
        self.imageUrls.removeAll()
        
        self.screenState = .loading
        //Update recent searches
        //Using a child context of main moc as we don't want to overload the main thread
        let childMoc = self.persistanceController.newChildContext(name: "Recent search save moc")
        self.imageSearchController.updateRecentSearchTexts(text: searchText, inMoc: childMoc)

        //Now get the images
        self.imageSearchController.getImageList(searchText: searchText, itemsPerPage: UIConstant.itemPerPage, shouldResetPage: true) {
            status, imageUrlList, error in
            
            guard status else {
                self.screenState = .error
                return
            }
            
            guard let imageUrls = imageUrlList, imageUrls.count > 0 else {
                self.screenState = .noresult
                return
            }
            
            self.imageUrls.append(contentsOf: imageUrls)
            self.screenState = .showResult
        }
        
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.screenState = .intiateSearch
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.characters.count == 0  {
            self.screenState = .intiateSearch
        }
    }
}


extension ImageGridViewcontroller: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageUrls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as! ImageCollectionViewCell
        if let imageUrlString = self.imageUrls[indexPath.row].largeSquareUrl, let imageUrl = URL(string: imageUrlString) {
            cell.loader.startAnimating()
            cell.imageView.sd_setImage(with: imageUrl) {
                image, error, type, url in
                if url == imageUrl {
                    cell.loader.stopAnimating()
                }
            }
        }
        else {
            cell.imageView.image = nil
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        guard self.imageUrls.count >= UIConstant.itemPerPage else {
            return
        }
        
        if indexPath.row == self.imageUrls.count-1 && !self.isLoading  {
            self.screenState = .loadMore
            self.loadMoreData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let urlString = self.imageUrls[indexPath.row].originalUrl else {
            return
        }
        let imageDetailViewController = ImageDetailViewController(imageUrlString: urlString)
        self.navigationController?.pushViewController(imageDetailViewController, animated: true)
    }
    
    func loadMoreData() {
        guard let searchText = searchBar.text else {
            assert(false, "This should not happen")
        }
        
        
        //Now get the images
        self.imageSearchController.getImageList(searchText: searchText, itemsPerPage: UIConstant.itemPerPage, shouldResetPage: false) {
            status, imageUrlList, error in
            
            self.isLoading = false
            guard status else {
                self.screenState = .error
                return
            }
            
            guard let imageUrls = imageUrlList, imageUrls.count > 0 else {
                self.screenState = .noresult
                return
            }
            
            self.imageUrls.append(contentsOf: imageUrls)
            self.screenState = .showResult
        }
    }
    
}

extension ImageGridViewcontroller: UITableViewDelegate, UITableViewDataSource {

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recentCell", for: indexPath)
        if let recentSearch = self.fetchedResultsController.object(at: indexPath) as? RecentSearch {
            cell.textLabel?.text = recentSearch.searchText
        }
        else {
            cell.textLabel?.text = nil
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         if let recentSearch = self.fetchedResultsController.object(at: indexPath) as? RecentSearch {
            self.searchBar.text = recentSearch.searchText
            self.searchBarSearchButtonClicked(self.searchBar)
        }
    }
}

extension ImageGridViewcontroller:NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.recentTextTableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                self.recentTextTableView.insertRows(at: [indexPath], with: .fade)
            }
        case .delete:
            if let indexPath = indexPath {
                self.recentTextTableView.deleteRows(at: [indexPath], with: .fade)
            }
        case .update:
            if let indexPath = indexPath {
                self.recentTextTableView.reloadRows(at: [indexPath], with: .fade)
            }
        case .move:
            if let indexPath = indexPath, let newIndexpath = newIndexPath {
                self.recentTextTableView.deleteRows(at: [indexPath], with: .fade)
                self.recentTextTableView.insertRows(at: [newIndexpath], with: .fade)
            }
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.recentTextTableView.endUpdates()
    }
}
