-module(buscol).
-compile(export_all).
-include("const.hrl").


setup_data(Business) ->
   Data =  string:tokens(Business, ","),
   [_A, _B,_C, _D, _F, _G, _H, _I, _J, _K, _L, _M] = Data,
   DataSet = [
               {?Id, list_to_binary(_A)},
               {?Uuid, list_to_binary(_B)},
               {?Name, list_to_binary(_C)},
               {?Add1, list_to_binary(_D)},
               {?Add2, list_to_binary(_F)},
               {?City, list_to_binary(_G)},
               {?State, list_to_binary(_H)},
               {?Zip, list_to_binary(_I)},
               {?Country, list_to_binary(_J)},
               {?Phone, list_to_binary(_K)},
               {?Website, list_to_binary(_L)},
               {?Created_at, list_to_binary(_M)}
           ],
    set_buckets(list_to_binary(_A), DataSet),
    set_bucket_indexed_json(?BucketBusiness, 
                            list_to_binary(_A),
                            DataSet,
                            [{"buscol", list_to_binary(_A)}]).

write_businesses()->
    {ok, Device} = file:open("engineering_project_businesses.csv", [read]),
     for_each_business(Device).

for_each_business(Device) ->
     case io:get_line(Device, "") of
        eof  -> file:close(Device);
        Line ->
            setup_data(Line),
            for_each_business(Device)
    end.


connect()->
    {ok, Pid} = riakc_pb_socket:start_link("127.0.0.1", 8087),
    Pid.

disconnect(Pid)->
    riakc_pb_socket:stop(Pid).

set_buckets(Name, Keys)->
    {ok, Pid} = connect(),
    N = case is_binary(Name) of
        false ->
            list_to_binary(Name);
        true ->
            Name
    end,
    lists:foreach(fun(X) ->
                {Key, Data}  = X,
                K = case is_binary(Key) of
                    false ->
                        list_to_binary(Key);
                    true ->
                        Key
                end,
                Obj = riakc_obj:new(N, K, Data),
                riakc_pb_socket:put(Pid, Obj)
        end, Keys),
    disconnect(Pid).

json_indexes(Bucket, IndexList)->
     SecondaryIndexes = lists:foldl(fun(X, Indexes) ->
                 { _IndexName, _IndexValue} = X,
                 Index = {{binary_index, _IndexName}, [_IndexValue]},
                 lists:append([Indexes,[Index]])
         end, [], IndexList),  
     SecondaryIndexes,

    Obj1 = riakc_obj:get_update_metadata(Bucket),
    Obj2 = riakc_obj:set_secondary_index(Obj1, SecondaryIndexes),
    riakc_obj:update_metadata(Bucket,Obj2).

set_bucket_indexed_json(Bucket, Key, Data, Indexes) ->
    {ok, Pid} = connect(),
    In = jsx:encode(Data),
    Obj = riakc_obj:new(Bucket, Key, In, <<"application/json">>),
    IndexedObj = json_indexes(Obj, Indexes),
    Result = riakc_pb_socket:put(Pid, IndexedObj),
    disconnect(Pid),
    Result.
