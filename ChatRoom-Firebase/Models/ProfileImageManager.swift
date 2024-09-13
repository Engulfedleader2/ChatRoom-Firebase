//
//  ProfileImageManager.swift
//  ChatRoom-Firebase
//
//  Created by Israel on 9/11/24.
//

import FirebaseStorage
import UIKit

class ProfileImageManager {
    
    static let shared = ProfileImageManager()
    private let storage = Storage.storage().reference()
    
    private init() {}
    
    // Upload profile image to Firebase Storage
    func uploadProfileImage(_ image: UIImage, for userID: String, completion: @escaping (Result<String, Error>) -> Void) {
        // Compress the image to JPEG format
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(ProfileImageError.imageConversionFailed))
            return
        }
        
        // Create a reference to the profile image location in Firebase Storage
        let profileImageRef = storage.child("profile_images/\(userID).jpg")
        
        // Upload the image data
        profileImageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Get the download URL for the uploaded image
            profileImageRef.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                // Return the download URL as a string
                if let urlString = url?.absoluteString {
                    completion(.success(urlString))
                } else {
                    completion(.failure(ProfileImageError.urlCreationFailed))
                }
            }
        }
    }
    
    // Load profile image from Firebase Storage
    func loadProfileImage(from urlString: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
        // Validate the URL string
        guard let url = URL(string: urlString) else {
            completion(.failure(ProfileImageError.invalidURL))
            return
        }
        
        // Create a URL session to download the image
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Validate the downloaded data and convert it to UIImage
            if let data = data, let image = UIImage(data: data) {
                completion(.success(image))
            } else {
                completion(.failure(ProfileImageError.imageLoadingFailed))
            }
        }.resume()
    }
    
    // Custom errors for handling profile image operations
    enum ProfileImageError: Error {
        case imageConversionFailed
        case urlCreationFailed
        case invalidURL
        case imageLoadingFailed
    }
}
