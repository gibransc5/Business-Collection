-module(buscol_search).
-include("const.hrl").
-compile(export_all).

get_records()->
    Pid  = buscol:connect(),
    {_R, Result} =  riakc_pb_socket:get_index_eq(Pid,                
        ?BucketBusiness, 
        {binary_index, "buscol"},
        <<"onelocal">>,
        [{max_results, 50}]),
    buscol:disconnect(Pid),
    case _R of 
        error ->
            error;
        _->
            Result
    end.

get_more_records(_Continuation) ->
    Pid  = buscol:connect(),
    {_R, Result} =  riakc_pb_socket:get_index_eq(Pid,
        ?BucketBusiness,
        {binary_index, "buscol"},
        <<"onelocal">>,
        [{max_results, 50},{continuation,_Continuation}]),
    buscol:disconnect(Pid),
    case _R of 
        error ->
            error;
        _->
            Result
    end.

search_businesses(_Continuation)->
    case _Continuation of
        [] ->
            {_,Businesses,_,_Next} = get_records(),
            {Businesses,_Next};
        _->
            {_,Businesses,_,_Next}  = get_more_records(_Continuation),
            {Businesses,_Next}
    end.

