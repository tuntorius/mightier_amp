package boaventura.com.devel.br.flutteraudioquery.loaders;

import android.content.ContentResolver;
import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.net.Uri;
import android.provider.MediaStore;
import android.util.Log;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import boaventura.com.devel.br.flutteraudioquery.loaders.tasks.AbstractLoadTask;
import boaventura.com.devel.br.flutteraudioquery.sortingtypes.PlaylistSortType;
import io.flutter.plugin.common.MethodChannel;


public class PlaylistLoader extends AbstractLoader {

    public enum PlayListMethodType { READ, WRITE }

    private static final String[] PLAYLIST_PROJECTION = {
            MediaStore.Audio.Playlists._ID,
            MediaStore.Audio.Playlists.NAME,
            MediaStore.Audio.Playlists.DATA,
            MediaStore.Audio.Playlists.DATE_ADDED,
    };

    private static final String[] PLAYLIST_MEMBERS_PROJECTION = {
            MediaStore.Audio.Playlists.Members.AUDIO_ID,
            MediaStore.Audio.Playlists.Members.PLAY_ORDER
    };

    public PlaylistLoader(Context context) {
        super(context);
    }


    /**
     * This method get all playlists available on device storage
     * @param result  MethodChannel.Result object to send reply for dart
     * @param sortType PlaylistSortType object to define sort type for data queried.
     */
    public void getPlaylists(final MethodChannel.Result result, final PlaylistSortType sortType){
        createLoadTask(result,null,null,
                parseSortType(sortType),QUERY_TYPE_DEFAULT).execute();
    }

    /**
     * This method is used to parse PlaylistSortType object into a string
     * that will be used in SQL to query data in a specific sort mode.
     * @param sortType PlaylistSortType The type of sort desired.
     * @return A String for SQL language query usage.
     */
    private String parseSortType(final PlaylistSortType sortType){
        String sortOrder = null;

        switch (sortType){
            case DEFAULT:
                sortOrder = MediaStore.Audio.Playlists.DEFAULT_SORT_ORDER;
                break;

            case NEWEST_FIRST:
                sortOrder = MediaStore.Audio.Playlists.DATE_ADDED + " DESC";
                break;

            case OLDEST_FIRST:
                sortOrder = MediaStore.Audio.Playlists.DATE_ADDED + " ASC";
                break;
            default:
                break;
        }

        return sortOrder;
    }

    /**
     * This method gets a specific playlist using it id.
     * @param result MethodChannel.Result object to send reply for dart.
     * @param playlistId Id of playlist.
     */
    private void getPlaylistById(final MethodChannel.Result result, final String playlistId){

        createLoadTask(result, MediaStore.Audio.Playlists._ID + " =?", new String[]{playlistId},
                null, QUERY_TYPE_DEFAULT).execute();
    }

    /**
     * This method query playlist using name as qyery parameter.
     * @param results MethodChannel.Result object to send reply for dart.
     * @param namedQuery query param.
     * @param sortType PlaylistSortType The type of sort desired.
     */
    public void searchPlaylists(final MethodChannel.Result results, final String namedQuery,
                                final PlaylistSortType sortType ){
        String[] args = new String[] { namedQuery + "%"};
        createLoadTask(results,MediaStore.Audio.Playlists.NAME + " like ?", args,
                parseSortType(sortType), QUERY_TYPE_DEFAULT ).execute();
    }

    /**
     * This method creates a new playlist.
     * @param results MethodChannel.Result object to send reply for dart.
     * @param name playlist desired name.
     */
    public void createPlaylist(final MethodChannel.Result results, final String name) {
        if (name != null && name.length() > 0) {
            ContentResolver resolver = getContentResolver();
            final String selection =  PLAYLIST_PROJECTION[1] + " =?";

            if ( !verifyPlaylistExistence(new String[]{ PLAYLIST_PROJECTION[1] }, selection,
                    new String[]{name}) ){
                ContentValues values = new ContentValues();
                values.put(PLAYLIST_PROJECTION[1], name);

                try {
                    Uri uri = resolver.insert(MediaStore.Audio.Playlists.EXTERNAL_CONTENT_URI, values);

                    if (uri!=null)
                        updateResolver();

                    Cursor cursor = resolver.query(
                            uri, PLAYLIST_PROJECTION, null, null,
                            MediaStore.Audio.Playlists.DEFAULT_SORT_ORDER);

                    if (cursor!= null){
                        Map<String, Object> data = new HashMap<>();

                        while(cursor.moveToNext()){
                            try{
                                for (String key : PLAYLIST_PROJECTION) {
                                    String dataValue =  cursor.getString( cursor.getColumnIndex( key ));
                                     data.put(key,dataValue);
                                }
                                data.put("memberIds", new ArrayList<String>());
                            }

                            catch(Exception ex){
                                results.error("PLAYLIST_READING_FAIL", ex.getMessage(), null);
                                cursor.close();
                            }
                        }
                        cursor.close();
                        results.success(data);
                    }
                }

                catch (Exception ex){
                    results.error("NAME_NOT_ACCEPTED", ex.getMessage(), null);
                }
            }

            else
                results.error("PLAYLIST_NAME_EXISTS", "Playlist " + name + " already exists" ,null);
        }

        else
            results.error("INVALID PLAYLIST NAME","Invalid name", null);

    }

