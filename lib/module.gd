DeclareCategory( "IsQuiverRepresentationElement", IsVector );
DeclareCategory( "IsQuiverRepresentation", IsVectorSpace and CategoryCollections( IsQuiverRepresentationElement ) );

DeclareOperation( "QuiverRepresentationElement", [ IsQuiverRepresentation, IsCollection ] );
DeclareOperation( "QuiverRepresentationElementNC", [ IsQuiverRepresentation, IsCollection ] );
DeclareOperation( "QuiverRepresentationElementByVertices", [ IsQuiverRepresentation, IsDenseList, IsDenseList ] );
DeclareAttribute( "RepresentationOfElement", IsQuiverRepresentationElement );
DeclareAttribute( "ElementVectors", IsQuiverRepresentationElement );
DeclareOperation( "ElementVector", [ IsQuiverRepresentationElement, IsPosInt ] );
DeclareOperation( "ElementVector", [ IsQuiverRepresentationElement, IsVertex ] );
DeclareOperation( "PathAction", [ IsQuiverRepresentationElement, IsPath ] );
DeclareOperation( "QuiverAlgebraAction", [ IsQuiverRepresentationElement, IsQuiverAlgebraElement ] );

DeclareOperation( "QuiverRepresentation", [ IsQuiverAlgebra, IsDenseList, IsDenseList ] );
DeclareAttribute( "AlgebraOfRepresentation", IsQuiverRepresentation );
DeclareAttribute( "QuiverOfRepresentation", IsQuiverRepresentation );
DeclareAttribute( "FieldOfRepresentation", IsQuiverRepresentation );
DeclareAttribute( "VertexDimensions", IsQuiverRepresentation );
DeclareOperation( "VertexDimension", [ IsQuiverRepresentation, IsPosInt ] );
DeclareOperation( "VertexDimension", [ IsQuiverRepresentation, IsVertex ] );
DeclareAttribute( "MatricesOfRepresentation", IsQuiverRepresentation );
DeclareOperation( "MatrixForArrow", [ IsQuiverRepresentation, IsPosInt ] );
DeclareOperation( "MatrixForArrow", [ IsQuiverRepresentation, IsArrow ] );
DeclareOperation( "MatrixForPath", [ IsQuiverRepresentation, IsPath ] );
DeclareOperation( "MatrixForAlgebraElement", [ IsQuiverRepresentation, IsQuiverAlgebraElement and IsUniform ] );
