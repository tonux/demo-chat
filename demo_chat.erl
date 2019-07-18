-module(demo_chat).
-author("tonuxSamb"). 
-version("1.0"). 
-export([run/0]).

-define(OPTIONS, [binary, {packet, 0}, {active, false}, {reuseaddr, true}]).
-record(user, {userName=none, socket=none}).

% when user is first connect ask username
login(Socket) ->
    gen_tcp:send(Socket, "Give your username :) "),
    case listen(Socket) of
        {ok, N} ->
            UserName = binary_to_list(N),
            UserName,
            server ! {join, #user{userName =  lists:sublist(UserName, 1, length(UserName) - 2), socket = Socket} },
            client(Socket);
        _ -> ok
    end.

server() -> server([]).
server(Users) ->
    receive
        {join, User=#user{userName = _UserName, socket = Socket}} ->
            self() ! {post, Socket, "  has joined the channel. \n\r"},
            server(Users ++ [User]);
        {post, Socket, Content} ->
            {value, #user{userName = From}, List} = lists:keytake(Socket, 3, Users),
            Message = "__" ++ From ++ " : " ++ Content,
            lists:map(fun(#user{socket = S}) ->
                    gen_tcp:send(S, Message)
                end, List);
        {quit, Socket} ->
            {value, #user{userName = _UserName}, List} = lists:keytake(Socket, 3, Users),
            self() ! {post, none, _Message = "left the channel."},
            server(List)
    end,
    server(Users).

%% lists:keytake(Socket, 3, Users) : Take first Tuple which its 3em element is Socket, Also yield Rest of List: 

client(Socket) ->
    case listen(Socket) of
        {ok, Content} ->
            server ! {post, Socket, binary_to_list(Content)},
            client(Socket);
        _ -> server ! {quit, Socket}
    end.
 
% listens for data on a socket, receives the binary
listen(Socket) ->
    case gen_tcp:recv(Socket, 0) of
        Response -> Response
    end.

acceptor(ListenSocket) ->
    {ok, Socket} = gen_tcp:accept(ListenSocket),
    spawn(fun() -> login(Socket) end),
    acceptor(ListenSocket).

run() ->
    register(server, spawn(fun() -> server() end)),
    {ok, ListenSocket} = gen_tcp:listen(4000, ?OPTIONS),
    acceptor(ListenSocket).