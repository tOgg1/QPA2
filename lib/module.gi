DeclareRepresentation( "IsQuiverModuleElementRep",
                       IsComponentObjectRep and IsAttributeStoringRep, [] );
DeclareRepresentation( "IsQuiverModuleRep",
                       IsComponentObjectRep and IsAttributeStoringRep, [] );

BindGlobal( "FamilyOfQuiverModuleElements",
            NewFamily( "quiver module elements" ) );
BindGlobal( "FamilyOfQuiverModules",
            CollectionsFamily( FamilyOfQuiverModuleElements ) );

DeclareSideOperations( IsQuiverModule, IsLeftQuiverModule, IsRightQuiverModule, IsQuiverBimodule );
DeclareSideOperations( AsModule, AsLeftQuiverModule, AsRightQuiverModule, AsBimodule );
DeclareSideOperations( QuiverModule, LeftQuiverModule, RightQuiverModule, QuiverBimodule );
DeclareSideOperations( ZeroModule, LeftZeroModule, RightZeroModule, ZeroBimodule );
DeclareSideOperations( IsQuiverModuleElement,
                       IsLeftQuiverModuleElement, IsRightQuiverModuleElement, IsQuiverBimoduleElement );
DeclareSideOperations( AsModuleCategory,
                       AsLeftModuleCategory, AsRightModuleCategory, AsBimoduleCategory );
DeclareSideOperations( ModuleCategory,
                       LeftModuleCategory, RightModuleCategory, BimoduleCategory );


InstallMethodWithSides( AsModule,
                        [ IsQuiverRepresentation ],
side -> function( R )
  local k, Q, rep_algebra, cat, module_type, left_algebra,  
        right_algebra, algebras, M;

  M := rec();
  ObjectifyWithAttributes( M, NewType( FamilyOfQuiverModules,
                                       IsQuiverModule^side and IsQuiverModuleRep ),
                           UnderlyingRepresentation, R,
                           LeftActingDomain, FieldOfRepresentation( R ),
                           Side, side );

  rep_algebra := AlgebraOfRepresentation( R );
  if side = LEFT_RIGHT then
    algebras := TensorProductFactorsLeftRight( rep_algebra );
  else
    algebras := [ fail, fail ];
    algebras[ Int( side ) ] := rep_algebra^side;
  fi;
  if algebras[ Int( LEFT ) ] <> fail then
    SetLeftActingAlgebra( M, algebras[ Int( LEFT ) ] );
  fi;
  if algebras[ Int( RIGHT ) ] <> fail then
    SetRightActingAlgebra( M, algebras[ Int( RIGHT ) ] );
  fi;

  cat := AsModuleCategory( side, CapCategory( R ) );
  Add( cat, M );

  return M;
end );

InstallMethodWithSides( QuiverModule,
                        [ "algebra", IsDenseList, IsList ],
side -> function( A, dimensions, matrices )
  return AsModule( side, QuiverRepresentation( A^side, dimensions, matrices ) );
end );

InstallMethodWithSides( QuiverModule,
                        [ "algebra", IsDenseList, IsDenseList, IsDenseList ],
side -> function( A, dimensions, arrows, matrices_for_arrows )
  return AsModule( side,
                   QuiverRepresentation( A^side,
                                         dimensions, arrows, matrices_for_arrows ) );
end );

InstallMethod( QuiverBimodule,
               [ IsQuiverAlgebra, IsQuiverAlgebra, IsDenseList, IsList ],
function( A, B, dimensions, matrices )
  return QuiverBimodule( [ A, B ], dimensions, matrices );
end );

InstallMethod( QuiverBimodule,
               [ IsQuiverAlgebra, IsQuiverAlgebra, IsDenseList, IsDenseList, IsList ],
function( A, B, dimensions, arrows, matrices_for_arrows )
  return QuiverBimodule( [ A, B ], dimensions, arrows, matrices_for_arrows );
end );

InstallMethodWithSides( ZeroModule, [ "algebra" ],
side -> function( A )
  return AsModule( side, ZeroRepresentation( A^side ) );
end );

InstallMethod( \=, [ IsQuiverModule, IsQuiverModule ],
function( M1, M2 )
  return Side( M1 ) = Side( M2 )
         and UnderlyingRepresentation( M1 ) = UnderlyingRepresentation( M2 );
end );

InstallMethod( String,
               [ IsQuiverModule ],
function( M )
  return String( UnderlyingRepresentation( M ) );
end );

InstallMethod( ViewObj,
               [ IsQuiverModule ],
function( R )
  Print( "<", String( R ), ">" );
end );

InstallMethod( QuiverOfModule,
               [ IsQuiverModule ],
function( M )
  return QuiverOfRepresentation( UnderlyingRepresentation( M ) );
end );

