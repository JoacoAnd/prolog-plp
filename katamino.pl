:- use_module(piezas).

% 1- sublista(+Descartar, +Tomar, +L, -R)
% Separamos la lista en DL y RyAlgoMas. DL serán los elementos a descartar, por lo que declaramos que esa sea
% su longitud. Luego separamos RyAlgoMas en R y otro término que no nos interesa. R tendrá longitud Tomar,
% que son la cantidad de elementos que nos interesa quedarnos.
sublista(Descartar, Tomar, L, R) :- length(DL, Descartar), length(R, Tomar), append(DL, RyAlgoMas, L), append(R, _, RyAlgoMas). 

% 12 - Reversibilidad
% No es reversible ya que el predicado se cuelga.
% - Cuando ejecutamos length(DL, Descartar), al no estar instanciado Descartar, DL se instanciará con todas las listas genéricas 
%   de tamaño N tal que N >= 0, y también se instanciará en cada caso Descartar como N. 
% - Luego se verifica length(R, Tomar). En caso de que no se cumpla, se pasa a la siguiente instanciación de DL y Descartar.
%   Como R y Tomar están instanciados, si esta verificación falla lo hará para cualquier instanciación de DL y Descartar. 
%   Prolog intentará encontrar alguna que sí lo cumpla (lo cual nunca ocurrirá), por lo que se cuelga.
% - Si se cumple el caso anterior, se verifica ahora append(DL, RyAlgoMas, L). Acá pueden ocurrir dos casos:
%   1. Si Descartar es mayor al tamaño de L, entonces la consulta devuelve false, ya que no existe ninguna lista tal que, 
%      al concatenarla con DL, resulte L. En ese caso, continuará con las consultas infinitas ya explicadas, y el programa se cuelga.
%   2. Si Descartar es menor o igual al tamaño de L, entonces RyAlgoMas se instancia como un sufijo de L sin los primeros Descartar elementos.
% - Por último, se verifica append(R, _, RyAlgoMas), es decir, que R sea prefijo de RyAlgoMas. Esto es verdadero en una cantidad 
%   finita de instanciaciones de DL, que ocurren cuando simultáneamente Descartar se instancia como una solución correcta y se devuelve. 
%   Esta cantidad de soluciones será igual a las veces que R ocurre en L. Sin embargo, el predicado sigue buscando soluciones 
%   (que serán siempre incorrectas) hasta que se cuelga.

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
generarLista(K, Piezas, [P | PS]) :- K > 0, length(Piezas, LP), LP >= K, elegirPieza(Piezas, P, RestoPiezas), K1 is K - 1, generarLista(K1, RestoPiezas, PS).

kPiezas(K, PS) :- nombrePiezas(Piezas), generarLista(K, Piezas, PS).

% 6- seccionTablero(+T, +ALTO, +ANCHO, +IJ, ?ST)

% Usamos el predicado sublista para quedarnos con un tablero con la altura requerida a partir de la coordenada I. Luego usamos
% recortarEnAnchura para, de ese tablero recortado, quedarnos con la anchura requerida a partir de la coordenada J. 
seccionTablero(T, ALTO, ANCHO, (I, J), ST) :- I1 is I - 1, sublista(I1, ALTO, T, STAltura), J1 is J - 1, maplist(sublista(J1, ANCHO), STAltura, ST).

% 7- ubicarPieza(+Tablero, +Identificador)
% Dado un tablero y el identificador de una pieza, busca ubicar la pieza en el tablero instanciando ST como Pieza en seccionTablero

ubicarPieza(Tablero, Identificador) :- 
    pieza(Identificador, Pieza), 
    tamanio(Pieza, ALTO, ANCHO), 
    coordenadas(Tablero, IJ),
    seccionTablero(Tablero, ALTO, ANCHO, IJ, Pieza).

% 8- ubicarPiezas(+Tablero, +Poda, +Identificadores)

% ubicarPiezaConPoda(+Tablero, +Poda, +Identificadores)
% Ubica la pieza y verifica la poda

ubicarPiezaConPoda(Tablero, Poda, Identificadores) :-
    ubicarPieza(Tablero, Identificadores),
    poda(Poda, Tablero).

ubicarPiezas(Tablero, Poda, Identificadores) :-
    maplist(ubicarPiezaConPoda(Tablero, Poda), Identificadores).

% 9- llenarTablero(+Poda, +Columnas, -Tablero)
% Ubica las k Piezas en el tablero de k Columnas

llenarTablero(Poda, Columnas, Tablero) :- tablero(Columnas, Tablero), kPiezas(Columnas, Piezas), ubicarPiezas(Tablero, Poda, Piezas).

% 10- Medición
cantSoluciones(Poda, Columnas, N) :-
findall(T, llenarTablero(Poda, Columnas, T), TS),
length(TS, N).

% 21,190,209 inferences, 0.812 CPU in 0.853 seconds (95% CPU, 26080257 Lips)
% N = 28.

% 795,691,124 inferences, 28.859 CPU in 29.216 seconds (99% CPU, 27571322 Lips)
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

% 10,403,821 inferences, 0.734 CPU in 0.741 seconds (99% CPU, 14166905 Lips)
% N = 28.

% 218,861,156 inferences, 8.297 CPU in 8.463 seconds (98% CPU, 26378746 Lips)
% N = 200.

