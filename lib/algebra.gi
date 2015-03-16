DeclareRepresentation( "IsPathAlgebraElementRep", IsComponentObjectRep,
                       [ "algebra", "paths", "coefficients" ] );

InstallGlobalFunction( PathAlgebraElement,
function( algebra, coefficients, paths )
  local Cs, Ps, Cs_, Ps_, p, i, nonzeroIndices;
  Cs_ := ShallowCopy( coefficients );
  Ps_ := ShallowCopy( paths );
  SortParallel( Ps_, Cs_ );
  p := fail;
  Cs := [];
  Ps := [];
  for i in [ 1 .. Length( Ps_ ) ] do
    if Ps_[ i ] = p then
      Cs[ 1 ] := Cs[ 1 ] + Cs_[ i ];
    else
      Add( Ps, Ps_[ i ], 1 );
      Add( Cs, Cs_[ i ], 1 );
    fi;
    p := Ps_[ i ];
  od;
  nonzeroIndices := PositionsProperty( Cs, c -> not IsZero( c ) );
  Cs := Cs{ nonzeroIndices };
  Ps := Ps{ nonzeroIndices };
  return PathAlgebraElementNC( algebra, Cs, Ps );
end );

InstallGlobalFunction( PathAlgebraElementNC,
function( algebra, coefficients, paths )
  return Objectify( NewType( ElementsFamily( FamilyObj( algebra ) ),
                             IsPathAlgebraElement and IsPathAlgebraElementRep ),
                    rec( algebra := algebra,
                         paths := paths,
                         coefficients := coefficients ) );
end );

InstallMethod( PathAsAlgebraElement, "for path algebra and path",
               [ IsPathAlgebra, IsPath ],
function( A, p )
  return PathAlgebraElementNC( A, [ One( LeftActingDomain( A ) ) ], [ p ] );
end );

InstallMethod( PrintObj, "for element of path algebra",
               [ IsPathAlgebraElement ],
function( e )
  local Cs, Ps, i;
  Cs := Coefficients( e );
  Ps := Paths( e );
  if Length( Ps ) = 0 then
    Print( "0" );
    return;
  fi;
  for i in [ 1 .. Length( Cs ) ] do
    if i > 1 then Print( " + " ); fi;
    Print( Cs[ i ], "*");
    View( Ps[ i ] );
  od;
end );

InstallMethod( AlgebraOfElement, "for element of path algebra",
               [ IsPathAlgebraElement and IsPathAlgebraElementRep ],
function( e )
  return e!.algebra;
end );

InstallMethod( Coefficients, "for element of path algebra",
               [ IsPathAlgebraElement and IsPathAlgebraElementRep ],
function( e )
  return e!.coefficients;
end );

InstallMethod( Paths, "for element of path algebra",
               [ IsPathAlgebraElement and IsPathAlgebraElementRep ],
function( e )
  return e!.paths;
end );

InstallMethod( Zero, "for element of quiver algebra",
               [ IsQuiverAlgebraElement ],
function( e )
  return Zero( AlgebraOfElement( e ) );
end );

InstallMethod( One, "for element of quiver algebra",
               [ IsQuiverAlgebraElement ],
function( e )
  return One( AlgebraOfElement( e ) );
end );

InstallMethod( AdditiveInverse, "for element of path algebra",
               [ IsPathAlgebraElement ],
function( e )
  return PathAlgebraElement
         ( AlgebraOfElement( e ),
           List( Coefficients( e ), AdditiveInverse ),
           Paths( e ) );
end );

InstallMethod( \=, "for elements of path algebra", IsIdenticalObj,
               [ IsPathAlgebraElement, IsPathAlgebraElement ],
function( e1, e2 )
  return Paths( e1 ) = Paths( e2 )
         and Coefficients( e1 ) = Coefficients( e2 );
end );

