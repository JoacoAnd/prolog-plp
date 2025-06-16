:- use_module(piezas).

% 1- sublista(+Descartar, +Tomar, +L, -R)
% Separamos la lista en DL y RyAlgoMas. DL seran los elementos a descartar, por lo que declaramos que esa sea
% su longitud. Luego separamos RyAlgoMas en R y otro termino que no nos interesa. R tendra longitud Tomar,
% que son la cantidad de elementos que nos interesa quedarnos.
sublista(Descartar, Tomar, L, R) :- append(DL, RyAlgoMas, L), length(DL, Descartar), append(R, _, RyAlgoMas), length(R, Tomar).

% 2- tablero(+K, -T)
% Declaramos que T tiene 5 filas porque asi se indica en la consigna. Luego usamos maplist para que cada elemento de T
% satisfaga el goal Fila: este sera verdadero cuando la longitud de la fila sea igual a K. Pasamos entonces Fila(K)
% para rellenar el tablero con K columnas.

fila(K, Fila) :- length(Fila, K).
tablero(K, T) :- K > 0, length(T, 5), maplist(fila(K), T).

% 3- tamaño(+M, -F, -C)
% Filas sera la longitud de la matriz y columnas la longitud de la primera fila 
% (Asumimos que todas las filas tienen igual longitud al ser una matriz). 

tamanio([M|MS], Filas, Columnas) :- length([M|MS], Filas), length(M, Columnas).

% 4- coordenadas(+T, -IJ)
% Usamos nth1 porque nos permite acceder a cada uno de los elementos de una lista segun su indice.
% El indice I en el tablero sera la Fila. Y con el indice J en cada Fila nos dara la coordenada.

coordenadas(T, (I,J)) :- nth1(I, T, Fila), nth1(J, Fila, _).

% 5- kPiezas(+K, -PS)

elegirPieza([P | Piezas], P, Piezas).
elegirPieza([_ | Piezas], P, Resto) :- elegirPieza(Piezas, P, Resto).

generarLista(0, _, []).
generarLista(K, Piezas, [P | PS]) :- K > 0, elegirPieza(Piezas, P, RestoPiezas), K1 is K - 1, generarLista(K1, RestoPiezas, PS).

kPiezas(K, PS) :- nombrePiezas(Piezas), generarLista(K, Piezas, PS).

% 6- seccionTablero(+T, +ALTO, +ANCHO, +IJ, ?ST)
% Usando el predicado sublista, recortarEnAnchura se queda con el ancho requerido a partir de la coordenada J
% de cada lista de la matriz.
recortarEnAnchura([], _, _, []).
recortarEnAnchura([A|SA], ANCHO, J, [S|ST]) :- J1 is J - 1, sublista(J1, ANCHO, A, S), recortarEnAnchura(SA, ANCHO, J, ST).

% Usamos el predicado sublista para quedarnos con un tablero con la altura requerida a partir de la coordenada I. Luego usamos
% recortarEnAnchura para, de ese tablero recortado, quedarnos con la anchura requerida a partir de la coordenada J. 
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

