//
//  AudioQueryDelegate.swift
//  flutter_audio_query
//
//  Created by lukas on 14.09.20.
//

import Foundation
import MediaPlayer

@available(iOS 9.3, *)
public class AudioQueryDelegate: AudioQueryDelegateProtocol {
    //private let m_instance = AudioQueryDelegate()
    private let ERROR_CODE_PENDING_RESULT = "pending_result";
    private let ERROR_CODE_PERMISSION_DENIED = "PERMISSION DENIED";
    private let SORT_TYPE = "sort_type";
    private let PLAYLIST_METHOD_TYPE = "method_type";
    private let REQUEST_CODE_PERMISSION_READ_EXTERNAL = 0x01;
    private let REQUEST_CODE_PERMISSION_WRITE_EXTERNAL = 0x02;

    //private final PermissionManager m_permissionManager;

    private var m_pendingCall: FlutterMethodCall?;
    private var m_pendingResult: FlutterResult?;
    
    private var avaibale: Bool = false

    private var  m_artistLoader: ArtistLoader;
    private var  m_albumLoader: AlbumLoader;
    private var  m_songLoader: SongLoader;
    private var  m_genreLoader: GenreLoader;
    private var  m_playlistLoader: PlaylistLoader;
    private var  m_imageLoader: ImageLoader;
    
    init(){
        m_artistLoader = ArtistLoader()
        m_albumLoader = AlbumLoader()
        m_songLoader = SongLoader()
        m_genreLoader = GenreLoader()
        m_playlistLoader = PlaylistLoader()
        m_imageLoader = ImageLoader()
        
        MPMediaLibrary.requestAuthorization {
            (status) in
            if status == .authorized {
                self.avaibale = true
            }
        }
    }
    
    /**
     * Method used to handle all method calls that is about artist.
     * @param call Method call
     * @param result results input
     */
    
    public func artistSourceHandler(_ call: FlutterMethodCall, _ result: FlutterResult){
        /* if ( canIbeDependency(call, result) ){

            if (m_permissionManager.isPermissionGranted(Manifest.permission.READ_EXTERNAL_STORAGE) ){
                 clearPendencies(); */
                handleReadOnlyMethods(call, result);
            /* } else
                m_permissionManager.askForPermission(Manifest.permission.READ_EXTERNAL_STORAGE,
                        REQUEST_CODE_PERMISSION_READ_EXTERNAL);

        } else finishWithAlreadyActiveError(result); */

    }


    /**
     * Method used to handle all method calls that is about album data queries.
     * @param call Method call
     * @param result results input
     */
    
    public func albumSourceHandler(_ call: FlutterMethodCall, _ result: FlutterResult) {
        /* if ( canIbeDependency(call, result)){

            if (m_permissionManager.isPermissionGranted(Manifest.permission.READ_EXTERNAL_STORAGE) ){
                 clearPendencies(); */
                handleReadOnlyMethods(call, result);
            /* } else
                m_permissionManager.askForPermission(Manifest.permission.READ_EXTERNAL_STORAGE,
                        REQUEST_CODE_PERMISSION_READ_EXTERNAL);
        } else finishWithAlreadyActiveError(result); */
    }

    /**
     * Method used to handle all method calls that is about song data queries.
     * @param call Method call
     * @param result results input
     */
    
    public func songSourceHandler(_ call: FlutterMethodCall, _ result: FlutterResult){
        /* if ( canIbeDependency(call, result)){

            if (m_permissionManager.isPermissionGranted(Manifest.permission.READ_EXTERNAL_STORAGE) ){
                 clearPendencies(); */
                handleReadOnlyMethods(call, result);
            /* } else
                m_permissionManager.askForPermission(Manifest.permission.READ_EXTERNAL_STORAGE,
                        REQUEST_CODE_PERMISSION_READ_EXTERNAL);
        } else finishWithAlreadyActiveError(result); */
    }

    public func artworkSourceHandler(_ call: FlutterMethodCall, _ result: FlutterResult){
        /* if ( canIbeDependency(call, result)){

            if (m_permissionManager.isPermissionGranted(Manifest.permission.READ_EXTERNAL_STORAGE) ){
                 clearPendencies(); */
                handleReadOnlyMethods(call, result);
            /* } else
                m_permissionManager.askForPermission(Manifest.permission.READ_EXTERNAL_STORAGE,
                        REQUEST_CODE_PERMISSION_READ_EXTERNAL);
        } else finishWithAlreadyActiveError(result); */
    }

    /**
     * Method used to handle all method calls that is about genre data queries.
     * @param call Method call
     * @param result results input
     */
    
