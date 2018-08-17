//
//  AWS.swift
//  HCFA
//
//  Created by Collin Price on 8/16/18.
//  Copyright © 2018 Collin Price. All rights reserved.
//

import AWSCore
import AWSS3

let S3BUCKET = API.environment == "production" ? "hcfa-app-prod" : "hcfa-app-dev"

func getPoolID() -> String? {
    if let path = Bundle.main.path(forResource: "awsconfiguration", ofType: "json") {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            let json = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
            if let json = json as? Dictionary<String, AnyObject> {
                if let cred = json["CredentialsProvider"] as? [String:Any] {
                    if let identity = cred["CognitoIdentity"] as? [String:Any] {
                        if let def = identity["Default"] as? [String:Any] {
                            if let poolID = def["PoolId"] as? String {
                                return poolID
                            }
                        }
                    }
                }
            }
        } catch { }
    }
    return nil
}

func userS3Key(_ uid: Int) -> String {
    return "users/\(uid)/profile.jpeg"
}

func eventS3Key(_ eid: Int) -> String {
    return "events/\(eid)/image.jpeg"
}

func userImageURL(_ uid: Int) -> String {
    return "https://s3.amazonaws.com/\(S3BUCKET)/\(userS3Key(uid))"
}

func eventImageURL(_ eid: Int) -> String {
    return "https://s3.amazonaws.com/\(S3BUCKET)/\(eventS3Key(eid))"
}

func updateEventImages(_ eid: Int, _ data: Data) {
    
    if var eventImages = defaults.dictionary(forKey: "eventImages") as? [String:Data] {
        eventImages[String(eid)] = data
        defaults.set(eventImages, forKey: "eventImages")
    } else {
        defaults.set([String(eid):data], forKey: "eventImages")
    }
}

func deleteEventImage(_ eid: Int) {
    if let poolID = getPoolID() {
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: .USEast1,
                                                                identityPoolId: poolID)
        let configuration = AWSServiceConfiguration(region: .USEast1, credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        let S3 = AWSS3.default()
        let deleteObjectRequest = AWSS3DeleteObjectRequest()
        deleteObjectRequest?.bucket = S3BUCKET
        deleteObjectRequest?.key = eventS3Key(eid)
        S3.deleteObject(deleteObjectRequest!).continueWith { (task: AWSTask) -> AnyObject? in
            if let error = task.error {
                print("Error occurred: \(error)")
                return nil
            }
            return nil
        }
    }
}