InstallMethod( FieldOfModule,
               [ IsQuiverModule ],
function( M )
  return FieldOfRepresentation( UnderlyingRepresentation( M ) );
end );

InstallMethod( VertexDimensions,
               [ IsQuiverModule ],
function( M )
  return VertexDimensions( UnderlyingRepresentation( M ) );
end );

InstallMethod( VertexDimension,
               [ IsQuiverModule, IsPosInt ],
function( M, i )
  return VertexDimension( UnderlyingRepresentation( M ), i );
end );

InstallMethod( VertexDimension,
               [ IsQuiverModule, IsVertex ],
function( M, v )
  return VertexDimension( UnderlyingRepresentation( M ), v );
end );

InstallMethod( AsModuleElement,
               [ IsQuiverRepresentationElement, IsQuiverModule ],
function( e, M )
  local me, elem_cat;
  if RepresentationOfElement( e ) <> UnderlyingRepresentation( M ) then
    Error( "Element is not from the underlying representation of the module" );
  fi;
  elem_cat := IsQuiverModuleElement^Side( M );
  me := rec();
  ObjectifyWithAttributes( me, NewType( FamilyOfQuiverModuleElements,
                                        elem_cat and IsQuiverModuleRep ),
                           UnderlyingRepresentationElement, e,
                           ModuleOfElement, M,
                           Side, Side( M ) );
  return me;
end );

DeclareSideOperations( AsModuleElement, AsLeftModuleElement, AsRightModuleElement,
                       AsBimoduleElement );

InstallMethodWithSides( AsModuleElement,
                        [ IsQuiverRepresentationElement ],
side -> function( r )
  return AsModuleElement( r, AsModule( side, RepresentationOfElement( r ) ) );
end );


InstallMethod( QuiverModuleElement,
               [ IsQuiverModule, IsList ],
function( M, vectors )
  local R, e;
  R := UnderlyingRepresentation( M );
  e := QuiverRepresentationElement( R, vectors );
  return AsModuleElement( e, M );
end );

InstallMethod( QuiverModuleElement,
               [ IsQuiverModule, IsDenseList, IsList ],
function( M, vertices, vectors )
  local R, e;
  R := UnderlyingRepresentation( M );
  e := QuiverRepresentationElement( R, vertices, vectors );
  return AsModuleElement( e, M );
end );

InstallMethod( Zero,
               [ IsQuiverModule ],
function( M )
  local R;
  R := UnderlyingRepresentation( M );
  return AsModuleElement( Zero( R ), M );
end );

InstallMethod( ElementVectors,
               [ IsQuiverModuleElement ],
function( e )
  return ElementVectors( UnderlyingRepresentationElement( e ) );
end );

InstallMethod( ElementVector,
               [ IsQuiverModuleElement, IsPosInt ],
function( e, i )
  return ElementVector( UnderlyingRepresentationElement( e ), i );
end );

InstallMethod( \[\], [ IsQuiverModuleElement, IsPosInt ], ElementVector );

InstallMethod( ElementVector,
               [ IsQuiverModuleElement, IsVertex ],
function( e, v )
  return ElementVector( UnderlyingRepresentationElement( e ), v );
end );

InstallMethod( String,
               [ IsQuiverModuleElement ],
function( e )
  return Concatenation( "left module element ", String( ElementVectors( e ) ) );
end );

InstallMethod( String,
               [ IsRightQuiverModuleElement ],
function( e )
  return Concatenation( "right module element ", String( ElementVectors( e ) ) );
end );

InstallMethod( ViewObj,
               [ IsQuiverModuleElement ],
function( e )
  Print( "<", String( e ), ">" );
end );

InstallMethod( \in, "for quiver module element and quiver module",
               [ IsQuiverModuleElement, IsQuiverModule ],
function( e, M )
  return ModuleOfElement( e ) = M;
end );

InstallMethod( \^,
               [ IsQuiverAlgebraElement, IsLeftQuiverModuleElement ],
function( ae, me )
  local A, Q, re, re_;
  A := AlgebraOfElement( ae );
  Q := QuiverOfAlgebra( A );
  re := UnderlyingRepresentationElement( me );
  if IsLeftQuiver( Q ) then
    re_ := QuiverAlgebraAction( re, ae );
  else
    re_ := QuiverAlgebraAction( re, OppositeAlgebraElement( ae ) );
  fi;
  return AsModuleElement( re_, ModuleOfElement( me ) );
end );

