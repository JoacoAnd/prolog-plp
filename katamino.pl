:- use_module(piezas).

% 1- sublista(+Descartar, +Tomar, +L, -R)

sublista(Descartar, Tomar, L, R) :- append(DL, RyAlgoMas, L), length(DL, Descartar), append(R, _, RyAlgoMas), length(R, Tomar).

% 2- tablero(+K, -T)

fila(K, Fila) :- length(Fila, K).
tablero(K, T) :- K > 0, length(T, 5), maplist(fila(K), T).

% 3- tamaño(+M, -F, -C)

tamanio([M|MS], Filas, Columnas) :- length([M|MS], Filas), length(M, Columnas).

% 4- coordenadas(+T, -IJ)

coordenadas(T, (I,J)) :- nth1(I, T, Fila), nth1(J, Fila, _).

% 5- kPiezas(+K, -PS)

elegirPieza([P | Piezas], P, Piezas).
elegirPieza([_ | Piezas], P, Resto) :- elegirPieza(Piezas, P, Resto).

generarLista(0, _, []).
generarLista(K, Piezas, [P | PS]) :- K > 0, elegirPieza(Piezas, P, RestoPiezas), K1 is K - 1, generarLista(K1, RestoPiezas, PS).

kPiezas(K, PS) :- nombrePiezas(Piezas), generarLista(K, Piezas, PS).

% 6- seccionTablero(+T, +ALTO, +ANCHO, +IJ, ?ST)

recortarEnAnchura([], _, _, []).
recortarEnAnchura([A|SA], ANCHO, J, [S|ST]) :- J1 is J - 1, sublista(J1, ANCHO, A, S), recortarEnAnchura(SA, ANCHO, J, ST).
seccionTablero(T, ALTO, ANCHO, (I, J), ST) :- I1 is I - 1, sublista(I1, ALTO, T, STAltura), recortarEnAnchura(STAltura, ANCHO, J, ST).

% 7- ubicarPieza(+Tablero, +Identificador)

ubicarPieza(Tablero, Identificador) :- 
    pieza(Identificador, Pieza), 
    tamanio(Pieza, ALTO, ANCHO), 
    coordenadas(Tablero, IJ),
    seccionTablero(Tablero, ALTO, ANCHO, IJ, Pieza).

% 8- ubicarPiezas(+Tablero, +Poda, +Identificadores)

ubicarPiezas(_, _, []).
ubicarPiezas(Tablero, Poda, [P|PS]) :-
    ubicarPieza(Tablero, P),
    poda(Poda, Tablero),
    ubicarPiezas(Tablero, Poda, PS).

% 9- llenarTablero(+Poda, +Columnas, -Tablero)

llenarTablero(Poda, Columnas, Tablero) :- tablero(Columnas, Tablero), kPiezas(Columnas, Piezas), ubicarPiezas(Tablero, Poda, Piezas).

% 10- Medicion
cantSoluciones(Poda, Columnas, N) :-
findall(T, llenarTablero(Poda, Columnas, T), TS),
length(TS, N).
 
% 36,023,793 inferences, 1.812 CPU in 1.870 seconds (97% CPU, 19875196 Lips)
% N = 28.

% 1,426,464,108 inferences, 69.531 CPU in 70.363 seconds (99% CPU, 20515439 Lips)
% N = 200.

% 11- Optimizacion

coordenadaEsLibre(T, (I,J)) :- nth1(I, T, Fila), nth1(J, Fila, Coordenada), var(Coordenada).

todosGruposLibresModulo5(T) :- 
    findall(Coord, coordenadaEsLibre(T, Coord), CoordenadasLibres),
    agrupar(CoordenadasLibres, G),
    forall(member(Grupo, G), (
        length(Grupo, L),
        L mod 5 =:= 0
    )).

poda(sinPoda, _).
poda(podaMod5, T) :- todosGruposLibresModulo5(T).

% 15,606,258 inferences, 0.891 CPU in 0.897 seconds (99% CPU, 17522816 Lips)
% N = 28.

% 320,257,103 inferences, 11.109 CPU in 11.188 seconds (99% CPU, 28827644 Lips)
% N = 200.