InstallMethod( \+, "for elements of path algebra", IsIdenticalObj,
               [ IsPathAlgebraElement, IsPathAlgebraElement ],
function( e1, e2 )
  local Cs1, Ps1, Cs2, Ps2, Cs, Ps, i, j, c1, c2, p1, p2;
  Cs1 := Coefficients( e1 ); Ps1 := Paths( e1 );
  Cs2 := Coefficients( e2 ); Ps2 := Paths( e2 );
  Cs := []; Ps := [];
  i := 1; j := 1;
  while i <= Length( Cs1 ) and j <= Length( Cs2 ) do
    c1 := Cs1[ i ]; c2 := Cs2[ j ];
    p1 := Ps1[ i ]; p2 := Ps2[ j ];
    if p1 = p2 then
      if not IsZero( c1 + c2 ) then
        Add( Cs, c1 + c2 ); Add( Ps, p1 );
      fi;
      i := i + 1;
      j := j + 1;
    elif p1 < p2 then
      Add( Cs, c1 ); Add( Ps, p1 );
      i := i + 1;
    else
      Add( Cs, c2 ); Add( Ps, p2 );
      j := j + 1;
    fi;
  od;
  while i <= Length( Cs1 ) do
    Add( Cs, Cs1[ i ] ); Add( Ps, Ps1[ i ] );
    i := i + 1;
  od;
  while j <= Length( Cs2 ) do
    Add( Cs, Cs2[ j ] ); Add( Ps, Ps2[ j ] );
    j := j + 1;
  od;
  return PathAlgebraElement( AlgebraOfElement( e1 ), Cs, Ps );
end );

InstallMethod( \*, "for elements of path algebra", IsIdenticalObj,
               [ IsPathAlgebraElement, IsPathAlgebraElement ],
function( e1, e2 )
  local Cs, Ps, nonzeros;
  Cs := List( Cartesian( Coefficients( e1 ), Coefficients( e2 ) ), c -> c[ 1 ] * c[ 2 ] );
  Ps := List( Cartesian( Paths( e1 ), Paths( e2 ) ), p -> p[ 1 ] * p[ 2 ] );
  nonzeros := PositionsProperty( Ps, p -> p <> fail );
  return PathAlgebraElement
         ( AlgebraOfElement( e1 ),
           Cs{ nonzeros },
           Ps{ nonzeros } );
end );

InstallMethod( \*, "for path and element of quiver algebra",
               [ IsPath, IsQuiverAlgebraElement ],
function( p, e )
  return PathAsAlgebraElement( AlgebraOfElement( e ), p ) * e;
end );

InstallMethod( \*, "for element of quiver algebra and path",
               [ IsQuiverAlgebraElement, IsPath ],
function( e, p )
  return e * PathAsAlgebraElement( AlgebraOfElement( e ), p );
end );

InstallMethod( \*, "for multiplicative element and element of path algebra",
               [ IsMultiplicativeElement, IsPathAlgebraElement ],
function( c, e )
  if c in LeftActingDomain( AlgebraOfElement( e ) ) then
    return PathAlgebraElement
           ( AlgebraOfElement( e ),
             c * Coefficients( e ),
             Paths( e ) );
  else
    TryNextMethod();
  fi;
end );

InstallMethod( \*, "for element of quiver algebra and multiplicative element",
               [ IsQuiverAlgebraElement, IsMultiplicativeElement ],
function( e, c )
  if c in LeftActingDomain( AlgebraOfElement( e ) ) then
    return c * e;
  else
    TryNextMethod();
  fi;
end );

InstallMethod( LeadingPath, "for element of path algebra",
               [ IsPathAlgebraElement ],
function( e )
  return Paths( e )[ 1 ];
end );

InstallMethod( LeadingCoefficient, "for element of path algebra",
               [ IsPathAlgebraElement ],
function( e )
  return Coefficients( e )[ 1 ];
end );

