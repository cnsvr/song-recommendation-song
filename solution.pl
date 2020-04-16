% alper ahmetoglu
% 2012400147
% compiling: yes
% complete: yes

% artist(ArtistName, Genres, AlbumIds).
% album(AlbumId, AlbumName, ArtistNames, TrackIds).
% track(TrackId, TrackName, ArtistNames, AlbumName, [Explicit, Danceability, Energy,
%                                                    Key, Loudness, Mode, Speechiness,
%                                                    Acousticness, Instrumentalness, Liveness,
%                                                    Valence, Tempo, DurationMs, TimeSignature]).



iterateTrackIds([],L,L).
iterateTrackIds([H|T],L2,[H1|T1]) :-
  track(H,TrackName,_,_,_),
  H1 = TrackName,
  iterateTrackIds(T,L2,T1).
  

getArtistTracks(ArtistName, TrackIds, TrackNames) :-
  findall(IDs,album(_,_,[ArtistName],IDs),ResultIDs), % Result is list of lists which contains all trackIds of corresponding artist.
  append(ResultIDs,TrackIds),
  %iterate TrackIds,found track names, append TrackNames list.
  iterateTrackIds(TrackIds,[],TrackNames).
  
  

% albumFeatures(+AlbumId, -AlbumFeatures) 5 points
% artistFeatures(+ArtistName, -ArtistFeatures) 5 points

% trackDistance(+TrackId1, +TrackId2, -Score) 5 points
% albumDistance(+AlbumId1, +AlbumId2, -Score) 5 points
% artistDistance(+ArtistName1, +ArtistName2, -Score) 5 points

% findMostSimilarTracks(+TrackId, -SimilarIds, -SimilarNames) 10 points
% findMostSimilarAlbums(+AlbumId, -SimilarIds, -SimilarNames) 10 points
% findMostSimilarArtists(+ArtistName, -SimilarArtists) 10 points

% filterExplicitTracks(+TrackList, -FilteredTracks) 5 points

% getTrackGenre(+TrackId, -Genres) 5 points

% discoverPlaylist(+LikedGenres, +DislikedGenres, +Features, +FileName, -Playlist) 30 points