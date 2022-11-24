package boaventura.com.devel.br.flutteraudioquery.loaders;

import android.content.ContentResolver;
import android.content.ContentUris;
import android.content.Context;
import android.database.Cursor;
import android.net.Uri;
import android.os.Build;
import android.provider.MediaStore;
import android.util.Log;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import boaventura.com.devel.br.flutteraudioquery.loaders.tasks.AbstractLoadTask;
import boaventura.com.devel.br.flutteraudioquery.sortingtypes.SongSortType;
import io.flutter.plugin.common.MethodChannel;

public class SongLoader extends AbstractLoader {

    private static final String TAG = "MDBG";

    private static final int QUERY_TYPE_GENRE_SONGS = 0x01;
    private static final int QUERY_TYPE_ALBUM_SONGS = 0x02;

    //private static final String MOST_PLAYED = "most_played"; //undocumented column
    //private static final String RECENTLY_PLAYED = "recently_played"; // undocumented column

    private static final String[] SONG_ALBUM_PROJECTION = {
            MediaStore.Audio.AlbumColumns.ALBUM,
            MediaStore.Audio.AlbumColumns.ALBUM_ART
    };

    static private final String[] SONG_PROJECTION = {
            MediaStore.Audio.Media._ID,// row id
            MediaStore.Audio.Media.ALBUM_ID,
            MediaStore.Audio.Media.ARTIST_ID,
            MediaStore.Audio.Media.ARTIST,
            MediaStore.Audio.Media.ALBUM,
            MediaStore.Audio.Media.IS_MUSIC,
            MediaStore.Audio.Media.IS_PODCAST,
            MediaStore.Audio.Media.IS_RINGTONE,
            MediaStore.Audio.Media.IS_ALARM,
            MediaStore.Audio.Media.IS_NOTIFICATION,
            MediaStore.Audio.Media.TITLE,
            MediaStore.Audio.Media.DISPLAY_NAME,
            MediaStore.Audio.Media.COMPOSER,
            MediaStore.Audio.Media.YEAR,
            MediaStore.Audio.Media.TRACK,
            MediaStore.Audio.Media.DURATION, // duration of the audio file in ms
            MediaStore.Audio.Media.BOOKMARK, // position, in ms, where playback was at in last stopped
            MediaStore.Audio.Media.DATA, // file data path
            MediaStore.Audio.Media.SIZE, // string with file size in bytes
    };

    public SongLoader(final Context context){

        super(context);

        /*getContentResolver().registerContentObserver(
                MediaStore.Audio.Media.EXTERNAL_CONTENT_URI,
                true,
                new ContentObserver(null){
                    @Override
                    public boolean deliverSelfNotifications() {
                        return super.deliverSelfNotifications();
                    }

                    @Override
                    public void onChange(boolean selfChange) {
                        super.onChange(selfChange);
                        Log.i("MDBG", "onChange(self) in SongLoaderObserver");
                    }

                    @Override
                    public void onChange(boolean selfChange, Uri uri) {
                        super.onChange(selfChange, uri);
                        Log.i("MDBG", "onChange(self,uri) in SongLoaderObserver Uri: " + uri);
                    }
                }

                );*/
    }

    /**
     * This method is used to parse SongSortType object into a string
     * that will be used in SQL to query data in a specific sort mode.
     *
     * @param sortType SongSortType The type of sort desired.
     * @return A String for SQL language query usage.
     */
    private String parseSortOrder(SongSortType sortType){
        String sortOrder;

        switch (sortType){

            case ALPHABETIC_COMPOSER:
                sortOrder = MediaStore.Audio.Media.COMPOSER+ " ASC";
                break;

            case GREATER_DURATION:
                sortOrder = MediaStore.Audio.Media.DURATION + " DESC";
                break;

            case SMALLER_DURATION:
                sortOrder = MediaStore.Audio.Media.DURATION + " ASC";
                break;

            case RECENT_YEAR:
                sortOrder = MediaStore.Audio.Media.YEAR + " DESC";
                break;

            case OLDEST_YEAR:
                sortOrder = MediaStore.Audio.Media.YEAR + " ASC";
                break;

            case ALPHABETIC_ARTIST:
                sortOrder = MediaStore.Audio.Media.ARTIST_KEY;
                break;

            case ALPHABETIC_ALBUM:
                sortOrder = MediaStore.Audio.Media.ALBUM_KEY;
                break;

            case SMALLER_TRACK_NUMBER:
                sortOrder = MediaStore.Audio.Media.TRACK + " ASC";
                break;

            case GREATER_TRACK_NUMBER:
                sortOrder = MediaStore.Audio.Media.TRACK + " DESC";
                break;

            case DISPLAY_NAME:
                sortOrder = MediaStore.Audio.Media.DISPLAY_NAME;
                break;
            case DEFAULT:
            default:
                sortOrder = MediaStore.Audio.Media.DEFAULT_SORT_ORDER;
                break;
        }
        return sortOrder;
    }

