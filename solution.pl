% furkan cansever
% 2016400348
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





iterateAlbumIds([],[]).
iterateAlbumIds([AlbumHead|AlbumTail],[TracksHead|TracksTail]) :-
  album(AlbumHead,_,_,TrackIds),
  TracksHead = TrackIds,
  iterateAlbumIds(AlbumTail,TracksTail).

iterateTrackIds([],[]).
iterateTrackIds([TrackHead|TrackTail],[TrackNameHead|TrackNameTail]) :-
  track(TrackHead,TrackName,_,_,_),
  TrackNameHead = TrackName,
  iterateTrackIds(TrackTail,TrackNameTail).


getArtistTracks(ArtistName, TrackIds, TrackNames) :-
  artist(ArtistName,_,AlbumIds),
  iterateAlbumIds(AlbumIds,TrackIDs),
  append(TrackIDs,TrackIds),
  iterateTrackIds(TrackIds,TrackNames).
  


addTwoList([],[],[]).
addTwoList(R,[],R).
addTwoList([H0|T0],[H1|T1],[H2|T2]) :-
  H2 is (H0) + (H1),
  addTwoList(T0,T1,T2).

divideList([],_,[]).
divideList([],1,[]).
divideList([H|T],D,[H1|T1]) :-
  H1 is H/D,
  divideList(T,D,T1).

iterateFeatures([],L,L).
iterateFeatures([TrackHead|TrackTail],Temp,Result) :-
  track(TrackHead,_,_,_,Features),
  filter_features(Features,FilteredFeatures),
  addTwoList(FilteredFeatures,Temp,L3),
  iterateFeatures(TrackTail,L3,Result).


albumFeatures(AlbumId, AlbumFeatures) :-
  album(AlbumId,_,_,IDs),
  length(IDs,Sum),
  iterateFeatures(IDs,[],AllTracksSum),
  divideList(AllTracksSum,Sum,AlbumFeatures).



artistFeatures(ArtistName, ArtistFeatures) :-
  artist(ArtistName,_,AlbumIds),
  iterateAlbumIds(AlbumIds,TrackIDs),
  append(TrackIDs,TrackIds),
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
  
removeItemsFromList(_,0,[],[]).
removeItemsFromList([H|T],S,[H1|T1],[H2|T2]) :-
  Score-TrackID-TrackName = H,
  (Score =:= 0 -> removeItemsFromList(T,S,[H1|T1],[H2|T2]);
    H1 = TrackID,
    H2 = TrackName,
    Count is -(S,1),
    removeItemsFromList(T,Count,T1,T2)
  ).

findMostSimilarTracks(TrackId, SimilarIds, SimilarNames) :-
  findall(TrackID-TrackName,track(TrackID,TrackName,_,_,_),Result),
  trackSimilarList(TrackId,Result,PairList),
  keysort(PairList,SortedPairList),
  removeItemsFromList(SortedPairList,30,SimilarIds,SimilarNames).
  
albumSimilarList(_,[],[]).
albumSimilarList(AlbumID,[H|T],[H1|T1]) :-
  AlbumId-AlbumName = H,
  albumDistance(AlbumID,AlbumId,Score),
  H1 = Score-AlbumId-AlbumName,
  albumSimilarList(AlbumID,T,T1).

removeAlbumsFromList(_,0,[],[]).
removeAlbumsFromList([H|T],S,[H1|T1],[H2|T2]) :-
  Score-TrackID-TrackName = H,
  (Score =:= 0 -> removeAlbumsFromList(T,S,[H1|T1],[H2|T2]);
    H1 = TrackID,
    H2 = TrackName,
    Count is -(S,1),
    removeAlbumsFromList(T,Count,T1,T2)
  ).

findMostSimilarAlbums(AlbumId, SimilarIds, SimilarNames) :-
  findall(AlbumID-AlbumName,album(AlbumID, AlbumName,_,_),Result),
  albumSimilarList(AlbumId,Result,PairList),
  keysort(PairList,SortedPairList),
  removeAlbumsFromList(SortedPairList,30,SimilarIds,SimilarNames).


artistSimilarList(_,[],[]).
artistSimilarList(ArtistName,[H|T],[H1|T1]) :-
  artistDistance(ArtistName,H,Score),
  H1 = Score-H,
  artistSimilarList(ArtistName,T,T1).

