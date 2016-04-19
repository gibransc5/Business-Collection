-module(buscol).
-compile(export_all).
-include("const.hrl")

connect()->
    {ok, Pid} = riakc_pb_socket:start_link("127.0.0.1", 8087),
    Pid.

disconnect(Pid)->
    riakc_pb_socket:stop(Pid).


setup_data(Business) ->
   Data =  string:tokens(Business, ","),

   [_A, _B,_C, _D, _F, _G, _H, _I, _J, _K, _L, _M] = string:tokens(Business, ",").

write_businesses()->
    {ok, Device} = file:open("engineering_project_businesses.csv", [read]),
     for_each_business(Device).

for_each_business(Device) ->
     case io:get_line(Device, "") of
        eof  -> file:close(Device);
        Line ->
        Data = string:tokens(Line, ","),
	for_each_business(Device)
    end.


