:- use_module(piezas).

% 1- sublista(+Descartar, +Tomar, +L, -R)

sublista(Descartar, Tomar, L, R) :- append(DL, RyAlgoMas, L), length(DL, Descartar), append(R, _, RyAlgoMas), length(R, Tomar).

% 2- tablero(+K, -T)
fila(K, Fila) :- length(Fila, K).
tablero(K, T) :- K > 0, length(T, 5), length(L, K), maplist(fila(K), T).

% 3- tamaño(+M, -F, -C)

tamanio(Matriz, Filas, Columnas) :- length(Matriz, Filas), member(Fila, Matriz), length(Fila, Columnas).

% 4- coordenadas(+T, -IJ)

coordenadas(T, (I, J)) :- tamanio(T, Filas, Columnas), between(1, Filas, I), between(1, Columnas, J).

% 5- kPiezas(+K, -PS)

elegirPieza([P | Piezas], P, Piezas).
elegirPieza([_ | Piezas], P, Resto) :- elegirPieza(Piezas, P, Resto).

generarLista(0, _, []).
generarLista(K, Piezas, [P | PS]) :- K > 0, elegirPieza(Piezas, P, RestoPiezas), K1 is K - 1, generarLista(K1, RestoPiezas, PS).

kPiezas(K, PS) :- nombrePiezas(Piezas), generarLista(K, Piezas, PS).

% 6-