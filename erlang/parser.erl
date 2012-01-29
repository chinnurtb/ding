%%% @author Gert Meulyzer <@G3rtm on Twitter>
%%% @copyright (C) 2012, Gert Meulyzer
%%% @doc
%%% Parser module for IRC messages.
%%% This time, let's try to keep everything working with binaries.
%%% -spec Function(ArgName1 :: Type1, ..., ArgNameN :: TypeN) -> RT.
%%% -spec Function(ArgType1, ..., ArgTypeN) -> ReturnType.
%%% A little documentation can't hurt.
%%% @end
%%% Created : 29 Jan 2012 by Gert Meulyzer <@G3rtm on Twitter>

-module(parser).
-include("irc.hrl").

-define(COLON, 58).

%% Shut up! This is just here until I finish the module. :p
-compile(export_all).

-spec lines(Packet :: binary()) -> [binary()].
lines(Packet) ->
    binary:split(Packet, <<"\r\n">>, [global, trim]).

-spec starts_with_colon(B :: binary()) -> boolean().
starts_with_colon(<<>>) ->
    false;
starts_with_colon(Bin) ->
    binary:first(Bin) == ?COLON.

-spec words_in_line(Line :: binary()) -> [binary()].
words_in_line(Line) ->
    binary:split(Line, <<" ">>, [global, trim]).

next_word([]) ->
    {the_end, []};
next_word([H]) ->
    {H, []};
next_word([H|T]) ->
    {H, T}.

-spec get_prefix(Words :: [binary()]) -> {binary(), [binary()]}.
get_prefix([H|T]=L) ->
    case starts_with_colon(H) of
        true -> {H, T};
        _ -> {<<>>, L}
    end;
get_prefix(A) ->
    {<<>>,A}.

-spec get_arguments_and_tail(AfterCmd :: [binary()]) -> {binary(), [binary()]}.
get_arguments_and_tail(AfterCmd) ->
    {Args, T} = lists:splitwith(fun(X) -> not(starts_with_colon(X)) end, AfterCmd),
    {Args, iolist_to_binary([ [ <<" ">>, X ] || X <- T ])}.


-spec parse_line(Line :: binary()) -> [tuple()].
parse_line(Line) ->
    Words = words_in_line(Line),
    {P, Rest1} = get_prefix(Words),
    {C, Rest2} = next_word(Rest1),
    {A, T} = get_arguments_and_tail(Rest2),
    [{prefix, P}, {cmd, C}, {args, A}, {tail, T}].