    /**
     * This method query for all songs available on device storage
     * @param result MethodChannel.Result object to send reply for dart
     * @param sortType SongSortType object to define sort type for data queried.
     *
     */
    public void getSongs(final MethodChannel.Result result, final SongSortType sortType){

        createLoadTask( result,null,null,
                parseSortOrder(sortType), QUERY_TYPE_DEFAULT).execute();
    }

    /**
     *
     * This method makes a query that search genre by name with
     * nameQuery as query String.
     *
     * @param result MethodChannel.Result object to send reply for dart.
     * @param namedQuery Query param to match song title.
     * @param sortType SongSortType object to define sort type for data queried.
     */
    public void searchSongs(final MethodChannel.Result result, final String namedQuery,
                            final SongSortType sortType){

        String[] args =  new String[]{namedQuery + "%"};
        createLoadTask(result, MediaStore.Audio.Media.TITLE + " like ?",
                args, parseSortOrder(sortType), QUERY_TYPE_DEFAULT).execute();
    }

    /**
     * This method fetch songs by Ids. Here it is used to fetch
     * songs that appears on specific playlist.
     *
     * @param result MethodChannel.Result object to send reply for dart.
     * @param songIds Ids of songs that will be fetched.
     */
    public void getSongsFromPlaylist(MethodChannel.Result result, final List<String> songIds){
        String[] values;

        if ( (songIds != null) && (songIds.size() > 0) ){
             values = songIds.toArray(new String[songIds.size()] );
             this.
             createLoadTask(result, SONG_PROJECTION[0] + " =?", values, prepareIDsSongsSortOrder(songIds), QUERY_TYPE_DEFAULT)
                     .execute();
        }
        else result.success( new ArrayList<Map<String,Object>>() );
    }

    /**
     * This method creates a SQL CASE WHEN THEN in order to get specific songs
     * from Media table where the query results is sorted matching [songIds] list values order.
     *
     * @param songIds Song ids list
     * @return Sql String case when then or null if songIds size is not greater then 1.
     */
    private String prepareIDsSongsSortOrder(final List<String> songIds){
        if (songIds.size() == 1)
            return null;

        StringBuilder orderStr = new StringBuilder("CASE ")
                .append(MediaStore.MediaColumns._ID)
                .append(" WHEN '")
                .append(songIds.get(0))
                .append("'")
                .append(" THEN 0");

        for(int i = 1; i < songIds.size(); i++){
            orderStr.append(" WHEN '")
                    .append( songIds.get(i) )
                    .append("'")
                    .append(" THEN ")
                    .append(i);
        }

        orderStr.append(" END, ")
                .append(MediaStore.MediaColumns._ID)
                .append(" ASC");
        return orderStr.toString();
    }

    /**
     * This method queries for all songs that appears on specific album.
     *
     * @param result MethodChannel.Result object to send reply for dart.
     * @param albumId Album id that we want fetch songs
     * @param sortType SongSortType object to define sort type for data queried.
     */
    public void getSongsFromAlbum(final MethodChannel.Result result, final String albumId,
                                  final SongSortType sortType){

       // Log.i("MFBG", "Art: " + artist + " album: " + albumId);
        String selection = MediaStore.Audio.Media.ALBUM_ID + " =?";

       createLoadTask( result, selection, new String[] {albumId},
               parseSortOrder(sortType), QUERY_TYPE_ALBUM_SONGS).execute();
    }

