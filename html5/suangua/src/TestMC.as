package {
	import laya.display.Scene;
	import laya.net.AtlasInfoManager;
	import laya.net.ResourceVersion;
	import laya.net.URL;
	import laya.utils.Handler;
	import laya.utils.Stat;
	import laya.utils.Utils;
	import laya.events.Event;
	import laya.net.HttpRequest;
	import ui.TestMCUI;
	import laya.display.Text;
	import laya.ui.TextArea;
	
	
	public class TestMC extends TestMCUI {
		/**设置单例的引用方式，方便其他类引用 */
		public static var instance:TestMC;

		public function TestMC() {
			
			TestMC.instance = this;
            this.t1.visible = false;
			this.t2.visible = false;
			
			this.suan.on(Event.CLICK,this,ok);
        }

		private function ok(e:Object):void{
			this.suan.visible = false;
			loadgua();
			
		}

		private var hr:HttpRequest = new HttpRequest();
		private function loadgua():void{
			
			//hr.once(Event.PROGRESS, this, onHttpRequestProgress);
			hr.once(Event.COMPLETE, this, showData);
			//hr.once(Event.ERROR, this, onHttpRequestError);
			hr.send("gua.txt", null, 'get', 'text');
		}
		
		private var gualist:Array = new Array();
		private function showData(e:Event):void{
			var data:String =hr.data;
			var t:Array = new Array();
			t = data.split("\r\n");
			
				for (var i:int = 0; i < 64*11;i+=11){
					var t1:Object = new Object();
						t1 = {
							"Title":t[i],
						"Type":t[i + 1],
						"Xiangyue":t[i + 2],
						"Intro":t[i + 3],
						"Career":t[i + 4],
						"Business":t[i + 5],
						"Fame":t[i+6],
						"Travel":t[i+7],
						"Marriage":t[i + 8],
						"Decision":t[i + 9]
					};
					
					
						gualist[t[i + 10]] = t1;
						
				}

			
			doSuan();
		}

		private function doSuan():void
		{
			var gua:String = OneGua();
			trace(gua);

			
			var temp:Object = gualist[gua];
			
			this.t1.visible = true;
			this.t2.visible = true;
		
			var t:String = temp["Title"];
			this.t1.text = t.split("（")[0]+"\n（"+t.split("（")[1].split("）")[0]+"）\n"+t.split("）")[1];
			this.t2.text = temp["Type"];
			
			
			var s1:String = temp["Xiangyue"]+"\n\n"+temp["Intro"]+"\n\n"+temp["Career"]+"\n\n"+temp["Business"]+"\n\n"+temp["Fame"]+"\n\n"+temp["Travel"]+"\n\n"+temp["Marriage"]+"\n\n"+temp["Decision"];
			var t3:TextArea = createTextAear(30,s1);
			
			var onemc:OneguaMC = new OneguaMC(gua);
			
			this.addChild(onemc);
			
			onemc.width = 100;
			onemc.height = 100;
				
		}

		private function OneGua():String
		{
			var a1:String = (Math.round(Math.random()*100)%2).toString();
			var a2:String = (Math.round(Math.random()*100)%2).toString();
			var a3:String = (Math.round(Math.random() * 100) % 2).toString();
			
			var b1:String = (Math.round(Math.random()*100)%2).toString();
			var b2:String = (Math.round(Math.random()*100)%2).toString();
			var b3:String = (Math.round(Math.random()*100)%2).toString();
			return a1+a2+a3+b1+b2+b3;
		}

		private function createTextAear(size,txt):TextArea {
        var _text:TextArea = new TextArea();
        _text.text = txt;
        _text.type = 'text';
        _text.editable = true;
        _text.width = 560;
        _text.height = 868;
        _text.x = 26;
        _text.y = 200;
        _text.zOrder = 10;
        _text.fontSize = size || 28;
        _text.color = '#ff0000';
        // _text.font = '';
        _text.bold = true;
      //  _text.bgColor = '#FFFFFF'
      //  _text.borderColor = '#000000';
        _text.wordWrap = true;
        _text.overflow = Laya.Text.SCROLL;
        Laya.stage.addChild(_text);
        _text.vScrollBarSkin = 'comp/vscroll.png';
        return _text;
    }
    }
}