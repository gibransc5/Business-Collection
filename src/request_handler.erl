-module(request_handler).
-compile({parse_transform, leptus_pt}).

%% leptus callbacks
-export([init/3]).
-export([get/3]).
-export([terminate/4]).

init(_Route, _Req, State) ->
    {ok, State}.

get("/businesses/", _Req, State) ->
    {Status, Response}  = case buscol_search:search_businesses([]) of 
    {error, ResErr,Stat1,_} -> {Stat1, ResErr};
        _->
            {_BusinessesIds, _NextPage, Stat2} = buscol_search:search_businesses([]),
            ResSucc = [{<<"businesses">>,_BusinessesIds },{<<"next_page">>, _NextPage}],
            {Stat2, ResSucc}
    end,
    {Status, {json, Response},State};

get("/businesses/:next_id", _Req, State) ->
    NextId = leptus_req:param(_Req, next_id),
    {Status, Response} = case buscol_search:search_businesses(NextId) of
        {error, ResErr,Stat1,_} -> {Stat1, ResErr};
        _->
            {_BusinessesIds, _NextPage, Stat2} = buscol_search:search_businesses(NextId),
            ResSucc = [{<<"businesses">>,_BusinessesIds },{<<"next_page">>, _NextPage}],
            {Stat2, ResSucc}
    end,
    {Status, {json, Response},State};

get("/business/:id", Req, State) ->
    Id = leptus_req:param(Req, id),
    {Status, Response} = buscol:get_business(Id),
    {Status, {json, Response}, State}.

terminate(_Reason, _Route, _Req, _State) ->
    ok.

