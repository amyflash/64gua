package laya.d3.core.pixelLine {
	import laya.d3.core.RenderableSprite3D;
	import laya.d3.core.Sprite3D;
	import laya.d3.core.material.BaseMaterial;
	import laya.d3.core.render.RenderElement;
	import laya.d3.math.Color;
	import laya.d3.math.Vector3;
	import laya.d3.math.Vector4;
	
	/**
	 * <code>PixelLineSprite3D</code> 类用于像素线渲染精灵。
	 */
	public class PixelLineSprite3D extends RenderableSprite3D {
		
		/** @private */
		private var _geometryFilter:PixelLineFilter;
		
		private var _pixelLineDatas:Vector.<PixelLineData>;
		
		private var _lineCount:int;
		
		/**
		 * 获取line过滤器。
		 * @return  line过滤器。
		 */
		public function get pxLineFilter():PixelLineFilter {
			return _geometryFilter as PixelLineFilter;
		}
		
		/**
		 * 获取line渲染器。
		 * @return  line渲染器。
		 */
		public function get pxLineRenderer():PixelLineRenderer {
			return _render as PixelLineRenderer;
		}
		
		/**
		 * 获取line数量
		 * @return  line数量。
		 */
		public function get lineCount():int 
		{
			return _lineCount;
		}
		
		/**
		 * 设置line数量
		 * @param	value  line数量。
		 */
		public function set lineCount(value:int):void 
		{
			_lineCount = value;
			if (_pixelLineDatas.length >= value){
				_pixelLineDatas.length = value;
			}
			else{
				for (var i:int = 0, j:int = value - _pixelLineDatas.length; i < j; i++ ){
					var _pixelLineData:PixelLineData = new PixelLineData();
					Vector3.ZERO.cloneTo(_pixelLineData.startPosition);
					Vector3.ZERO.cloneTo(_pixelLineData.endPosition);
					Color.WHITE.cloneTo(_pixelLineData.startColor);
					Color.WHITE.cloneTo(_pixelLineData.endColor);
					_pixelLineDatas.push(_pixelLineData);
				}
			}
			_geometryFilter._resetLineData();
		}
		
		/**
		 * 获取line数据
		 * @return  line数据。
		 */
		public function get pixelLineDatas():Vector.<PixelLineData> 
		{
			return _pixelLineDatas;
		}
		
		/**
		 * 更新线
		 * @param	index  		   索引
		 * @param	startPosition  初始点位置
		 * @param	endPosition	   结束点位置
		 * @param	startColor	   初始点颜色
		 * @param	endColor	   结束点颜色
		 */
		public function setLine(index:int, startPosition:Vector3, endPosition:Vector3, startColor:Color, endColor:Color):void {
			if (index < _pixelLineDatas.length) {
				var _pixelLineData:PixelLineData = _pixelLineDatas[index];
				startPosition.cloneTo(_pixelLineData.startPosition);
				endPosition.cloneTo(_pixelLineData.endPosition);
				startColor.cloneTo(_pixelLineData.startColor);
				endColor.cloneTo(_pixelLineData.endColor);
				
				_geometryFilter._updateLineData(index, startPosition, endPosition, startColor, endColor);
			}
		}
		
		/**
		 * 更新多条线
		 * @param	data   线数据
		 */
		public function setLines(data:Vector.<PixelLineData>):void {
			_pixelLineDatas.length = 0;
			var count:Number = data.length;
			for (var i:int = 0; i < count; i++ ){
				var _pixelLineData:PixelLineData = new PixelLineData();
				data[i].cloneTo(_pixelLineData);
				_pixelLineDatas.push(_pixelLineData);
			}
			lineCount = count;
		}
		
		/**
		 * @inheritDoc
		 */
		public function _changeRenderObjects(sender:PixelLineRenderer, index:int, material:BaseMaterial):void {
			var renderObjects:Vector.<RenderElement> = _render._renderElements;
			(material) || (material = PixelLineMaterial.defaultMaterial);
			var renderElement:RenderElement = renderObjects[index];
			(renderElement) || (renderElement = renderObjects[index] = new RenderElement());
			renderElement.setTransform(_transform);
			renderElement.setGeometry(_geometryFilter);
			renderElement.render = _render;
			renderElement.material = material;
		}
		
		
		
		/**
		 * 创建一个 <code>PixelLineSprite3D</code> 实例。
		 * @param count 需要绘制线段的数量。
		 * @param name 名字。
		 */
		public function PixelLineSprite3D(count:int = 2, name:String = null) {
			super(name);
			_lineCount = count;
			_pixelLineDatas = new Vector.<PixelLineData>();
			for (var i:int = 0; i < count; i++ ){
				var _pixelLineData:PixelLineData = new PixelLineData();
				Vector3.ZERO.cloneTo(_pixelLineData.startPosition);
				Vector3.ZERO.cloneTo(_pixelLineData.endPosition);
				Color.WHITE.cloneTo(_pixelLineData.startColor);
				Color.WHITE.cloneTo(_pixelLineData.endColor);
				_pixelLineDatas.push(_pixelLineData);
			}
			
			_geometryFilter = new PixelLineFilter(this);
			_render = new PixelLineRenderer(this);
			_changeRenderObjects(_render as PixelLineRenderer, 0, PixelLineMaterial.defaultMaterial);
			_geometryFilter._initLineData();
		}
	}
}