InstallMethod( LeadingTerm, "for element of path algebra",
               [ IsPathAlgebraElement ],
function( e )
  local Cs, Ps, len;
  Cs := Coefficients( e );
  Ps := Paths( e );
  return PathAlgebraElementNC( AlgebraOfElement( e ),
                               [ Cs[ 1 ] ], [ Ps[ 1 ] ] );
end );

InstallMethod( NonLeadingTerms, "for element of path algebra",
               [ IsPathAlgebraElement ],
function( e )
  local Cs, Ps, len;
  Cs := Coefficients( e );
  Ps := Paths( e );
  len := Length( Ps );
  return PathAlgebraElementNC( AlgebraOfElement( e ),
                               Cs{ [ 2 .. len ] },
                               Ps{ [ 2 .. len ] } );
end );

InstallMethod( DivideByList, "for element of path algebra and list",
               [ IsPathAlgebraElement, IsList ],
function( e, divisors )
  local A, remainder, Ps, Cs, d_lp, d_lc, n_div, quotients,
        divisionOccured, lp, lc, i, q, left_q, right_q;
  A := AlgebraOfElement( e );
  remainder := Zero( e );
  Ps := Paths( e );
  Cs := Coefficients( e );
  d_lp := List( divisors, LeadingPath );
  d_lc := List( divisors, LeadingCoefficient );
  n_div := Length( divisors );
  quotients := List( [ 1 .. n_div ], i -> [] );
  while not IsZero( e ) do
    #Print( "loop\n" );
    #Print( "e = ", e, "\n" );
    #Print( "r = ", remainder, "\n" );
    #if InputFromUser( "continue? " ) = 0 then break; fi;
    divisionOccured := false;
    for i in [ 1 .. n_div ] do
      lp := LeadingPath( e );
      lc := LeadingCoefficient( e );
      q := lp / d_lp[ i ];
      if q = fail then
        continue;
      fi;
      left_q := ( lc / d_lc[ i ] ) * PathAsAlgebraElement( A, q[ 1 ] );
      right_q := PathAsAlgebraElement( A, q[ 2 ] );
      e := e - left_q * divisors[ i ] * right_q;
      Add( quotients[ i ], [ left_q, right_q ] );
      divisionOccured := true;
      if IsZero( e ) then
        break;
      fi;
      #Print( "i = ", i, "\n" );
      #Print( "left_q = ", left_q, "; right_q = ", right_q, "\n" );
      #Print( "e = ", e, "\n" );
    od;
    if not divisionOccured then
      remainder := remainder + LeadingTerm( e );
      e := NonLeadingTerms( e );
    fi;
  od;
  return [ quotients, remainder ];
end );

InstallMethod( Reduce, "for element of path algebra and list",
               [ IsPathAlgebraElement, IsList ],
function( e, divisors )
  return DivideByList( e, divisors )[ 2 ];
end );

InstallMethod( OverlapRelation,
               "for elements of path algebra",
               [ IsPathAlgebraElement, IsPathAlgebraElement,
                 IsPath, IsPath ],
function( f, g, b, c )
  local A, fc, bg;
  # LeadingPath( f ) * c = b * LeadingPath( g )
  A := AlgebraOfElement( f );
  fc := f * PathAsAlgebraElement( A, c );
  bg := PathAsAlgebraElement( A, b ) * g;
  return ( 1 / LeadingCoefficient( f ) ) * fc - ( 1 / LeadingCoefficient( g ) ) * bg;
end );

InstallMethod( OverlapRelations,
               "for elements of path algebra",
               [ IsPathAlgebraElement, IsPathAlgebraElement ],
function( f, g )
  local lp_f, lp_g, pathOverlaps, overlapRelations, o;
  lp_f := LeadingPath( f );
  lp_g := LeadingPath( g );
  pathOverlaps := PathOverlaps( lp_f, lp_g );
  overlapRelations := [];
  for o in pathOverlaps do
    Add( overlapRelations, OverlapRelation( f, g, o[ 1 ], o[ 2 ] ) );
  od;
  return overlapRelations;
end );

