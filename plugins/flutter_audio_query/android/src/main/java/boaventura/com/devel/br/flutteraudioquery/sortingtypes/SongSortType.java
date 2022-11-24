package boaventura.com.devel.br.flutteraudioquery.sortingtypes;

public enum SongSortType {
    DEFAULT,

    /**
     * Returns the songs sorted using [composer] property as sort
     * parameter.*/
    ALPHABETIC_COMPOSER,

    /**
     * Returns the songs sorted using [duration] property as
     * sort parameter. In this case the songs with greatest
     * duration in milliseconds will come first.
     */
    GREATER_DURATION,

    /**
     * Returns the songs sorted using [duration] property as
     * sort parameter. In this case the songs with smaller
     * duration in milliseconds will come first.
     */
    SMALLER_DURATION,

    /**
     * Returns the songs sorted using [year] property as
     * sort parameter. In this case the songs that has more
     * recent year will come first.
     * */
    RECENT_YEAR,

    /**Returns the songs sorted using [year] property as
     * sort parameter. In this case the songs that has more
     * oldest year will come first.
     */
    OLDEST_YEAR,

    /**
     * Returns the songs alphabetically sorted using [artist] property as
     * sort parameter. In this case*/
    ALPHABETIC_ARTIST,

    /**
     * Returns the songs alphabetically sorted using [album] property as
     * sort parameter. In this case*/
    ALPHABETIC_ALBUM,

    /**
     *  Returns the songs sorted using [track] property as sort param.
     *  The songs with greater track number will come first.
     *  NOTE: In Android platform [track] property number encodes both the track
     *  number and the disc number. For multi-disc sets, this number will be 1xxx
     *  for tracks on the first disc, 2xxx for tracks on the second disc, etc.
     */
    GREATER_TRACK_NUMBER,

    /**
     * Returns the songs sorted using [track] property as sort param.
     * The songs with smaller track number will come first.
     * NOTE: In Android platform [track] property number encodes both the track
     * number and the disc number. For multi-disc sets, this number will be 1xxx
     * for tracks on the first disc, 2xxx for tracks on the second disc, etc
     */
    SMALLER_TRACK_NUMBER,

    /**
     * Return the songs sorted using [display_name] property as sort param.
     * Is a good option to used when desired have the original album songs order.
     * */
    DISPLAY_NAME,

    /**
     * Return the songs sorted by Ids using the same order that IDs appears
     * in IDs query argument list.
     */
    CURRENT_IDs_ORDER
}
