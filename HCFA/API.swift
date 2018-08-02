//
//  API.swift
//  HCFA
//
//  Created by Collin Price on 7/7/18.
//  Copyright © 2018 Collin Price. All rights reserved.
//

import Foundation

enum URLResponses {
    case Success
    case Error
    case InvalidSession
    case NotConnected
}

class API {
    static let environment = "development"
    static let rootURLString = "http://0.0.0.0:8080"
    
    class func login(email: String, password: String, completionHandler: @escaping (URLResponses, Any?) -> Void) {
        
        let path = "/users/login?email=\(email)&password=\(password)"
        
        API.performRequest(requestType: "GET", urlPath: path, json: nil, completionHandler: completionHandler)
    }
    
    class func register(first: String, last: String, email: String, password: String,
                        completionHandler: @escaping (URLResponses, Any?) -> Void) {
        
        let json = ["first_name": first, "last_name": last, "email": email, "password": password]
        
        API.performRequest(requestType: "POST", urlPath: "/users/register", json: json,
                           completionHandler: completionHandler)
    }
    
    class func validate(uid: Int, token: String, completionHandler: @escaping (URLResponses, Any?) -> Void) {
        
        let path = "/users/validate?uid=\(uid)&token=\(token)"
        
        API.performRequest(requestType: "GET", urlPath: path, json: nil, completionHandler: completionHandler)
    }
    
    class func addLeader(uid: Int, token: String, email: String,
                         completionHandler: @escaping (URLResponses, Any?) -> Void) {
        
        let json = ["uid": uid, "token": token, "email": email] as [String:Any]
        
        API.performRequest(requestType: "POST", urlPath: "/users/leader/add", json: json,
                           completionHandler: completionHandler)
    }
    
    class func removeLeader(uid: Int, token: String, email: String,
                            completionHandler: @escaping (URLResponses, Any?) -> Void) {
        
        let json = ["uid": uid, "token": token, "email": email] as [String:Any]
        
        API.performRequest(requestType: "POST", urlPath: "/users/leader/remove", json: json,
                           completionHandler: completionHandler)
    }
    
    class func addAdmin(uid: Int, token: String, email: String,
                        completionHandler: @escaping (URLResponses, Any?) -> Void) {
        
        let json = ["uid": uid, "token": token, "email": email] as [String:Any]
        
        API.performRequest(requestType: "POST", urlPath: "/users/admin/add", json: json,
                           completionHandler: completionHandler)
    }
    
    class func removeAdmin(uid: Int, token: String, email: String,
                           completionHandler: @escaping (URLResponses, Any?) -> Void) {
        
        let json = ["uid": uid, "token": token, "email": email] as [String:Any]
        
        API.performRequest(requestType: "POST", urlPath: "/users/admin/remove", json: json,
                           completionHandler: completionHandler)
    }
    
    class func changePassword(uid: Int, token: String, oldPassword: String, newPassword: String,
                              completionHandler: @escaping (URLResponses, Any?) -> Void) {
    
        let json = ["uid": uid, "token": token, "old_password": oldPassword,
                    "new_password": newPassword] as [String:Any]
        
        API.performRequest(requestType: "POST", urlPath: "/users/update/password", json: json,
                           completionHandler: completionHandler)
    }
    
    class func updateContact(uid: Int, token: String, first: String, last: String, email: String,
                             completionHandler: @escaping (URLResponses, Any?) -> Void) {
        
        let json = ["uid": uid, "token": token, "first": first, "last": last, "email": email] as [String:Any]
        
        API.performRequest(requestType: "POST", urlPath: "/users/update/contact", json: json,
                           completionHandler: completionHandler)
    }
    
    class func updateImage(uid: Int, token: String, image: String,
                           completionHandler: @escaping (URLResponses, Any?) -> Void) {
        
        let json = ["uid": uid, "token": token, "image": image] as [String:Any]
        
        API.performRequest(requestType: "POST", urlPath: "/users/update/image", json: json,
                           completionHandler: completionHandler)
    }
    
    class func getEvents(completionHandler: @escaping (URLResponses, Any?) -> Void) {
        
        API.performRequest(requestType: "GET", urlPath: "/events", json: nil, completionHandler: completionHandler)
    }
    
