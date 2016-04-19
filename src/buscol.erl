-module(buscol).
-compile(export_all).
-include("const.hrl").

clean()->
    Pid = connect(),
    {ok, B} = riakc_pb_socket:list_buckets(Pid),

    lists:foreach(fun(X) ->
             {ok, K} = riakc_pb_socket:list_keys(Pid,X),
                lists:foreach(fun(Y) ->
                            case X of
                                <<"rekon">> -> ignore;
                                _->
                                    riakc_pb_socket:delete(Pid, X, Y)
                            end
                    end, K)
        end,B),
	disconnect(Pid).

start_data()->
    Pid = connect(),
    {ok, DataList} = riakc_pb_socket:list_buckets(Pid),
    case length(DataList) > 1 of
        true ->
            "database completed";
        false ->
            try
                write_businesses(),
                "database completed"
            catch
                Ex:Type -> {Ex,Type,erlang:get_stacktrace()} 
            end
    end.
        
setup_data(Business) ->
   Data =  string:tokens(Business, ","),
   case length(Data) of
       12 ->
           [Id, Uuid, Name, Address, Address2, City, State,
           Zip, Country, Phone, Website, Created_at] = Data,
            DataSet = [
               {?Id, list_to_binary(Id)},
               {?Uuid, list_to_binary(Uuid)},
               {?Name, list_to_binary(Name)},
               {?Add1, list_to_binary(Address)},
               {?Add2, list_to_binary(Address2)},
               {?City, list_to_binary(City)},
               {?State, list_to_binary(State)},
               {?Zip, list_to_binary(Zip)},
               {?Country, list_to_binary(Country)},
               {?Phone, list_to_binary(Phone)},
               {?Website, list_to_binary(Website)},
               {?Created_at, list_to_binary(Created_at)}
           ],
           set_bucket_indexed_json(?BucketBusiness,
                                    list_to_binary(Id),
                                    DataSet,
                                    [
                                        {"buscol", <<"onelocal">>},
                                        {"id", list_to_binary(Id)}
                                    ]);
        13 ->
            [Id, Uuid, Name1, Name2, Address, Address2, City, State,
                Zip, Country, Phone, Website, Created_at] = Data,
            Name = Name1 ++  Name2,
            DataSet = [
                {?Id, list_to_binary(Id)},
                {?Uuid, list_to_binary(Uuid)},
                {?Name, list_to_binary(Name)},
                {?Add1, list_to_binary(Address)},
                {?Add2, list_to_binary(Address2)},
                {?City, list_to_binary(City)},
                {?State, list_to_binary(State)},
                {?Zip, list_to_binary(Zip)},
                {?Country, list_to_binary(Country)},
                {?Phone, list_to_binary(Phone)},
                {?Website, list_to_binary(Website)},
                {?Created_at, list_to_binary(Created_at)}
            ],
            set_bucket_indexed_json(?BucketBusiness,
                list_to_binary(Id),
                DataSet,
                [
                    {"buscol", <<"onelocal">>},
                    {"id", list_to_binary(Id)}
                    
                ]);

       _-> 
           [Id, Uuid, Name, Address, City, State,
           Zip, Country, Phone, Website, Created_at] = Data,
           DataSet = [
               {?Id, list_to_binary(Id)},
               {?Uuid, list_to_binary(Uuid)},
               {?Name, list_to_binary(Name)},
               {?Add1, list_to_binary(Address)},
               {?City, list_to_binary(City)},
               {?State, list_to_binary(State)},
               {?Zip, list_to_binary(Zip)},
               {?Country, list_to_binary(Country)},
               {?Phone, list_to_binary(Phone)},
               {?Website, list_to_binary(Website)},
               {?Created_at, list_to_binary(Created_at)}
           ],
           set_bucket_indexed_json(?BucketBusiness,
                                    list_to_binary(Id),
                                    DataSet,
                                    [
                                        {"buscol", <<"onelocal">>},
                                        {"id", list_to_binary(Id)}
                                    ])
   end.

write_businesses()->
    {ok, Device} = file:open("engineering_project_businesses.csv", [read]),
     for_each_business(Device).

for_each_business(Device) ->
     case io:get_line(Device, "") of
        eof  -> file:close(Device);
        Line ->
            timer:sleep(1),
            setup_data(Line),
            for_each_business(Device)
    end.


connect()->
    {ok, Pid} = riakc_pb_socket:start_link("127.0.0.1", 8087),
    Pid.

disconnect(Pid)->
    riakc_pb_socket:stop(Pid).

set_buckets(Name, Keys)->
    Pid = connect(),
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
    Pid = connect(),
    In = jsx:encode(Data),
    Obj = riakc_obj:new(Bucket, Key, In, <<"application/json">>),
    IndexedObj = json_indexes(Obj, Indexes),
    Result = riakc_pb_socket:put(Pid, IndexedObj),
    disconnect(Pid),
    Result.
