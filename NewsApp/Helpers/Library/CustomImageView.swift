//
//  CustomImageView.swift
//  NewsApp
//
//  Created by Kautsya Kanu on 31/12/19.
//  Copyright © 2019 Kautsya Kanu. All rights reserved.
//

import UIKit
import CoreData

class CustomImageView: UIImageView {
    //MARK: Properties
    private let context: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = CoreDataStack.shared.persistentContainer.viewContext
        return context
    }()
    private var urlString = ""
    //MARK: Elements
    private var loader: UIActivityIndicatorView!
    
    //MARK:- IBInspectable
    @IBInspectable private var shouldPersist: Bool = false
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLoader()
    }
    
    private func setupLoader() {
        loader = UIActivityIndicatorView()
        addSubview(loader)
        loader.hidesWhenStopped = true
        loader.translatesAutoresizingMaskIntoConstraints = false
        loader.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        loader.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
}

//MARK:- Available Functions
extension CustomImageView {
    func setImage(with urlString: String) {
        image = nil
        self.urlString = urlString
        loader.startAnimating()
        //Checking cache
        if let cachedImage = imageCache.object(forKey: urlString as NSString) {
            setImage(image: cachedImage, for: urlString)
            return
        }
        
        guard let url = URL(string: urlString)?.safeURL() else {
            self.setImage(image: #imageLiteral(resourceName: "NoImage.png"), for: urlString)
            return
        }
        let remoteImageTask = URLSession.shared.dataTask(with: url, completionHandler: { [weak self] data, response, error in
            guard let self = self else { return }
            guard let data = data,
                let remoteImage = UIImage(data: data) else {
                    self.setImage(image: #imageLiteral(resourceName: "NoImage.png"), for: urlString, animate: true)
                    return
            }
            self.setImage(image: remoteImage, for: urlString, shouldCache: true, animate: true)
        })
        
        //Async Image fetching from CoreData or Remote
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else { return }
            //Checking CoreData
            if self.shouldPersist,
                let coreImage = self.fetchCoreImage(with: urlString) {
                self.setImage(image: coreImage, for: urlString, shouldCache: true, animate: true)
                return
            }
            //Fetching Remote Image
            remoteImageTask.resume()
        }
    }
    
    private func fetchCoreImage(with urlString: String) -> UIImage? {
        let request = Image.fetchAll()
        let predicate = NSPredicate(format: "urlString == %@", urlString)
        request.predicate = predicate
        request.fetchLimit = 1
        guard let coreImage = try? context.fetch(request).first,
            let coreImageData = coreImage.data as Data? else {
            return nil
        }
        return UIImage(data: coreImageData)
    }
    
    private func setImage(image: UIImage, for urlString: String,
                          shouldCache: Bool = false, animate: Bool = false) {
        if shouldCache {
            imageCache.setObject(image, forKey: urlString as NSString)
        }
        if shouldCache && shouldPersist {
            let coreImage = Image(context: context)
            coreImage.urlString = urlString
            coreImage.data = image.pngData() as NSData?
            try? context.save()
        }
        DispatchQueue.main.async {
            if urlString == self.urlString {
                self.loader.stopAnimating()
                if animate { self.animate(image: image) }
                else { self.image = image }
            }
        }
    }
    
    private func animate(image: UIImage?) {
        UIView.transition(with: self, duration: 0.5, options: [.transitionCrossDissolve],
                          animations: { [weak self] in
                            self?.image = image
            }, completion: nil)
    }
}
