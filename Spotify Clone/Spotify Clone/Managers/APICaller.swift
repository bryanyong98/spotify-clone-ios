//
//  APICaller.swift
//  Spotify Clone
//
//  Created by Bryan Yong on 03/09/2023.
//

import Foundation


final class APICaller {
    static let shared = APICaller()

    private init() {}

    struct Constants {
        static let baseURL = "https://api.spotify.com/v1"
    }

    struct EndPoint {
        static let userProfile = "/me"
    }

    enum APIError: Error {
        case failedToGetData
    }

    public func getCurrentUserProfile(completion: @escaping (Result<UserProfile, Error>) -> Void) {
        createRequest(
            with: URL(string: "\(Constants.baseURL)\(EndPoint.userProfile)"),
            type: .GET
        ) { baseRequest in
            let task = URLSession.shared.dataTask(with: baseRequest) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }

                do {
                    let result = try JSONDecoder().decode(UserProfile.self, from: data)
                    completion(.success(result))
                }
                catch {
                    print("receive getCurrentUserProfile error: \(error)")
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }

    // MARK: - Private

    enum HTTPMethod: String {
        case GET
        case POST
    }

    private func createRequest(
        with url: URL?,
        type: HTTPMethod,
        completion: @escaping (URLRequest) -> Void
    ) {
        AuthManager.shared.withValidToken { token in
            guard let apiURL = url else { return }
            var request = URLRequest(url: apiURL)
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.httpMethod = type.rawValue
            request.timeoutInterval = 30

            completion(request)
        }
    }
}