InstallMethod( \^,
               [ IsRightQuiverModuleElement, IsQuiverAlgebraElement ],
function( me, ae )
  local A, Q, re, re_;
  A := AlgebraOfElement( ae );
  Q := QuiverOfAlgebra( A );
  re := UnderlyingRepresentationElement( me );
  if IsRightQuiver( Q ) then
    re_ := QuiverAlgebraAction( re, ae );
  else
    re_ := QuiverAlgebraAction( re, OppositeAlgebraElement( ae ) );
  fi;
  return AsModuleElement( re_, ModuleOfElement( me ) );
end );

InstallMethod( \^,
               [ IsQuiverAlgebraElement, IsQuiverBimoduleElement ],
function( a, m )
  local M, r, ax1;
  M := ModuleOfElement( m );
  r := UnderlyingRepresentationElement( m );
  ax1 := [ a, One( RightActingAlgebra( M ) ) ]^LEFT_RIGHT;
  return AsModuleElement( QuiverAlgebraAction( r, ax1 ), M );
end );

InstallMethod( \^,
               [ IsQuiverBimoduleElement, IsQuiverAlgebraElement ],
function( m, a )
  local M, r, 1xa;
  M := ModuleOfElement( m );
  r := UnderlyingRepresentationElement( m );
  1xa := [ One( LeftActingAlgebra( M ) ), a ]^LEFT_RIGHT;
  return AsModuleElement( QuiverAlgebraAction( r, 1xa ), M );
end );

InstallMethod( \=, [ IsQuiverModuleElement, IsQuiverModuleElement ],
function( e1, e2 )
  local re1, re2;
  if ModuleOfElement( e1 ) <> ModuleOfElement( e2 ) then
    return false;
  fi;
  re1 := UnderlyingRepresentationElement( e1 );
  re2 := UnderlyingRepresentationElement( e2 );
  return re1 = re2;
end );

InstallMethod( \+, [ IsQuiverModuleElement, IsQuiverModuleElement ],
function( e1, e2 )
  local re1, re2;
  if ModuleOfElement( e1 ) <> ModuleOfElement( e2 ) then
    Error( "cannot add elements of different modules" );
  fi;
  re1 := UnderlyingRepresentationElement( e1 );
  re2 := UnderlyingRepresentationElement( e2 );
  return AsModuleElement( re1 + re2, ModuleOfElement( e1 ) );
end );

InstallMethod( \*, "for multiplicative element and element of quiver module",
               [ IsMultiplicativeElement, IsQuiverModuleElement ],
function( c, e )
  return AsModuleElement( c * UnderlyingRepresentationElement( e ),
                          ModuleOfElement( e ) );
end );

InstallMethod( \*, "for element of quiver module and multiplicative element",
               [ IsQuiverModuleElement, IsMultiplicativeElement ],
function( e, c )
  return AsModuleElement( UnderlyingRepresentationElement( e ) * c,
                          ModuleOfElement( e ) );
end );

# basis of modules

BindGlobal( "FamilyOfQuiverModuleBases",
            NewFamily( "quiver module bases" ) );

DeclareRepresentation( "IsQuiverModuleBasisRep", IsComponentObjectRep and IsAttributeStoringRep,
                       [ ] );

InstallMethod( CanonicalBasis, "for quiver module",
               [ IsQuiverModule ],
function( M )
  local R, rep_basis, B;
  R := UnderlyingRepresentation( M );
  rep_basis := CanonicalBasis( R );
  B := rec( module := M,
            underlyingRepresentationBasis := rep_basis );
  ObjectifyWithAttributes( B,
                           NewType( FamilyOfQuiverModuleBases,
                                    IsBasis and IsQuiverModuleBasisRep ),
                           IsCanonicalBasis, true );
  return B;
end );

InstallMethod( Basis, "for quiver module",
               [ IsQuiverModule ],
               CanonicalBasis );

InstallMethod( BasisVectors, "for quiver module basis",
               [ IsBasis and IsQuiverModuleBasisRep ],
function( B )
  return List( BasisVectors( B!.underlyingRepresentationBasis ),
               v -> AsModuleElement( v, B!.module ) );
end );

# TODO: right modules?
InstallMethod( UnderlyingLeftModule, "for quiver module basis",
               [ IsBasis and IsQuiverModuleBasisRep ],
function( B )
  return B!.module;
end );