InstallMethod( TipReduce, "for collection",
               [ IsCollection ],
function( relations )
  local iteration, limit, len, didReductions, i, j, q, lc_i, lc_j, r;
  len := Length( relations );
  relations := ShallowCopy( relations );
  iteration := 0;
  limit := 0;
  #Print( "TipReduce\n" );
  while true do
    iteration := iteration + 1;
    if limit > 0 and iteration > limit then
      Error( "TipReduce iteration limit reached" );
    fi;
    #Print( "TipReduce iteration ", iteration, "\n" );
    #Print( "relations:\n" ); for i in [ 1 .. len ] do Print( "  ", relations[ i ], "\n" ); od;
    didReductions := false;
    for i in [ 1 .. len ] do
      for j in [ 1 .. len ] do
        #Print( "TipReduce i = ", i, ", j = ", j, "\n" );
        if i = j or IsZero( relations[ i ] ) or IsZero( relations[ j ] ) then
          continue;
        fi;
        q := LeadingPath( relations[ i ] ) / LeadingPath( relations[ j ] );
        if q <> fail then
          lc_i := LeadingCoefficient( relations[ i ] );
          lc_j := LeadingCoefficient( relations[ j ] );
          r := relations[ i ] - ( lc_i / lc_j ) * ( q[ 1 ] * relations[ j ] * q[ 2 ] );
          relations[ i ] := r;
          #if IsZero( r ) then Print( "!!!!!! r = 0 !!!!!!\n" ); fi;
          didReductions := true;
        fi;
      od;
    od;
    if not didReductions then
      break;
    fi;
  od;
  return Filtered( relations, e -> not IsZero( e ) );
end );

InstallMethod( ComputeGroebnerBasis, "for list",
               [ IsList ],
function( relations )
  local basis, newRelations, basisLen, i, j, overlapRelations, r,
        remainder, qr,
        limit, iteration;
  basis := TipReduce( relations );
  iteration := 0;
  #limit := 100;
  #for iteration in [ 1 .. limit ] do
  while true do
    iteration := iteration + 1;
    #Print( "ComputeGroebnerBasis iteration ", iteration, "\n" );
    #Print( "basis: ", basis, "\n" );
    newRelations := [];
    basisLen := Length( basis );
    for i in [ 1 .. basisLen ] do
      for j in [ 1 .. basisLen ] do
        overlapRelations := OverlapRelations( basis[ i ], basis[ j ] );
        #Print( "Overlaps (", i, ", ", j, "): ", overlapRelations, "\n" );
        for r in overlapRelations do
          qr := DivideByList( r, basis );
          remainder := qr[ 2 ];
          if not IsZero( remainder ) then
            Add( newRelations, remainder );
          fi;
        od;
      od;
    od;
    if Length( newRelations ) > 0 then
      Append( basis, newRelations );
      basis := TipReduce( basis );
    else
      break;
    fi;
  od;
  return basis;
end );


DeclareRepresentation( "IsPathAlgebraRep", IsComponentObjectRep,
                       [ "field", "quiver" ] );

InstallOtherMethod( PathAlgebra, "for field and quiver",
                    [ IsField, IsQuiver ],
function( k, Q )
  local elementFam, algebraFam, algebraType, A;
  # TODO: algebra should have its own elements family,
  # but this should rely only on ( k, Q ).
  # If we make a new algebra with same arguments, we
  # should get the same family.
  elementFam := ElementsFamily( FamilyObj( Q ) );
  algebraFam := CollectionsFamily( elementFam );
  algebraType := NewType( algebraFam, IsPathAlgebra and IsPathAlgebraRep );
  A := Objectify( algebraType,
                  rec( field := k,
                       quiver := Q ) );
  return A;
end );

InstallMethod( PrintObj, "for path algebra",
               [ IsPathAlgebra ],
function( A )
  Print( "<path algebra ", LeftActingDomain( A ), " * ",
         QuiverOfAlgebra( A ), ">" );
end );

