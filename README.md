## Song Recommendation System

### This is a simple song recommendation system project.

### 1 Introduction

In this project, you will implement a song recommendation system in Prolog. This system will be a rather simple system, yet useful for users to find new songs in their favorite genre with the specified song features.

### 2 Knowledge Base

You have three main files as your knowledge base: artists.pl, albums.pl, tracks.pl. These are collected with the help of [Spotify API](https://developer.spotify.com). There are three different types of predicates defined as follows:
  * **artist(ArtistName, ArtistGenres, AlbumIds).**
    * **ArtistName**: Name of the artist. (string)
    * **ArtistGenres**: List of genres the artist associated with. (list of strings)
    * **AlbumIds**: List of albums of the artist specified with their IDs. (list of strings)
    
  * **album(AlbumId, AlbumName, ArtistNames, TrackIds).**
    * **AlbumId**: A unique ID of an album. (string)
    * **AlbumName**: Name of the album. (string)
    * **ArtistNames**: Names of album’s artists. (list of strings)
    * **TrackIds**: List of tracks in the album specified with their IDs. (list of strings)
   
  * **track(TrackId, TrackName, ArtistNames, AlbumName, Features).**
    * **TrackId**: A unique ID of a track. (string)
    * **TrackName**: Name of the track. (string)
    * **ArtistNames**: List of names of track’s artists. (list of strings) – AlbumName: Name of the album. (string)
    * **Features**: [explicit, danceability, energy, key, loudness, mode, speechiness, acousticness, instrumentalness, liveness, valence, tempo, duration ms, time signature]
    
  
For more information on features, please check [Spotify API reference page](https://developer.spotify.com/documentation/web-api/reference/tracks/get-audio-features/). In the project, you will only use features with the red color (this is my quite arbitrary choice). All features are numbers.

### 3 Predicates
In this section, the predicates you are going to implement for your song recommendation system will be explained.
  * **3.1** **getArtistTracks(+ArtistName, -TrackIds, -TrackNames)**
    * This predicate will give us track IDs and track names of an artist.
    
  * **3.2** **albumFeatures(+AlbumId, -AlbumFeatures)**
    * In this predicate, you will return the features of an album. Feature of an album is defined as the average of the features of its tracks. Consider only features that are indicated in red in the previous section.

  * **3.3** **artistFeatures(+ArtistName, -ArtistFeatures)**
    * In this predicate, you will return the features of an artist. Feature of an artist is defined as the average of the features of its tracks. Consider only features that are indicated in red in the previous section.
    
  * **3.4** **trackDistance(+TrackId1, +TrackId2, -Score)**
    * Distance between two tracks depends on the Euclidean distance between their features. Let x = [x1,x2,...,x8], and y = [y1,y2,...,y8] be features of track 1 and track 2 respectively.Lower the distance, the more similar the tracks.
    
  * **3.5** **albumDistance(+AlbumId1, +AlbumId2, -Score)**
    * Distance between two albums depends on the Euclidean distance between their features, as in predicate 3.4. You should first implement predicate 3.2 to be able to implement this predicate.
    
  * **3.6**  **artistDistance(+ArtistName1, +ArtistName2, -Score)**
    * Distance between two artists depends on the Euclidean distance between their features, as in predicate 3.4 and 3.5. You should first implement predicate 3.3 to be able to implement this predicate.
    
  * **3.7** **findMostSimilarTracks(+TrackId, -SimilarIds, -SimilarNames)**
     * Given a track, you will return its 30 closest neighbors (most similar 30 tracks). As you might guess, lower the distance between tracks, the more similar the tracks. In order to implement this predicate, you should implement predicate 3.4.
  
  * **3.8** **findMostSimilarAlbums(+AlbumId, -SimilarIds, -SimilarNames)**
    * Given an album, you will return its 30 closest neighbors (most similar 30 albums).In order to implement this predicate, you should implement predicate 3.5.
  
  * **3.9**  **findMostSimilarArtists(+ArtistName, -SimilarArtists)**
    * Given an artist, you will return its 30 closest neighbors (most similar 30 artists). In order to implement this predicate, you should implement predicate 3.6.

  * **3.10** **filterExplicitTracks(+TrackList, -FilteredTracks)**
    * In this predicate, you will filter tracks which has explicit lyrics and return the filtered tracks.
    
  * **3.11** **getTrackGenre(+TrackId, -Genres)**
    * In this predicate, you will return genres of a track. Genres of a track is a list of genres that its artists associated with. There may be a multiple of artists of a track. In this case, genres are the concatenated list genres of both artists. If there is no genre associated with the artist, return an empty list.
  
  * **3.12** **discoverPlaylist(+LikedGenres, +DislikedGenres, +Features, +FileName,-Playlist)**

    * The ultimate predicate. In this predicate, the user will enter a list of liked genres, a list of disliked genres, features (danceability, energy, . . . ) and the recommendation system will return 30 tracks with respect to these settings. The genre of each track in the playlist should include at least one string from LikedGenres, and no string from DislikedGenres. However, the user might not be very informed about genres. Therefore, the system should give results in a more general fashion. For example, the track “Tides of Time” in the examples of predicate 3.11 should be included in the playlist if the user sets LikedGenres = ["metal"], even if "metal" is not in the genre list by itself, but a substring of one or more of the genres. If the user enters LikedGenres = ["pop"], every track which has a substring "pop" in at least one of its genres is a valid track. Likewise, if the user does not want to listen to jazz music, she/he does not have to know every specific jazz genre. She/he enters DislikedGenres = ["jazz"] and there will not be any track with genres including jazz as a substring.
The playlist should be sorted with respect to distances between tracks and Features. Tracks with smaller distances (more similar to the Features) should appear first.
    * The playlist should be written to the file with name FileName in the following order:
      * [trackid1,trackid2,trackid3,. . . ,trackid30] 
      * [trackname1,trackname2,trackname3,. . . ,trackname30] 
      * [artists1,artist2,artists3,. . . ,artists30] 
      * [distance1,distance2,distance3,. . . ,distance30]
      * Example outputs will be provided with its query.
      
      
### HOW TO RUN

  
Instead of reloading the knowledge base every time you make a change, use **load.pl** to load it once in the swipl terminal. When you make a change, you can reload solution.pl by typing:

[solution].

Because loading the knowledge base takes some time.
