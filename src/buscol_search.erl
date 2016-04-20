-module(buscol_search).
-include("const.hrl").
-compile(export_all).

get_records()->
    Pid  = buscol:connect(),
    {_R, Result}  =  try
        riakc_pb_socket:get_index_eq(Pid,                
        ?BucketBusiness, 
        {binary_index, "buscol"},
        <<"onelocal">>,
        [{max_results, 50}])
    catch
        error:Reason ->
            io:fwrite("Error reason: ~p~n", [Reason]);
        throw:Reason ->
            io:fwrite("Throw reason: ~p~n", [Reason]);
        exit:Reason ->
            io:fwrite("Exit reason: ~p~n", [Reason])
    end,

    buscol:disconnect(Pid),
    case _R of 
        error ->
            error;
        _->
            Result
    end.

get_more_records(_Continuation) ->
    Pid  = buscol:connect(),
    {_R, Result}  =  try 
        riakc_pb_socket:get_index_eq(Pid,
        ?BucketBusiness,
        {binary_index, "buscol"},
        <<"onelocal">>,
        [{max_results, 50},{continuation,_Continuation}])
    catch
        error:Reason ->
            io:fwrite("Error reason: ~p~n", [Reason]);
        throw:Reason ->
            io:fwrite("Throw reason: ~p~n", [Reason]);
        exit:Reason ->
            io:fwrite("Exit reason: ~p~n", [Reason])
    end,
    
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
            case get_records() of
                error ->
                    {error,?BUSINESSES_NOT_FOUND,404,[]};
                _->
                    {_,Businesses,_,_Next} = get_records(),
                    {Businesses,_Next, 200}
            end;
        _->
            case get_more_records(_Continuation) of
                error ->
                    {error,?BUSINESSES_NOT_FOUND,404,[]};
                _->
                    {_,Businesses,_,_Next} = get_more_records(_Continuation),
                    {Businesses,_Next, 200}
            end
    end.