    /**
     * This method is used to remove an entire playlist.
     * @param results MethodChannel.Result object to send reply for dart.
     * @param playlistId Playlist Id that will be removed.
     */
    public void removePlaylist(final MethodChannel.Result results, final String playlistId){
        ContentResolver resolver = getContentResolver();
        try {
            int rows = resolver.delete(MediaStore.Audio.Playlists.EXTERNAL_CONTENT_URI,
                    MediaStore.Audio.Playlists._ID + "=?", new String[]{playlistId});
            updateResolver();
            results.success("");
        }
        catch (Exception ex){
            results.error("PLAYLIST_DELETE_FAIL", "Was not possible remove playlist", null);
        }
    }

    /**
     * This method is used to add a song to playlist. After add song the updated playlist is
     * sent to dart side code.
     * @param results MethodChannel.Result object to send reply for dart.
     * @param playlistId Id of the playlist that we want add song
     * @param songId Id of the song that we will add to playlist..
     */
    public void addSongToPlaylist(final MethodChannel.Result results, final String playlistId,
                                  final String songId){

        Uri playlistUri = MediaStore.Audio.Playlists.Members.getContentUri("external",
                Long.parseLong(playlistId));

        int base = getBase(playlistUri);

        if (base != -1){
            ContentResolver resolver = getContentResolver();
            ContentValues values = new ContentValues();
            values.put(MediaStore.Audio.Playlists.Members.AUDIO_ID, songId);
            values.put(MediaStore.Audio.Playlists.Members.PLAY_ORDER, base);
            resolver.insert(playlistUri, values);
            //updateResolver();
            getPlaylistById(results, playlistId);
        }

        else {
            results.error("Error adding song to playlist", "base value " + base,null);
        }
    }

    /**
     *
     * @param results MethodChannel.Result object to send reply for dart.
     * @param playlistId
     * @param from
     * @param to
     */
    public void moveSong(final MethodChannel.Result results,
                         final String playlistId, final int from, final int to){

        if ( (from >= 0) && (to >= 0) ){
            boolean result = MediaStore.Audio.Playlists.Members.moveItem(getContentResolver(),
                    Long.parseLong(playlistId), from, to);

            if (result){
                updateResolver();
                getPlaylistById(results, playlistId);
            }

            else
                results.error("SONG_SWAP_NO_SUCCESS", "Song swap operation was not success", null);
        }

        else {
            results.error("SONG_SWAP_NULL_ID", "Some song is null",null);
        }

    }


    private void updateResolver(){
        getContentResolver().notifyChange(Uri.parse("content://media"), null);
    }

    /**
     * This method
     * @param results MethodChannel.Result object to send reply for dart.
     * @param playlistId
     * @param songId
     */
    public void removeSongFromPlaylist(final MethodChannel.Result results, final String playlistId,
                                       final String songId){

        if (playlistId != null && songId != null){
            final String selection = PLAYLIST_PROJECTION[0] + " = '" + playlistId + "'";

            if ( !verifyPlaylistExistence( new String[]{PLAYLIST_PROJECTION[0]}, selection, null )){
                results.error("Unavailable playlist", "", null);
                return;
            }

            ContentResolver resolver = getContentResolver();
            Uri uri = MediaStore.Audio.Playlists.Members.getContentUri("external",
                    Long.parseLong(playlistId ) );


            int deletedRows = resolver.delete(uri, MediaStore.Audio.Playlists.Members.AUDIO_ID + " =?",
                    new String[]{ songId } );

            if (deletedRows > 0 ){
                updateResolver();
                getPlaylistById(results, playlistId);
            }

            else results.error("Was not possible delete song data from this playlist","",null);
        }

        else {
            results.error("Error removing song from playlist", "",null);
        }
    }

