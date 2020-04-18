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

albumDistance(AlbumId1, AlbumId2, Score) :-
  albumFeatures(AlbumId1,Result1),
  albumFeatures(AlbumId2,Result2),
  featuresDistance(Result1,Result2,S),
  Score is sqrt(S).



artistDistance(ArtistName1, ArtistName2, Score) :-
  artistFeatures(ArtistName1,Result1),
  artistFeatures(ArtistName2,Result2),
  featuresDistance(Result1,Result2,S),
  Score is sqrt(S).


trackSimilarList(_,[],[]).
trackSimilarList(TrackID,[H|T],[H1|T1]) :-
  TrackId-TrackName = H,
  trackDistance(TrackID,TrackId,Score),
  H1 = Score-TrackId-TrackName,
  trackSimilarList(TrackID,T,T1).

albumSimilarList(_,[],[]).
albumSimilarList(AlbumID,[H|T],[H1|T1]) :-
  AlbumId-AlbumName = H,
  albumDistance(AlbumID,AlbumId,Score),
  H1 = Score-AlbumId-AlbumName,
  albumSimilarList(AlbumID,T,T1).

artistSimilarList(_,[],[]).
artistSimilarList(ArtistName,[H|T],[H1|T1]) :-
  artistDistance(ArtistName,H,Score),
  H1 = Score-H,
  artistSimilarList(ArtistName,T,T1).



removeItemsFromList(_,0,[],[]).
removeItemsFromList([H|T],S,[H1|T1],[H2|T2]) :-
  Score-TrackID-TrackName = H,
  (Score =:= 0 -> removeItemsFromList(T,S,[H1|T1],[H2|T2]);
    H1 = TrackID,
    H2 = TrackName,
    Count is -(S,1),
    removeItemsFromList(T,Count,T1,T2)
  ).

removeArtistFromList(_,0,[]).
removeArtistFromList([H|T],S,[H1|T1]) :-
  Score-ArtistName = H,
  (Score =:= 0 -> removeArtistFromList(T,S,[H1|T1]);
    H1 = ArtistName,
    Count is -(S,1),
    removeArtistFromList(T,Count,T1)
  ).
  

findMostSimilarTracks(TrackId, SimilarIds, SimilarNames) :-
  findall(TrackID-TrackName,track(TrackID,TrackName,_,_,_),Result),
  trackSimilarList(TrackId,Result,PairList),
  keysort(PairList,SortedPairList),
  removeItemsFromList(SortedPairList,30,SimilarIds,SimilarNames).
  


findMostSimilarAlbums(AlbumId, SimilarIds, SimilarNames) :-
  findall(AlbumID-AlbumName,album(AlbumID, AlbumName,_,_),Result),
  albumSimilarList(AlbumId,Result,PairList),
  keysort(PairList,SortedPairList),
  removeItemsFromList(SortedPairList,30,SimilarIds,SimilarNames).
  

findMostSimilarArtists(ArtistName, SimilarArtists) :-
  findall(Artists,artist(Artists, _, _),Result),
  artistSimilarList(ArtistName,Result,PairList),
  keysort(PairList,SortedPairList),
  removeArtistFromList(SortedPairList,30,SimilarArtists).


filterTracks([],L,L).
filterTracks([H|T],L2,Result) :-
  track(H, _, _, _,[E|_]),
  (E =:= 1 -> filterTracks(T,L2,Result);
    append(L2,[H],L3),
    filterTracks(T,L3,Result)
  ).

filterExplicitTracks(TrackList, FilteredTracks) :-
  filterTracks(TrackList,[],FilteredTracks).



trackGenre([],L,L).
trackGenre([H|T],L2,Result) :-
  artist(H,Genres,_),
  append(L2,Genres,L3),
  trackGenre(T,L3,Result).

getTrackGenre(TrackId, Genres) :-
  track(TrackId,_,ArtistNames,_,_),
  trackGenre(ArtistNames,[],Genres).
  %append(Result,Genres).

% sub_string("heavy pop",_,_,_,"pop").
 

discoverPlaylist(+LikedGenres, +DislikedGenres, +Features, +FileName, -Playlist).

  







