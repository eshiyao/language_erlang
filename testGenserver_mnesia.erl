-module(testGenserver_mnesia).
-behavior(gen_server).

-export([init/1,start/0,
	 stop/0,
	 mnesia_writing/0,
	 handle_call/3,
	 handle_info/2]).

-ifndef(tabs).
-define(tabs,[tab1]).
-endif.

-record(tab1,{key=k1,value=v1}).

init([])->
	%%mnesia_start(),
	mnesia_subscribe(),
	{ok,test_state}.

start()->gen_server:start_link({local,?MODULE},?MODULE,[],[]).
stop()->gen_server:stop(?MODULE).

terminate(_R,_S)->ok.

mnesia_writing()->gen_server:call(?MODULE,{start_writing}).

handle_call({start_writing},_From,_State)->
	F=fun()->mnesia:write(#tab1{}),
	ok end,
	Reply=mnesia:transaction(F),
	io:format("server: handle_call State~n~p~n",[_State]),
	{reply,Reply,_State}.

handle_info({write,Obj_table,ActivityID},State)->
	io:format("mnesia subscribed, State: ~p~n",[State]),
	io:format("tab: ~p~n ActivityID: ~p~n",[Obj_table,ActivityID]),	
	{noreply,State}.


%%%
%%%internal functions
%%%

mnesia_subscribe()->
	[mnesia:subscribe({tab,Tab,simple})||Tab<-?tabs].
