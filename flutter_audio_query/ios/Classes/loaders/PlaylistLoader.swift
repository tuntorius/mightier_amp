//
//  PlaylistLoader.swift
//  flutter_audio_query
//
//  Created by lukas on 15.09.20.
//

import Foundation
import MediaPlayer

class PlaylistLoader {
    
    private let noCloudItems = MPMediaPropertyPredicate(value: false, forProperty: MPMediaItemPropertyIsCloudItem)
    
    init() {
       
    }
    
    func getPlaylists(_ result: FlutterResult, _ sortType: PlaylistSortType) -> Void {
        //get all playlists and convert to a map
        let query = MPMediaQuery.init(filterPredicates: [noCloudItems])
        query.groupingType = .playlist
        let allPlaylists = query.collections
        
        createPlaylistListAndReturn(result, sortType, allPlaylists)
        
    }
    
    func searchPlaylists(_ result: FlutterResult, _ query: String, _ sortType: PlaylistSortType) -> Void {
        //get all playlists from playlist and convert to a map
        let filterQuery: Set<MPMediaPropertyPredicate> = [MPMediaPropertyPredicate(value: query, forProperty: MPMediaPlaylistPropertyPlaylistAttributes, comparisonType: .contains), noCloudItems]
        let allPlaylists = MPMediaQuery.init(filterPredicates: filterQuery).collections?.compactMap({$0}) as! [MPMediaPlaylist]

        createPlaylistListAndReturn(result, sortType, allPlaylists)
        
    }
    
    private func createPlaylistListAndReturn(_ result: FlutterResult, _ sortType: PlaylistSortType, _ allPlaylists: [MPMediaItemCollection]?){
        var playlistsList: [[String: Any]] = []
        for playlist in allPlaylists! {
            //get playlist name and ID
            let playlistName = playlist.value(forProperty: MPMediaPlaylistPropertyName) as! String
            let playlistDate = "n/a"
            var memberIDs: [String] = []
            for song in playlist.items {
                memberIDs.append(String(song.persistentID))
            }
            
            //add playlist to returning collection
            playlistsList.append(["name": playlistName, "memberIds": memberIDs, "date_added": playlistDate])
        }
        
        sortPlaylistListAndReturn(result, sortType, playlistsList)
    }
    
    private func sortPlaylistListAndReturn(_ result: FlutterResult, _ sortType: PlaylistSortType, _ playlistsList: [[String: Any]]){
        //remove duplicates
        /*var sortedPlaylistList = Array(Set(playlistsList))
        //sort by sortType
        switch sortType {
        case .DEFAULT:
            sortedPlaylistList.sort{$0["name"]!.first! < $1["name"]!.first!}
        case .NEWEST_FIRST:
            break;
        case .LDEST_FIRST:
            break;
        }
        
        //debug
        for playlist in sortedPlaylistList {
            print(playlist["name"] ?? "n/a")
        }
        
        print("\(sortedPlaylistList.count)" + " playlists")
        
        result(sortedPlaylistList)*/
        result(playlistsList)
    }
    
}