    /**
     * This method queries for songs from specific artist that appears on specific album.
     *
     * @param result MethodChannel.Result object to send reply for dart.
     * @param albumId Album id that we want fetch songs
     * @param artist Artist name that appears in album
     * @param sortType SongSortType object to define sort type for data queried.
     */
    public void getSongsFromArtistAlbum(final MethodChannel.Result result, final String albumId,
                                        final String artist, final SongSortType sortType){
        String selection = MediaStore.Audio.Media.ALBUM_ID + " =?"
                + " and " + MediaStore.Audio.Media.ARTIST + " =?";

        createLoadTask( result, selection, new String[] {albumId, artist},
                parseSortOrder(sortType), QUERY_TYPE_ALBUM_SONGS).execute();
    }
    /**
     * This method queries songs from a specific artist.
     * @param result MethodChannel.Result object to send reply for dart.
     * @param artistId Artist name that we want fetch songs.
     * @param sortType SongSortType object to define sort type for data queried.
     */
    public void getSongsFromArtist(final MethodChannel.Result result, final String artistId,
                                   final SongSortType sortType ){

        createLoadTask(result, MediaStore.Audio.Media.ARTIST_ID + " =?",
                new String[] { artistId }, parseSortOrder(sortType), QUERY_TYPE_DEFAULT )
                .execute();
    }

    /**
     * This method queries songs that appears on specific genre.
     *
     * @param result MethodChannel.Result object to send reply for dart.
     * @param genre Genre name that we want songs.
     * @param sortType SongSortType object to define sort type for data queried.
     */
    public void getSongsFromGenre(final MethodChannel.Result result, final String genre,
                                  final SongSortType sortType){

        createLoadTask(result, genre, null,
                parseSortOrder( sortType), QUERY_TYPE_GENRE_SONGS )
                .execute();
    }

    /**
     * This method fetch songs with specified Ids.
     * @param result MethodChannel.Result object to send reply for dart.
     * @param ids Songs Ids.
     * @param sortType SongSortType object to define sort type for data queried.
     */
    public void getSongsById(final MethodChannel.Result result, final List<String> ids,
                             final SongSortType sortType){

        String[] selectionArgs;
        String sortOrder = null;
        String selection = MediaStore.Audio.Media._ID;

        if (ids == null || ids.isEmpty()) {
            result.error("NO_SONG_IDS", "No Ids was provided", null);
            return;
        }

        if (ids.size() > 1){
            selectionArgs = ids.toArray( new String[ ids.size() ]);

            if(sortType == SongSortType.CURRENT_IDs_ORDER)
                sortOrder = prepareIDsSongsSortOrder( ids );
        }

        else{
            sortOrder = parseSortOrder(sortType);
            selection = selection + " =?";
            selectionArgs = new String[]{ ids.get(0) };
        }

        createLoadTask(result, selection, selectionArgs,
                sortOrder, QUERY_TYPE_DEFAULT).execute();
    }



    @Override
    protected SongTaskLoad createLoadTask(MethodChannel.Result result, final String selection, final String [] selectionArgs,
                                final String sortOrder, final int type){

        return new SongTaskLoad(result, getContentResolver(), selection, selectionArgs, sortOrder, type);

    }


    private static class SongTaskLoad extends AbstractLoadTask< List< Map<String,Object> > > {
        private MethodChannel.Result m_result;
        private ContentResolver m_resolver;
        private int m_queryType;

        /**
         *
         * @param result
         * @param m_resolver
         * @param selection
         * @param selectionArgs
         * @param sortOrder
         */
        SongTaskLoad(MethodChannel.Result result, ContentResolver m_resolver, String selection,
                     String[] selectionArgs, String sortOrder, int type){

            super(selection, selectionArgs, sortOrder);
            this.m_resolver = m_resolver;
            this.m_result =result;
            this.m_queryType = type;
        }

        @Override
        protected void onPostExecute(List<Map<String, Object>> map) {
            super.onPostExecute(map);
            m_result.success(map);
            this.m_resolver = null;
            this.m_result = null;
        }

        @Override
        protected List< Map<String,Object> > loadData(
                final String selection, final String [] selectionArgs,
                final String sortOrder ){

            switch (m_queryType){
                case QUERY_TYPE_DEFAULT:
                    // In this case the selection will be always by id.
                    // used for fetch songs for playlist or songs by id.
                    if ( (selectionArgs!=null) && (selectionArgs.length > 1) ){
                        return basicLoad( createMultipleValueSelectionArgs(MediaStore.Audio.Media._ID,
                                selectionArgs), selectionArgs, sortOrder);

                    } else
                        return  basicLoad(selection, selectionArgs, sortOrder);

                case QUERY_TYPE_ALBUM_SONGS:
                    //Log.i("MDBG", "new way");
                    return basicLoad(selection,selectionArgs,sortOrder);

                case QUERY_TYPE_GENRE_SONGS:
                    List<String> songIds = getSongIdsFromGenre(selection);
                    int idCount = songIds.size();
                    if ( idCount > 0){

                        if (idCount > 1 ){
                            String[] args = songIds.toArray( new String[idCount] );
                            String createdSelection = createMultipleValueSelectionArgs(
                                    MediaStore.Audio.Media._ID, args);
                            return  basicLoad(
                                    createdSelection,
                                    args,sortOrder );
                        }

                        else {
                            return basicLoad(MediaStore.Audio.Media._ID + " =?",
                                    new String[]{ songIds.get(0)},
                                    sortOrder );
                        }
                    }
                    break;

                default:
                    break;
            }

            return new ArrayList<>();
        }

