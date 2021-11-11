//
//  StorageManager.swift
//  Messenger
//
//  Created by Valados on 08.11.2021.
//

import Foundation
import FirebaseStorage

final class StorageManager {
    static let shared = StorageManager()
    
    private let storage = Storage.storage().reference()
    
    public typealias UploadPictureCompletion = (Result<String, Error>) -> Void
    
    /// Uploads picture to firebase storage and returns completion with url strin to download
    public func uploadProfilePicture(with data: Data,fileName: String, completion: @escaping UploadPictureCompletion){
        storage.child("images/\(fileName)").putData(data,metadata: nil,completion: { metadata, error in
            guard error == nil else {
                //failed
                print("Failed to upload data to firebase for picture")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
        })
        
        self.storage.child("images/\(fileName)").downloadURL(completion: { url, error in
            guard let url = url else{
                print("Failed to get download url")
                completion(.failure(StorageErrors.failedToGetDownloadUrl))
                return
            }
            let urlString = url.absoluteString
            print("download url returned: \(urlString)")
            completion(.success(urlString))
        })
    }
    /// Upload image that will be sent in a conversation message
    public func uploadMessagePhoto(with data: Data,fileName: String, completion: @escaping UploadPictureCompletion){
        storage.child("message_images/\(fileName)").putData(data,metadata: nil,completion: { [weak self] metadata, error in
            guard error == nil else {
                //failed
                print("Failed to upload data to firebase for picture")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            print(fileName)
            self?.storage.child("message_images/\(fileName)").downloadURL(completion: { url, error in
                guard let url = url else{
                    print("Failed to get download url")
                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    return
                }
                let urlString = url.absoluteString
                print("download url returned: \(urlString)")
                completion(.success(urlString))
            })
        })
    }
    /// Upload video that will be sent in a conversation message
    public func uploadMessageVideo(with fileUrl: URL,fileName: String, completion: @escaping UploadPictureCompletion){
        storage.child("message_videos/\(fileName)").putFile(from: fileUrl,metadata: nil,completion: { [weak self] metadata, error in
            guard error == nil else {
                //failed
                print("Failed to upload video file to firebase")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            print(fileName)
            self?.storage.child("message_videos/\(fileName)").downloadURL(completion: { url, error in
                guard let url = url else{
                    print("Failed to get download url")
                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    return
                }
                let urlString = url.absoluteString
                print("download url returned: \(urlString)")
                completion(.success(urlString))
            })
        })
    }
    public enum StorageErrors: Error{
        case failedToUpload
        case failedToGetDownloadUrl
    }
    
    public func downloadURL(for path:String, completion: @escaping(Result<URL, Error>) -> Void){
        let reference = storage.child(path)
        reference.downloadURL(completion: { url, error in
            guard let url = url, error == nil else{
                completion(.failure(StorageErrors.failedToGetDownloadUrl))
                return
            }
            completion(.success(url))
        })
    }
}