    /**
     *
     * @param playlistUri
     * @return
     */
    private int getBase(final Uri playlistUri){
        String[] col = new String[]{ "count(*)"};
        int base = -1;

        Cursor cursor = getContentResolver().query(playlistUri, col, null,null,null );
        if (cursor != null){
            cursor.moveToNext();
            base = cursor.getInt(0);
            base +=1;
            cursor.close();
        }
        return base;
    }


    /**
     * This method verify if a playlist already exists.
     * @param projection
     * @param selection
     * @param args
     * @return
     */
    private boolean verifyPlaylistExistence(final String[] projection, final String selection, final String[] args){
        boolean flag = false;
        Cursor cursor = getContentResolver().query(MediaStore.Audio.Playlists.EXTERNAL_CONTENT_URI,
                projection, selection, args, null);

        if ( (cursor!=null) && (cursor.getCount() > 0) ){
            flag = true;
            cursor.close();
        }
        return flag;
    }

    @Override
    protected PlaylistLoadTask createLoadTask(
            MethodChannel.Result result, String selection, String[] selectionArgs, String sortOrder, int type) {

        return new PlaylistLoadTask(result, getContentResolver(), selection, selectionArgs, sortOrder);
    }

    static class PlaylistLoadTask extends AbstractLoadTask< List<Map<String, Object>> >{
        private ContentResolver m_resolver;
        private MethodChannel.Result m_result;


        /**
         * Constructor for AbstractLoadTask.
         *
         * @param selection     SQL selection param. WHERE clauses.
         * @param selectionArgs SQL Where clauses query values.
         * @param sortOrder     Ordering.
         */
         PlaylistLoadTask(final MethodChannel.Result result, final ContentResolver resolver,
                                String selection, String[] selectionArgs, String sortOrder) {
            super(selection, selectionArgs, sortOrder);

            m_resolver = resolver;
            m_result = result;
        }

        @Override
        protected List<Map<String, Object>> loadData(String selection, String[] selectionArgs, String sortOrder) {
            Cursor cursor = m_resolver.query(MediaStore.Audio.Playlists.EXTERNAL_CONTENT_URI,
                    PLAYLIST_PROJECTION, selection, selectionArgs, sortOrder);

            List<Map<String,Object>> dataList = new ArrayList<>();

            if (cursor != null){
                while (cursor.moveToNext()){
                    try {
                        Map<String,Object> playlistData = new HashMap<>();
                        for (String key : PLAYLIST_PROJECTION){
                            String data = cursor.getString( cursor.getColumnIndex( key ));
                            //Log.d("MDBG"," READING " + key + " : " + data );
                            playlistData.put(key, data );
                        }

                        playlistData.put("memberIds", getPlaylistMembersId(
                                Long.parseLong( (String)playlistData.get(PLAYLIST_PROJECTION[0]))) );

                        dataList.add(playlistData);
                    }
                    catch (Exception ex){
                        Log.e(TAG_ERROR, ex.getMessage());
                    }
                }
                cursor.close();
            }
            return dataList;
        }

        @Override
        protected void onPostExecute(final List<Map<String, Object>> maps) {
            super.onPostExecute(maps);
            m_result.success(maps);
            m_result = null;
            m_resolver = null;
        }

        /**
         *
         * This method fetch member ids of a specific playlist.
         * @param playlistId Id of playlist
         * @return List of strings with members Ids or empty list if
         * the specified playlist has no members.
         *
         */
        private List<String> getPlaylistMembersId(final long playlistId){
             Cursor membersCursor = m_resolver.query(MediaStore.Audio.Playlists.Members.getContentUri(
                     "external", playlistId),
                     PLAYLIST_MEMBERS_PROJECTION,
                     null,
                     null,
                     MediaStore.Audio.Playlists.Members.DEFAULT_SORT_ORDER,
                     null );

             List<String> memberIds = new ArrayList<>();

             if (membersCursor != null){

                 while ( membersCursor.moveToNext() ){
                     try{
                         //for(String column : PLAYLIST_MEMBERS_PROJECTION)
                         // only getting member id yet.
                         memberIds.add( membersCursor.getString(
                                 membersCursor.getColumnIndex(PLAYLIST_MEMBERS_PROJECTION[0] )) );
                     }
                     catch (Exception ex){
                         Log.e(TAG_ERROR, "PlaylistLoader::getPlaylistMembersId method exception");
                         Log.e(TAG_ERROR, ex.getMessage());
                     }
                 }

                 membersCursor.close();
             }
             return memberIds;
         }
    }
}
