//
//  FlickrClient-Constants.swift
//  VirtualTourist
//
//  Created by Manish Sharma on 2/20/16.
//  Copyright © 2016 CelG Mobile LLC. All rights reserved.
//

import Foundation

extension FlickrClient {
    
    
    struct Constants {
        static let BASE_URL = "https://api.flickr.com/services/rest/"
        static let API_KEY = "f778facf87ae054193ecafc40daaf52c"
        static let EXTRAS = "url_m"
        static let DATA_FORMAT = "json"
        static let NO_JSON_CALLBACK = "1"
        static let ACCURACY = "16"
        static let PRIVACY_FILTER = "1"
        static let PER_PAGE = "20"
    }
    
    struct Method {
        static let PHOTO_SEARCH = "flickr.photos.search"
    }
    
    struct MethodArguments {
        static let METHOD_NAME = "method"
        static let API_KEY = "api_key"
        static let EXTRAS = "extras"
        static let DATA_FORMAT = "format"
        static let NO_JSON_CALLBACK = "nojsoncallback"
        static let LATITUDE = "lat"
        static let LONGITUDE = "lon"
        static let ACCURACY = "accuracy"
        static let PRIVACY_FILTER = "privacy_filter"
        static let PAGE = "page"
        static let PER_PAGE = "per_page"
    }
    
    struct JsonKeys {
        static let TopLevelPhotos = "photos"
        static let Pages = "pages"
        static let PhotosDictInData = "photo"
        static let Stat = "stat"
        static let URL = "url_m"
        static let Per_Page = "per_page"
        static let Page = "page"
        static let Total = "total"
    }
}
