package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author amyflash.com
	 */
	public class Main extends Sprite 
	{
		private var bagua:Object;
		public function Main() 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			ok();
		}
		
		private function ok():void{
			loadgua();
			
			/*bagua = {
				"111":"乾",
				"000":"坤",
				"101":"离",
				"010":"坎",
				"001":"震",
				"100":"艮",
				"110":"巽",
				"011":"兑"
			}*/
			
		
			
			
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
		
		private function loadgua():void{
			var url:String = "gua.txt"
			var u1:URLLoader = new URLLoader();
			var ur:URLRequest = new URLRequest(url);
			u1.load(ur);
			u1.addEventListener(Event.COMPLETE, showData);
		}
		
		private var gualist:Array = new Array();
		private function showData(e:Event):void{
			var data:String = e.currentTarget.data;
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
				
			var gua:String = OneGua();
			trace(JSON.stringify(gualist[gua]));
				
			}
		}
		
	}
	