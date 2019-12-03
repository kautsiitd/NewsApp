//
//  UIImageView.swift
//  NewsApp
//
//  Created by Kautsya Kanu on 01/12/19.
//  Copyright © 2019 Kautsya Kanu. All rights reserved.
//

import UIKit

public enum FetchedImageType {
    case cache
    case downloaded
    case none
}

extension UIImageView {
    public func setImageWithUrl(_ url: URL?,
                                handleLoader: Bool = false,
                                placeHolderImage: UIImage? = nil,
                                completion: @escaping (_ imageSet: Bool) -> Void = { _ in}) {
        guard let url = url else {
            assignImage(image: placeHolderImage)
            completion(true)
            return
        }
        self.getImageWith(url, handleLoader: handleLoader, placeHolderImage: placeHolderImage, completion: { [weak self] image, _, _ in
            guard let image = image else {
                self?.assignImage(image: placeHolderImage)
                completion(true)
                return
            }
            self?.animate(image: image,
                         withAnimation: .transitionCrossDissolve)
            completion(true)
        })
    }
    
    public func animate(image: UIImage,
                        withAnimation: UIView.AnimationOptions) {
        DispatchQueue.main.async {
            UIView.transition(with: self,
                              duration: 0.5,
                              options: withAnimation,
                              animations: { [weak self] in
                                self?.assignImage(image: image)
            }, completion: nil)
        }
    }
    
    private func assignImage(image: UIImage?) {
        DispatchQueue.main.async { [weak self] in
            self?.stopLoader()
            self?.image = image
        }
    }
    
    public func getImageWith(_ url: URL?,
                             handleLoader: Bool = false,
                             placeHolderImage: UIImage? = nil,
                             completion: @escaping (_ image: UIImage?, _ url: URL?, _ type: FetchedImageType) -> Void = { _,_,_  in
        }) {
        guard let url = url else {
            completion(#imageLiteral(resourceName: "NoImage.png"), nil, .none)
            DispatchQueue.main.async { [weak self] in
                self?.stopLoader()
            }
            return
        }
        if let cachedImage = imageCache.object(forKey: url.absoluteString as NSString) {
            completion(cachedImage, url, .cache)
        }
        else {
            if handleLoader {showLoader()}
            downloadImageWith(url: url, completion: { [weak self] image in
                guard let image = image else {
                    completion(placeHolderImage, url, .downloaded)
                    return
                }
                imageCache.setObject(image,
                                     forKey: url.absoluteString as NSString)
                completion(image, url, .downloaded)
                DispatchQueue.main.async {
                    self?.stopLoader()
                }
            })
        }
    }
    
    fileprivate func downloadImageWith(url: URL,
                                       completion: @escaping (_ image: UIImage?) -> Void = { _ in
        }) {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            self?.getDataFromUrl(url: url) { data, response, error in
                guard let data = data,
                    let image = UIImage(data: data) else {
                        print(url)
                        print(error?.localizedDescription ?? "")
                        completion(#imageLiteral(resourceName: "NoImage.png"))
                        return
                }
                completion(image)
            }
        }
    }
    
    fileprivate func getDataFromUrl(url: URL,
                                    completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }
}

/// Showing Loader on UIImageView untill Image loads
extension UIImageView {
    static var activityIndicatorTag: Int {
        return 999999
    }
    public func showLoader() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            let activityIndicator = UIActivityIndicatorView(style: .medium)
            activityIndicator.tag = UIImageView.activityIndicatorTag
            activityIndicator.center = CGPoint(x: self.bounds.midX,
                                               y: self.bounds.midY)
            activityIndicator.hidesWhenStopped = true
            activityIndicator.startAnimating()
            self.addSubview(activityIndicator)
        }
    }
    public func stopLoader() {
        DispatchQueue.main.async { [weak self] in
            if let activityIndicator = self?.subviews.filter(
                { $0.tag == UIImageView.activityIndicatorTag}).first as? UIActivityIndicatorView {
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
            }
        }
    }
}
