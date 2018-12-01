package laya.d3.graphics.Vertex {
	import laya.d3.graphics.VertexDeclaration;
	import laya.d3.graphics.VertexElement;
	import laya.d3.graphics.VertexElementFormat;
	import laya.d3.math.Vector2;
	import laya.d3.math.Vector3;
	import laya.d3.math.Vector4;
	
	/**
	 * <code>VertexPositionNormalTextureSkin</code> 类用于创建位置、法线、纹理、骨骼索引、骨骼权重顶点结构。
	 */
	public class VertexPositionNormalTextureSkinSTangent extends VertexMesh {
		
		private static const _vertexDeclaration:VertexDeclaration = new VertexDeclaration(80, [
		new VertexElement(0, VertexElementFormat.Vector3, VertexMesh.MESH_POSITION0), 
		new VertexElement(12, VertexElementFormat.Vector3, VertexMesh.MESH_NORMAL0), 
		new VertexElement(24, VertexElementFormat.Vector2, VertexMesh.MESH_TEXTURECOORDINATE0), 
		new VertexElement(32, VertexElementFormat.Vector4, VertexMesh.MESH_BLENDWEIGHT0), 
		new VertexElement(48, VertexElementFormat.Vector4, VertexMesh.MESH_BLENDINDICES0), 
		new VertexElement(64, VertexElementFormat.Vector4, VertexMesh.MESH_TANGENT0)]);
		
		public static function get vertexDeclaration():VertexDeclaration {
			return _vertexDeclaration;
		}
		
		private var _position:Vector3;
		private var _normal:Vector3;
		private var _textureCoordinate:Vector2;
		private var _blendIndex:Vector4;
		private var _blendWeight:Vector4;
		private var _tangent:Vector3;
		
		public function get position():Vector3 {
			return _position;
		}
		
		public function get normal():Vector3 {
			return _normal;
		}
		
		public function get textureCoordinate():Vector2 {
			return _textureCoordinate;
		}
		
		public function get blendIndex():Vector4 {
			return _blendIndex;
		}
		
		public function get blendWeight():Vector4 {
			return _blendWeight;
		}
		
		public function get tangent():Vector3 {
			return _tangent;
		}
		
		override public function get vertexDeclaration():VertexDeclaration {
			return _vertexDeclaration;
		}
		
		public function VertexPositionNormalTextureSkinSTangent(position:Vector3, normal:Vector3, textureCoordinate:Vector2, tangent:Vector3, blendIndex:Vector4, blendWeight:Vector4) {
			_position = position;
			_normal = normal;
			_textureCoordinate = textureCoordinate;
			_tangent = tangent;
			_blendIndex = blendIndex;
			_blendWeight = blendWeight;
		}
	
	}

}