InstallMethodWithSides( AsModuleCategory, [ IsQuiverRepresentationCategory ],
side -> function( rep_cat )
  local rep_algebra, Q, _R, _r, _M, _m, algebras, A, B, cat;

  rep_algebra := AlgebraOfCategory( rep_cat );
  Q := QuiverOfAlgebra( rep_algebra );

  _R := UnderlyingRepresentation;
  _r := UnderlyingRepresentationHomomorphism;
  _M := AsModule^side;
  _m := f -> AsModuleHomomorphism( side, f );

  if side = LEFT_RIGHT then
    algebras := TensorProductFactorsLeftRight( rep_algebra );
    A := algebras[ 1 ];
    B := algebras[ 2 ];
    cat := CreateCapCategory( Concatenation( "bimodules over ", String( A ), " and ", String( B ) ) );
    SetFilterObj( cat, IsQuiverBimoduleCategory );
    SetAlgebrasOfCategory( cat, algebras );
  else
    A := rep_algebra^side;
    cat := CreateCapCategory( Concatenation( String( side ), " modules over ", String( A ) ) );
    if side = LEFT then
      SetFilterObj( cat, IsLeftQuiverModuleCategory );
    else
      SetFilterObj( cat, IsRightQuiverModuleCategory );
    fi;
    SetAlgebraOfCategory( cat, A );
  fi;
  SetUnderlyingRepresentationCategory( cat, rep_cat );
  SetIsAbelianCategory( cat, true );

  AddIsEqualForObjects( cat,
  function( M1, M2 )
    return IsEqualForObjects( _R( M1 ), _R( M2 ) );
  end );

  AddIsEqualForMorphisms( cat,
  function( m1, m2 )
    return IsEqualForMorphisms( _r( m1 ), _r( m2 ) );
  end );

  AddZeroObject( cat, function()
    return _M( ZeroObject( rep_cat ) );
  end );
  AddZeroMorphism( cat, function( M1, M2 )
    return _m( ZeroMorphism( _R( M1 ), _R( M2 ) ) );
  end );
  AddIdentityMorphism( cat, M -> _m( IdentityMorphism( _R( M ) ) ) );
  AddPreCompose( cat, function( m1, m2 )
    return _m( PreCompose( _r( m1 ), _r( m2 ) ) );
  end );
  AddAdditionForMorphisms( cat, function( m1, m2 )
    return _m( AdditionForMorphisms( _r( m1 ), _r( m2 ) ) );
  end );
  AddAdditiveInverseForMorphisms( cat, m -> _m( AdditiveInverseForMorphisms( _r( m ) ) ) );
  AddKernelEmbedding( cat, m -> _m( KernelEmbedding( _r( m ) ) ) );
  AddCokernelProjection( cat, m -> _m( CokernelProjection( _r( m ) ) ) );
  AddLiftAlongMonomorphism( cat, function( i, test )
    return _m( LiftAlongMonomorphism( _r( i ), _r( test ) ) );
  end );
  AddColiftAlongEpimorphism( cat, function( e, test )
    return _m( ColiftAlongEpimorphism( _r( e ), _r( test ) ) );
  end );
  AddDirectSum( cat, function( summands )
    return _M( DirectSum( List( summands, _R ) ) );
  end );
  AddInjectionOfCofactorOfDirectSumWithGivenDirectSum( cat, function( summands, i, sum )
    return _m( InjectionOfCofactorOfDirectSumWithGivenDirectSum
               ( List( summands, _R ), i, _R( sum ) ) );
  end );
  AddProjectionInFactorOfDirectSumWithGivenDirectSum( cat, function( summands, i, sum )
    return _m( ProjectionInFactorOfDirectSumWithGivenDirectSum
               ( List( summands, _R ), i, _R( sum ) ) );
  end );

  Finalize( cat );

  return cat;
end );

InstallMethodWithSides( ModuleCategory, [ "algebra" ],
side -> function( A )
  return AsModuleCategory( side, CategoryOfQuiverRepresentations( A^side ) );
end );

InstallMethod( BimoduleCategory, [ IsQuiverAlgebra, IsQuiverAlgebra ],
function( A, B )
  return BimoduleCategory( [ A, B ] );
end );

InstallMethod( UnderlyingRepresentationFunctor, "for a module category",
        [ IsQuiverModuleCategory ], 
        function( C )
    
    local   D,  underlying;
    
    D := UnderlyingRepresentationCategory( C );
    underlying := CapFunctor( "UnderlyingRepresentation", C, D );
    
    AddObjectFunction( underlying, UnderlyingRepresentation ); 
    AddMorphismFunction( underlying, 
            function( M, f, N ) return UnderlyingRepresentationHomomorphism( f ); end );
    
    return underlying;
end );

DeclareSideOperations( AsModuleFunctor, AsLeftModuleFunctor, AsRightModuleFunctor, AsBimoduleFunctor );

InstallMethodWithSides( AsModuleFunctor, 
        [ IsQuiverRepresentationCategory ],
side -> function( C )
    local   F;
    
    F := CapFunctor( "RepresentationModuleEquivalence", C, AsModuleCategory( side, C ) );
    
    AddObjectFunction( F, AsModule^side ); 
    AddMorphismFunction( F, 
            function( M, f, N ) return AsModuleHomomorphism( side, f ); end );
    
    return F;
end );