    class func createEvent(uid: Int, token: String, title: String, location: String, startDate: String,
                           endDate: String, description: String, image: String?,
                           completionHandler: @escaping (URLResponses, Any?) -> Void) {
        
        let json = ["uid": uid, "token": token, "title": title, "location": location,
                    "start": startDate, "end": endDate, "description": description,
                    "image": image] as [String:Any?]
        
        API.performRequest(requestType: "POST", urlPath: "/events/create", json: json,
                           completionHandler: completionHandler)
    }
    
    class func updateEvent(uid: Int, token: String, eid: Int, title: String, location: String,
                           startDate: String, endDate: String, description: String, image: String?,
                           completionHandler: @escaping (URLResponses, Any?) -> Void) {
        
        let json = ["uid": uid, "token": token, "eid":eid, "title": title, "location": location,
                    "start": startDate, "end": endDate, "description": description, "image": image] as [String:Any?]
        
        API.performRequest(requestType: "POST", urlPath: "/events/update", json: json,
                           completionHandler: completionHandler)
    }
    
    class func deleteEvents(uid: Int, token: String, events: [Int],
                           completionHandler: @escaping (URLResponses, Any?) -> Void) {
        
        let json = ["uid": uid, "token": token, "events": events] as [String:Any]
        
        API.performRequest(requestType: "POST", urlPath: "/events/delete", json: json,
                           completionHandler: completionHandler)
    }
    
    class func getCourses(uid: Int, token: String, completionHandler: @escaping (URLResponses, Any?) -> Void) {
        
        let path = "/courses?uid=\(uid)&token=\(token)"
        
        API.performRequest(requestType: "GET", urlPath: path, json: nil, completionHandler: completionHandler)
    }

    class func createCourse(uid: Int, token: String, leader_first: String, leader_last: String, year: String,
                            gender: String, location: String, material: String, meetings: [String:String]?,
                            abcls: [String], groupme: String?, members: [String], admins: [String],
                            completionHandler: @escaping (URLResponses, Any?) -> Void) {
        
        let json = ["uid": uid, "token": token, "leader_first": leader_first, "leader_last": leader_last,
                    "year": year, "gender": gender, "location": location, "material": material,
                    "meetings": meetings, "abcls": abcls, "groupme": groupme, "members": members,
                    "admins": admins] as [String : Any?]
        
        API.performRequest(requestType: "POST", urlPath: "/courses/create", json: json,
                           completionHandler: completionHandler)
    }
    
    class func updateCourse(uid: Int, token: String, cid: Int, leader_first: String, leader_last: String,
                            year: String, gender: String, location: String, material: String,
                            meetings: [String:String]?, abcls: [String], groupme: String?, members: [String],
                            admins: [String], completionHandler: @escaping (URLResponses, Any?) -> Void) {
        
        let json = ["uid": uid, "token": token, "cid": cid, "leader_first": leader_first,
                    "leader_last": leader_last, "year": year, "gender": gender, "location": location,
                    "material": material, "meetings": meetings, "abcls": abcls, "groupme": groupme,
                    "members": members,  "admins": admins] as [String : Any?]
        
        API.performRequest(requestType: "POST", urlPath: "/courses/update", json: json,
                           completionHandler: completionHandler)
    }
    
    class func deleteCourse(uid: Int, token: String, cid: Int,
                            completionHandler: @escaping (URLResponses, Any?) -> Void) {
        
        let json = ["uid": uid, "token": token, "cid": cid] as [String:Any]
        
        API.performRequest(requestType: "POST", urlPath: "/courses/delete", json: json,
                           completionHandler: completionHandler)
    }
    
    class func leaveCourse(uid: Int, token: String, cid: Int,
                           completionHandler: @escaping (URLResponses, Any?) -> Void) {
        
        let json = ["uid": uid, "token": token, "cid": cid] as [String:Any]
        
        API.performRequest(requestType: "POST", urlPath: "/courses/leave", json: json,
                           completionHandler: completionHandler)
    }
    
