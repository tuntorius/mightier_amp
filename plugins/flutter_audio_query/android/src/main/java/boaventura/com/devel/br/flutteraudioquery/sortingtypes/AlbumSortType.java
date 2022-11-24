package boaventura.com.devel.br.flutteraudioquery.sortingtypes;

public enum AlbumSortType {
    DEFAULT,

    /**Returns the albums sorted in alphabetic order using the album [artist]
     * property as sort parameter
     */
    ALPHABETIC_ARTIST_NAME,


    //static const String MOST_RECENT_FIRST_YEAR = "MOST_RECENT_FIRST_YEAR";
    //static const String MOST_RECENT_LAST_YEAR = "MOST_RECENT_LAST_YEAR";

    /**
     * Returns the albums sorted using [numberOfSongs] property as sort
     * parameter. In This case the albums with more number of songs will
     * come first.
     */
    MORE_SONGS_NUMBER_FIRST,

    /**
      * Returns the albums sorted using [numberOfSongs] property as sort
      * parameter. In This case the albums with less number of songs will
      * come first.
      * */
    LESS_SONGS_NUMBER_FIRST,

    /**
     * Returns the albums sorted using [lastYear] property as sort param.
     * In this case the albums with more recent year value will come first.
     * */
    MOST_RECENT_YEAR,

    /**
     * Returns the albums sorted using [lastYear] property as sort param.
     * In this case the albums with more oldest year value will come first.
     * */
    OLDEST_YEAR,

    /**
     * Return the songs sorted by Ids using the same order that IDs appears
     * in IDs query argument list.
     */
    CURRENT_IDs_ORDER
}
