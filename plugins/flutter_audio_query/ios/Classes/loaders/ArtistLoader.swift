//
//  ArtistLoader.swift
//  flutter_audio_query
//
//  Created by lukas on 15.09.20.
//

import Foundation
import MediaPlayer

class ArtistLoader {
    
    private let noCloudItems = MPMediaPropertyPredicate(value: false, forProperty: MPMediaItemPropertyIsCloudItem)
    
    init() {
       
    }
    
    func getArtists(_ result: FlutterResult, _ sortType: ArtistSortType) -> Void {
        //get all artists and convert to a map
        let query = MPMediaQuery.init(filterPredicates: [noCloudItems])
        query.groupingType = .artist
        let allArtists = query.collections?.compactMap({$0})
        
        createArtistListAndReturn(result, sortType, allArtists)
        
    }
    
    func getArtistsByID(_ result: FlutterResult, _ artistIDs: [String], _ sortType: ArtistSortType) -> Void {
        //get all artists and convert to a map
        let filterID: Set<MPMediaPropertyPredicate> = [MPMediaPropertyPredicate(value: artistIDs, forProperty: MPMediaItemPropertyArtistPersistentID), noCloudItems]
        let allArtists = MPMediaQuery.init(filterPredicates: filterID).collections?.compactMap({$0})
        
        createArtistListAndReturn(result, sortType, allArtists)
        
    }
    
    func getArtistsFromGenre(_ result: FlutterResult, _ genreName: String, _ sortType: ArtistSortType){
        //get all artists from genre and convert to a map
        let filterGenre: Set<MPMediaPropertyPredicate> = [MPMediaPropertyPredicate(value: genreName, forProperty: MPMediaItemPropertyGenre), noCloudItems]
        let allArtists = MPMediaQuery.init(filterPredicates: filterGenre).collections?.compactMap({$0})
        
        createArtistListAndReturn(result, sortType, allArtists)
        
    }
    
    func searchArtists(_ result: FlutterResult, _ query: String, _ sortType: ArtistSortType) -> Void {
        //get all artists and convert to a map
        let filterID: Set<MPMediaPropertyPredicate> = [MPMediaPropertyPredicate(value: query, forProperty: MPMediaItemPropertyArtist, comparisonType: MPMediaPredicateComparison.contains), noCloudItems]
        let allArtists = MPMediaQuery.init(filterPredicates: filterID).collections?.compactMap({$0})
        
        createArtistListAndReturn(result, sortType, allArtists)
    }
    
    private func createArtistListAndReturn(_ result: FlutterResult, _ sortType: ArtistSortType, _ allArtists: [MPMediaItemCollection]?){
        var artistList: [[String: String]] = []
        for collection in allArtists! {
            //get artist name and ID
            let artistName = collection.representativeItem?.artist
            let artistID = collection.representativeItem?.artistPersistentID
            //count the album sections of a MPMediaQuery with album.artist == artist
            let filterArtistAlbum: Set<MPMediaPropertyPredicate> = [MPMediaPropertyPredicate(value: artistName, forProperty: MPMediaItemPropertyAlbumArtist)]
            let allAlbums = MPMediaQuery.init(filterPredicates: filterArtistAlbum)
            allAlbums.groupingType = MPMediaGrouping.album
            let numOfArtistAlbums = allAlbums.collections?.count
            
            let filterArtistSongs: Set<MPMediaPropertyPredicate> = [MPMediaPropertyPredicate(value: artistName, forProperty: MPMediaItemPropertyArtist)]
            let allSongs = MPMediaQuery.init(filterPredicates: filterArtistSongs)
            let numOfArtistSongs = allSongs.collections?.count
            
            //add artist to returning collection
            artistList.append(["artist_cover": "", "artist": artistName ?? "n/a", "number_of_albums": String(numOfArtistAlbums ?? 0),"_id": String(artistID ?? 0), "number_of_tracks": String(numOfArtistSongs ?? 0)])
        }

        sortArtistListAndReturn(result, sortType, artistList)
    }
    
    private func sortArtistListAndReturn(_ result: FlutterResult, _ sortType: ArtistSortType, _ artistList: [[String: String]]){
        //remove duplicates
        var sortedArtistList = Array(Set(artistList))
        //sort by sortType
        switch sortType {
        case ArtistSortType.DEFAULT:
            sortedArtistList.sort{$0["artist"]!.first! < $1["artist"]!.first!}
        case ArtistSortType.LESS_ALBUMS_NUMBER_FIRST:
            sortedArtistList.sort{$0["number_of_albums"]! < $1["number_of_albums"]!}
        case ArtistSortType.MORE_ALBUMS_NUMBER_FIRST:
            sortedArtistList.sort{$0["number_of_albums"]! > $1["number_of_albums"]!}
        case ArtistSortType.LESS_TRACKS_NUMBER_FIRST:
            sortedArtistList.sort{$0["number_of_tracks"]! < $1["number_of_tracks"]!}
        case ArtistSortType.MORE_TRACKS_NUMBER_FIRST:
            sortedArtistList.sort{$0["number_of_tracks"]! > $1["number_of_tracks"]!}
        case ArtistSortType.CURRENT_IDs_ORDER:
            sortedArtistList.sort{$0["_id"]! < $1["_id"]!}
        }
        
        
        //debug
        for artist in sortedArtistList {
            print(artist["artist"] ?? "n/a")
        }
        
        result(sortedArtistList)
    }
    
}
