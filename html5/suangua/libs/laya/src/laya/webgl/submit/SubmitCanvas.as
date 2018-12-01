package laya.webgl.submit {
	import laya.maths.Matrix;
	import laya.webgl.canvas.WebGLContext2D;
	import laya.webgl.shader.d2.ShaderDefines2D;
	import laya.webgl.shader.d2.value.Value2D;
	import laya.webgl.utils.CONST3D2D;
	import laya.webgl.utils.Mesh2D;
	import laya.webgl.utils.RenderState2D;
	
	public class SubmitCanvas extends Submit {
		
		/*[DISABLE-ADD-VARIABLE-DEFAULT-VALUE]*/
		public static function create(ctx_src:WebGLContext2D, alpha:Number, filters:Array):SubmitCanvas {
			var o:SubmitCanvas = (!POOL._length) ? (new SubmitCanvas()) : POOL[--POOL._length];
			o._ctx_src = ctx_src;
			o._ref = 1;
			o._numEle = 0;
			var v:Value2D = o.shaderValue;
			v.alpha = alpha;			
			v.defines.setValue(0);
			filters && filters.length && v.setFilters(filters);
			return o;
		}
		
		public var _matrix:Matrix = new Matrix();
		public var _ctx_src:WebGLContext2D;
		public var _matrix4:Array = CONST3D2D.defaultMatrix4.concat();
		
		public function SubmitCanvas() {
			super(Submit.TYPE_2D);
			shaderValue = new Value2D(0, 0);
		}
		
		public override function renderSubmit():int {
			//�������RenderTarget
			if (_ctx_src._targets) {
				alert('nimei');
				debugger;
				//_ctx_src._targets.flush(_ctx_src);
				return 1;
			}
			//�������ֱ�������
			var preAlpha:Number = RenderState2D.worldAlpha;
			var preMatrix4:Array = RenderState2D.worldMatrix4;
			var preMatrix:Matrix = RenderState2D.worldMatrix;
			
			var preFilters:Array = RenderState2D.worldFilters;
			var preWorldShaderDefines:ShaderDefines2D = RenderState2D.worldShaderDefines;
			
			var v:Value2D = this.shaderValue;
			var m:Matrix = this._matrix;
			var m4:Array = _matrix4;
			var mout:Matrix = Matrix.TEMP;
			Matrix.mul(m, preMatrix, mout);
			m4[0] = mout.a;
			m4[1] = mout.b;
			m4[4] = mout.c;
			m4[5] = mout.d;
			m4[12] = mout.tx;
			m4[13] = mout.ty;
			
			RenderState2D.worldMatrix = mout.clone();
			RenderState2D.worldMatrix4 = m4;
			RenderState2D.worldAlpha = RenderState2D.worldAlpha * v.alpha;
			if (v.filters && v.filters.length) {
				RenderState2D.worldFilters = v.filters;
				RenderState2D.worldShaderDefines = v.defines;
			}
			
			_ctx_src.flush();
			
			RenderState2D.worldAlpha = preAlpha;
			RenderState2D.worldMatrix4 = preMatrix4;
			RenderState2D.worldMatrix.destroy();
			RenderState2D.worldMatrix = preMatrix;
			
			RenderState2D.worldFilters = preFilters;
			RenderState2D.worldShaderDefines = preWorldShaderDefines;
			
			return 1;
		}
		
		public override function releaseRender():void {
			if( (--this._ref) <1)
			{
				var cache:Array = POOL;
				this._ctx_src = null;
				//_vb = null;
				_mesh = null;
				cache[cache._length++] = this;
			}
		}
		
		//TODO:coverage
		public override function clone(context:WebGLContext2D,mesh:Mesh2D,pos:int):ISubmit
		{
			return null;
		}
		
		//TODO:coverage
		public override function getRenderType():int {
			return Submit.TYPE_CANVAS;
		}
		
		private static var POOL:Array =/*[STATIC SAFE]*/ (POOL = [], POOL._length = 0, POOL);
	}

}