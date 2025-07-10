:- use_module(piezas).

% 1- sublista(+Descartar, +Tomar, +L, -R)
% Separamos la lista en DL y RyAlgoMas. DL serán los elementos a descartar, por lo que declaramos que esa sea
% su longitud. Luego separamos RyAlgoMas en R y otro término que no nos interesa. R tendrá longitud Tomar,
% que son la cantidad de elementos que nos interesa quedarnos.
sublista(Descartar, Tomar, L, R) :- length(DL, Descartar), length(R, Tomar), append(DL, RyAlgoMas, L),  append(R, _, RyAlgoMas). 
% 12- evaluamos la reversibilidad de sublista
% Como append es reversible, y length es reversible, y sublista es una combinación de append y length, sublista es reversible.
% 1) al evaluar append(DL, RyAlgoMas, L) obtenemos DL y RyAlgoMas.
% 2) al evaluar length(DL, Descartar), con DL ya instanciado, podemos obtener Descartar.
% 3) al evaluar append(R, _, RyAlgoMas) con RyAlgoMas ya instanciado, obtenemos R.
% 4) al evaluar length(R, Tomar), con R ya instanciado, podemos obtener Tomar.
%
% Aquí algunos ejemplos de cómo se evalúa sublista:
% a) Modo sublista(-D, +T, +L, -R):
%    ?- sublista(D, 2, [a,b,c,d], R).
%    D = 0, R = [a,b] ;
%    D = 1, R = [b,c] ;
%    D = 2, R = [c,d] ;
%    false.
% b) Modo sublista(+D, +T, +L, -R):
%    ?- sublista(1, 2, [a,b,c,d], R).
%    R = [b,c].
% c) Modo sublista(-D, +T, +L, +R):
%    ?- sublista(D, 2, [a,b,c,d], [c,d]).
%    D = 2.

% 2- tablero(+K, -T)
% Declaramos que T tiene 5 filas porque así se indica en la consigna. Luego usamos maplist para que cada elemento de T
% satisfaga el goal Fila: este será verdadero cuando la longitud de la fila sea igual a K. Pasamos entonces Fila(K)
% para rellenar el tablero con K columnas.

fila(K, Fila) :- length(Fila, K).
tablero(K, T) :- K > 0, length(T, 5), maplist(fila(K), T).

% 3- tamaño(+M, -F, -C)
% Filas será la longitud de la matriz y columnas la longitud de la primera fila 
% (Asumimos que todas las filas tienen igual longitud al ser una matriz). 

tamanio([M|MS], Filas, Columnas) :- length([M|MS], Filas), length(M, Columnas).

% 4- coordenadas(+T, -IJ)
% Usamos nth1 porque nos permite acceder a cada uno de los elementos de una lista según su índice.
% El índice I en el tablero será la Fila. Y con el índice J en cada Fila nos dará la coordenada.

coordenadas(T, (I,J)) :- nth1(I, T, Fila), nth1(J, Fila, _).

% 5- kPiezas(+K, -PS)
% elegirPieza(+Piezas, -PSeleccionada, -Resto)
% Seleccionamos una pieza de una lista de piezas y devolvemos la pieza y la lista sin ella.
elegirPieza([P | Piezas], P, Piezas).
elegirPieza([_ | Piezas], P, Resto) :- elegirPieza(Piezas, P, Resto).

generarLista(0, _, []).
generarLista(K, Piezas, [P | PS]) :- K > 0, elegirPieza(Piezas, P, RestoPiezas), K1 is K - 1, generarLista(K1, RestoPiezas, PS).

kPiezas(K, PS) :- nombrePiezas(Piezas), generarLista(K, Piezas, PS).

% 6- seccionTablero(+T, +ALTO, +ANCHO, +IJ, ?ST)

% Usamos el predicado sublista para quedarnos con un tablero con la altura requerida a partir de la coordenada I. Luego usamos
% recortarEnAnchura para, de ese tablero recortado, quedarnos con la anchura requerida a partir de la coordenada J. 
seccionTablero(T, ALTO, ANCHO, (I, J), ST) :- I1 is I - 1, sublista(I1, ALTO, T, STAltura), J1 is J - 1, maplist(sublista(J1, ANCHO), STAltura, ST).

% 7- ubicarPieza(+Tablero, +Identificador)

ubicarPieza(Tablero, Identificador) :- 
    pieza(Identificador, Pieza), 
    tamanio(Pieza, ALTO, ANCHO), 
    coordenadas(Tablero, IJ),
    seccionTablero(Tablero, ALTO, ANCHO, IJ, Pieza).

% 8- ubicarPiezas(+Tablero, +Poda, +Identificadores)

% ubicarPiezaConPoda(+Tablero, +Poda, +Identificadores)
% Ubica la pieza y verifica la poda.

ubicarPiezaConPoda(Tablero, Poda, Identificadores) :-
    ubicarPieza(Tablero, Identificadores),
    poda(Poda, Tablero).

ubicarPiezas(Tablero, Poda, Identificadores) :-
    maplist(ubicarPiezaConPoda(Tablero, Poda), Identificadores).

% 9- llenarTablero(+Poda, +Columnas, -Tablero)

llenarTablero(Poda, Columnas, Tablero) :- tablero(Columnas, Tablero), kPiezas(Columnas, Piezas), ubicarPiezas(Tablero, Poda, Piezas).

% 10- Medición
cantSoluciones(Poda, Columnas, N) :-
findall(T, llenarTablero(Poda, Columnas, T), TS),
length(TS, N).

% 36,023,793 inferences, 1.812 CPU in 1.870 seconds (97% CPU, 19875196 Lips)
% N = 28.

% 1,426,464,108 inferences, 69.531 CPU in 70.363 seconds (99% CPU, 20515439 Lips)
% N = 200.

% 11- Optimización

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

% 10,329,020 inferences, 0.891 CPU in 0.889 seconds (100% CPU, 11597496 Lips)
% N = 28.

% 218,818,075 inferences, 8.813 CPU in 8.896 seconds (99% CPU, 24830420 Lips)
% N = 200.