removeArtistFromList(_,0,[]).
removeArtistFromList([H|T],S,[H1|T1]) :-
  Score-ArtistName = H,
  (Score =:= 0 -> removeArtistFromList(T,S,[H1|T1]);
    H1 = ArtistName,
    Count is -(S,1),
    removeArtistFromList(T,Count,T1)
  ).

  

findMostSimilarArtists(ArtistName, SimilarArtists) :-
  findall(Artists,artist(Artists, _, _),Result),
  artistSimilarList(ArtistName,Result,PairList),
  keysort(PairList,SortedPairList),
  removeArtistFromList(SortedPairList,30,SimilarArtists).


filterTracks([],[]).
filterTracks([H|T],[H1|T1]) :-
  track(H, _, _, _,[E|_]),
  (E =:= 1 -> filterTracks(T,[H1|T1]);
    H1 = H,
    filterTracks(T,T1)
  ).

filterExplicitTracks(TrackList, FilteredTracks) :-
  filterTracks(TrackList,FilteredTracks).



trackGenre([],[]).
trackGenre([H|T],[H1|T1]) :-
  artist(H,Genres,_),
  H1 = Genres,
  trackGenre(T,T1).

getTrackGenre(TrackId, Genres) :-
  (track(TrackId,_,ArtistNames,_,_) -> trackGenre(ArtistNames,Result),append(Result,Res),list_to_set(Res,Genres);
    trackGenre([],Genres)
  ).

%sub_string(+String,_,_,_,+substring).
% sub_string("heavy pop",_,_,_,"pop").
 
  
each_contains([],[]) --> false.
each_contains([H1|T1],Item) :-
  (sub_string(H1,_,_,_,Item) -> true;
    each_contains(T1,Item)
  ).


contains([],[]) --> false.
contains([H1|T1],[H2|T2]) :- 
  (each_contains([H1|T1],H2) -> true;
    contains([H1|T1], T2)
    
  ).



filterLikedAndDislikeGenre(_,_,[],_,L,L).
filterLikedAndDislikeGenre(Liked,Dislike,[H3|T3],Features,L2,Result) :-
  ArtistName-Genres = H3,
  
  
  ((contains(Genres,Liked),not(contains(Genres,Dislike))) -> 
  
  getArtistTracks(ArtistName,TrackIds,_),
  pairList(TrackIds,Features,ArtistName,[],R),
  append(L2,R,L3),
  filterLikedAndDislikeGenre(Liked,Dislike,T3,Features,L3,Result);
    filterLikedAndDislikeGenre(Liked,Dislike,T3,Features,L2,Result)
  ).

%pairList(TrackIds,TrackNames,ArtistName,Result).
pairList([],_,_,L,L).
pairList([H1|T1],FeaturesOfTrack,ArtistName,L2,Result) :-
  track(H1,TrackName,_,_,Features),
  filter_features(Features,FilteredFeatures),
  featuresDistance(FilteredFeatures,FeaturesOfTrack,S),
  Score is sqrt(S),
  NewPair = Score-H1-TrackName-ArtistName,
  append(L2,[NewPair],L3),
  pairList(T1,FeaturesOfTrack,ArtistName,L3,Result).





filterPlayList(_,0,[]).
filterPlayList([H|T],S,[H|T1]) :-
  Count is -(S,1),
  filterPlayList(T,Count,T1).


iteratePlaylist([],[],[],[],[]).
iteratePlaylist([H1|T1],[H2|T2],[H3|T3],[H4|T4],[H5|T5]) :-
  T-N-A-D = H1,
  H2 = T, H3 = N, H4 = A, H5 = [D],
  iteratePlaylist(T1,T2,T3,T4,T5).


discoverPlaylist(LikedGenres,DislikedGenres,Features,FileName,Playlist) :-
  findall(ArtistName-Genres,artist(ArtistName,Genres,_),Result),
  filterLikedAndDislikeGenre(LikedGenres,DislikedGenres,Result,Features,[],PairList),
  keysort(PairList,SortedPairList),
  filterPlayList(SortedPairList,30,Playlist),
  iteratePlaylist(Playlist,Distance,TrackIds,TrackNames,ArtistName),
  open(FileName,write,Stream),
  writeln(Stream,TrackIds),
  writeln(Stream,TrackNames),
  writeln(Stream,ArtistName),
  writeln(Stream,Distance),
  close(Stream).




