package laya.d3.resource.models {
	import laya.d3.core.BufferState;
	import laya.d3.core.render.RenderContext3D;
	import laya.d3.graphics.IndexBuffer3D;
	import laya.d3.graphics.Vertex.VertexPosition;
	import laya.d3.graphics.VertexBuffer3D;
	import laya.layagl.LayaGL;
	import laya.utils.Stat;
	import laya.webgl.WebGLContext;
	
	/**
	 * @private
	 * <code>SkyBox</code> 类用于创建天空盒。
	 */
	public class SkyBox {
		/**@private */
		public static var _instance:SkyBox;
		
		/**
		 * @private
		 */
		public static function __init__():void {
			_instance = new SkyBox();
			_instance._vertexBuffer.lock = true;//锁住资源防止被资源管理释放
			_instance._indexBuffer.lock = true;//锁住资源防止被资源管理释放
		}
		
		/**@private */
		private var _vertexBuffer:VertexBuffer3D;
		/**@private */
		private var _indexBuffer:IndexBuffer3D;
		
		/**@private */
		public var _bufferState:BufferState;
		
		/**
		 * 创建一个 <code>SkyBox</code> 实例。
		 */
		public function SkyBox() {
			/*[DISABLE-ADD-VARIABLE-DEFAULT-VALUE]*/
			var halfHeight:Number = 0.5;
			var halfWidth:Number = 0.5;
			var halfDepth:Number = 0.5;
			var vertices:Float32Array = new Float32Array([-halfDepth, halfHeight, -halfWidth, halfDepth, halfHeight, -halfWidth, halfDepth, halfHeight, halfWidth, -halfDepth, halfHeight, halfWidth,//上
			-halfDepth, -halfHeight, -halfWidth, halfDepth, -halfHeight, -halfWidth, halfDepth, -halfHeight, halfWidth, -halfDepth, -halfHeight, halfWidth]);//下
			var indices:Uint8Array = new Uint8Array([0, 1, 2, 2, 3, 0, //上
			4, 7, 6, 6, 5, 4, //下
			0, 3, 7, 7, 4, 0, //左
			1, 5, 6, 6, 2, 1,//右
			3, 2, 6, 6, 7, 3, //前
			0, 4, 5, 5, 1, 0]);//后
			
			_vertexBuffer = new VertexBuffer3D(VertexPosition.vertexDeclaration.vertexStride * 8, WebGLContext.STATIC_DRAW, false);
			_vertexBuffer.vertexDeclaration = VertexPosition.vertexDeclaration;
			_indexBuffer = new IndexBuffer3D(IndexBuffer3D.INDEXTYPE_UBYTE, 36, WebGLContext.STATIC_DRAW, false);
			_vertexBuffer.setData(vertices);
			_indexBuffer.setData(indices);
			
			var bufferState:BufferState = new BufferState();
			bufferState.bind();
			bufferState.applyVertexBuffer(_vertexBuffer);
			bufferState.applyIndexBuffer(_indexBuffer);
			bufferState.unBind();
			_bufferState = bufferState;
		}
		
		/**
		 * @private
		 */
		public function _render(state:RenderContext3D):void {
			LayaGL.instance.drawElements(WebGLContext.TRIANGLES, 36, WebGLContext.UNSIGNED_BYTE, 0);
			Stat.trianglesFaces += 12;
			Stat.drawCall++;
		}
	}
}