package boaventura.com.devel.br.flutteraudioquery.delegate;

import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.content.pm.PackageManager;
import android.os.Build;
import android.util.Log;
import android.util.Size;

import java.util.List;

import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import boaventura.com.devel.br.flutteraudioquery.loaders.AlbumLoader;
import boaventura.com.devel.br.flutteraudioquery.loaders.ArtistLoader;
import boaventura.com.devel.br.flutteraudioquery.loaders.GenreLoader;
import boaventura.com.devel.br.flutteraudioquery.loaders.ImageLoader;
import boaventura.com.devel.br.flutteraudioquery.loaders.PlaylistLoader;
import boaventura.com.devel.br.flutteraudioquery.loaders.SongLoader;
import boaventura.com.devel.br.flutteraudioquery.sortingtypes.AlbumSortType;
import boaventura.com.devel.br.flutteraudioquery.sortingtypes.ArtistSortType;
import boaventura.com.devel.br.flutteraudioquery.sortingtypes.GenreSortType;
import boaventura.com.devel.br.flutteraudioquery.sortingtypes.PlaylistSortType;
import boaventura.com.devel.br.flutteraudioquery.sortingtypes.SongSortType;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.view.FlutterNativeView;

///
// * AudioQueryDelegate makes a validation if a method call can be executed, permission validation and
// * requests and delegates the desired method call to a required loader class where the real call
// * happens in background
// *
// * <p>The work flow in this class is: </p>
// * <p>1) Verify if  already exists a call method to be executed. If there's we finish with a error if not
// *  we go to step 2.</p>
// *
// *  <p>2) Verify if we have system permissions to run a specific method. If permission is granted we go
// *  to step 3, if not, we make a system permission request and if permission is denied we finish with a
// *  permission_denial error other way we go to step 3.</p>
// *
// *  <p>3) After all validation process we delegate the current method call to a required Loader class
// *  to do a hard work in background. </p>
// *
// */