InstallMethod( ViewObj, "for path algebra",
               [ IsPathAlgebra ],
function( A )
  Print( LeftActingDomain( A ), " * ", Name( QuiverOfAlgebra( A ) ) );
end );

InstallMethod( QuiverOfAlgebra, "for path algebra",
               [ IsPathAlgebra and IsPathAlgebraRep ],
function( A )
  return A!.quiver;
end );

InstallMethod( LeftActingDomain, "for path algebra",
               [ IsPathAlgebra and IsPathAlgebraRep ],
function( A )
  return A!.field;
end );

InstallMethod( GeneratorsOfAlgebra, "for quiver algebra",
               [ IsQuiverAlgebra ],
function( A )
  return PrimitivePaths( QuiverOfAlgebra( A ) );
end );

InstallMethod( RelationsOfAlgebra, "for path algebra",
               [ IsPathAlgebra ],
function( A )
  return [];
end );

InstallMethod( PathAlgebra, "for path algebra",
               [ IsPathAlgebra ],
function( A )
  return A;
end );

# TODO: InstallMethod( Basis, "for path algebra", [ IsPathAlgebra ]

InstallMethod( \in, "for element of path algebra and path algebra",
               [ IsPathAlgebraElement, IsPathAlgebra ],
function( e, A )
  return A = AlgebraOfElement( e );
end );

InstallMethod( Zero, "for path algebra",
               [ IsPathAlgebra ],
function( A )
  return PathAlgebraElement( A, [], [] );
end );

InstallMethod( One, "for path algebra",
               [ IsPathAlgebra ],
function( A )
  local vertices;
  vertices := Vertices( QuiverOfAlgebra( A ) );
  return PathAlgebraElement( A,
                             List( vertices, v -> One( LeftActingDomain( A ) ) ),
                             vertices );
end );

InstallMethod( \., "for quiver algebra and positive integer",
	       [ IsQuiverAlgebra, IsPosInt ],
function( A, string_as_int )
  return PathAsAlgebraElement( A, \.( QuiverOfAlgebra( A ), string_as_int ) );
end );

InstallMethod( \[\], "for quiver algebra and int",
	       [ IsQuiverAlgebra, IsInt ],
function( A, i )
  return PathAsAlgebraElement( A, QuiverOfAlgebra( A )[ i ] );
end );


DeclareRepresentation( "IsPathIdealRep", IsComponentObjectRep,
                       [ "algebra", "generators", "groebnerBasis" ] );

InstallMethod( TwoSidedIdealByGenerators, "for path algebra and collection",
               [ IsPathAlgebra, IsCollection ],
function( A, generators )
  local groebnerBasis;
  groebnerBasis := ComputeGroebnerBasis( generators );
  return Objectify( NewType( FamilyObj( A ),
                             IsPathIdeal and IsPathIdealRep ),
                    rec( algebra := A,
                         generators := generators,
                         groebnerBasis := groebnerBasis ) );
end );

InstallMethod( PrintObj, "for path ideal",
               [ IsPathIdeal ],
function( I )
  Print( "<Ideal generated by ", GeneratorsOfIdeal( I ), ">" );
end );

InstallMethod( ViewObj, "for path ideal",
               [ IsPathIdeal ],
function( I )
  Print( "<Ideal generated by ", GeneratorsOfIdeal( I ), ">" );
end );

InstallMethod( GroebnerBasis, "for path ideal",
               [ IsPathIdeal and IsPathIdealRep ],
function( I )
  return I!.groebnerBasis;
end );

InstallMethod( GeneratorsOfIdeal, "for path ideal",
               [ IsPathIdeal and IsPathIdealRep ],
function( I )
  return I!.generators;
end );

InstallMethod( LeftActingRingOfIdeal, "for path ideal",
               [ IsPathIdeal and IsPathIdealRep ],
function( I )
  return I!.algebra;
end );

