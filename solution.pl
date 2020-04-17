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



features([explicit-0, danceability-1, energy-1,
          key-0, loudness-0, mode-1, speechiness-1,
       	  acousticness-1, instrumentalness-1,
          liveness-1, valence-1, tempo-0, duration_ms-0,
          time_signature-0]).

filter_features(Features, Filtered) :- features(X), filter_features_rec(Features, X, Filtered).
filter_features_rec([], [], []).
filter_features_rec([FeatHead|FeatTail], [Head|Tail], FilteredFeatures) :-
    filter_features_rec(FeatTail, Tail, FilteredTail),
    _-Use = Head,
    (
        (Use is 1, FilteredFeatures = [FeatHead|FilteredTail]);
        (Use is 0,
            FilteredFeatures = FilteredTail
        )
    ).


iterateTrackIds([],L,L).
iterateTrackIds([H|T],L2,[H1|T1]) :-
  track(H,TrackName,_,_,_),
  H1 = TrackName,
  iterateTrackIds(T,L2,T1).

addTwoList([],[],[]).
addTwoList(R,[],R).
addTwoList([H0|T0],[H1|T1],[H2|T2]) :-
  H2 is H0 + H1,
  addTwoList(T0,T1,T2).



divideList([],_,[]).
divideList([],1,[]).
divideList([H|T],D,[H1|T1]) :-
  H1 is H/D,
  divideList(T,D,T1).

iterateFeatures([],L,L).
iterateFeatures([H|T],L2,Result) :-
  track(H,_,_,_,Features),
  filter_features(Features,FilteredFeatures),
  addTwoList(FilteredFeatures,L2,L3),
  iterateFeatures(T,L3,Result).


iterateAlbumIds([],L,L).
iterateAlbumIds([H|T],L2,Result) :-
  album(H,_,_,TrackIds),
  append(L2,TrackIds,NewList),
  iterateAlbumIds(T,NewList,Result).

getArtistTracks(ArtistName, TrackIds, TrackNames) :-
  findall(AlbumIds,artist(ArtistName,_,AlbumIds),Result),

  %findall(IDs,album(_,_,[ArtistName],IDs),ResultIDs), % Result is list of lists which contains all trackIds of corresponding artist.
  append(Result,ArtistAlbums),
  %iterate TrackIds,found track names, append TrackNames list.
  iterateAlbumIds(ArtistAlbums,[],TrackIds),
  iterateTrackIds(TrackIds,[],TrackNames).
  
  

 albumFeatures(AlbumId, AlbumFeatures) :-
  %findall(IDs,album(AlbumId,_,_,IDs),Result),
  %append(Result,ResultIDs),
  album(AlbumId,_,_,IDs),
  length(IDs,Sum),
  iterateFeatures(IDs,[],AllTracksSum),
  divideList(AllTracksSum,Sum,AlbumFeatures).



artistFeatures(ArtistName, ArtistFeatures) :-
  getArtistTracks(ArtistName,TrackIds,_),
  length(TrackIds,Sum),
  iterateFeatures(TrackIds,[],AllTracksSum),
  divideList(AllTracksSum,Sum,ArtistFeatures).



featuresDistance([],[],0).
featuresDistance([H0|T0],[H1|T1],Sum) :-
  featuresDistance(T0,T1,S),
  Sum is S + (H0-H1)*(H0-H1).


trackDistance(TrackId1, TrackId2, Score) :-
  track(TrackId1,_,_,_,Explicit1),
  filter_features(Explicit1,Result1),
  track(TrackId2,_,_,_,Explicit2),
  filter_features(Explicit2,Result2),
  featuresDistance(Result1,Result2,S),
  Score is sqrt(S).

albumDistance(+AlbumId1, +AlbumId2, -Score).



artistDistance(+ArtistName1, +ArtistName2, -Score).

findMostSimilarTracks(+TrackId, -SimilarIds, -SimilarNames).
findMostSimilarAlbums(+AlbumId, -SimilarIds, -SimilarNames).
findMostSimilarArtists(+ArtistName, -SimilarArtists).

filterExplicitTracks(+TrackList, -FilteredTracks).

getTrackGenre(+TrackId, -Genres).

discoverPlaylist(+LikedGenres, +DislikedGenres, +Features, +FileName, -Playlist).







