:- use_module(piezas).

% 1- sublista(+Descartar, +Tomar, +L, -R)

sublista(Descartar, Tomar, L, R) :- append(DL, RyAlgoMas, L), length(DL, Descartar), append(R, _, RyAlgoMas), length(R, Tomar).

% 2- tablero(+K, -T)

copiar(_, 0, []).
copiar(L, N, [X|XS]) :-
    X is L,
    N1 is N - 1,
    copiar(L, N1, XS).
tablero(K, T) :- K > 0, length(L, K), copiar(L, K, T).