        /**
         * This method fetch song ids that appears on specific genre.
         * @param genre genre name
         * @return List of ids in string.
         */
        private List<String> getSongIdsFromGenre(final String genre){
           Cursor songIdsCursor = m_resolver.query(MediaStore.Audio.Media.EXTERNAL_CONTENT_URI,
                    new String[] {"Distinct " + MediaStore.Audio.Media._ID, "genre_name" },
                    "genre_name" + " =?",new String[] {genre},null);

           List<String> songIds = new ArrayList<>();

           if (songIdsCursor != null){

               while ( songIdsCursor.moveToNext() ){
                   try {
                       String id = songIdsCursor.getString(songIdsCursor.getColumnIndex(MediaStore.Audio.Media._ID));
                       songIds.add(id);
                   }
                   catch (Exception ex){
                       Log.e(TAG_ERROR, "SongLoader::getSonIdsFromGenre method exception");
                       Log.e(TAG_ERROR, ex.getMessage() );
                   }
               }
               songIdsCursor.close();
           }

           return songIds;
        }

        private List<Map<String,Object>> basicLoad(final String selection, final String[] selectionArgs,
                                                   final String sortOrder){

            List< Map<String, Object> > dataList = new ArrayList<>();
            Cursor songsCursor = null;

            try{
                songsCursor = m_resolver.query(
                        MediaStore.Audio.Media.EXTERNAL_CONTENT_URI,
                        SongLoader.SONG_PROJECTION, selection, selectionArgs, sortOrder );
            }

            catch (RuntimeException ex){

                System.out.println("SongLoader::basicLoad " + ex);
                m_result.error("SONG_READ_ERROR", ex.getMessage() , null);
            }

            if (songsCursor != null){
                Map<String,String> albumArtMap = new HashMap<>();

                while( songsCursor.moveToNext() ){
                    try {
                        Map<String, Object> songData = new HashMap<>();
                        for (String column : songsCursor.getColumnNames()){
                            switch (column ){
                                case MediaStore.Audio.Media._ID:
                                    String id = songsCursor.getString( songsCursor.getColumnIndex(column));
                                    final Uri uri = ContentUris.appendId(MediaStore.Audio.Media.EXTERNAL_CONTENT_URI.buildUpon(),
                                            Long.parseLong( id )).build();
                                    songData.put("uri" , uri.toString() );
                                    songData.put(column, id);
                                    break;
                                    
                                case MediaStore.Audio.Media.IS_MUSIC:
                                case MediaStore.Audio.Media.IS_PODCAST:
                                case MediaStore.Audio.Media.IS_RINGTONE:
                                case MediaStore.Audio.Media.IS_ALARM:
                                case MediaStore.Audio.Media.IS_NOTIFICATION:
                                    songData.put(column,
                                            (songsCursor.getInt(songsCursor.getColumnIndex(column)) != 0));
                                    break;
                                default:
                                    songData.put(column, songsCursor.getString( songsCursor.getColumnIndex(column)) );
                            }

                        }


                        String albumKey = songsCursor.getString(
                                songsCursor.getColumnIndex(SONG_PROJECTION[4]));

                        String artPath;
                        if (!albumArtMap.containsKey(albumKey)) {

                            artPath = getAlbumArtPathForSong(albumKey);
                            albumArtMap.put(albumKey, artPath);

                            //Log.i("MDBG", "song for album  " + albumKey + "adding path: " + artPath);
                        }

                        artPath = albumArtMap.get(albumKey);
                        songData.put("album_artwork", artPath);
                        dataList.add(songData);
                    }

                    catch(Exception ex){
                        Log.e(TAG_ERROR, "SongLoader::basicLoad method exception");
                        Log.e(TAG_ERROR, ex.getMessage() );
                    }
                }

                songsCursor.close();
            }

            return dataList;
        }

