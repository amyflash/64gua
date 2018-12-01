package 
{
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author amyflash.com
	 */
	public class OneguaMC extends Sprite 
	{
		
		public function OneguaMC(s:String) 
		{
			super();
			addChild(createOneGua(s));
		
		}
		
		private function createOne(w:int,h:int):Sprite{
			var a:Sprite = new Sprite();
			a.graphics.beginFill(0x000000);
			a.graphics.drawRect(0, 0, w, h);
			a.graphics.endFill();
			return a;
		}
		
		private function createYao(n:String):Sprite
		{
			var mc:Sprite = new Sprite();
				if(n=="0"){
						var b1:Sprite = createOne(50,20);
						var b2:Sprite = createOne(50,20);
						b1.x =10;
						b1.y= 10;
						b2.x = b1.x+50+10;
						b2.y =10;
						mc.addChild(b1);
						mc.addChild(b2);
					}else if(n=="1"){
						var b3:Sprite = createOne(110,20);
						b3.x = 10;
						b3.y = 10;
						mc.addChild(b3);
					}
				return mc;
		}
		
		private function createOneGua(s:String):Sprite
		{
			var mc:Sprite = new Sprite();
			var a:Array = s.split("");
			for(var i:int=0;i<a.length;i++){
					var b:Sprite = createYao(a[i]);
					mc.addChild(b);
					b.y = i*30;
				}
			return mc;
		}
		
		public function clear():void{
			while (this.numChildren > 0) this.removeChildAt(0);
		}
		
	}

}