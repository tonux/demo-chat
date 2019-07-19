-module(demo_chat).
-author("tonuxSamb"). 
-version("1.0"). 
-export([run/0]).

-define(OPTIONS, [binary, {packet, 0}, {active, false}, {reuseaddr, true}]).
-record(user, {userName, socket}).

% when user is first connect ask username
login(Socket) ->
    gen_tcp:send(Socket, "Give your username :) "),
    case listen(Socket) of
        {ok, Name} ->
            UserName = binary_to_list(Name),
            UserName,
            server ! {join, #user{userName =  lists:sublist(UserName, 1, length(UserName) - 2), socket = Socket} },
            client(Socket);
        _ -> ok
    end.

server() -> server({[]}).
server({Users}) ->
    receive
        {join, User=#user{userName = _UserName, socket = Socket}} ->
            self() ! {post, Socket, "  has joined the channel. \n\r"},
            server({Users ++ [User]});
        {post, Socket, Content} ->
            
            {value, #user{userName = From}, List} = lists:keytake(Socket, 3, Users),
            Message = "--" ++ From ++ " : " ++ Content,
            case Content of
            [113,117,105,116,13,10] ->
                %% equal quit
                case List of 
                    [] -> 
                        quit([], Socket);
                    _ -> 
                        quit(List, Socket, From)
                end;
            _ ->
                %% not equal quit 
                lists:map(fun(#user{socket = S}) ->
                    save(Message),
                    gen_tcp:send(S, Message)
                end, List)
            end;
        {quit, Socket} ->
            % put content in File
            {value, #user{userName = _UserName}, List} = lists:keytake(Socket, 3, Users),
            server({List})
    end,
    server({Users}).

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

save(Message) ->
    case file:read_file_info("Message.txt") of
        {ok, _FileInfo} ->
                 file:write_file("Message.txt", Message, [append]);
        {error, enoent} ->
                 donothing
 end.

quit([], Socket) -> 
    gen_tcp:send(Socket, " you left the channel. \n\r"),
    gen_tcp:close(Socket).
quit(List, Socket, From) -> 
    lists:map(fun(#user{socket = S}) ->
        gen_tcp:send(S, "**" ++ From ++ " left the channel. \n\r"),
        gen_tcp:close(Socket)
    end, List).

acceptor(ListenSocket) ->
    {ok, Socket} = gen_tcp:accept(ListenSocket),
    spawn(fun() -> login(Socket) end),
    acceptor(ListenSocket).

run() ->
    register(server, spawn(fun() -> server() end)),
    {ok, ListenSocket} = gen_tcp:listen(4000, ?OPTIONS),
    acceptor(ListenSocket).