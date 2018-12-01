package laya.d3.core.pixelLine {
	import laya.d3.core.BufferState;
	import laya.d3.core.GeometryElement;
	import laya.d3.core.render.RenderContext3D;
	import laya.d3.graphics.IndexBuffer3D;
	import laya.d3.graphics.VertexBuffer3D;
	import laya.d3.math.Color;
	import laya.d3.math.Vector3;
	import laya.d3.math.Vector4;
	import laya.layagl.LayaGL;
	import laya.utils.Stat;
	import laya.webgl.WebGL;
	import laya.webgl.WebGLContext;
	
	/**
	 * <code>PixelLineFilter</code> 类用于线过滤器。
	 */
	public class PixelLineFilter extends GeometryElement {
		
		private var _owner:PixelLineSprite3D;
		private var _vertices:Float32Array;
		private var _vertexBuffer:VertexBuffer3D;
		private const _floatCountPerVertices:int = 7;
		private var _verticesIndex:int = 0;
		
		private var _indices:Uint16Array;
		private var _indexBuffer:IndexBuffer3D;
		private var _indicesIndex:int = 0;
		private var _index:int = 0;
		
		private var _lineBufferState:BufferState = new BufferState();
		
		public function PixelLineFilter(owner:PixelLineSprite3D) {
			
			_owner = owner;
			
			var pointCount:int = _owner.lineCount * 2;
			
			_vertices = new Float32Array(pointCount * _floatCountPerVertices);
			_vertexBuffer = new VertexBuffer3D(PixelLineVertex.vertexDeclaration.vertexStride * pointCount, WebGLContext.STATIC_DRAW, false);
			_vertexBuffer.vertexDeclaration = PixelLineVertex.vertexDeclaration;
			
			_indices = new Uint16Array(pointCount);
			_indexBuffer = new IndexBuffer3D(IndexBuffer3D.INDEXTYPE_USHORT, pointCount, WebGLContext.STATIC_DRAW, false);
			
			_lineBufferState.bind();
			_lineBufferState.applyVertexBuffer(_vertexBuffer);
			_lineBufferState.applyIndexBuffer(_indexBuffer);
			_lineBufferState.unBind();
			_applyBufferState(_lineBufferState);
		}
		
		/** @private */
		public function _resetLineData():void{
			
			_destroy();
			
			_verticesIndex = 0;
			_indicesIndex = 0;
			_index = 0;
			
			var pointCount:int = _owner.lineCount * 2;
			
			_vertices = new Float32Array(pointCount * _floatCountPerVertices);
			_vertexBuffer = new VertexBuffer3D(PixelLineVertex.vertexDeclaration.vertexStride * pointCount, WebGLContext.STATIC_DRAW, false);
			_vertexBuffer.vertexDeclaration = PixelLineVertex.vertexDeclaration;
			
			_indices = new Uint16Array(pointCount);
			_indexBuffer = new IndexBuffer3D(IndexBuffer3D.INDEXTYPE_USHORT, pointCount, WebGLContext.STATIC_DRAW, false);
			
			_lineBufferState.bind();
			_lineBufferState.applyVertexBuffer(_vertexBuffer);
			_lineBufferState.applyIndexBuffer(_indexBuffer);
			_lineBufferState.unBind();
			_applyBufferState(_lineBufferState);
			
			_initLineData();
		}
		
		/** @private */
		public function _initLineData():void{
			
			var _pixelLineDatas:Vector.<PixelLineData> = _owner.pixelLineDatas;
			var _pixelLineData:PixelLineData;
			for (var i:int = 0, j:int = _pixelLineDatas.length; i < j; i++ ){
				_pixelLineData = _pixelLineDatas[i];
				var startPositione:Float32Array = _pixelLineData.startPosition.elements;
				var endPositione:Float32Array = _pixelLineData.endPosition.elements;
				var startColore:Float32Array = _pixelLineData.startColor.elements;
				var endColore:Float32Array = _pixelLineData.endColor.elements;
				
				_vertices[_verticesIndex + 0] = startPositione[0];
				_vertices[_verticesIndex + 1] = startPositione[1];
				_vertices[_verticesIndex + 2] = startPositione[2];
				_vertices[_verticesIndex + 3] = startColore[0];
				_vertices[_verticesIndex + 4] = startColore[1];
				_vertices[_verticesIndex + 5] = startColore[2];
				_vertices[_verticesIndex + 6] = startColore[3];
				
				_vertices[_verticesIndex + 7] = endPositione[0];
				_vertices[_verticesIndex + 8] = endPositione[1];
				_vertices[_verticesIndex + 9] = endPositione[2];
				_vertices[_verticesIndex + 10] = endColore[0];
				_vertices[_verticesIndex + 11] = endColore[1];
				_vertices[_verticesIndex + 12] = endColore[2];
				_vertices[_verticesIndex + 13] = endColore[3];
				
				_verticesIndex += _floatCountPerVertices * 2;
				
				
				_indices[_indicesIndex + 0] = _index++;
				_indices[_indicesIndex + 1] = _index++;
				
				_indicesIndex += 2;
			}
			
			_vertexBuffer.setData(_vertices, 0, 0, _verticesIndex);
			_indexBuffer.setData(_indices, 0, 0, _indicesIndex);
			
		}
		
		/** @private */
		public function _updateLineData(index:int, startPosition:Vector3, endPosition:Vector3, startColor:Color, endColor:Color):void{
			
			var startPositione:Float32Array = startPosition.elements;
			var endPositione:Float32Array = endPosition.elements;
			var startColore:Float32Array = startColor.elements;
			var endColore:Float32Array = endColor.elements;
			
			var vbOffset:int = index * _floatCountPerVertices * 2;
			
			_vertices[vbOffset + 0] = startPositione[0];
			_vertices[vbOffset + 1] = startPositione[1];
			_vertices[vbOffset + 2] = startPositione[2];
			
			_vertices[vbOffset + 3] = startColore[0];
			_vertices[vbOffset + 4] = startColore[1];
			_vertices[vbOffset + 5] = startColore[2];
			_vertices[vbOffset + 6] = startColore[3];
			
			
			_vertices[vbOffset + 7] = endPositione[0];
			_vertices[vbOffset + 8] = endPositione[1];
			_vertices[vbOffset + 9] = endPositione[2];
			
			_vertices[vbOffset + 10] = endColore[0];
			_vertices[vbOffset + 11] = endColore[1];
			_vertices[vbOffset + 12] = endColore[2];
			_vertices[vbOffset + 13] = endColore[3];
			
			_vertexBuffer.setData(_vertices, vbOffset, vbOffset, _floatCountPerVertices * 2);
			
			var ibOffset:int = index * 2;
			
			_indices[ibOffset + 0] = ibOffset;
			_indices[ibOffset + 1] = ibOffset + 1;
			_indexBuffer.setData(_indices, ibOffset, ibOffset, 2);
		}
		
		/** @private */
		public function _updateLinesData(pixelLineData:Vector.<PixelLineData>):void{
			
			_verticesIndex = 0;
			_indicesIndex = 0;
			_index = 0;
			
			_initLineData();
		}
		
		/**
		 * 渲染前调用
		 * @param	state 渲染状态
		 * @return  是否渲染
		 */
		override public function _prepareRender(state:RenderContext3D):Boolean {
			
			return true;
		}
		
		/**
		 * 渲染时调用
		 * @param	state 渲染状态
		 */
		override public function _render(state:RenderContext3D):void {
			LayaGL.instance.drawElements(WebGLContext.LINES, _indicesIndex, WebGLContext.UNSIGNED_SHORT, 0);
			Stat.drawCall++;
		}
		
		public function _destroy():void{
			_vertexBuffer.destroy();
			_indexBuffer.destroy();
			
			_vertices = null;
			_indices = null;
		}
	}
}