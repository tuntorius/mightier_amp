//
//  SongLoader.swift
//  flutter_audio_query
//
//  Created by lukas on 15.09.20.
//

import Foundation
import MediaPlayer

class SongLoader {
    
    private let noCloudItems = MPMediaPropertyPredicate(value: false, forProperty: MPMediaItemPropertyIsCloudItem)
    
    init() {
       
    }
    
    func getSongs(_ result: FlutterResult, _ sortType: SongSortType) -> Void {
        //get all songs and convert to a map
        let allSongs = MPMediaQuery.init(filterPredicates: [noCloudItems]).items
        
        createSongListAndReturn(result, sortType, allSongs)
        
    }
    
    func getSongsFromArtist(_ result: FlutterResult, _ artist: String, _ sortType: SongSortType){
        //get all songs from genre and convert to a map
        let filterArtist: Set<MPMediaPropertyPredicate> = [MPMediaPropertyPredicate(value: artist, forProperty: MPMediaItemPropertyArtist), noCloudItems]
        let allSongs = MPMediaQuery.init(filterPredicates: filterArtist).items

        createSongListAndReturn(result, sortType, allSongs)
        
    }
    
    func getSongsFromAlbum(_ result: FlutterResult, _ albumID: String, _ sortType: SongSortType){
        //get all songs from genre and convert to a map
        let filterAlbum: Set<MPMediaPropertyPredicate> = [MPMediaPropertyPredicate(value: UInt64(albumID), forProperty: MPMediaItemPropertyAlbumPersistentID), noCloudItems]
        let allSongs = MPMediaQuery.init(filterPredicates: filterAlbum).items
        
        createSongListAndReturn(result, sortType, allSongs)
        
    }
    
    func getSongsFromArtistAlbum(_ result: FlutterResult, _ artist: String, _ albumID: String, _ sortType: SongSortType){
        //get all songs from genre and convert to a map
        let filterArtistAlbum: Set<MPMediaPropertyPredicate> = [MPMediaPropertyPredicate(value: UInt64(albumID), forProperty: MPMediaItemPropertyAlbumPersistentID), MPMediaPropertyPredicate(value: artist, forProperty: MPMediaItemPropertyArtist), noCloudItems]
        let allSongs = MPMediaQuery.init(filterPredicates: filterArtistAlbum).items
        
        createSongListAndReturn(result, sortType, allSongs)
        
    }
    
    func getSongsFromGenre(_ result: FlutterResult, _ genreName: String, _ sortType: SongSortType){
        //get all songs from genre and convert to a map
        let filterGenre: Set<MPMediaPropertyPredicate> = [MPMediaPropertyPredicate(value: genreName, forProperty: MPMediaItemPropertyGenre), noCloudItems]
        let allSongs = MPMediaQuery.init(filterPredicates: filterGenre).items
        
        createSongListAndReturn(result, sortType, allSongs)
        
    }
    
    func getSongsFromPlaylist(_ result: FlutterResult, _ ids: [String], _ sortType: SongSortType){
        var allSongs: [MPMediaItem]? = []
        //for each id
        for id in ids {
            //filter all songs for id == .persistentID and add song to allSongs
            let filterID: Set<MPMediaPropertyPredicate> = [MPMediaPropertyPredicate(value: UInt64(id), forProperty: MPMediaItemPropertyPersistentID), noCloudItems]
            if let items = MPMediaQuery.init(filterPredicates: filterID).items, MPMediaQuery.init(filterPredicates: filterID).items!.count > 0{
                    allSongs?.append(items[0])
            }
        }
        
        createSongListAndReturn(result, sortType, allSongs)
        
    }
    
    func searchSongs(_ result: FlutterResult, _ query: String, _ sortType: SongSortType) -> Void {
        //get all songs from genre and convert to a map
        let filterQuery: Set<MPMediaPropertyPredicate> = [MPMediaPropertyPredicate(value: query, forProperty: MPMediaItemPropertyTitle, comparisonType: .contains), noCloudItems]
        let allSongs = MPMediaQuery.init(filterPredicates: filterQuery).items

        createSongListAndReturn(result, sortType, allSongs)
        
    }
    
    private func createSongListAndReturn(_ result: FlutterResult, _ sortType: SongSortType, _ allSongs: [MPMediaItem]?){
        var songsList: [[String: String]] = []
        for song in allSongs! {
            //get song name and ID
            let songName = song.title ?? "n/a"
            let songID = String(song.persistentID)
            let songAlbumName = song.albumTitle ?? "n/a"
            let songAlbumID = String(song.albumPersistentID)
            let songArtistName = song.artist ?? "n/a"
            let songArtistID = String(song.artistPersistentID)
            let songComposerName = song.composer ?? "n/a"
            let songYear = "n/a"
            let songAlbumTrack = String(song.albumTrackNumber)
            let songDuration = String(Double(song.playbackDuration)).replacingOccurrences(of: ".", with: "")
            let songBookmark = "n/a"
            let songDataPath = song.assetURL?.absoluteString ?? "n/a"
            let songURI = song.assetURL?.absoluteString ?? "n/a"
            let songSize = "n/a"
            let songArtwork = ""
            let songPodcast = song.podcastTitle != nil ? "true" : "false"
            //add song to returning collection
            songsList.append(["album_id": songAlbumID, "artist_id": songArtistID, "artist": songArtistName, "album": songAlbumName, "title": songName, "_display_name": songName,"_id": songID ,"composer": songComposerName, "year": songYear, "track": songAlbumTrack, "duration": songDuration, "bookmark": songBookmark, "_data": songDataPath, "uri": songURI, "_size": songSize, "album_artwork": songArtwork, "is_music": "true", "is_podcast": songPodcast ])
        }
        
        sortSongListAndReturn(result, sortType, songsList)
    }
    
    private func sortSongListAndReturn(_ result: FlutterResult, _ sortType: SongSortType, _ songsList: [[String: String]]){
        //remove duplicates
        var sortedSongList = Array(Set(songsList))
        //sort by sortType
        switch sortType {
        case .DEFAULT:
            sortedSongList.sort{$0["title"]!.first! < $1["title"]!.first!}
        case .ALPHABETIC_ALBUM:
            sortedSongList.sort{$0["album"]!.first! < $1["album"]!.first!}
        case .ALPHABETIC_ARTIST:
            sortedSongList.sort{$0["artist"]!.first! < $1["artist"]!.first!}
        case .ALPHABETIC_COMPOSER:
            sortedSongList.sort{$0["composer"]!.first! < $1["composer"]!.first!}
        case .DISPLAY_NAME:
            sortedSongList.sort{$0["_display_name"]!.first! < $1["_display_name"]!.first!}
        case .GREATER_DURATION:
            sortedSongList.sort{$0["duration"]! > $1["duration"]!}
        case .SMALLER_DURATION:
            sortedSongList.sort{$0["duration"]! < $1["duration"]!}
        case .GREATER_TRACK_NUMBER:
            sortedSongList.sort{$0["track"]! > $1["track"]!}
        case .SMALLER_TRACK_NUMBER:
            sortedSongList.sort{$0["track"]! < $1["track"]!}
        case SongSortType.CURRENT_IDs_ORDER:
            sortedSongList.sort{$0["_id"]! < $1["_id"]!}
        default:
            break;
        }
        
        //debug
        for song in sortedSongList {
            print(song["title"] ?? "n/a")
        }
        
        print("\(sortedSongList.count)" + " songs")
        
        result(sortedSongList)
    }
    
}
