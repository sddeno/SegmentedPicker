//
//  ContentView.swift
//  SegmentedPickerPOC
//
//  Created by Shubham Deshmukh on 22/09/25.
//

import SwiftUI
    
// MARK: - Entities
struct Series: Identifiable {
    let id: Int
    let title: String
}

struct Episode: Identifiable {
    let id: Int
    let title: String
    let description: String
}

// MARK: - Service
class EpisodeService {
    func fetchEpisodes(for seriesId: Int, completion: @escaping ([Episode]) -> Void) {
        // Simulated API Response
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let episodes = (1...10).map {
                Episode(id: $0, title: "Series \(seriesId) Episode \($0)",
                        description: "Description for episode \($0) in series \(seriesId)")
            }
            completion(episodes)
        }
    }
}

// MARK: - Interactor
class SeriesInteractor {
    private let service = EpisodeService()
    
    func getEpisodes(for seriesId: Int, completion: @escaping ([Episode]) -> Void) {
        service.fetchEpisodes(for: seriesId, completion: completion)
    }
}

// MARK: - ViewAdapter
class SeriesViewAdapter: ObservableObject {
    @Published var seriesList: [Series] = []
    @Published var selectedSeriesId: Int = 0
    @Published var episodes: [Episode] = []
}


// MARK: - Presenter
class SeriesPresenter {
    private let interactor = SeriesInteractor()
    private let adapter: SeriesViewAdapter
    
    init(adapter: SeriesViewAdapter) {
        self.adapter = adapter
        loadSeriesList()
    }
    
    private func loadSeriesList() {
        // For demo: Pretend we have 5 series
        let list = (1...10).map { Series(id: $0, title: "Series \($0)") }
        adapter.seriesList = list
        if let first = list.first {
            selectSeries(first.id)
        }
    }
    
    func selectSeries(_ seriesId: Int) {
        adapter.selectedSeriesId = seriesId
        interactor.getEpisodes(for: seriesId) { [weak self] episodes in
            self?.adapter.episodes = episodes
        }
    }
}



extension Color {
    static let channel4Green = Color(hex: "#598c14")
}
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#") // skip leading #
        
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        
        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0
        
        self.init(red: r, green: g, blue: b)
    }
}



// MARK: - SwiftUI View

struct SeriesEpisodesView: View {
    @StateObject private var adapter = SeriesViewAdapter()
    private var presenter: SeriesPresenter
    
    @Namespace private var underlineAnimation
    
    init() {
        let adapter = SeriesViewAdapter()
        self._adapter = StateObject(wrappedValue: adapter)
        self.presenter = SeriesPresenter(adapter: adapter)
    }
    
    var body: some View {
        VStack {
            // Custom Horizontal Picker
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(adapter.seriesList) { series in
                        VStack {
                            Text(series.title)
                                .foregroundColor(adapter.selectedSeriesId == series.id ? .channel4Green : .white)
                                .onTapGesture {
                                    withAnimation(.spring()) {
                                        presenter.selectSeries(series.id)
                                    }
                                }
                            
                            // Underline indicator with custom color
                            if adapter.selectedSeriesId == series.id {
                                Rectangle()
                                    .fill(Color.channel4Green)
                                    .matchedGeometryEffect(id: "underline", in: underlineAnimation)
                                    .frame(height: 3)
                            } else {
                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(height: 3)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }

            
            // Episodes List
            List(adapter.episodes) { episode in
                VStack(alignment: .leading, spacing: 4) {
                    Text(episode.title)
                        .font(.headline)
                    Text(episode.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            }
        }
        .background(Color.black.edgesIgnoringSafeArea(.all)) // for dark background look
    }
}


//
//#Preview {
//    SeriesEpisodesView()
//}
