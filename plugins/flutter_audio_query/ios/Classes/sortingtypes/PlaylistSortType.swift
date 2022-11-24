public enum PlaylistSortType: Int {

    /**
     * The Default sort order for playlist. DEFAULT value the playlist
     * query will return playlists sorted by alphabetically
     */
    case DEFAULT

    /**
     * The most recent playlists will come first in playlist queries.
     *
     */
    case NEWEST_FIRST
    /**
     * The most old playlists will come first in playlist queries.
     */
    case LDEST_FIRST
}