    public func genreSourceHandler(_ call: FlutterMethodCall, _ result: FlutterResult){
        /* if ( canIbeDependency(call, result)){

            if (m_permissionManager.isPermissionGranted(Manifest.permission.READ_EXTERNAL_STORAGE) ){
                 clearPendencies(); */
                handleReadOnlyMethods(call, result);
            /*}
                else
                m_permissionManager.askForPermission(Manifest.permission.READ_EXTERNAL_STORAGE,
                        REQUEST_CODE_PERMISSION_READ_EXTERNAL);
        }
        else
            finishWithAlreadyActiveError(result);*/
    }

    /*
     * Method used to handle all method calls that is about playlist.
     * @param call Method call
     * @param result results input
     */
    
    public func playlistSourceHandler(_ call: FlutterMethodCall, _ result: FlutterResult){
        /*PlaylistLoader.PlayListMethodType type =
                PlaylistLoader.PlayListMethodType.values()[ (int) call.argument(PLAYLIST_METHOD_TYPE)];

        switch (type){
            case READ:
                /* if ( canIbeDependency(call, result)){

                    if (m_permissionManager.isPermissionGranted(Manifest.permission.READ_EXTERNAL_STORAGE) ){
                         clearPendencies(); */
                        handleReadOnlyMethods(call, result);
                    /*}
                    else
                        m_permissionManager.askForPermission(Manifest.permission.READ_EXTERNAL_STORAGE,
                                REQUEST_CODE_PERMISSION_READ_EXTERNAL);
                } else finishWithAlreadyActiveError(result); */
                break;

            //in iOS Playlists are read only
            /*case WRITE:
                /* if ( canIbeDependency(call, result)){

                    if (m_permissionManager.isPermissionGranted(Manifest.permission.WRITE_EXTERNAL_STORAGE) ){
                         clearPendencies(); */
                        handleWriteMethods(call, result);
                    /*}
                    else
                        m_permissionManager.askForPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE,
                                REQUEST_CODE_PERMISSION_WRITE_EXTERNAL);
                } else finishWithAlreadyActiveError(result); */
                break;*/

            default:
                result(FlutterMethodNotImplemented);
                break;
        }*/
        handleReadOnlyMethods(call, result)
    }

    /**
     * This method do the real delegate work. After all validation process this method
     * delegates the calls that are read only to a required loader class where all call happen in background.
     * @param call method to be called.
     * @param result results input object.
     */
    private func handleReadOnlyMethods(_ call: FlutterMethodCall, _ result: FlutterResult){
        
        if(!avaibale){
            result(FlutterMethodNotImplemented)
            return
        }

        let arguments = call.arguments as? [String: Any]
        switch (call.method){

            // artists calls section
            case "getArtists":
                //m_artistLoader.getArtists(result, ArtistSortType.values()[(int)call.argument(SORT_TYPE)] );
                m_artistLoader.getArtists(result, ArtistSortType.init(rawValue: arguments![SORT_TYPE] as! Int)!)
                print("get Artists")
                break;

            case "getArtistsById":
                let idList = arguments!["artist_ids"] as! [String]
                m_artistLoader.getArtistsByID(result, idList, ArtistSortType.init(rawValue: arguments![SORT_TYPE] as! Int)!)
                print("getArtistsById: \(arguments ?? ["args": "no args"])")
                break;

            case "getArtistsFromGenre":
                /*m_artistLoader.getArtistsFromGenre(result, (String)call.argument("genre_name"),
                        ArtistSortType.values()[(int)call.argument(SORT_TYPE)] );*/
                let genre = arguments!["genre_name"] as! String
                m_artistLoader.getArtistsFromGenre(result, genre, ArtistSortType.init(rawValue: arguments![SORT_TYPE] as! Int)!)
                print("getArtistsFromGenre: \(arguments ?? ["args": "no args"])")
                break;

            case "searchArtistsByName":
//                m_artistLoader.searchArtistsByName( result,
//                        (String)call.argument("query"),
//                        ArtistSortType.values()[(int)call.argument(SORT_TYPE)] );
                let name = arguments!["query"] as! String
                m_artistLoader.searchArtists(result, name, ArtistSortType.init(rawValue: arguments![SORT_TYPE] as! Int)!)
                print("searchArtistsByName: \(arguments ?? ["args": "no args"])")
                break;

            //album calls section
            case "getAlbums":
                m_albumLoader.getAlbums(result, AlbumSortType.init(rawValue: arguments![SORT_TYPE] as! Int)!);
                print("getAlbums: \(arguments ?? ["args": "no args"])")
                break;

            case "getAlbumsById":
                let idList = arguments!["album_ids"] as! [String]
                m_albumLoader.getAlbumsByID(result, idList, AlbumSortType.init(rawValue: arguments![SORT_TYPE] as! Int)!)
                print("getAlbumsById: \(arguments ?? ["args": "no args"])")

                break;
            
            case "getAlbumsFromArtist":
                
                let artist = arguments!["artist"] as! String
                m_albumLoader.getAlbumsFromArtist(result, artist, AlbumSortType.init(rawValue: arguments![SORT_TYPE] as! Int)!)
                print("getAlbumsFromArtist: \(arguments ?? ["args": "no args"])")
                break;

            case "getAlbumsFromGenre":
                let genre = arguments!["genre_name"] as! String
                m_albumLoader.getAlbumsFromGenre(result, genre, AlbumSortType.init(rawValue: arguments![SORT_TYPE] as! Int)!)
                print("getAlbumsFromGenre: \(arguments ?? ["args": "no args"])")
                break;

            case "searchAlbums":
//                m_albumLoader.searchAlbums(result, (String)call.argument("query"),
//                        AlbumSortType.values()[(int)call.argument(SORT_TYPE)] );
                let name = arguments!["query"] as! String
                m_albumLoader.searchAlbums(result, name, AlbumSortType.init(rawValue: arguments![SORT_TYPE] as! Int)!)
                print("searchAlbums: \(arguments ?? ["args": "no args"])")
                break;

            // song calls section
            case "getSongs":
                //m_songLoader.getSongs(result, SongSortType.values()[(int)call.argument(SORT_TYPE)] );
                m_songLoader.getSongs(result, SongSortType.init(rawValue: arguments![SORT_TYPE] as! Int)!)
                print("getSongs: \(arguments ?? ["args": "no args"])")
                break;

            case "getSongsFromAlbum":
//                idList = call.argument("song_ids");
//                m_songLoader.getSongsById(result, idList,
//                        SongSortType.values()[(int)call.argument(SORT_TYPE)]);
                let album = arguments!["album_id"] as! String
                m_songLoader.getSongsFromAlbum(result, album, SongSortType.init(rawValue: arguments?[SORT_TYPE] as? Int ?? 0)!)
                print("getSongsFromAlbum: \(arguments ?? ["args": "no args"])")
                break;

            case "getSongsFromArtist":
//                m_songLoader.getSongsFromArtist( result, (String) call.argument("artist" ),
//                        SongSortType.values()[ (int)call.argument(SORT_TYPE) ] );
                let artist = arguments!["artist"] as! String
                m_songLoader.getSongsFromArtist(result, artist, SongSortType.init(rawValue: arguments![SORT_TYPE] as! Int)!)
                print("getSongsFromArtist: \(arguments ?? ["args": "no args"])")
                break;

            case "getSongsFromArtistAlbum":
//                m_songLoader.getSongsFromAlbum( result,
//                        (String) call.argument("album_id" ),
//                        SongSortType.values()[ (int)call.argument(SORT_TYPE) ] );
                let artist = arguments!["artist"] as! String
                let album = arguments!["album_id"] as! String
                m_songLoader.getSongsFromArtistAlbum(result, artist, album, SongSortType.init(rawValue: arguments![SORT_TYPE] as! Int)!)
                print("getSongsFromArtistAlbum: \(arguments ?? ["args": "no args"])")
                break;

            case "getSongsFromGenre":
//                m_songLoader.getSongsFromGenre(result, (String) call.argument("genre_name"),
//                        SongSortType.values()[ (int)call.argument(SORT_TYPE) ] );
                let genre = arguments!["genre_name"] as! String
                m_songLoader.getSongsFromGenre(result, genre, SongSortType.init(rawValue: arguments![SORT_TYPE] as! Int)!)
                print("getSongsFromGenre: \(arguments ?? ["args": "no args"])")
                break;

            case "getSongsFromPlaylist":
//                final List<String> ids = call.argument("memberIds");
//                m_songLoader.getSongsFromPlaylist(result, ids);
                let ids = arguments!["memberIds"] as! [String]
                m_songLoader.getSongsFromPlaylist(result, ids, SongSortType.DEFAULT)
                print("getSongsFromPlaylist: \(arguments ?? ["args": "no args"])")
                break;

            case "searchSongs":
//                m_songLoader.searchSongs(result, (String)call.argument("query"),
//                        SongSortType.values()[ (int)call.argument(SORT_TYPE) ]);
                let query = arguments!["query"] as! String
                m_songLoader.searchSongs(result, query, SongSortType.init(rawValue: arguments![SORT_TYPE] as! Int)!)
                print("searchSongs: \(arguments ?? ["args": "no args"])")
                break;

            // genre calls section
            case "getGenres":
                //m_genreLoader.getGenres(result, GenreSortType.values()[ (int)call.argument(SORT_TYPE) ]);
                m_genreLoader.getGenres(result, GenreSortType.init(rawValue: arguments![SORT_TYPE] as! Int)!)
                print("getGenres: \(arguments ?? ["args": "no args"])")
                break;

            case "searchGenres":
//                m_genreLoader.searchGenres(result, (String) call.argument("query"),
//                        GenreSortType.values()[ (int)call.argument(SORT_TYPE) ] );
                let query = arguments!["query"] as! String
                m_genreLoader.searchGenres(result, query, GenreSortType.init(rawValue: arguments![SORT_TYPE] as! Int)!)
                print("searchGenres: \(arguments ?? ["args": "no args"])")
                break;

                // playlist read calls section
            case "getPlaylists":
//                m_playlistLoader.getPlaylists(result,
//                        PlaylistSortType.values()[(int)call.argument(SORT_TYPE)]);
                m_playlistLoader.getPlaylists(result, PlaylistSortType.init(rawValue: arguments![SORT_TYPE] as! Int)!)
                print("getPlaylists: \(arguments ?? ["args": "no args"])")
                break;

            case "searchPlaylists":
//                m_playlistLoader.searchPlaylists(result, (String)call.argument("query"),
//                        PlaylistSortType.values()[(int)call.argument(SORT_TYPE)]);
                let query = arguments!["query"] as! String
                m_playlistLoader.searchPlaylists(result, query, PlaylistSortType.init(rawValue: arguments![SORT_TYPE] as! Int)!)
                print("searchPlaylists: \(arguments ?? ["args": "no args"])")
                break;

            case "getArtwork":
//                if (android.os.Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q){
//                    int resourceType = (int) call.argument( "resource" );
//                    String resourceId = (String) call.argument( "id" );
//                    int width = (int) call.argument("width");
//                    int height = (int) call.argument("height");
//                    m_imageLoader.searchArtworkBytes(result, resourceType, resourceId,
//                            new Size(width, height));
//                }
//                else result.notImplemented();
                let id = arguments!["id"] as! String
                let width = arguments!["width"] as? Int
                let height = arguments!["height"] as? Int
                let type = arguments!["resource"] as? Int
                m_imageLoader.getArtworkByID(result, id, type ?? 0, Double(width ?? 250), Double(height ?? 250))
                print("getArtwork: \(arguments ?? ["args": "no args"])")

                break;

            default:
                result(FlutterMethodNotImplemented);
        }

    }

    /**
     * This method handle all methods calls that need write something on
     * device memory.
     * @param call
     * @param result
     */
    /*private func handleWriteMethods(_ call: FlutterMethodCall, _ result: FlutterResult){
        String playlistId;
        String songId;
        final String keyPlaylistName = "playlist_name";
        final String keyPlaylistId = "playlist_id";
        final String keySongId = "song_id";

        final String keyFromPosition = "from";
        final String keyToPosition = "to";

        switch (call.method){

            case "createPlaylist":
                String name = call.argument(keyPlaylistName);
                m_playlistLoader.createPlaylist(result, name);
                break;

            case "addSongToPlaylist":
                playlistId = call.argument( keyPlaylistId );
                songId = call.argument( keySongId );
                m_playlistLoader.addSongToPlaylist(result, playlistId, songId);
                break;

            case "removeSongFromPlaylist":
                playlistId = call.argument(keyPlaylistId);
                songId = call.argument(keySongId);
                m_playlistLoader.removeSongFromPlaylist(result, playlistId, songId);
                break;

            case "removePlaylist":
                playlistId = call.argument(keyPlaylistId);
                m_playlistLoader.removePlaylist(result, playlistId);
                break;

            case "moveSong":
                playlistId = call.argument(keyPlaylistId);
                m_playlistLoader.moveSong(result, playlistId,
                        ((int) call.argument(keyFromPosition) ),
                        ((int)call.argument(keyToPosition))
                );
                break;

            default:
                result.notImplemented();
        }
    }*/
    
}

protocol AudioQueryDelegateProtocol{

    /**
     * Interface method to handle artist queries related calls
     * @param call
     * @param result
     */
    func artistSourceHandler(_ call: FlutterMethodCall, _ result: FlutterResult);

    /**
     * Interface method to handle album queries related calls
     * @param call
     * @param result
     */
    func albumSourceHandler(_ call: FlutterMethodCall, _ result: FlutterResult);

    /**
     * Interface method to handle song queries related calls
     * @param call
     * @param result
     */
    func songSourceHandler(_ call: FlutterMethodCall, _ result: FlutterResult);

    /**
     * Interface method to handle genre queries related calls
     * @param call
     * @param result
     */
    func genreSourceHandler(_ call: FlutterMethodCall, _ result: FlutterResult);

    /**
     * Interface method to handle playlist related calls
     * @param call
     * @param result
     */
    func playlistSourceHandler(_ call: FlutterMethodCall, _ result: FlutterResult);
}
