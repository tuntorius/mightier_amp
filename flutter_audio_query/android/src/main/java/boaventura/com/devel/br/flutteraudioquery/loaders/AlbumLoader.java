package boaventura.com.devel.br.flutteraudioquery.loaders;

import android.content.ContentResolver;
import android.content.Context;
import android.database.Cursor;
import android.provider.MediaStore;
import android.util.Log;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import boaventura.com.devel.br.flutteraudioquery.loaders.tasks.AbstractLoadTask;
import boaventura.com.devel.br.flutteraudioquery.sortingtypes.AlbumSortType;
import io.flutter.plugin.common.MethodChannel;

public class AlbumLoader extends AbstractLoader {

    //private final ContentResolver m_resolver;
    private static final int QUERY_TYPE_GENRE_ALBUM = 0x01;
    private static final int QUERY_TYPE_ARTIST_ALBUM = 0x02;

    private static final String[] ALBUM_PROJECTION = {
            MediaStore.Audio.AudioColumns._ID,
            MediaStore.Audio.AlbumColumns.ALBUM,
            MediaStore.Audio.AlbumColumns.ALBUM_ART,
            MediaStore.Audio.AlbumColumns.ARTIST,
            MediaStore.Audio.AlbumColumns.FIRST_YEAR,
            MediaStore.Audio.AlbumColumns.LAST_YEAR,
            MediaStore.Audio.AlbumColumns.NUMBER_OF_SONGS
            /*, MediaStore.Audio.AlbumColumns.ALBUM_ID*/
            //MediaStore.Audio.AlbumColumns.NUMBER_OF_SONGS_FOR_ARTIST,
    };

    private static final String[] ALBUM_MEDIA_PROJECTION = {
            MediaStore.Audio.Media.ALBUM_ID,
            MediaStore.Audio.Media.ALBUM,
            MediaStore.Audio.Media.IS_MUSIC
    };

    public AlbumLoader(final Context context) {
        super(context);
    }

    /**
     * This method is used to parse AlbumSortType object into a string
     * that will be used in SQL to query data in a specific sort mode.
     * @param sortType AlbumSortType The type of sort desired.
     * @return A String for SQL language query usage.
     */
    private String parseSortOrder(AlbumSortType sortType) {
        String sortOrder;

        switch (sortType) {

            case LESS_SONGS_NUMBER_FIRST:
                sortOrder = MediaStore.Audio.Albums.NUMBER_OF_SONGS + " ASC";
                break;

            case MORE_SONGS_NUMBER_FIRST:
                sortOrder = MediaStore.Audio.Albums.NUMBER_OF_SONGS + " DESC";
                break;

            case ALPHABETIC_ARTIST_NAME:
                sortOrder = MediaStore.Audio.Albums.ARTIST;
                break;

            case MOST_RECENT_YEAR:
                sortOrder = MediaStore.Audio.Albums.LAST_YEAR + " DESC";
                break;

            case OLDEST_YEAR:
                sortOrder = MediaStore.Audio.Albums.LAST_YEAR + " ASC";
                break;

            case DEFAULT:
            default:
                sortOrder = MediaStore.Audio.Albums.DEFAULT_SORT_ORDER;
                break;
        }
        return sortOrder;
    }

    /**
     * Fetch albums by id.
     * @param result
     * @param ids
     * @param sortType
     */
    public void getAlbumsById(final MethodChannel.Result result, final List<String> ids,
                             final AlbumSortType sortType){

        String[] selectionArgs;
        String sortOrder = null;

        if (ids == null || ids.isEmpty()) {
            result.error("NO_ALBUM_IDS", "No Ids was provided", null);
            return;
        }

        if (ids.size() > 1){
            selectionArgs = ids.toArray( new String[ ids.size() ]);

            if(sortType == AlbumSortType.CURRENT_IDs_ORDER)
                sortOrder = prepareIDsSortOrder( ids );
        }

        else{
            sortOrder = parseSortOrder(sortType);
            selectionArgs = new String[]{ ids.get(0) };
        }

        createLoadTask(result, MediaStore.Audio.Albums._ID, selectionArgs,
                sortOrder, QUERY_TYPE_DEFAULT).execute();
    }

    /**
     * This method queries all albums available on device storage
     * @param result MethodChannel.Result object to send reply for dart
     * @param sortType AlbumSortType object to define sort type for data queried.
     */
    public void getAlbums(MethodChannel.Result result, AlbumSortType sortType) {
        createLoadTask(result, null, null,
                parseSortOrder(sortType), QUERY_TYPE_DEFAULT)
                .execute();
    }

