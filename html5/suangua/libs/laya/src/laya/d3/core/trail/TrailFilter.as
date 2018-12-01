package laya.d3.core.trail {
	
	import laya.d3.core.FloatKeyframe;
	import laya.d3.core.GeometryElement;
	import laya.d3.core.Gradient;
	import laya.d3.core.render.RenderContext3D;
	import laya.d3.core.render.RenderElement;
	import laya.d3.core.scene.Scene3D;
	import laya.d3.core.GradientMode;
	import laya.d3.core.TextureMode;
	import laya.d3.core.FloatKeyframe;
	import laya.d3.math.Color;
	import laya.d3.math.Vector3;
	import laya.events.EventDispatcher;
	
	/**
	 * <code>TrailFilter</code> 类用于创建拖尾过滤器。
	 */
	public class TrailFilter extends EventDispatcher {
		/** 渲染模式_精灵运动轨迹广告牌模式。*/
		public static const RENDERMODE_TRAJECTORYBILLBOARD:int = 0;
		/** 渲染模式_精灵方向广告牌模式。*/
		public static const RENDERMODE_SPRITEFORWADBILLBOARD:int = 1;
		
		public var _owner:TrailSprite3D;
		private var _trailRenderElements:Vector.<TrailRenderElement>;
		
		private var _minVertexDistance:Number;
		private var _widthMultiplier:Number;
		private var _time:Number;
		private var _widthCurve:Vector.<FloatKeyframe>;
		private var _colorGradient:Gradient;
		private var _textureMode:int;
		
		public var _curtime:Number = 0;
		//记录当前拖尾完成时的最后一个位置position
		public var _curSubTrailFinishPosition:Vector3 = new Vector3();
		//记录当前拖尾完成时最后一个位置叉积计算出来的向量
		public var _curSubTrailFinishDirection:Vector3 = new Vector3();
		public var _curSubTrailFinishCurTime:Number = 0;
		//当前拖尾完成的标志
		public var _curSubTrailFinished:Boolean = false;
		public var _hasLifeSubTrail:Boolean = false;
		
		//拖尾总长度
		public var _trailTotalLength:Number = 0;
		//拖尾替补长度
		public var _trailSupplementLength:Number = 0;
		//拖尾死亡长度
		public var _trailDeadLength:Number = 0;
		
		public var _isStart:Boolean = false;
		private var _trailRenderElementIndex:int;
		
		/**渲染模式*/
		public var renderMode:int = 0;
		
		/**
		 * 获取淡出时间。
		 * @return  淡出时间。
		 */
		public function get time():Number {
			return _time;
		}
		
		/**
		 * 设置淡出时间。
		 * @param value 淡出时间。
		 */
		public function set time(value:Number):void {
			_time = value;
			_owner._render._shaderValues.setNumber(TrailSprite3D.LIFETIME, value);
		}
		
		/**
		 * 获取新旧顶点之间最小距离。
		 * @return  新旧顶点之间最小距离。
		 */
		public function get minVertexDistance():Number {
			return _minVertexDistance;
		}
		
		/**
		 * 设置新旧顶点之间最小距离。
		 * @param value 新旧顶点之间最小距离。
		 */
		public function set minVertexDistance(value:Number):void {
			_minVertexDistance = value;
		}
		
		/**
		 * 获取宽度倍数。
		 * @return  宽度倍数。
		 */
		public function get widthMultiplier():Number {
			return _widthMultiplier;
		}
		
		/**
		 * 设置宽度倍数。
		 * @param value 宽度倍数。
		 */
		public function set widthMultiplier(value:Number):void {
			_widthMultiplier = value;
		}
		
		/**
		 * 获取宽度曲线。
		 * @return  宽度曲线。
		 */
		public function get widthCurve():Vector.<FloatKeyframe> {
			return _widthCurve;
		}
		
		/**
		 * 设置宽度曲线。
		 * @param value 宽度曲线。
		 */
		public function set widthCurve(value:Vector.<FloatKeyframe>):void {
			_widthCurve = value;
			var widthCurveFloatArray:Float32Array = new Float32Array(value.length * 4);
			var i:int, j:int, index:int = 0;
			for (i = 0, j = value.length; i < j; i++) {
				widthCurveFloatArray[index++] = value[i].time;
				widthCurveFloatArray[index++] = value[i].inTangent;
				widthCurveFloatArray[index++] = value[i].outTangent;
				widthCurveFloatArray[index++] = value[i].value;
			}
			_owner._render._shaderValues.setBuffer(TrailSprite3D.WIDTHCURVE, widthCurveFloatArray);
			_owner._render._shaderValues.setInt(TrailSprite3D.WIDTHCURVEKEYLENGTH, value.length);
		}
		
		/**
		 * 获取颜色梯度。
		 * @return  颜色梯度。
		 */
		public function get colorGradient():Gradient {
			return _colorGradient;
		}
		
		/**
		 * 设置颜色梯度。
		 * @param value 颜色梯度。
		 */
		public function set colorGradient(value:Gradient):void {
			_colorGradient = value;
			_owner._render._shaderValues.setBuffer(TrailSprite3D.GRADIENTCOLORKEY, value._rgbElements);
			_owner._render._shaderValues.setBuffer(TrailSprite3D.GRADIENTALPHAKEY, value._alphaElements);
			if (value.mode == GradientMode.Blend) {
				_owner._render._defineDatas.add(TrailSprite3D.SHADERDEFINE_GRADIENTMODE_BLEND);
			} else {
				_owner._render._defineDatas.remove(TrailSprite3D.SHADERDEFINE_GRADIENTMODE_BLEND);
			}
		}
		
		/**
		 * 获取纹理模式。
		 * @return  纹理模式。
		 */
		public function get textureMode():int {
			return _textureMode;
		}
		
		/**
		 * 设置纹理模式。
		 * @param value 纹理模式。
		 */
		public function set textureMode(value:int):void {
			_textureMode = value;
		}
		
		public function TrailFilter(owner:TrailSprite3D) {
			
			_owner = owner;
			_initDefaultData();
			
			_trailRenderElements = new Vector.<TrailRenderElement>();
			
			addRenderElement();
		}
		
		/**
		 * @private
		 */
		private function _changeRenderElement(index:int):void {
			
			var render:TrailRenderer = _owner._render as TrailRenderer;
			var elements:Vector.<RenderElement> = render._renderElements;
			
			var renderElement:RenderElement = elements[index];
			if (renderElement) {
				renderElement.setGeometry(_trailRenderElements[index]);
			} else {
				var material:TrailMaterial = render.sharedMaterials[0] as TrailMaterial;
				(material) || (material = TrailMaterial.defaultMaterial);
				renderElement = elements[index] = new RenderElement();
				renderElement.setTransform(_owner._transform);
				renderElement.render = render;
				renderElement.material = material;
				renderElement.setGeometry(_trailRenderElements[index]);
			}
		}
		
		/**
		 * @private
		 */
		public function getRenderElementsCount():int {
			return _trailRenderElements.length;
		}
		
		/**
		 * @private
		 */
		public function addRenderElement():int {
			for (var i:int = 0; i < _trailRenderElements.length; i++) {
				if (_trailRenderElements[i]._isDead == true) {
					_trailRenderElements[i].reActivate();
					_changeRenderElement(i);
					return i;
				}
			}
			
			var _trailRenderElement:TrailRenderElement = new TrailRenderElement(this);
			_trailRenderElements.push(_trailRenderElement);
			_changeRenderElement(_trailRenderElements.length - 1);
			return _trailRenderElements.length - 1;
		}
		
		/**
		 * @private
		 */
		public function getRenderElement(index:int):GeometryElement {
			return _trailRenderElements[index];
		}
		
		/**
		 * @private
		 */
		public function _update(state:RenderContext3D):void {
			_curtime += (state.scene as Scene3D).timer._delta / 1000;
			_owner._render._shaderValues.setNumber(TrailSprite3D.CURTIME, _curtime);
			
			if (_curSubTrailFinished) {
				_curSubTrailFinished = false;
				addRenderElement();
			}
		}
		
		/**
		 * @private
		 */
		public function _initDefaultData():void {
			
			time = 5.0;
			minVertexDistance = 0.1;
			widthMultiplier = 1;
			textureMode = TextureMode.Stretch;
			
			var widthKeyFrames:Vector.<FloatKeyframe> = new Vector.<FloatKeyframe>();
			var widthKeyFrame1:FloatKeyframe = new FloatKeyframe();
			widthKeyFrame1.time = 0;
			widthKeyFrame1.inTangent = 0;
			widthKeyFrame1.outTangent = 0;
			widthKeyFrame1.value = 1;
			widthKeyFrames.push(widthKeyFrame1);
			var widthKeyFrame2:FloatKeyframe = new FloatKeyframe();
			widthKeyFrame2.time = 1;
			widthKeyFrame2.inTangent = 0;
			widthKeyFrame2.outTangent = 0;
			widthKeyFrame2.value = 1;
			widthKeyFrames.push(widthKeyFrame2);
			widthCurve = widthKeyFrames;
			
			var gradient:Gradient = new Gradient(2, 2);
			gradient.mode = GradientMode.Blend;
			gradient.addColorRGB(0, Color.WHITE);
			gradient.addColorRGB(1, Color.WHITE);
			gradient.addColorAlpha(0, 1);
			gradient.addColorAlpha(1, 1);
			colorGradient = gradient;
		}
		
		/**
		 * @private
		 */
		public function reset():void {
			
			for (var i:int = 0; i < _trailRenderElements.length; i++) {
				_trailRenderElements[i].reActivate();
			}
			_isStart = false;
			_hasLifeSubTrail = false;
			_curSubTrailFinished = false;
			_curSubTrailFinishCurTime = 0;
			_trailTotalLength = 0;
			_trailSupplementLength = 0;
			_trailDeadLength = 0;
		}
		
		/**
		 * @private
		 */
		public function destroy():void {
			for (var i:int = 0; i < _trailRenderElements.length; i++) {
				_trailRenderElements[i]._destroy();
			}
			_trailRenderElements = null;
			_widthCurve = null;
			_colorGradient = null;
			_curSubTrailFinishPosition = null;
			_curSubTrailFinishDirection = null;
		}
	}
}