InstallMethod( RightActingRingOfIdeal, "for path ideal",
               [ IsPathIdeal and IsPathIdealRep ],
function( I )
  return I!.algebra;
end );

InstallMethod( IsIdeal, "for ring and path ideal",
               [ IsRing, IsPathIdeal ],
function( R, I )
  return R = LeftActingRingOfIdeal( I );
end );

InstallMethod( \in, "for element of path algebra and path ideal",
               [ IsPathAlgebraElement, IsPathIdeal ],
function( e, I )
  return e in LeftActingRingOfIdeal( I )
         and IsZero( Reduce( e, GroebnerBasis( I ) ) );
end );


DeclareRepresentation( "IsQuotientOfPathAlgebraRep", IsComponentObjectRep,
                       [ "pathAlgebra", "relations", "ideal" ] );

InstallMethod( QuotientOfPathAlgebra, "for path algebra and collection",
               [ IsPathAlgebra, IsCollection ],
function( A, relations )
  local I;
  I := TwoSidedIdealByGenerators( A, relations );
  return QuotientOfPathAlgebra( A, I );
end );

InstallMethod( QuotientOfPathAlgebra, "for path algebra and path ideal",
               [ IsPathAlgebra, IsPathIdeal ],
function( A, I )
  return Objectify( NewType( FamilyObj( A ),
                             IsQuotientOfPathAlgebra and IsQuotientOfPathAlgebraRep ),
                    rec( pathAlgebra := A,
                         relations := GeneratorsOfIdeal( I ),
                         ideal := I ) );
end );  

InstallMethod( PrintObj, "for quotient of path algebra",
               [ IsQuotientOfPathAlgebra ],
function( A )
  Print( "<quotient of path algebra ", LeftActingDomain( A ), " * ",
         QuiverOfAlgebra( A ), " / ", RelationsOfAlgebra( A ), ">" );
end );

InstallMethod( ViewObj, "for quotient of path algebra",
               [ IsQuotientOfPathAlgebra ],
function( A )
  Print( "( ", LeftActingDomain( A ), " * ", Name( QuiverOfAlgebra( A ) ),
         " ) / ", RelationsOfAlgebra( A ) );
end );

InstallMethod( \/, "for path algebra and path ideal",
               [ IsPathAlgebra, IsPathIdeal ],
               QuotientOfPathAlgebra );

InstallMethod( QuiverOfAlgebra, "for quotient of path algebra",
               [ IsQuotientOfPathAlgebra ],
function( A )
  return QuiverOfAlgebra( PathAlgebra( A ) );
end );

InstallMethod( LeftActingDomain, "for quotient of path algebra",
               [ IsQuotientOfPathAlgebra ],
function( A )
  return LeftActingDomain( PathAlgebra( A ) );
end );

InstallMethod( RelationsOfAlgebra, "for quotient of path algebra",
               [ IsQuotientOfPathAlgebra and IsQuotientOfPathAlgebraRep ],
function( A )
  return A!.relations;
end );

InstallMethod( IdealOfQuotient, "for quotient of path algebra",
               [ IsQuotientOfPathAlgebra and IsQuotientOfPathAlgebraRep ],
function( A )
  return A!.ideal;
end );

InstallMethod( PathAlgebra, "for quotient of path algebra",
               [ IsQuotientOfPathAlgebra and IsQuotientOfPathAlgebraRep ],
function( A )
  return A!.pathAlgebra;
end );

InstallMethod( Zero, "for quotient of path algebra",
               [ IsQuotientOfPathAlgebra ],
function( A )
  return QuotientOfPathAlgebraElement( A, Zero( PathAlgebra( A ) ) );
end );

InstallMethod( One, "for quotient of path algebra",
               [ IsQuotientOfPathAlgebra ],
function( A )
  return QuotientOfPathAlgebraElement( A, One( PathAlgebra( A ) ) );
end );


DeclareRepresentation( "IsQuotientOfPathAlgebraElementRep", IsComponentObjectRep,
                       [ "algebra", "representative" ] );

