//
//  GenreLoader.swift
//  flutter_audio_query
//
//  Created by lukas on 15.09.20.
//

import Foundation
import MediaPlayer

class GenreLoader {
    
    private let noCloudItems = MPMediaPropertyPredicate(value: false, forProperty: MPMediaItemPropertyIsCloudItem)
    
    init() {
       
    }
    
    func getGenres(_ result: FlutterResult, _ sortType: GenreSortType) -> Void {
        //get all genres and convert to a map
        let query = MPMediaQuery.init(filterPredicates: [noCloudItems])
        query.groupingType = .genre
        let allGenres = query.collections?.compactMap({$0})
        
        createGenreListAndReturn(result, sortType, allGenres)
        
    }
    
    func searchGenres(_ result: FlutterResult, _ query: String, _ sortType: GenreSortType) -> Void {
        //get all genres from genre and convert to a map
        let filterQuery: Set<MPMediaPropertyPredicate> = [MPMediaPropertyPredicate(value: query, forProperty: MPMediaItemPropertyGenre, comparisonType: .contains), noCloudItems]
        let allGenres = MPMediaQuery.init(filterPredicates: filterQuery).collections?.compactMap({$0})

        createGenreListAndReturn(result, sortType, allGenres)
        
    }
    
    private func createGenreListAndReturn(_ result: FlutterResult, _ sortType: GenreSortType, _ allGenres: [MPMediaItemCollection]?){
        var genresList: [[String: String]] = []
        for genre in allGenres! {
            //get genre name and ID
            let genreName = genre.representativeItem?.genre ?? "n/a"
            //add genre to returning collection
            genresList.append(["name": genreName])
        }
        
        sortGenreListAndReturn(result, sortType, genresList)
    }
    
    private func sortGenreListAndReturn(_ result: FlutterResult, _ sortType: GenreSortType, _ genresList: [[String: String]]){
        //remove duplicates
        var sortedGenreList = Array(Set(genresList))
        //sort by sortType
        switch sortType {
        case .DEFAULT:
            sortedGenreList.sort{$0["name"]!.first! < $1["name"]!.first!}
        }
        
        //debug
        for genre in sortedGenreList {
            print(genre["name"] ?? "n/a")
        }
        
        print("\(sortedGenreList.count)" + " genres")
        
        result(sortedGenreList)
    }
    
}
