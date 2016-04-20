-module(request_handler).
-compile({parse_transform, leptus_pt}).

%% leptus callbacks
-export([init/3]).
-export([get/3]).
-export([terminate/4]).

init(_Route, _Req, State) ->
    {ok, State}.

get("/", _Req, State) ->
    {<<"Hello, leptus!">>, State};

get("/business/:id", Req, State) ->
    Id = leptus_req:param(Req, id),
    {Status, Response} = buscol:get_business(Id),
    {Status, {json, Response}, State}.

terminate(_Reason, _Route, _Req, _State) ->
    ok.

