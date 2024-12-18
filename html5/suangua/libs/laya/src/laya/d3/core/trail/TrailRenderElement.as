package laya.d3.core.trail {
	import laya.d3.core.BaseCamera;
	import laya.d3.core.BufferState;
	import laya.d3.core.GeometryElement;
	import laya.d3.core.render.RenderContext3D;
	import laya.d3.core.TextureMode;
	import laya.d3.graphics.VertexBuffer3D;
	import laya.d3.graphics.VertexDeclaration;
	import laya.d3.math.MathUtils3D;
	import laya.d3.math.Vector3;
	import laya.layagl.LayaGL;
	import laya.utils.Stat;
	import laya.webgl.WebGL;
	import laya.webgl.WebGLContext;
	
	/**
	 * <code>TrailRenderElement</code> 类用于创建拖尾渲染单元。
	 */
	public class TrailRenderElement extends GeometryElement {
		
		private static var renderElementCount:int = 0;
		public var _id:int;
		
		private var _owner:TrailFilter;
		private var _camera:BaseCamera;
		
		//固定顶点个数
		private var _verticesCount:Number = 0;
		//虚拟顶点个数
		private var _virtualVerticesCount:int = 0;
		
		private const _maxVerticesCount:int = 256;
		
		private var _vertices1:Float32Array;
		private var _vertexBuffer1:VertexBuffer3D;
		private const _floatCountPerVertices1:int = 8;
		private var _verticesIndex1:int = 0;
		private var _everyAddVerticeCount1:int;
		private var _delLength:Number = 0;
		
		private var _vertices2:Float32Array;
		private var _vertexBuffer2:VertexBuffer3D;
		private const _floatCountPerVertices2:int = 1;
		
		private var _everyGroupVertexBirthTime:Vector.<Number>;
		private var _VerticesToTailLength:Float32Array;
		private var _everyVertexToPreVertexDistance:Float32Array;
		
		private var _lastPosition:Vector3 = new Vector3();
		private var _curPosition:Vector3 = new Vector3();
		private var _delVector3:Vector3 = new Vector3();
		private var _lastFixedVertexPosition:Vector3 = new Vector3();
		private var _pointAtoBVector3:Vector3 = new Vector3();
		
		private var _pointe:Float32Array;
		private var _pointAtoBVector3e:Float32Array;
		
		private var _pointA:Vector3 = new Vector3();
		private var _pointB:Vector3 = new Vector3();
		
		private var _isStart:Boolean = false;
		private var _isFinish:Boolean = false;
		public var _isDead:Boolean = false;
		private var _curtime:Number;
		private var _curDisappearIndex:int = 0;
		
		public function TrailRenderElement(owner:TrailFilter) {
			_owner = owner;
			_id = renderElementCount++;
			
			if (_id == 0) {
				owner._owner.transform.position.cloneTo(_lastPosition);
			} else {
				owner._curSubTrailFinishPosition.cloneTo(_lastPosition);
			}
			
			_everyGroupVertexBirthTime = new Vector.<Number>();
			_VerticesToTailLength = new Float32Array(_maxVerticesCount);
			_everyVertexToPreVertexDistance = new Float32Array(_maxVerticesCount);
			_vertices1 = new Float32Array(_maxVerticesCount * _floatCountPerVertices1);
			_vertices2 = new Float32Array(_maxVerticesCount * _floatCountPerVertices2);
			
			var vertexDeclaration1:VertexDeclaration = VertexTrail.vertexDeclaration1;
			_vertexBuffer1 = new VertexBuffer3D(_maxVerticesCount * vertexDeclaration1.vertexStride, WebGLContext.STATIC_DRAW, true);
			_vertexBuffer1.vertexDeclaration = vertexDeclaration1
			
			var vertexDeclaration2:VertexDeclaration = VertexTrail.vertexDeclaration2;
			_vertexBuffer2 = new VertexBuffer3D(_maxVerticesCount * vertexDeclaration2.vertexStride, WebGLContext.STATIC_DRAW, true);
			_vertexBuffer2.vertexDeclaration = vertexDeclaration2;
			
			var vertexBuffers:Vector.<VertexBuffer3D> = new Vector.<VertexBuffer3D>();
			vertexBuffers.push(_vertexBuffer1);
			vertexBuffers.push(_vertexBuffer2);
			
			var bufferState:BufferState = new BufferState();
			bufferState.bind();
			bufferState.applyVertexBuffers(vertexBuffers);
			bufferState.unBind();
			_applyBufferState(bufferState);
		}
		
		/**
		 * @private
		 * 更新Trail数据
		 */
		private function _updateTrail():void {
			
			_everyAddVerticeCount1 = 0;
			if (!_isStart) {
				_addTrailByFirstPosition(_lastPosition, _curPosition);
			}
			
			_addTrailByNextPosition(_curPosition);
			_vertexBuffer1.setData(_vertices1, _verticesIndex1, _verticesIndex1, _everyAddVerticeCount1);
			_verticesIndex1 += _everyAddVerticeCount1;
			_curPosition.cloneTo(_lastPosition);
			
			if (_virtualVerticesCount == 2) {
				_verticesIndex1 -= _floatCountPerVertices1 * 2;
			}
		}
		
		/**
		 * @private
		 * 通过起始位置添加TrailRenderElement起始数据
		 * @param	firstPosition  起始位置
		 * @param	secondPosition 第二次位置
		 */
		private function _addTrailByFirstPosition(firstPosition:Vector3, secondPosition:Vector3):void {
			switch (_owner.renderMode) {
			case TrailFilter.RENDERMODE_TRAJECTORYBILLBOARD: 
				Vector3.subtract(secondPosition, firstPosition, _delVector3);//运动差值
				break;
			case TrailFilter.RENDERMODE_SPRITEFORWADBILLBOARD: 
				_owner._owner.transform.forward.cloneTo(_delVector3);
				break;
			}
			Vector3.cross(_delVector3, _camera.transform.forward, _pointAtoBVector3);
			Vector3.normalize(_pointAtoBVector3, _pointAtoBVector3);
			Vector3.scale(_pointAtoBVector3, _owner.widthMultiplier / 2, _pointAtoBVector3);
			
			_updateVerticesByPosition(firstPosition);
			
			firstPosition.cloneTo(_lastFixedVertexPosition);
			_verticesCount += 2;
			
			_curtime = _owner._hasLifeSubTrail ? _owner._curSubTrailFinishCurTime : _owner._curtime;
			_everyGroupVertexBirthTime.push(_curtime);
			_isStart = true;
			_owner._hasLifeSubTrail = true;
		}
		
		/**
		 * @private
		 * 通过位置更新TrailRenderElement数据
		 * @param	position  位置
		 */
		private function _addTrailByNextPosition(position:Vector3):void {
			switch (_owner.renderMode) {
			case TrailFilter.RENDERMODE_TRAJECTORYBILLBOARD: 
				Vector3.subtract(position, _lastFixedVertexPosition, _delVector3);
				break;
			case TrailFilter.RENDERMODE_SPRITEFORWADBILLBOARD:
				_owner._owner.transform.forward.cloneTo(_delVector3);
				break;
			}
			Vector3.cross(_delVector3, _camera.transform.forward, _pointAtoBVector3);
			Vector3.normalize(_pointAtoBVector3, _pointAtoBVector3);
			
			Vector3.scale(_pointAtoBVector3, _owner.widthMultiplier / 2, _pointAtoBVector3);
			
			_delLength = Vector3.scalarLength(_delVector3);
			
			//位置差值 大于等于 最小顶点间距
			if (_delLength - _owner.minVertexDistance >= MathUtils3D.zeroTolerance) {
				
				_owner._trailTotalLength += _delLength;
				_owner._trailSupplementLength = 0;
				_updateVerticesByPosition(position);
				
				position.cloneTo(_lastFixedVertexPosition);
				_verticesCount += 2;
				_virtualVerticesCount = 0;
				_everyGroupVertexBirthTime.push(_owner._curtime);
				
				//满足TrailRenderElement完成条件
				if (_verticesCount == _maxVerticesCount) {
					_onTrailRenderElementFinish();
				}
			} 
			//位置差值 小于 最小顶点间距
			else {
				
				_owner._trailSupplementLength = _delLength;
				_updateVerticesByPosition(position);
				_virtualVerticesCount = 2;
			}
		}
		
		/**
		 * @private
		 * 通过位置更新顶点数据
		 * @param	position 位置
		 */
		private function _updateVerticesByPosition(position:Vector3):void {
			
			_pointe = position.elements;
			_pointAtoBVector3e = _pointAtoBVector3.elements;
			_curtime = _owner._curtime;
			
			if (_owner._hasLifeSubTrail && _isStart == false) {
				_pointe = _owner._curSubTrailFinishPosition.elements;
				_pointAtoBVector3e = _owner._curSubTrailFinishDirection.elements;
				_curtime = _owner._curSubTrailFinishCurTime;
			}
			
			_vertices1[_verticesIndex1 + _everyAddVerticeCount1++] = _pointe[0];
			_vertices1[_verticesIndex1 + _everyAddVerticeCount1++] = _pointe[1];
			_vertices1[_verticesIndex1 + _everyAddVerticeCount1++] = _pointe[2];
			_vertices1[_verticesIndex1 + _everyAddVerticeCount1++] = -_pointAtoBVector3e[0];
			_vertices1[_verticesIndex1 + _everyAddVerticeCount1++] = -_pointAtoBVector3e[1];
			_vertices1[_verticesIndex1 + _everyAddVerticeCount1++] = -_pointAtoBVector3e[2];
			_vertices1[_verticesIndex1 + _everyAddVerticeCount1++] = _curtime;
			_vertices1[_verticesIndex1 + _everyAddVerticeCount1++] = 1.0;
			
			_vertices1[_verticesIndex1 + _everyAddVerticeCount1++] = _pointe[0];
			_vertices1[_verticesIndex1 + _everyAddVerticeCount1++] = _pointe[1];
			_vertices1[_verticesIndex1 + _everyAddVerticeCount1++] = _pointe[2];
			_vertices1[_verticesIndex1 + _everyAddVerticeCount1++] = _pointAtoBVector3e[0];
			_vertices1[_verticesIndex1 + _everyAddVerticeCount1++] = _pointAtoBVector3e[1];
			_vertices1[_verticesIndex1 + _everyAddVerticeCount1++] = _pointAtoBVector3e[2];
			_vertices1[_verticesIndex1 + _everyAddVerticeCount1++] = _curtime;
			_vertices1[_verticesIndex1 + _everyAddVerticeCount1++] = 0.0;
			
			_VerticesToTailLength[_verticesCount / 2] = _owner._trailTotalLength + _owner._trailSupplementLength;
			
			if (_owner._trailSupplementLength == 0) {
				_everyVertexToPreVertexDistance[_verticesCount / 2] = _delLength;
			} else {
				_everyVertexToPreVertexDistance[_verticesCount / 2] = _isStart ? _owner._trailSupplementLength : 0;
			}
		}
		
		/**
		 * 更新VertexBuffer2数据
		 */
		public function _updateVertexBuffer2():void {
			
			var _uvIndex:int = 0;
			var _uvX:Number = 0.0;
			
			var i:int, j:int;
			for (i = 0, j = (_verticesCount + _virtualVerticesCount) / 2; i < j; i++) {
				if (_owner.textureMode == TextureMode.Stretch) {
					_uvX = (_VerticesToTailLength[i] - _owner._trailDeadLength) / (_owner._trailTotalLength + _owner._trailSupplementLength - _owner._trailDeadLength);
				} else {
					_uvX = _owner._trailTotalLength + _owner._trailSupplementLength - _VerticesToTailLength[i];
				}
				_vertices2[_uvIndex++] = 1.0 - _uvX;
				_vertices2[_uvIndex++] = 1.0 - _uvX;
			}
			_vertexBuffer2.setData(_vertices2, 0, 0, _verticesCount + _virtualVerticesCount);
		}
		
		/**
		 * trailRenderElement完成时调用
		 * @param	finishedPosition
		 */
		private function _onTrailRenderElementFinish():void {
			
			_lastFixedVertexPosition.cloneTo(_owner._curSubTrailFinishPosition);
			_pointAtoBVector3.cloneTo(_owner._curSubTrailFinishDirection);
			_owner._curSubTrailFinishCurTime = _owner._curtime;
			_isFinish = true;
		}
		
		/**
		 * @private
		 */
		public function _updateDisappear():void {
			
			var i:int, j:int;
			for (i = _curDisappearIndex, j = (_verticesCount + _virtualVerticesCount) / 2; i < j; i++) {
				if (_owner._curtime - _everyGroupVertexBirthTime[i] >= _owner.time + MathUtils3D.zeroTolerance) {
					_curDisappearIndex++;
					//增加拖尾消失长度
					_owner._trailDeadLength += _everyVertexToPreVertexDistance[_curDisappearIndex];
					if (_curDisappearIndex >= (_verticesCount + _virtualVerticesCount) / 2) {
						if(_verticesCount < _maxVerticesCount)
						continue;
						_isDead = true;
					}
				}
			}
		}
		
		/**
		 * 渲染前调用
		 * @param	state 渲染状态
		 * @return  是否渲染
		 */
		override public function _prepareRender(state:RenderContext3D):Boolean {
			_camera = state.camera;
			if (_camera == null)
				return false;
			
			_owner._owner.transform.position.cloneTo(_curPosition);
			
			if (!_isDead) {
				if (_verticesCount < _maxVerticesCount) {
					
					if (!_owner._isStart) {
						_owner._owner.transform.position.cloneTo(_lastPosition);
						_owner._isStart = true;
					}
					
					if (!Vector3.equals(_lastPosition, _curPosition)) {
						_updateTrail();
					}
				} else {
					if (_isFinish) {
						_isFinish = false;
						_owner._curSubTrailFinished = true;
					}
				}
				
				if (_verticesCount > 0) {
					_updateVertexBuffer2();
					_updateDisappear();
					return true;
				}
			}
			return false;
		}
		
		/**
		 * 渲染时调用
		 * @param	state 渲染状态
		 */
		override public function _render(state:RenderContext3D):void {
			if (_isDead)
				return;
			LayaGL.instance.drawArrays(WebGLContext.TRIANGLE_STRIP, _curDisappearIndex * 2, _verticesCount + _virtualVerticesCount - _curDisappearIndex * 2);
			Stat.drawCall++;
			Stat.trianglesFaces += (_verticesCount + _virtualVerticesCount - _curDisappearIndex * 2 - 2);
		}
		
		/**
		 * 重新激活该renderElement
		 */
		public function reActivate():void {
			
			_id = TrailRenderElement.renderElementCount++;
			_isStart = false;
			_isFinish = false;
			_isDead = false;
			_verticesCount = 0;
			_virtualVerticesCount = 0;
			_verticesIndex1 = 0;
			_delLength = 0;
			_curDisappearIndex = 0;
			_everyGroupVertexBirthTime = new Vector.<Number>();
			_owner._curSubTrailFinishPosition.cloneTo(_lastPosition);
		
		}
		
		/**
		 * @private
		 */
		public function _destroy():void {
			_vertexBuffer1.destroy();
			_vertexBuffer2.destroy();
			
			_vertices1 = null;
			_vertexBuffer1 = null;
			_vertices2 = null;
			_vertexBuffer2 = null;
			_everyGroupVertexBirthTime = null;
			_VerticesToTailLength = null;
			_everyVertexToPreVertexDistance = null;
			
			_lastPosition = null;
			_curPosition = null;
			_delVector3 = null;
			_lastFixedVertexPosition = null;
			_pointAtoBVector3 = null;
			_pointe = null;
			_pointAtoBVector3e = null;
			_pointA = null;
			_pointB = null;
		}
	
	}
}