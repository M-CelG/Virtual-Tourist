//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Manish Sharma on 2/20/16.
//  Copyright © 2016 CelG Mobile LLC. All rights reserved.
//

import Foundation


class FlickrClient: NSObject {
    
    // Create shared session
    var session: NSURLSession
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    // Get http data task method
    func getFlickrDataTaskMethod(parameters : [String: AnyObject], completionHandler: ((data: AnyObject?, error: NSError?) -> Void)) -> NSURLSessionDataTask {
        
        let url = Constants.BASE_URL + FlickrClient.escapeParameters(parameters)
        
        let urlNSURL = NSURL(string: url)
        let request = NSURLRequest(URL: urlNSURL!)
        
        let task = session.dataTaskWithRequest(request) {data, response, error in
            
            // First check for any error
            if error != nil {
                completionHandler(data: nil, error: error)
                print("Error during task request to Flickr: \(error?.userInfo)")
            }
            
            // Make sure successful response status code was received
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 || statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    completionHandler(data: nil, error: NSError(domain: "Get Request to Flickr", code: 1, userInfo: [NSLocalizedDescriptionKey : "Here is your response code:\(response.statusCode)"]))
                } else if let response = response {
                    completionHandler(data: nil, error: NSError(domain: "Get Request to Flickr", code: 1, userInfo: [NSLocalizedDescriptionKey : "Here is the response: \(response)"]))
                } else {
                    completionHandler(data: nil, error: NSError(domain: "Get Request to Flickr", code: 1, userInfo: [NSLocalizedDescriptionKey : "Invalid response to the request"]))
                }
               return
            }
            
            // Make sure data received is valid
            guard let receivedData = data else {
                completionHandler(data: nil, error: NSError(domain: "Get Request to Flickr", code: 1, userInfo: [NSLocalizedDescriptionKey : "Invalid data received for the get request"]))
                return
            }
            
            self.jsonParseMethod(receivedData, completionHandler: completionHandler)
        
        }
        // Start the task
        task.resume()
        return task
    }
    
    func taskForImageData (url: String, completionHandler:(imageData: NSData?, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        let urlNSURL = NSURL(string: url)
        
        let request = NSURLRequest(URL: urlNSURL!)
        
        let task = session.dataTaskWithRequest(request) {data, response, error in
            
            if error != nil {
                print("Error in downloading Image data from Flickr")
                completionHandler(imageData: nil, error: NSError(domain: "Unable to download Image from Flickr", code: 20, userInfo: [NSLocalizedDescriptionKey: "Unable to download particular Image from Flickr"]))
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    print("Unable to download Image response statusCode:\(response.statusCode)")
                    completionHandler(imageData: nil, error: NSError(domain: "Unable to download Image", code: 21, userInfo: [NSLocalizedDescriptionKey: "Unable to download : Response Code\(response.statusCode)"]))
                    return
                } else if let response = response {
                    print("Unable to download Image with response: \(response)")
                    completionHandler(imageData: nil, error: NSError(domain: "Unable to download Image", code: 22, userInfo: [NSLocalizedDescriptionKey: "Unable to download : Response\(response)"]))
                    return
                } else {
                    print("Unable to download Image with Invalid response")
                    completionHandler(imageData: nil, error: NSError(domain: "Unable to download Image", code: 23, userInfo: [NSLocalizedDescriptionKey: "Unable to download Image: Invalid response received"]))
                    return
                }
            }
            
            guard let imageData = data else {
                print("Invalid Image Data received from Flickr")
                completionHandler(imageData: nil, error: NSError(domain: "Invalid Image Data received from Flickr", code: 24, userInfo: [NSLocalizedDescriptionKey: "Invalid Image Data received from Flickr"]))
                return
            }
            
            completionHandler(imageData: imageData, error: nil)
        
        }
        // Start Task
        task.resume()
        
        return task
    }
    
    
    // Mark: Method for parsing JSON Data
    func jsonParseMethod(data: NSData, completionHandler: ((results: AnyObject?, error: NSError?) -> Void)) {
        
        var parsedData: AnyObject? = nil
        var parsedError: NSError? = nil
        
        do {
            parsedData = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch let error as NSError {
            parsedError = error
        }
        
        completionHandler(results: parsedData, error: parsedError)
    }
    
    
    // Mark: Method for escaping parameters
    class func escapeParameters(parameters: [String: AnyObject]) -> String {
        // Create an array of String
        var returnedEscapedParameters = [String]()
        
        // Iterate over the parameters dictionary
        for (argument, value) in parameters {
            
            // make sure value is String value
            let stringValue = "\(value)"
            
            // Escape it
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            // Append to String Array
            if let unwrapedEscapedValue = escapedValue {
                returnedEscapedParameters.append(argument + "=" + unwrapedEscapedValue)
            } else {
                print("Unable to escape: \(stringValue)")
            }
            
        }
        return (!returnedEscapedParameters.isEmpty ? "?" : "") + (returnedEscapedParameters.joinWithSeparator("&"))
    }
    
    // Mark: Single Instance
    class func sharedInstance() -> FlickrClient {
        
        struct Singleton {
            
            static let sharedInstance = FlickrClient()
        }
        return Singleton.sharedInstance
    }

    

}
