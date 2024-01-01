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
        static let pageSize = 50
    }

    struct EndPoint {
        static let userProfile = "/me"
        static let newReleases = "/browse/new-releases"
        static let featuredPlaylists = "/browse/featured-playlists"
        static let recommendations = "/recommendations"
        static let recommendedGenres = "/recommendations/available-genre-seeds"
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

    public func getNewReleases(completion: @escaping ((Result<NewReleases, Error>)) -> Void) {
        createRequest(with: URL(string: "\(Constants.baseURL)\(EndPoint.newReleases)?limit=\(Constants.pageSize)"), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }

                do {
                    let result = try JSONDecoder().decode(NewReleases.self, from: data)
                    print("receive new release: \(result)")
                    completion(.success(result))
                }
                catch {
                    print("receive getNewReleases error: \(error)")
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }

    public func getFeaturedPlaylists(completion: @escaping ((Result<FeaturedPlaylistsResponse, Error>)) -> Void) {
        createRequest(
            with: URL(string: "\(Constants.baseURL)\(EndPoint.featuredPlaylists)?limit=20"),
            type: .GET,
            completion: { request in
                let task = URLSession.shared.dataTask(with: request) { data, _, error in
                    guard let data = data, error == nil else {
                        completion(.failure(APIError.failedToGetData))
                        return
                    }

                    do {
                        let result = try JSONDecoder().decode(FeaturedPlaylistsResponse.self, from: data)
                        print("receive featured playlist: \(result)")
                        completion(.success(result))
                    }
                    catch {
                        print("receive feat playlist error: \(error)")
                        completion(.failure(error))
                    }
                }
                task.resume()
            }
        )
    }

    public func getRecommendations(genres: Set<String>, completion: @escaping ((Result<RecommendationsResponse, Error>)) -> Void) {
        let seeds = genres.joined(separator: ",")
        createRequest(
            with: URL(string: "\(Constants.baseURL)\(EndPoint.recommendations)?limit=40&seed_genres=\(seeds)"),
            type: .GET,
            completion: { request in
                let task = URLSession.shared.dataTask(with: request) { data, _, error in
                    guard let data = data, error == nil else {
                        completion(.failure(APIError.failedToGetData))
                        return
                    }

                    do {
                        let result = try JSONDecoder().decode(RecommendationsResponse.self, from: data)
                        completion(.success(result))
                    }
                    catch {
                        completion(.failure(error))
                    }
                }
                task.resume()
            }
        )
    }

    public func getRecommendedGenres(completion: @escaping ((Result<RecommendedGenres, Error>)) -> Void) {
        createRequest(
            with: URL(string: "\(Constants.baseURL)\(EndPoint.recommendedGenres)"),
            type: .GET,
            completion: { request in
                let task = URLSession.shared.dataTask(with: request) { data, _, error in
                    guard let data = data, error == nil else {
                        completion(.failure(APIError.failedToGetData))
                        return
                    }

                    do {
                        let result = try JSONDecoder().decode(RecommendedGenres.self, from: data)
                        completion(.success(result))
                    }
                    catch {
                        completion(.failure(error))
                    }
                }
                task.resume()
            }
        )
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