    /**
     * Method used to query albums that appears in a specific genre
     * @param result MethodChannel.Result object to send reply for dart
     * @param genre String with genre name that you want find artist
     * @param sortType AlbumSortType object to define sort type for data queried.
     */
    public void getAlbumFromGenre(final MethodChannel.Result result, final String genre,
                                  AlbumSortType sortType) {
        createLoadTask(result, genre, null,
                parseSortOrder(sortType), QUERY_TYPE_GENRE_ALBUM)
                .execute();
    }

    /**
     *
     * This method makes a query that search album by name with
     * nameQuery as query String.
     *
     * @param results MethodChannel.Result object to send reply for dart
     * @param namedQuery The query param for match album title.
     * @param sortType AlbumSortType object to define sort type for data queried.
     */
    public void searchAlbums(final MethodChannel.Result results, final String namedQuery,
                             AlbumSortType sortType) {
        String[] args = new String[]{namedQuery + "%"};
        createLoadTask(results, MediaStore.Audio.AlbumColumns.ALBUM + " like ?", args,
                parseSortOrder(sortType), QUERY_TYPE_DEFAULT)
                .execute();
    }

    /**
     *
     * Method used to query albums from a specific artist
     *
     * @param result MethodChannel.Result object to send reply for dart
     * @param artistName That artist id that you wanna fetch the albums.
     * @param sortType AlbumSortType object to define sort type for data queried.
     */
    public void getAlbumsFromArtist(MethodChannel.Result result, String artistName, AlbumSortType sortType) {

        createLoadTask(result, ALBUM_PROJECTION[3] + " =?",
                new String[]{artistName}, parseSortOrder(sortType), QUERY_TYPE_DEFAULT)
                .execute();
    }

