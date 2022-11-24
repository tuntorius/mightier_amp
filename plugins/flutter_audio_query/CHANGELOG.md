## 0.3.5+6
 * Fixing missed song id empty field bug.

## 0.3.5+5
 * Support loading artwork on Android >= Q with getArtwork method
 * **Bug fix**: getGenres call bug fixed
 * **Bug fix**: getSongsById when call with one single id
 * **Bug fix**: getSongsFromArtist call
 * **Breaking change**:
    * The method getSongsFromArtist now accepts artistId as parameter.

## 0.3.4+2  
* Support V2 embedding Flutter API.
* Fixing accept permission bug when using V2 Embedding Flutter API.  
  
## ~~0.3.4+1~~  
* **BROKEN VERSION**
* **~~QUICK FIX~~** ~~Using V2 embedding Flutter API.~~  
  
  
## 0.3.3  
* **Bug fix**: Fixing the wrong 'numberOfSongs' property value when   
    load albums using getAlbumsFromArtist method.      
  
## 0.3.2  
* **Breaking change**: The methods "getAlbumsFromGenre", "getAlbumsFromArtist", "getSongsFromArtist",  
    "getSongsFromAlbum", "getSongsFromArtistAlbum", "getSongsFromGenre" and "getArtistsFromGenre"  
    now is using a string name parameter instead respective DataModel classes GenreInfo,   
    ArtistInfo and AlbumInfo.  
      
* Now is possible fetch multiple ArtistInfo objects using the method "getArtistsById".  
  
* **BUG FIX**: Fixing isMusic and methods like cast issue.  
  
## 0.2.1  
  
* **Breaking change**: Now getSongsFromAlbum don't take an ArtistInfo in parameter. If you want to get   
    all songs from an specific album you can use getSongsFromAlbum method. But if you want to get  
    all songs from an specific album from an specific artist do this with getSongsFromArtistAlbum  
    method.   
  
* Now is possible fetch songs by ID's with getSongsById method.  
  
* Now is possible fetch albums by ID's with getAlbumsById method.  
  
## 0.1.1  
  
* **Bug fix**: Before this fix, getGenre method was returning genres that has no one data  
    related, no one artist, album or a song. Now getGenre calls return only genres which   
    at least one artist, album or song appears.   
  
## 0.1.0  
  
* Documentation completed  
  
## 0.0.1  
  
* Initial Release