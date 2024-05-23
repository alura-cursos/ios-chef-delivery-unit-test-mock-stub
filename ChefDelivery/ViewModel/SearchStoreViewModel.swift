//
//  SearchStoreViewModel.swift
//  ChefDelivery
//
//  Created by ALURA on 03/05/24.
//

import Foundation
import Combine

enum SearchError: Error {
    case noResultsFound
}

class SearchStoreViewModel: ObservableObject {
    
    // MARK: - Attributes
    
    let service: SearchServiceProtocol
    @Published var storesType: [StoreType] = []
    @Published var searchText: String = ""
    
    var cancellables = Set<AnyCancellable>()
    
    init(service: SearchServiceProtocol) {
        self.service = service
    }
    
    // MARK: - Class methods
    
    func fetchData() {
        Task {
            do {
                let result = try await service.fetchData()
                switch result {
                case .success(let stores):
                    DispatchQueue.main.async {
                        self.storesType = stores
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func filteredStores() throws -> [StoreType] {
        if searchText.isEmpty {
            return storesType
        }
        
        let filteredList = storesType.filter { $0.matches(query: searchText.lowercased()) }
        
        if filteredList.isEmpty {
            throw SearchError.noResultsFound
        }
        
        return filteredList
    }
}
