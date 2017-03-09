InstallMethod( TensorProductOfRepresentations,
        "for two representations of (two) quivers",
        [ IsQuiverRepresentation, IsQuiverRepresentation, IsQuiverAlgebra, IsQuiverAlgebra, IsQuiverAlgebra ],
        function( R1, R2, A1, A2, A3 )
    
    local   K,  B1,  B2,  QB1,  QB2,  B3,  QB3,  verticesB3,  
            verticesA2,  partialtensor,  projections,  v,  tempdim,  
            i,  l,  j,  ij,  jl,  temprelations,  a,  start,  target,  
            istart,  targetl,  b1,  b2,  V,  arrowsB3,  maps,  
            dimension,  alpha,  source,  basis_i_j,  images_iprime_j,  
            beta,  iprime,  iB1,  iprimeB1,  basisR1_i_l,  
            basisR2_l_j,  b,  bprime,  matrix,  images_i_jprime,  
            jprime,  jB2,  jprimeB2;
    
    K := LeftActingDomain( A1 );
    B1 := AlgebraOfRepresentation( R1 );
    B2 := AlgebraOfRepresentation( R2 );
    if not IsTensorProductOfAlgebras( B1, A1, A2 ) or 
       not IsTensorProductOfAlgebras( B2, OppositeAlgebra( A2 ), A3 ) then
        Error( "Entered modules are not over the appropriate algebras,\n" );
    fi;
    
    QB1 := QuiverOfAlgebra( B1 );
    QB2 := QuiverOfAlgebra( B2 );
    B3 := TensorProductOfAlgebras( A1, A3 );
    QB3 := QuiverOfAlgebra( B3 );
    
    verticesB3 := Vertices( QB3 );
    verticesA2 := Vertices( QuiverOfAlgebra( A2 ) );
    
    partialtensor := function( r1, r2, v )
        local   i,  l,  temp,  j,  ij,  jl,  r1elem,  r2elem;
        
        i := ProjectPathFromProductQuiver( 1, v );  # vertex in A1
        l := ProjectPathFromProductQuiver( 2, v );  # vertex in A3
        temp := [ ];
        for j in verticesA2 do
            ij := PathInProductQuiver( QB1, [ i, j ] );
            jl := PathInProductQuiver( QB2, [ OppositePath( j ), l ] );
            r1elem := ElementVector( r1, ij );
            r2elem := ElementVector( r2, jl );
            if not IsEmptyVector( r1elem ) and not IsEmptyVector( r2elem ) then 
                Append( temp, KroneckerProduct( [ AsList( r1elem ) ], [ AsList( r2elem ) ] )[ 1 ] );
            fi;
        od;
        
        return temp;
    end;
 
    projections := [ ];
    for v in verticesB3 do
        tempdim := 0;
        i := ProjectPathFromProductQuiver( 1, v );  # vertex in A1
        l := ProjectPathFromProductQuiver( 2, v );  # vertex in A3
        for j in verticesA2 do
            ij := PathInProductQuiver( QB1, [ i, j ] );
            jl := PathInProductQuiver( QB2, [ OppositePath( j ), l ] );
            tempdim := tempdim + VertexDimension( R1, ij ) * VertexDimension( R2, jl );
        od;
        temprelations := [ ];
        for a in Arrows( QuiverOfAlgebra( A2 ) ) do
            start := Source( a ); 
            target := Target( a );
            istart := PathInProductQuiver( QB1, [ i, start ] );
            targetl := PathInProductQuiver( QB2, [ OppositePath( target ), l ] );
            
            for b1 in BasisVectorsByVertex( Basis( R1 ) )[ VertexNumber( istart ) ] do
                for b2 in BasisVectorsByVertex( Basis( R2 ) )[ VertexNumber( targetl ) ] do
                    Add( temprelations, partialtensor( QuiverAlgebraAction( b1, ElementaryTensor( One( A1 ), One( A2 ) * a, B1 ) ), b2, v) - 
                         partialtensor( b1, QuiverAlgebraAction( b2, ElementaryTensor( One( OppositeAlgebra( A2 ) ) * OppositePath( a ), One( A3), B2) ), v ) );
                od;
            od;
        od;
        V := K^tempdim;
        Add( projections, NaturalHomomorphismBySubspace( V, Subspace( V, temprelations ) ) );
    od;
    
    arrowsB3 := [ ];
    maps := [ ];
    dimension := List( projections, p -> Dimension( Range( p ) ) );
    for a in Arrows( QuiverOfAlgebra( A1 ) ) do
        for j in Vertices( QuiverOfAlgebra( A3 ) ) do
            alpha := PathInProductQuiver( QB3, [ a, j ] );
            source := Source( alpha );
            target := Target( alpha );
            if dimension[ VertexNumber( source ) ] = 0 or dimension[ VertexNumber( target ) ] = 0 then
                continue;
            fi;
            Add( arrowsB3, alpha );
            basis_i_j := [ ];
            images_iprime_j := [ ];
            for l in Vertices( QuiverOfAlgebra( A2 ) ) do
                beta := PathInProductQuiver( QB1, [ a, l ] );
                i := Source( a );
                iprime := Target( a );
                iB1 := PathInProductQuiver( QB1, [ i, l ] );
                iprimeB1 := PathInProductQuiver( QB1, [ iprime, l ] );
                basisR1_i_l := BasisVectorsByVertex( Basis( R1 ) )[ VertexNumber( iB1 ) ];
                basisR2_l_j := BasisVectorsByVertex( Basis( R2 ) )[ VertexNumber( PathInProductQuiver( QB2, [ OppositePath( l ), j ] ) ) ];
                for b in basisR1_i_l do
                    for bprime in basisR2_l_j do
                        Add( basis_i_j, partialtensor( b, bprime, PathInProductQuiver( QB3, [ i, j ] ) ) );  
                        Add( images_iprime_j, partialtensor( PathAction( b, beta ), bprime, PathInProductQuiver( QB3, [ iprime, j ] ) ) ); 
                    od;
                od;
            od;
            matrix := [ ];
            for b in BasisVectors( Basis( Range( projections[ VertexNumber( source ) ] ) ) ) do
                bprime := PreImagesRepresentative( projections[ VertexNumber( source ) ], b ); 
                Add( matrix, ImageElm( projections[ VertexNumber( target ) ], bprime * basis_i_j^( -1 ) * images_iprime_j ) );
            od;
            Add( maps, matrix );
        od;
    od;
    
    for i in Vertices( QuiverOfAlgebra( A1 ) ) do
        for a in Arrows( QuiverOfAlgebra( A3 ) ) do
            alpha := PathInProductQuiver( QB3, [ i, a ] );
            source := Source( alpha );
            target := Target( alpha );
            if dimension[ VertexNumber( source ) ] = 0 or dimension[ VertexNumber( target ) ] = 0 then
                continue;
            fi;
            Add( arrowsB3, alpha );
            basis_i_j := [ ];
            images_i_jprime := [ ];
            for l in Vertices( QuiverOfAlgebra( A2 ) ) do
                beta := PathInProductQuiver( QB2, [ OppositePath( l ), a ] );
                j := Source( a );
                jprime := Target( a );
                jB2 := PathInProductQuiver( QB2, [ OppositePath( l ), j ] );
                jprimeB2 := PathInProductQuiver( QB2, [ OppositePath( l ), jprime ] );
                basisR1_i_l := BasisVectorsByVertex( Basis( R1 ) )[ VertexNumber( PathInProductQuiver( QB1, [ i, l ] ) ) ];
                basisR2_l_j := BasisVectorsByVertex( Basis( R2 ) )[ VertexNumber( jB2 ) ];
                for b in basisR1_i_l do
                    for bprime in basisR2_l_j do
                        Add( basis_i_j, partialtensor( b, bprime, PathInProductQuiver( QB3, [ i, j ] ) ) );  
                        Add( images_i_jprime, partialtensor( b, PathAction( bprime, beta ), PathInProductQuiver( QB3, [ i, jprime ] ) ) ); 
                    od;
                od;
            od;
            matrix := [ ];
            for b in BasisVectors( Basis( Range( projections[ VertexNumber( source ) ] ) ) ) do
                bprime := PreImagesRepresentative( projections[ VertexNumber( source ) ], b ); 
                Add( matrix, ImageElm( projections[ VertexNumber( target ) ], bprime * basis_i_j^( -1 ) * images_i_jprime ) );
            od;
            Add( maps, matrix );
        od;
    od;
    maps := List( maps, m -> MatrixByRows( K, m ) );
    
    return QuiverRepresentationByRightMatrices( B3, dimension, arrowsB3, maps );
end
  );