public class AudioQueryDelegate implements PluginRegistry.RequestPermissionsResultListener,
    AudioQueryDelegateInterface {

    private static AudioQueryDelegate m_instance;

    private static final String ERROR_CODE_PENDING_RESULT = "pending_result";
    private static final String ERROR_CODE_PERMISSION_DENIED = "PERMISSION DENIED";
    private static final String SORT_TYPE = "sort_type";
    private static final String PLAYLIST_METHOD_TYPE = "method_type";
    private static final int REQUEST_CODE_PERMISSION_READ_EXTERNAL = 0x01;
    private static final int REQUEST_CODE_PERMISSION_WRITE_EXTERNAL = 0x02;

    private final PermissionManager m_permissionManager;

    private MethodCall m_pendingCall;
    private MethodChannel.Result m_pendingResult;

    private final ArtistLoader m_artistLoader;
    private final AlbumLoader m_albumLoader;
    private final SongLoader m_songLoader;
    private final GenreLoader m_genreLoader;
    private final PlaylistLoader m_playlistLoader;
    private final ImageLoader m_imageLoader;



    public static final AudioQueryDelegate instance(final Context context, final Activity activity){
        if (m_instance == null)
            m_instance = new AudioQueryDelegate(context, activity);

        return m_instance;
    }

    public static final AudioQueryDelegate instance(final PluginRegistry.Registrar registrar){
        if (m_instance == null)
            m_instance = new AudioQueryDelegate(registrar);

        return m_instance;
    }

    private AudioQueryDelegate(final Context context, final Activity activity){
        m_artistLoader = new ArtistLoader(context );
        m_albumLoader = new AlbumLoader(context );
        m_songLoader = new SongLoader( context );
        m_genreLoader = new GenreLoader( context );
        m_playlistLoader = new PlaylistLoader( context );
        m_imageLoader = new ImageLoader(context);

        m_permissionManager = new PermissionManager() {
            @Override
            public boolean isPermissionGranted(String permissionName) {

                return (ContextCompat.checkSelfPermission( activity, permissionName)
                        == PackageManager.PERMISSION_GRANTED);
            }

            @Override
            public void askForPermission(String permissionName, int requestCode) {
                ActivityCompat.requestPermissions(activity, new String[] {permissionName}, requestCode);
            }
        };
    }

    private AudioQueryDelegate(final PluginRegistry.Registrar registrar){

        m_artistLoader = new ArtistLoader(registrar.context() );
        m_albumLoader = new AlbumLoader(registrar.context() );
        m_songLoader = new SongLoader( registrar.context() );
        m_genreLoader = new GenreLoader( registrar.context() );
        m_playlistLoader = new PlaylistLoader( registrar.context() );
        m_imageLoader = new ImageLoader( registrar.context()  );

        m_permissionManager = new PermissionManager() {
            @Override
            public boolean isPermissionGranted(String permissionName) {

                return (ActivityCompat.checkSelfPermission( registrar.activity(), permissionName)
                    == PackageManager.PERMISSION_GRANTED);
            }

            @Override
            public void askForPermission(String permissionName, int requestCode) {
                ActivityCompat.requestPermissions(registrar.activity(), new String[] {permissionName}, requestCode);
            }
        };

        registrar.addRequestPermissionsResultListener(this);
        registrar.addViewDestroyListener(new PluginRegistry.ViewDestroyListener() {
            @Override
            public boolean onViewDestroy(FlutterNativeView flutterNativeView) {
                // ideal
                Log.i("MDBG", "onViewDestroy");
                return true;
            }
        });
    }


    /**
     * Method used to handle all method calls that is about artist.
     * @param call Method call
     * @param result results input
     */
    @Override
    public void artistSourceHandler(MethodCall call, MethodChannel.Result result){
        if ( canIbeDependency(call, result) ){

            if (m_permissionManager.isPermissionGranted(Manifest.permission.READ_EXTERNAL_STORAGE) ){
                clearPendencies();
                handleReadOnlyMethods(call, result);
            }

            else
                m_permissionManager.askForPermission(Manifest.permission.READ_EXTERNAL_STORAGE,
                        REQUEST_CODE_PERMISSION_READ_EXTERNAL);

        } else finishWithAlreadyActiveError(result);

    }


    /**
     * Method used to handle all method calls that is about album data queries.
     * @param call Method call
     * @param result results input
     */
    @Override
    public void albumSourceHandler(MethodCall call, MethodChannel.Result result) {
        if ( canIbeDependency(call, result)){

            if (m_permissionManager.isPermissionGranted(Manifest.permission.READ_EXTERNAL_STORAGE) ){
                clearPendencies();
                handleReadOnlyMethods(call, result);
            }
            else
                m_permissionManager.askForPermission(Manifest.permission.READ_EXTERNAL_STORAGE,
                        REQUEST_CODE_PERMISSION_READ_EXTERNAL);
        } else finishWithAlreadyActiveError(result);
    }

    /**
     * Method used to handle all method calls that is about song data queries.
     * @param call Method call
     * @param result results input
     */
    @Override
    public void songSourceHandler(MethodCall call, MethodChannel.Result result){
        if ( canIbeDependency(call, result)){

            if (m_permissionManager.isPermissionGranted(Manifest.permission.READ_EXTERNAL_STORAGE) ){
                clearPendencies();
                handleReadOnlyMethods(call, result);
            }
            else
                m_permissionManager.askForPermission(Manifest.permission.READ_EXTERNAL_STORAGE,
                        REQUEST_CODE_PERMISSION_READ_EXTERNAL);
        } else finishWithAlreadyActiveError(result);
    }

    public void artworkSourceHandler(MethodCall call, MethodChannel.Result result){
        if ( canIbeDependency(call, result)){

            if (m_permissionManager.isPermissionGranted(Manifest.permission.READ_EXTERNAL_STORAGE) ){
                clearPendencies();
                handleReadOnlyMethods(call, result);
            }
            else
                m_permissionManager.askForPermission(Manifest.permission.READ_EXTERNAL_STORAGE,
                        REQUEST_CODE_PERMISSION_READ_EXTERNAL);
        } else finishWithAlreadyActiveError(result);
    }

    /**
     * Method used to handle all method calls that is about genre data queries.
     * @param call Method call
     * @param result results input
     */
    @Override
    public void genreSourceHandler(MethodCall call, MethodChannel.Result result){
        if ( canIbeDependency(call, result)){

            if (m_permissionManager.isPermissionGranted(Manifest.permission.READ_EXTERNAL_STORAGE) ){
                clearPendencies();
                handleReadOnlyMethods(call, result);
            }

            else
                m_permissionManager.askForPermission(Manifest.permission.READ_EXTERNAL_STORAGE,
                        REQUEST_CODE_PERMISSION_READ_EXTERNAL);
        }
        else
            finishWithAlreadyActiveError(result);
    }

    /**
     * Method used to handle all method calls that is about playlist.
     * @param call Method call
     * @param result results input
     */
    @Override
    public void playlistSourceHandler(MethodCall call, MethodChannel.Result result){
        PlaylistLoader.PlayListMethodType type =
                PlaylistLoader.PlayListMethodType.values()[ (int) call.argument(PLAYLIST_METHOD_TYPE)];

        switch (type){
            case READ:
                if ( canIbeDependency(call, result)){

                    if (m_permissionManager.isPermissionGranted(Manifest.permission.READ_EXTERNAL_STORAGE) ){
                        clearPendencies();
                        handleReadOnlyMethods(call, result);
                    }
                    else
                        m_permissionManager.askForPermission(Manifest.permission.READ_EXTERNAL_STORAGE,
                                REQUEST_CODE_PERMISSION_READ_EXTERNAL);
                } else finishWithAlreadyActiveError(result);
                break;

            case WRITE:
                if ( canIbeDependency(call, result)){

                    if (m_permissionManager.isPermissionGranted(Manifest.permission.WRITE_EXTERNAL_STORAGE) ){
                        clearPendencies();
                        handleWriteMethods(call, result);
                    }
                    else
                        m_permissionManager.askForPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE,
                                REQUEST_CODE_PERMISSION_WRITE_EXTERNAL);
                } else finishWithAlreadyActiveError(result);
                break;

            default:
                result.notImplemented();
                break;
        }
    }

    /**
     * This method do the real delegate work. After all validation process this method
     * delegates the calls that are read only to a required loader class where all call happen in background.
     * @param call method to be called.
     * @param result results input object.
     */
    private void handleReadOnlyMethods(MethodCall call, MethodChannel.Result result){

        List<String> idList = null;
        switch (call.method){

            // artists calls section
            case "getArtists":
                m_artistLoader.getArtists(result, ArtistSortType.values()[(int)call.argument(SORT_TYPE)] );
                break;

            case "getArtistsById":
                idList = call.argument("artist_ids");
                m_artistLoader.getArtistsById(result, idList,
                        ArtistSortType.values()[(int)call.argument(SORT_TYPE)]);
                break;

            case "getArtistsFromGenre":
                m_artistLoader.getArtistsFromGenre(result, (String)call.argument("genre_name"),
                        ArtistSortType.values()[(int)call.argument(SORT_TYPE)] );
                break;

            case "searchArtistsByName":
                m_artistLoader.searchArtistsByName( result,
                        (String)call.argument("query"),
                        ArtistSortType.values()[(int)call.argument(SORT_TYPE)] );
                break;

            //album calls section
            case "getAlbums":
                m_albumLoader.getAlbums(result, AlbumSortType.values()[(int)call.argument(SORT_TYPE)] );
                break;

            case "getAlbumsById":
                idList =  call.argument("album_ids");
                m_albumLoader.getAlbumsById(result, idList,
                        AlbumSortType.values()[(int)call.argument(SORT_TYPE)]);
                break;
            case "getAlbumsFromArtist":
                String artist = call.argument("artist" );
                m_albumLoader.getAlbumsFromArtist(result, artist,
                        AlbumSortType.values()[(int)call.argument(SORT_TYPE)]);
                break;

            case "getAlbumsFromGenre":
                m_albumLoader.getAlbumFromGenre(result, (String)call.argument("genre_name"),
                        AlbumSortType.values()[(int)call.argument(SORT_TYPE)] );
                break;

            case "searchAlbums":
                m_albumLoader.searchAlbums(result, (String)call.argument("query"),
                        AlbumSortType.values()[(int)call.argument(SORT_TYPE)] );
                break;

            // song calls section
            case "getSongs":
                m_songLoader.getSongs(result, SongSortType.values()[(int)call.argument(SORT_TYPE)] );
                break;

            case "getSongsById":
                idList = call.argument("song_ids");
                m_songLoader.getSongsById(result, idList,
                        SongSortType.values()[(int)call.argument(SORT_TYPE)]);
                break;

            case "getSongsFromArtist":
                m_songLoader.getSongsFromArtist( result, (String) call.argument("artist" ),
                        SongSortType.values()[ (int)call.argument(SORT_TYPE) ] );
                break;

            case "getSongsFromAlbum":
                m_songLoader.getSongsFromAlbum( result,
                        (String) call.argument("album_id" ),
                        SongSortType.values()[ (int)call.argument(SORT_TYPE) ] );
                break;

            case "getSongsFromArtistAlbum":
                m_songLoader.getSongsFromArtistAlbum( result,
                        (String) call.argument("album_id" ),
                        (String) call.argument("artist"),
                        SongSortType.values()[ (int)call.argument(SORT_TYPE) ] );
                break;

            case "getSongsFromGenre":
                m_songLoader.getSongsFromGenre(result, (String) call.argument("genre_name"),
                        SongSortType.values()[ (int)call.argument(SORT_TYPE) ] );
                break;

            case "getSongsFromPlaylist":
                final List<String> ids = call.argument("memberIds");
                m_songLoader.getSongsFromPlaylist(result, ids);
                break;

            case "searchSongs":
                m_songLoader.searchSongs(result, (String)call.argument("query"),
                        SongSortType.values()[ (int)call.argument(SORT_TYPE) ]);
                break;

            // genre calls section
            case "getGenres":
                m_genreLoader.getGenres(result, GenreSortType.values()[ (int)call.argument(SORT_TYPE) ]);
                break;

            case "searchGenres":
                m_genreLoader.searchGenres(result, (String) call.argument("query"),
                        GenreSortType.values()[ (int)call.argument(SORT_TYPE) ] );
                break;

                // playlist read calls section
            case "getPlaylists":
                m_playlistLoader.getPlaylists(result,
                        PlaylistSortType.values()[(int)call.argument(SORT_TYPE)]);
                break;

            case "searchPlaylists":
                m_playlistLoader.searchPlaylists(result, (String)call.argument("query"),
                        PlaylistSortType.values()[(int)call.argument(SORT_TYPE)]);
                break;

            case "getArtwork":
                if (android.os.Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q){
                    int resourceType = (int) call.argument( "resource" );
                    String resourceId = (String) call.argument( "id" );
                    int width = (int) call.argument("width");
                    int height = (int) call.argument("height");
                    m_imageLoader.searchArtworkBytes(result, resourceType, resourceId,
                            new Size(width, height));
                }
                else result.notImplemented();

                break;

            default:
                result.notImplemented();
        }

    }

    /**
     * This method handle all methods calls that need write something on
     * device memory.
     * @param call
     * @param result
     */
    private void handleWriteMethods(MethodCall call, MethodChannel.Result result){
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
    }

    private boolean canIbeDependency(MethodCall call, MethodChannel.Result result){
        if ( !setPendingMethodAndCall(call, result) ){
            return false;
        }
        return true;
    }

    private boolean setPendingMethodAndCall(MethodCall call, MethodChannel.Result result){
        //There is something that needs to be delivered...
        if (m_pendingResult != null)
            return false;

        m_pendingCall = call;
        m_pendingResult = result;
        return true;
    }

    private void clearPendencies(){
        m_pendingResult = null;
        m_pendingCall = null;
    }

    private void finishWithAlreadyActiveError(MethodChannel.Result result){
        result.error(ERROR_CODE_PENDING_RESULT,
                "There is some result to be delivered", null);
    }

    private void finishWithError(String errorKey, String errorMsg, MethodChannel.Result result){
        clearPendencies();
        result.error(errorKey, errorMsg, null);
    }

    @Override
    public boolean onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        boolean permissionGranted = grantResults.length > 0
                && grantResults[0] == PackageManager.PERMISSION_GRANTED;

        switch (requestCode){

            case REQUEST_CODE_PERMISSION_READ_EXTERNAL:
                if (permissionGranted){
                    handleReadOnlyMethods(m_pendingCall, m_pendingResult);
                    clearPendencies();
                }
                else {
                    finishWithError(ERROR_CODE_PERMISSION_DENIED,
                            "READ EXTERNAL PERMISSION DENIED", m_pendingResult);
                }
                break;


            case REQUEST_CODE_PERMISSION_WRITE_EXTERNAL:
                if (permissionGranted){
                    handleWriteMethods(m_pendingCall, m_pendingResult);
                    clearPendencies();
                }

                else {
                    finishWithError(ERROR_CODE_PERMISSION_DENIED,
                            "WRITE EXTERNAL PERMISSION DENIED", m_pendingResult);
                }
                break;

            default:
                return false;
        }

        return true;
    }

    interface PermissionManager {
        boolean isPermissionGranted(String permissionName);
        void askForPermission(String permissionName, int requestCode);
    }
}

interface AudioQueryDelegateInterface{

    /**
     * Interface method to handle artist queries related calls
     * @param call
     * @param result
     */
    void artistSourceHandler(MethodCall call, MethodChannel.Result result);

    /**
     * Interface method to handle album queries related calls
     * @param call
     * @param result
     */
    void albumSourceHandler(MethodCall call, MethodChannel.Result result);

    /**
     * Interface method to handle song queries related calls
     * @param call
     * @param result
     */
    void songSourceHandler(MethodCall call, MethodChannel.Result result);

    /**
     * Interface method to handle genre queries related calls
     * @param call
     * @param result
     */
    void genreSourceHandler(MethodCall call, MethodChannel.Result result);

    /**
     * Interface method to handle playlist related calls
     * @param call
     * @param result
     */
    void playlistSourceHandler(MethodCall call, MethodChannel.Result result);
}