InstallGlobalFunction( QuotientOfPathAlgebraElement,
function( algebra, pathAlgebraElement )
  local representative;
  representative := Reduce( pathAlgebraElement,
                            GroebnerBasis( IdealOfQuotient( algebra ) ) );
  return Objectify( NewType( ElementsFamily( FamilyObj( algebra ) ),
                             IsQuotientOfPathAlgebraElement and IsQuotientOfPathAlgebraElementRep ),
                    rec( algebra := algebra,
                         representative := representative ) );
end );

InstallMethod( PathAsAlgebraElement, "for quotient of path algebra and path",
               [ IsQuotientOfPathAlgebra, IsPath ],
function( A, p )
  local representative;
  representative := PathAsAlgebraElement( PathAlgebra( A ), p );
  return QuotientOfPathAlgebraElement( A, representative );
end );

InstallMethod( PrintObj, "for element of quotient of path algebra",
               [ IsQuotientOfPathAlgebraElement ],
function( e )
  Print( "{ ", Representative( e ), " }" );
end );

InstallMethod( AlgebraOfElement, "for element of quotient of path algebra",
               [ IsQuotientOfPathAlgebraElement and IsQuotientOfPathAlgebraElementRep ],
function( e )
  return e!.algebra;
end );

InstallMethod( Representative, "for element of quotient of path algebra",
               [ IsQuotientOfPathAlgebraElement and IsQuotientOfPathAlgebraElementRep ],
function( e )
  return e!.representative;
end );

InstallMethod( Coefficients, "for element of quotient of path algebra",
               [ IsQuotientOfPathAlgebraElement ],
function( e )
  return Coefficients( Representative( e ) );
end );

InstallMethod( Paths, "for element of quotient of path algebra",
               [ IsQuotientOfPathAlgebraElement ],
function( e )
  return Paths( Representative( e ) );
end );

InstallMethod( \in, "for element of quotient of path algebra and quotient of path algebra",
               [ IsQuotientOfPathAlgebraElement, IsQuotientOfPathAlgebra ],
function( e, A )
  return A = AlgebraOfElement( e );
end );

InstallMethod( \=, "for elements of quotient of path algebra", IsIdenticalObj,
               [ IsQuotientOfPathAlgebraElement, IsQuotientOfPathAlgebraElement ],
function( e1, e2 )
  return Representative( e1 ) = Representative( e2 );
end );

InstallMethod( AdditiveInverse, "for element of quotient of path algebra",
               [ IsQuotientOfPathAlgebraElement ],
function( e )
  return QuotientOfPathAlgebraElement
         ( AlgebraOfElement( e ),
           AdditiveInverse( Representative( e ) ) );
end );

InstallMethod( \+, "for elements of quotient of path algebra", IsIdenticalObj,
               [ IsQuotientOfPathAlgebraElement, IsQuotientOfPathAlgebraElement ],
function( e1, e2 )
  return QuotientOfPathAlgebraElement
         ( AlgebraOfElement( e1 ),
           Representative( e1 ) + Representative( e2 ) );
end );

InstallMethod( \*, "for elements of quotient of path algebra", IsIdenticalObj,
               [ IsQuotientOfPathAlgebraElement, IsQuotientOfPathAlgebraElement ],
function( e1, e2 )
  return QuotientOfPathAlgebraElement
         ( AlgebraOfElement( e1 ),
           Representative( e1 ) * Representative( e2 ) );
end );

InstallMethod( \*, "for multiplicative element and element of quotient of path algebra",
               [ IsMultiplicativeElement, IsQuotientOfPathAlgebraElement ],
function( c, e )
  if c in LeftActingDomain( AlgebraOfElement( e ) ) then
    return QuotientOfPathAlgebraElement
           ( AlgebraOfElement( e ),
             c * Representative( e ) );
  else
    TryNextMethod();
  fi;
end );