        /**
         * This method the image of the album if exists. If there is no album artwork
         * null is returned
         * @param album Album name that we want the artwork
         * @return String with image path or null if there is no image.
         */
        private String getAlbumArtPathForSong(String album){
            Cursor artCursor = m_resolver.query(
                    MediaStore.Audio.Albums.EXTERNAL_CONTENT_URI,
                    SONG_ALBUM_PROJECTION,
                    SONG_ALBUM_PROJECTION[0] +  " =?",
                    new String[] {album},
                    null);

            String artPath = null;

            if (artCursor !=null){
                while (artCursor.moveToNext()) {

                    try {
                        artPath = artCursor.getString(artCursor.getColumnIndex(SONG_ALBUM_PROJECTION[1]));

                    }

                    catch (Exception ex) {
                        Log.e(TAG_ERROR, "SongLoader::getAlbumArtPathForSong method exception");
                        Log.e(TAG_ERROR, ex.getMessage());
                    }
                }

                artCursor.close();
            }

            return artPath;
        }

    }
}


/*
 *  NON DOCUMENTED MEDIA COLUMNS
 *
 * album_artist
 * duration
 * genre_name
 * recently_played
 * most_played
 *
 */

/*
 *          ALL MEDIA COLUMNS
 *
 * I/MDBG    (15056): Column: _id
 * I/MDBG    (15056): Column: _data
 * I/MDBG    (15056): Column: _display_name
 * I/MDBG    (15056): Column: _size
 * I/MDBG    (15056): Column: mime_type
 * I/MDBG    (15056): Column: date_added
 * I/MDBG    (15056): Column: is_drm
 * I/MDBG    (15056): Column: date_modified
 * I/MDBG    (15056): Column: title
 * I/MDBG    (15056): Column: title_key
 * I/MDBG    (15056): Column: duration
 * I/MDBG    (15056): Column: artist_id
 * I/MDBG    (15056): Column: composer
 * I/MDBG    (15056): Column: album_id
 * I/MDBG    (15056): Column: track
 * I/MDBG    (15056): Column: year
 * I/MDBG    (15056): Column: is_ringtone
 * I/MDBG    (15056): Column: is_music
 * I/MDBG    (15056): Column: is_alarm
 * I/MDBG    (15056): Column: is_notification
 * I/MDBG    (15056): Column: is_podcast
 * I/MDBG    (15056): Column: bookmark
 * I/MDBG    (15056): Column: album_artist
 * I/MDBG    (15056): Column: is_sound
 * I/MDBG    (15056): Column: year_name
 * I/MDBG    (15056): Column: genre_name
 * I/MDBG    (15056): Column: recently_played
 * I/MDBG    (15056): Column: most_played
 * I/MDBG    (15056): Column: recently_added_remove_flag
 * I/MDBG    (15056): Column: is_favorite
 * I/MDBG    (15056): Column: bucket_id
 * I/MDBG    (15056): Column: bucket_display_name
 * I/MDBG    (15056): Column: recordingtype
 * I/MDBG    (15056): Column: latitude
 * I/MDBG    (15056): Column: longitude
 * I/MDBG    (15056): Column: addr
 * I/MDBG    (15056): Column: langagecode
 * I/MDBG    (15056): Column: is_secretbox
 * I/MDBG    (15056): Column: is_memo
 * I/MDBG    (15056): Column: label_id
 * I/MDBG    (15056): Column: weather_ID
 * I/MDBG    (15056): Column: sampling_rate
 * I/MDBG    (15056): Column: bit_depth
 * I/MDBG    (15056): Column: recorded_number
 * I/MDBG    (15056): Column: recording_mode
 * I/MDBG    (15056): Column: is_ringtone_theme
 * I/MDBG    (15056): Column: is_notification_theme
 * I/MDBG    (15056): Column: is_alarm_theme
 * I/MDBG    (15056): Column: datetaken
 * I/MDBG    (15056): Column: artist_id:1
 * I/MDBG    (15056): Column: artist_key
 * I/MDBG    (15056): Column: artist
 * I/MDBG    (15056): Column: album_id:1
 * I/MDBG    (15056): Column: album_key
 * I/MDBG    (15056): Column: album
 *
 *
 */