    /**
     * This method creates a SQL CASE WHEN THEN in order to get specific elements
     * where the query results is sorted matching [IDs] list values order.
     *
     * @param idList Song IDs list
     * @return Sql String case when then or null if idList size is not greater then 1.
     */
    private String prepareIDsSortOrder(final List<String> idList){
        if (idList.size() == 1)
            return null;

        StringBuilder orderStr = new StringBuilder("CASE ")
                .append(MediaStore.MediaColumns._ID)
                .append(" WHEN '")
                .append(idList.get(0))
                .append("'")
                .append(" THEN 0");

        for(int i = 1; i < idList.size(); i++){
            orderStr.append(" WHEN '")
                    .append( idList.get(i) )
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
     * This method creates a new AlbumTaskLoader that is used to make
     * a background query for data.
     *
     * @param result MethodChannel.Result object to send reply for dart.
     * @param selection String with SQL selection.
     * @param selectionArgs Values to match '?' wildcards in selection.
     * @param sortOrder AlbumSortType object to define sort type for data queried.
     * @param type An integer number that can be used to identify what kind of task do you want to create.
     *
     * @return AlbumLoadTask object ready to be executed.
     */
    @Override
    protected AlbumLoadTask createLoadTask(
            final MethodChannel.Result result, final String selection,
            final String[] selectionArgs, final String sortOrder, final int type) {

        return new AlbumLoadTask(result, getContentResolver(), selection, selectionArgs,
                sortOrder, type);

    }

    static class AlbumLoadTask extends AbstractLoadTask<List<Map<String, Object>>> {

        private ContentResolver m_resolver;
        private MethodChannel.Result m_result;
        private int m_queryType;

        private AlbumLoadTask(final MethodChannel.Result result, ContentResolver resolver,
                              final String selection, final String[] selectionArgs,
                              final String sortOrder, final int type) {
            super(selection, selectionArgs, sortOrder);

            m_result = result;
            m_resolver = resolver;
            m_queryType = type;
        }

        /**
         * Utility method do create a multiple selection argument string.
         * By Example: "_id IN(?,?,?,?)".
         * @param params
         * @return String ready to multiple selection args matching.
         */
        private String createMultipleValueSelectionArgs( /*String column */String[] params) {

            StringBuilder stringBuilder = new StringBuilder();
            stringBuilder.append(MediaStore.Audio.Albums._ID + " IN(?");

            for (int i = 0; i < (params.length - 1); i++)
                stringBuilder.append(",?");

            stringBuilder.append(')');
            return stringBuilder.toString();
        }

        @Override
        protected List<Map<String, Object>> loadData(
                final String selection, final String[] selectionArgs,
                final String sortOrder) {

            switch (m_queryType) {
                case QUERY_TYPE_DEFAULT:
                    // In this case the selection will be always by id.
                    // used for fetch songs for playlist or songs by id.
                    if ( (selectionArgs!=null) && (selectionArgs.length > 1) ){
                        return basicDataLoad(
                                createMultipleValueSelectionArgs(selection, selectionArgs),
                                selectionArgs, sortOrder);

                    } else
                        return this.basicDataLoad(selection, selectionArgs, sortOrder);

                case QUERY_TYPE_GENRE_ALBUM:
                    List<String> albumsFromGenre = getAlbumNamesFromGenre(selection);
                    int idCount = albumsFromGenre.size();

                    if (idCount > 0) {
                        if (idCount > 1) {
                            String[] params = albumsFromGenre.toArray(new String[idCount]);
                            String createdSelection = createMultipleValueSelectionArgs(params);

                            return basicDataLoad(createdSelection, params,
                                    MediaStore.Audio.Albums.DEFAULT_SORT_ORDER);
                        } else {
                            return basicDataLoad(
                                    MediaStore.Audio.Albums._ID + " =?",
                                    new String[]{albumsFromGenre.get(0)},
                                    MediaStore.Audio.Artists.DEFAULT_SORT_ORDER);
                        }
                    }
                    break;

                case QUERY_TYPE_ARTIST_ALBUM:
                    return loadAlbumsInfoWithMediaSupport(selectionArgs[0]);

                default:
                    break;
            }

            return new ArrayList<>();
        }

        private List<Map<String, Object>> basicDataLoad(final String selection, final String[] selectionArgs,
                                                        final String sortOrder) {

            List<Map<String, Object>> dataList = new ArrayList<>();

            Cursor cursor = m_resolver.query(MediaStore.Audio.Albums.EXTERNAL_CONTENT_URI,
                    ALBUM_PROJECTION, selection, selectionArgs, sortOrder);

            if (cursor != null) {
                if (cursor.getCount() == 0) {
                    cursor.close();
                    return dataList;
                }
                else {
                    while ( cursor.moveToNext() ) {
                        try {
                            Map<String, Object> dataMap = new HashMap<>();
                            for (String albumColumn : ALBUM_PROJECTION) {
                                String value = cursor.getString(cursor.getColumnIndex(albumColumn));
                                dataMap.put(albumColumn, value);
                                //Log.i(TAG, albumColumn + ": " + value);
                            }
                            dataList.add(dataMap);
                        } catch (Exception ex) {
                            Log.e("ERROR", "AlbumLoader::basicLoad", ex);
                            Log.e("ERROR", "while reading basic load cursor");
                        }

                    }
                }
                cursor.close();
            }
            return dataList;
        }

        private List<String> getAlbumNamesFromGenre(final String genre) {
            List<String> albumNames = new ArrayList<>();

            Cursor albumNamesCursor = m_resolver.query(MediaStore.Audio.Media.EXTERNAL_CONTENT_URI,
                    new String[]{"Distinct " + MediaStore.Audio.Media.ALBUM_ID, "genre_name"},
                    "genre_name" + " =?", new String[]{genre}, null);

            if (albumNamesCursor != null) {

                while (albumNamesCursor.moveToNext()) {
                    try {
                        String albumName = albumNamesCursor.getString(albumNamesCursor.getColumnIndex(
                                MediaStore.Audio.Media.ALBUM_ID));
                        albumNames.add(albumName);
                    } catch (Exception ex) {
                        Log.e("ERROR", "AlbumLoader::getAlbumNamesFromGenre", ex);
                    }

                }
                albumNamesCursor.close();

            }

            return albumNames;
        }

        /**
         * This method is used to load albums from Media "Table" and not from Album "Table"
         * as basicDataLoad do.
         *
         * @param artistName The name of the artists that we can query for albums.
         */
        private List<Map<String, Object>> loadAlbumsInfoWithMediaSupport(final String artistName) {

            List<Map<String, Object>> dataList = new ArrayList<>();

            // we get albums from an specific artist
            Cursor artistAlbumsCursor = m_resolver.query(
                    MediaStore.Audio.Media.EXTERNAL_CONTENT_URI,
                    ALBUM_MEDIA_PROJECTION,
                    MediaStore.Audio.Albums.ARTIST + "=?" + " and "
                            + MediaStore.Audio.Media.IS_MUSIC + "=?"
                            + ") GROUP BY (" + MediaStore.Audio.Albums.ALBUM,
                    new String[]{artistName, "1"},
                    MediaStore.Audio.Media.DEFAULT_SORT_ORDER);

            if (artistAlbumsCursor != null) {
                while (artistAlbumsCursor.moveToNext()) {
                    String albumId = artistAlbumsCursor.getString(
                            artistAlbumsCursor.getColumnIndex(ALBUM_MEDIA_PROJECTION[0]));

                    Cursor albumDataCursor = m_resolver.query(
                            MediaStore.Audio.Albums.EXTERNAL_CONTENT_URI,
                            ALBUM_PROJECTION,
                            MediaStore.Audio.Albums._ID + "=?",
                            new String[]{albumId},
                            MediaStore.Audio.Albums.DEFAULT_SORT_ORDER);

                    if (albumDataCursor != null) {
                        Cursor albumArtistSongsCountCursor =
                                m_resolver.query(MediaStore.Audio.Media.EXTERNAL_CONTENT_URI,
                                        new String[]{
                                                MediaStore.Audio.Media._ID,
                                                MediaStore.Audio.Media.ARTIST,
                                                MediaStore.Audio.Media.IS_MUSIC
                                        },

                                MediaStore.Audio.Artists.ARTIST + " =?" + " and " +
                                        MediaStore.Audio.Media.ALBUM_ID + " =?" + " and " +
                                        MediaStore.Audio.Media.IS_MUSIC + "=?",
                                new String[]{artistName, albumId, "1"},null);

                        int songsNumber = -1;

                        if (albumArtistSongsCountCursor != null){
                            songsNumber = albumArtistSongsCountCursor.getCount();
                            albumArtistSongsCountCursor.close();
                        }
                        while (albumDataCursor.moveToNext()) {
                            try {
                                Map<String, Object> albumData = new HashMap<>();

                                //MediaStore.Audio.AudioColumns._ID,
                                albumData.put(ALBUM_PROJECTION[0], albumDataCursor.
                                        getString(albumDataCursor.getColumnIndex(ALBUM_PROJECTION[0]) ));

                                //MediaStore.Audio.AlbumColumns.ALBUM,
                                albumData.put(ALBUM_PROJECTION[1], albumDataCursor.
                                        getString(albumDataCursor.getColumnIndex(ALBUM_PROJECTION[1]) ) );

                                //MediaStore.Audio.AlbumColumns.ALBUM_ART,
                                albumData.put(ALBUM_PROJECTION[2], albumDataCursor.
                                        getString(albumDataCursor.getColumnIndex(ALBUM_PROJECTION[2]) ) );

                                //MediaStore.Audio.AlbumColumns.ARTIST,
                                albumData.put(ALBUM_PROJECTION[3], artistName);

                                //MediaStore.Audio.AlbumColumns.FIRST_YEAR,
                                albumData.put(ALBUM_PROJECTION[4], albumDataCursor.
                                        getString(albumDataCursor.getColumnIndex(ALBUM_PROJECTION[4]) ) );

                                //MediaStore.Audio.AlbumColumns.LAST_YEAR,
                                albumData.put(ALBUM_PROJECTION[5], albumDataCursor.
                                        getString(albumDataCursor.getColumnIndex(ALBUM_PROJECTION[5]) ) );

                                //MediaStore.Audio.AlbumColumns.NUMBER_OF_SONGS
                                albumData.put(ALBUM_PROJECTION[6], String.valueOf(songsNumber) );

                                /*for(int i = 0; i < ALBUM_PROJECTION.length -1; i++)
                                    albumData.put(ALBUM_PROJECTION[i], albumDataCursor.
                                            getString(albumDataCursor.getColumnIndex(ALBUM_PROJECTION[i])));

                                albumData.put(ALBUM_PROJECTION[ALBUM_PROJECTION.length-1],
                                        String.valueOf(songsNumber));
                               */
                                dataList.add(albumData);
                            }

                            catch (Exception ex) {
                                //TODO should I exit with results.error() here??
                                // think about it...
                                Log.e("ERROR", "AlbumLoader::loadAlbumsInfoWithMediaSupport", ex);
                            }
                        }
                        albumDataCursor.close();
                    }
                }
                artistAlbumsCursor.close();
            }
            return dataList;
        }

        @Override
        protected void onPostExecute(List<Map<String, Object>> data) {
            super.onPostExecute(data);
            m_resolver = null;
            m_result.success(data);
            m_result = null;
        }

    }
}
