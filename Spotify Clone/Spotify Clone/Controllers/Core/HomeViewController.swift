//
//  ViewController.swift
//  Spotify Clone
//
//  Created by Bryan Yong on 03/09/2023.
//

import UIKit

enum BrowseSectionType {
    case newReleases(viewModels: [NewReleasesCellViewModel])
    case featuredPlaylists(viewModels: [FeaturedPlaylistCellViewModel])
    case recommendedTracks(viewModels: [RecommendedTrackCellViewModel])
}

class HomeViewController: UIViewController {

    private lazy var collectionView: UICollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewCompositionalLayout { sectionIndex, _ -> NSCollectionLayoutSection? in
            return HomeViewController.createSectionLayout(index: sectionIndex)
        }
    )

    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.tintColor = .label
        spinner.hidesWhenStopped = true

        return spinner
    }()

    private var sections: [BrowseSectionType] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Browse"
        let button = UIBarButtonItem(
            image: UIImage(systemName: "gear"),
            style: .done,
            target: self,
            action: #selector(didTapSettings)
        )
        button.tintColor = .label
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = button
        configureCollectionView()
        view.addSubview(spinner)
        fetchData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }

    private func configureCollectionView() {
        view.addSubview(collectionView)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .systemBackground

        collectionView.register(NewReleaseCell.self, forCellWithReuseIdentifier: NewReleaseCell.identifier)
        collectionView.register(FeaturedPlaylistCell.self, forCellWithReuseIdentifier: FeaturedPlaylistCell.identifier)
        collectionView.register(RecommendedTrackCell.self, forCellWithReuseIdentifier: RecommendedTrackCell.identifier)
    }

    private func fetchData() {

        var newReleases: NewReleases?
        var featuredPlaylist: FeaturedPlaylistsResponse?
        var recommendations: RecommendationsResponse?
        let group = DispatchGroup()
        group.enter()
        group.enter()
        group.enter()
        
//        The 'defer' statement in Swift can help manage code that needs to execute before exiting a function or block of code, particularly when multiple return points exist. It aids in writing clean, readable code—a critical aspect when you're looking to hire Swift developers
        APICaller.shared.getFeaturedPlaylists { result in
            defer {
                group.leave()
            }
            switch result {
            case .success(let model):
                featuredPlaylist = model
            case .failure(let error):
                print(error.localizedDescription)
            }
        }

        APICaller.shared.getNewReleases { result in
            defer {
                group.leave()
            }
            switch result {
            case .success(let model):
                newReleases = model
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
        APICaller.shared.getRecommendedGenres { result in
            switch result {
            case .success(let model):
                let genres = model.genres
                var seeds = Set<String>()
                while seeds.count < 5 {
                    if let random = genres.randomElement() {
                        seeds.insert(random)
                    }
                }

                APICaller.shared.getRecommendations(genres: seeds) { recommendedResult in
                    defer {
                        group.leave()
                    }
                    switch recommendedResult {
                    case .success(let model):
                        recommendations = model
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }

        group.notify(queue: .main) { [weak self] in
            guard let self else { return }
            print("receive group.notify")
            guard let newAlbums = newReleases?.albums.items,
            let playlists = featuredPlaylist?.playlists.items,
            let tracks = recommendations?.tracks else {
                return
            }

            self.configureModels(newAlbum: newAlbums, playlist: playlists, tracks: tracks)
        }
    }

    private func configureModels(
        newAlbum: [Album],
        playlist: [Playlist],
        tracks: [AudioTrack]
    ) {
        print("receive configureModels")
        print(newAlbum.count)
        print(playlist.count)
        print(tracks.count)
        sections.append(.newReleases(viewModels: newAlbum.compactMap({
            return NewReleasesCellViewModel(
                name: $0.name,
                artworkURL: URL(string: $0.images.first?.url ?? ""),
                numberOfTracks: $0.total_tracks,
                artistName: $0.artists.first?.name ?? "-"
            )
        })))
        sections.append(.featuredPlaylists(viewModels: playlist.compactMap {
            return FeaturedPlaylistCellViewModel(
                name: $0.name,
                artworkURL: URL(string: $0.images.first?.url ?? ""),
                creatorName: $0.owner.display_name
            )
        }))
        sections.append(.recommendedTracks(viewModels: tracks.compactMap {
            return RecommendedTrackCellViewModel(
                name: $0.name,
                artistName: $0.artists.first?.name ?? "-",
                artworkURL: URL(string: $0.album.images.first?.url ?? "")
            )
        }))
        collectionView.reloadData()
    }

    @objc func didTapSettings() {
        let vc = SettingsViewController()
        vc.title = "Settings"
        vc .navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard sections.count > 0 else { return 0 }
        let type = sections[section]
        switch type {
        case .newReleases(let viewModel):
            return viewModel.count
        case .featuredPlaylists(let viewModel):
            return viewModel.count
        case .recommendedTracks(let viewModel):
            return viewModel.count
        }
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let type = sections[indexPath.section]

        switch type {
        case .newReleases(let viewModels):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: NewReleaseCell.identifier,
                for: indexPath
            ) as? NewReleaseCell else {
                return UICollectionViewCell()
            }

            let viewModel = viewModels[indexPath.row]
            cell.configure(with: viewModel)

            cell.backgroundColor = .systemGreen
            return cell

        case .featuredPlaylists(let viewModels):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: FeaturedPlaylistCell.identifier,
                for: indexPath
            ) as? FeaturedPlaylistCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: viewModels[indexPath.row])
            return cell

        case .recommendedTracks(let viewModels):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: RecommendedTrackCell.identifier,
                for: indexPath
            ) as? RecommendedTrackCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: viewModels[indexPath.row])
            return cell
        }

//        if indexPath.section == 0 {
//            cell.backgroundColor = .systemGreen
//        }
//        else if indexPath.section == 1 {
//            cell.backgroundColor = .systemPink
//        }
//        else if indexPath.section == 2 {
//            cell.backgroundColor = .systemCyan
//        }
//        return cell
    }

    static func createSectionLayout(index: Int) -> NSCollectionLayoutSection {

        switch index {
        case 0:
            return makeSections()
        case 1:
            // Item
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(1.0)
                )
            )
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)

            // Vertical group in a horizontal group
            let verticalGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .absolute(200),
                    heightDimension: .absolute(200)
                ),
                repeatingSubitem: item,
                count: 2
            )

            let horizontalGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .absolute(200),
                    heightDimension: .absolute(400)
                ),
                repeatingSubitem: verticalGroup,
                count: 1
            )
            
            // Section
            let section = NSCollectionLayoutSection(group: horizontalGroup)
            section.orthogonalScrollingBehavior = .groupPaging
            return section
        case 2:
            // Item
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(1.0)
                )
            )
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)

            // Vertical group in a horizontal group
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(80)
                ),
                repeatingSubitem: item,
                count: 1
            )
            
            // Section
            let section = NSCollectionLayoutSection(group: group)
            
            return section
        default:
            return makeSections()
        }
    }

    static func makeSections() -> NSCollectionLayoutSection {
        // Item
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
        )
        item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)

        // Vertical group in a horizontal group
        let verticalGroup = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(130)
            ),
            repeatingSubitem: item,
            count: 3
        )

        let horizontalGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.9),
                heightDimension: .absolute(390)
            ),
            repeatingSubitem: verticalGroup,
            count: 1
        )
        
        // Section
        let section = NSCollectionLayoutSection(group: horizontalGroup)
        section.orthogonalScrollingBehavior = .groupPaging
        
        return section
    }
}