    class func createCourseRequest(uid: Int, token: String, cid: Int, message: String?,
                                   completionHandler: @escaping (URLResponses, Any?) -> Void) {
        
        let json = ["uid": uid, "token": token, "cid": cid, "message": message] as [String:Any?]
        
        API.performRequest(requestType: "POST", urlPath: "/courses/request", json: json, completionHandler: completionHandler)
    }
    
    class func getTeams(uid: Int, token: String, completionHandler: @escaping (URLResponses, Any?) -> Void) {
        
        let path = "/teams?uid=\(uid)&token=\(token)"
        
        API.performRequest(requestType: "GET", urlPath: path, json: nil, completionHandler: completionHandler)
    }
    
    class func createTeam(uid: Int, token: String, name: String, description: String, leaders: [String],
                          meetings: [String:String]?, groupme: String?, members: [String], admins: [String],
                          completionHandler: @escaping (URLResponses, Any?) -> Void) {
        
        let json = ["uid": uid, "token": token, "name": name, "description": description, "leaders": leaders,
                    "meetings": meetings, "groupme": groupme, "members": members, "admins": admins] as [String:Any?]
        
        API.performRequest(requestType: "POST", urlPath: "/teams/create", json: json,
                           completionHandler: completionHandler)
    }
    
    class func updateTeam(uid: Int, token: String, tid: Int, name: String, description: String, leaders: [String],
                          meetings: [String:String]?, groupme: String?, members: [String], admins: [String],
                          completionHandler: @escaping (URLResponses, Any?) -> Void) {
        
        let json = ["uid": uid, "token": token, "tid": tid, "name": name, "description": description,
                    "leaders": leaders, "meetings": meetings, "groupme": groupme, "members": members,
                    "admins": admins] as [String:Any?]
        
        API.performRequest(requestType: "POST", urlPath: "/teams/update", json: json,
                           completionHandler: completionHandler)
    }
    
    class func deleteTeam(uid: Int, token: String, tid: Int,
                          completionHandler: @escaping (URLResponses, Any?) -> Void) {
        
        let json = ["uid": uid, "token": token, "tid": tid] as [String:Any]
        
        API.performRequest(requestType: "POST", urlPath: "/teams/delete", json: json,
                           completionHandler: completionHandler)
    }
    
    class func leaveTeam(uid: Int, token: String, tid: Int,
                         completionHandler: @escaping (URLResponses, Any?) -> Void) {
        
        let json = ["uid": uid, "token": token, "tid": tid] as [String:Any]
        
        API.performRequest(requestType: "POST", urlPath: "/teams/leave", json: json,
                           completionHandler: completionHandler)
    }
    
    class func createTeamRequest(uid: Int, token: String, tid: Int, message: String?,
                                   completionHandler: @escaping (URLResponses, Any?) -> Void) {
        
        let json = ["uid": uid, "token": token, "tid": tid, "message": message] as [String:Any?]
        
        API.performRequest(requestType: "POST", urlPath: "/teams/request", json: json, completionHandler: completionHandler)
    }
}

// Helpers
extension API {
    class func performRequest(requestType: String, urlPath: String, json: [String: Any?]?,
                              completionHandler:@escaping (URLResponses, Any?) -> Void) {
        
        var request = URLRequest(url: URL(string: API.rootURLString + urlPath)!)
        request.httpMethod = requestType
        
        if requestType == "POST" {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        if let json = json {
            let jsonData = try? JSONSerialization.data(withJSONObject: json)
            request.httpBody = jsonData
        }
        
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                if let _ = error {
                    return API.handle(nil, nil, completionHandler: completionHandler)
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    var jsonResponse : Any?
                    do {
                        jsonResponse = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                    } catch {
                        jsonResponse = nil
                    }
                    API.handle(httpResponse, jsonResponse, completionHandler: completionHandler)
                }
            }
        }
        task.resume()
    }
    
    class func handle(_ response: HTTPURLResponse?, _ data: Any?,
                      completionHandler: @escaping (URLResponses, Any?) -> Void) {
        
        if response == nil {
            return completionHandler(.NotConnected, nil)
        }
        
        let data = data as! [String:Any]
        if let errorMessage = data["error"] {
            if response?.statusCode == 403 {
                return completionHandler(.InvalidSession, nil)
            }
            return completionHandler(.Error, errorMessage)
        }
        
        completionHandler(.Success, data)
    }
}
