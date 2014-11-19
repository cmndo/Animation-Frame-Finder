package {
	
	public class AnimationKeyframeFinder {
		
		private var animations:Object = {};
		private var _this = undefined;
		
		public function AnimationKeyframeFinder(timeline) {
			// constructor code
			_this = timeline;
		}
		
		public function add(keyframeName:String, object:*, properties:*=undefined, ease:*=undefined):void{
			if(animations[keyframeName] == undefined){
				animations[keyframeName] = "";
			}
			
			if(_this.currentFrame == 1){
				this.animations[keyframeName] += "\n	0% {\n";
			}else{
				this.animations[keyframeName] += "\n	" + Math.round((_this.currentFrame / _this.totalFrames) * 100) + "% {\n";
			}
			
			for(var i:int = 0; i < properties.length; i++){
				if(properties[i] is String){
					this.animations[keyframeName] += "		" + properties[i] + ": " + object[properties[i]] +";\n"
				}else if(properties[i] is Object){
					for(var k in properties[i]){
						//k is the name of each object: "scaleX", "alpha"
						//properties[i][k] gives you the value of each object: "scale", "opacity"
						//object[k] gets the value of the Flash object: marker.scaleX, marker.alpha
						//scaleX doesn't mean anything in CSS, so we can supply a replacement for it.
						
						
						if(properties[i][k].indexOf("^") != -1){
	
							this.animations[keyframeName] += "		" + properties[i][k].replace("^" , object[k]) +";\n";
							
							
						}else{
							this.animations[keyframeName] += "		" + properties[i][k] + ": " + object[k] +";\n";
						}
					}
				}
				
			}
			if(ease == "out"){
				this.animations[keyframeName] += "		animation-timing-function: ease-out;\n"
			}else if(ease == "in"){
				this.animations[keyframeName] += "		animation-timing-function: ease-in;\n"
			}else{
				this.animations[keyframeName] += "		animation-timing-function: linear;\n"
			}
			this.animations[keyframeName] += "\n	}";
		}
		
		public function report(keyframeName:String):void{
			var reply = "@include keyframes("+keyframeName+"){"
			reply += this.animations[keyframeName];
			reply +="\n}";
			
			trace(reply);
		}

	}
	
	
	
}

