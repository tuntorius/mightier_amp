public enum ArtistSortType: Int {
    case DEFAULT

    /**
     * Returns the artists sorted using the number of albums as sorting parameter.
     * In this case the artists with more number of albums comes first.
     */
    case MORE_ALBUMS_NUMBER_FIRST

    /**
     * Returns the artists sorted using the number of albums as sorting parameter.
     * In this case the artists with less number of albums comes first.
     */
    case LESS_ALBUMS_NUMBER_FIRST

    /**
     * Returns the artists sorted using the number of tracks as sorting parameter.
     * In this case the artists with more number of tracks comes first.
     */
    case MORE_TRACKS_NUMBER_FIRST

    /**
     * Returns the artists sorted using the number of tracks as sorting parameter.
     * In this case the artists with less number of tracks comes first.
     */
    case LESS_TRACKS_NUMBER_FIRST

    /**
     * Return the songs sorted by Ids using the same order that IDs appears
     * in IDs query argument list.
     */
    case CURRENT_IDs_ORDER
}
