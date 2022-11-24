//
//  AlbumLoader.swift
//  flutter_audio_query
//
//  Created by lukas on 15.09.20.
//

import Foundation
import MediaPlayer

class AlbumLoader {
    
    private let noCloudItems = MPMediaPropertyPredicate(value: false, forProperty: MPMediaItemPropertyIsCloudItem)
    
    init() {
       
    }
    
    func getAlbums(_ result: FlutterResult, _ sortType: AlbumSortType) -> Void {
        //get all albums and convert to a map
        let query = MPMediaQuery.init(filterPredicates: [noCloudItems])
        query.groupingType = .album
        let allAlbums = query.collections?.compactMap({$0})
        
        createAlbumListAndReturn(result, sortType, allAlbums)
    }
    
    func getAlbumsByID(_ result: FlutterResult, _ albumIDs: [String], _ sortType: AlbumSortType) -> Void {
        //get all albums and convert to a map
        let filterID: Set<MPMediaPropertyPredicate> = [MPMediaPropertyPredicate(value: albumIDs, forProperty: MPMediaItemPropertyAlbumPersistentID), noCloudItems]
        let allAlbums = MPMediaQuery.init(filterPredicates: filterID).collections?.compactMap({$0})
        
        createAlbumListAndReturn(result, sortType, allAlbums)
        
    }
    
    func getAlbumsFromArtist(_ result: FlutterResult, _ artist: String, _ sortType: AlbumSortType){
        //get all albums from genre and convert to a map
        let filterArtist: Set<MPMediaPropertyPredicate> = [MPMediaPropertyPredicate(value: artist, forProperty: MPMediaItemPropertyAlbumArtist), noCloudItems]
        let allAlbums = MPMediaQuery.init(filterPredicates: filterArtist).collections?.compactMap({$0})
        
        createAlbumListAndReturn(result, sortType, allAlbums)
        
    }
    
    func getAlbumsFromGenre(_ result: FlutterResult, _ genreName: String, _ sortType: AlbumSortType){
        //get all albums from genre and convert to a map
        let filterGenre: Set<MPMediaPropertyPredicate> = [MPMediaPropertyPredicate(value: genreName, forProperty: MPMediaItemPropertyGenre), noCloudItems]
        let allAlbums = MPMediaQuery.init(filterPredicates: filterGenre).collections?.compactMap({$0})

        createAlbumListAndReturn(result, sortType, allAlbums)
        
    }
    
    func searchAlbums(_ result: FlutterResult, _ query: String, _ sortType: AlbumSortType) -> Void {
        //get all albums and convert to a map
        let filterID: Set<MPMediaPropertyPredicate> = [MPMediaPropertyPredicate(value: query, forProperty: MPMediaItemPropertyAlbumTitle, comparisonType: MPMediaPredicateComparison.contains), noCloudItems]
        let allAlbums = MPMediaQuery.init(filterPredicates: filterID).collections?.compactMap({$0})
        
        createAlbumListAndReturn(result, sortType, allAlbums)
        
    }
    
    private func createAlbumListAndReturn(_ result: FlutterResult, _ sortType: AlbumSortType, _ allAlbums: [MPMediaItemCollection]?){
        var albumsList: [[String: String]] = []
        for collection in allAlbums! {
            //get album name and ID
            let albumName = collection.items[0].albumTitle
            let albumID = collection.items[0].albumPersistentID
            let albumArtist = collection.value(forProperty: MPMediaItemPropertyAlbumArtist) as? String
            
            let filterAlbumSongs: Set<MPMediaPropertyPredicate> = [MPMediaPropertyPredicate(value: albumName, forProperty: MPMediaItemPropertyAlbumTitle)]
            let allSongs = MPMediaQuery.init(filterPredicates: filterAlbumSongs)
            let numOfAlbumSongs = allSongs.collections?.count
            let albumArt = collection.value(forProperty: MPMediaItemPropertyArtwork) != nil ? "avaible" : ""
            
            
            //add album to returning collection
            albumsList.append(["album_art": albumArt, "maxyear": "n/a", "album": albumName ?? "n/a", "minyear": "n/a","_id": String(albumID), "numsongs": String(numOfAlbumSongs ?? 0), "artist": String(albumArtist ?? "n/a")])
        }
        
        sortAlbumListAndReturn(result, sortType, albumsList)
        
    }
    
    private func sortAlbumListAndReturn(_ result: FlutterResult, _ sortType: AlbumSortType, _ albumsList: [[String: String]]){
        //remove duplicates
        var sortedAlbumList = Array(Set(albumsList))
        //sort by sortType
        switch sortType {
        case .DEFAULT:
            sortedAlbumList.sort{$0["album"]!.first! < $1["album"]!.first!}
        case .LESS_SONGS_NUMBER_FIRST:
            sortedAlbumList.sort{$0["number_of_tracks"]! < $1["number_of_tracks"]!}
        case .MORE_SONGS_NUMBER_FIRST:
            sortedAlbumList.sort{$0["number_of_tracks"]! > $1["number_of_tracks"]!}
        case AlbumSortType.CURRENT_IDs_ORDER:
            sortedAlbumList.sort{$0["_id"]! < $1["_id"]!}
        default:
            break;
        }
        
        //debug
        for album in sortedAlbumList {
            print(album["album"] ?? "n/a")
        }
        
        result(sortedAlbumList)
    }
    
}
