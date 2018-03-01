function xyz = dodecahedron
% dodecahedron return dodecahedron vertices

% golden ratio
fi = (1+sqrt(5))/2;
% vertices are at {(0,±1/fi,±fi), (±1/fi,±fi,0), (±fi,0,±1/fi), (±1,±1,±1)}
xyz = [
    0,      1/fi,   fi;
    0,     -1/fi,   fi;
    0,      1/fi,  -fi;
    0,     -1/fi,  -fi;

    1/fi,   fi,     0;
   -1/fi,   fi,     0;
    1/fi,  -fi,     0;
   -1/fi,  -fi,     0;

    fi,     0,      1/fi;
   -fi,     0,      1/fi;
    fi,     0,     -1/fi;
   -fi,     0,     -1/fi;

    1,      1,      1;
   -1,      1,      1;
    1,     -1,      1;
   -1,     -1,      1;
    1,      1,     -1;
   -1,      1,     -1;
    1,     -1,     -1;
   -1,     -1,     -1;
];
