package laya.d3.shader {
	import laya.webgl.WebGL;
	import laya.webgl.utils.ShaderCompile;
	
	/**
	 * <code>ShaderPass</code> 类用于实现ShaderPass。
	 */
	public class ShaderPass extends ShaderCompile {
		/**@private */
		private var _owner:Shader3D;
		/**@private */
		private var _cacheSharders:Array;
		/**@private */
		private var _publicValidDefine:int;
		/**@private */
		private var _spriteValidDefine:int;
		/**@private */
		private var _materialValidDefine:int;
		/**@private */
		private var _validDefineMap:Object;
		
		public function ShaderPass(owner:Shader3D, vs:String, ps:String) {
			/*[DISABLE-ADD-VARIABLE-DEFAULT-VALUE]*/
			_owner = owner;
			_cacheSharders = [];
			_publicValidDefine = 0;
			_spriteValidDefine = 0;
			_materialValidDefine = 0;
			_validDefineMap = {};
			super(vs, ps, null, _validDefineMap);
			var publicDefineMap:Object = owner._publicDefinesMap;
			var spriteDefineMap:Object = owner._spriteDefinesMap;
			var materialDefineMap:Object = owner._materialDefinesMap;
			for (var k:String in _validDefineMap) {
				if (publicDefineMap[k] != null)
					_publicValidDefine |= publicDefineMap[k];
				else if (spriteDefineMap[k] != null)
					_spriteValidDefine |= spriteDefineMap[k];
				else if (materialDefineMap[k] != null)
					_materialValidDefine |= materialDefineMap[k];
			}
		}
		
		/**
		 * @private
		 */
		private function _definesToNameDic(value:int, int2Name:Array):Object {
			var o:Object = {};
			var d:int = 1;
			for (var i:int = 0; i < 32; i++) {
				d = 1 << i;
				if (d > value) break;
				if (value & d) {
					var name:String = int2Name[d];
					o[name] = "";
				}
			}
			return o;
		}
		
		/**
		 * @private
		 */
		public function withCompile(publicDefine:int, spriteDefine:int, materialDefine:int):ShaderInstance {
			publicDefine &= _publicValidDefine;
			spriteDefine &= _spriteValidDefine;
			materialDefine &= _materialValidDefine;
			var shader:ShaderInstance;
			var spriteDefShaders:Array, materialDefShaders:Array;
			
			spriteDefShaders = _cacheSharders[publicDefine];
			if (spriteDefShaders) {
				materialDefShaders = spriteDefShaders[spriteDefine];
				if (materialDefShaders) {
					shader = materialDefShaders[materialDefine];
					if (shader)
						return shader;
				} else {
					materialDefShaders = spriteDefShaders[spriteDefine] = [];
				}
			} else {
				spriteDefShaders = _cacheSharders[publicDefine] = [];
				materialDefShaders = spriteDefShaders[spriteDefine] = [];
			}
			
			var publicDefGroup:Object = _definesToNameDic(publicDefine, _owner._publicDefines);
			var spriteDefGroup:Object = _definesToNameDic(spriteDefine, _owner._spriteDefines);
			var materialDefGroup:Object = _definesToNameDic(materialDefine, _owner._materialDefines);
			var key:String;
			if (Shader3D.debugMode) {
				var publicDefGroupStr:String = "";
				for (key in publicDefGroup)
					publicDefGroupStr += key + " ";
				
				var spriteDefGroupStr:String = "";
				for (key in spriteDefGroup)
					spriteDefGroupStr += key + " ";
				
				var materialDefGroupStr:String = "";
				for (key in materialDefGroup)
					materialDefGroupStr += key + " ";
					
				if (!WebGL.shaderHighPrecision)
					publicDefine+= Shader3D.SHADERDEFINE_HIGHPRECISION;//输出宏定义要保持设备无关性
					
				console.log("%cShader3DDebugMode---(Name:" + _owner._name + " PassIndex:" + _owner._passes.indexOf(this) + " PublicDefine:" + publicDefine + " SpriteDefine:" + spriteDefine + " MaterialDefine:" + materialDefine + " PublicDefineGroup:" + publicDefGroupStr + " SpriteDefineGroup:" + spriteDefGroupStr + "MaterialDefineGroup: " + materialDefGroupStr + ")---ShaderCompile3DDebugMode","color:green");
			}
			
			var defMap:* = {};
			var defineStr:String = "";
			if (publicDefGroup) {
				for (key in publicDefGroup) {
					defineStr += "#define " + key + "\n";
					defMap[key] = true;
				}
			}
			
			if (spriteDefGroup) {
				for (key in spriteDefGroup) {
					defineStr += "#define " + key + "\n";
					defMap[key] = true;
				}
			}
			
			if (materialDefGroup) {
				for (key in materialDefGroup) {
					defineStr += "#define " + key + "\n";
					defMap[key] = true;
				}
			}
			
			var vs:Array = _VS.toscript(defMap, []);
			var vsVersion:String = '';
			if (vs[0].indexOf('#version') == 0) {
				vsVersion = vs[0] + '\n';
				vs.shift();
			}
			
			var ps:Array = _PS.toscript(defMap, []);
			var psVersion:String = '';
			if (ps[0].indexOf('#version') == 0) {
				psVersion = ps[0] + '\n';
				ps.shift();
			}
			shader = new ShaderInstance(vsVersion + defineStr + vs.join('\n'), psVersion + defineStr + ps.join('\n'), _owner._attributeMap, _owner._uniformMap);
			
			materialDefShaders[materialDefine] = shader;
			return shader;
		}
	
	}

}