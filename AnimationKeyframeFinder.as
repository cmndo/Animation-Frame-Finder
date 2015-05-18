/*
	//for less consider these mixins
	.m-keyframes(@name; @arguments) {
		@-moz-keyframes @name {
			@arguments();
		}
		@-webkit-keyframes @name {
			@arguments();
		}
		@keyframes @name {
	        	@arguments();
	        }
	}
	
	.m-animation(@arguments) {
		-webkit-animation: @arguments;
		-moz-animation: @arguments;
		animation: @arguments;
	}

*/
package {
	
	import flash.utils.*;
	
	public class AnimationKeyframeFinder {
		
		private var animations:Object = {};
		private var _this = undefined;
		private var _precompiler = undefined;
		
		/*
			constructor
		*/
		public function AnimationKeyframeFinder(timeline, precompiler:String = "scss") {
			_this = timeline;
			_precompiler = precompiler;
		}
		
		/*
			private functions
		*/
		private function frameToTime(num) {
			return ((((num / _this.stage.frameRate)*100))/100)
		}
		
		/*
			find the percentage between the first and last frame where the current "index" is
			or if there are only 2 frames - use "from" and "to" instead of "0%" and "100%"
		*/
		private function frameToPerc(frames, index) {
			if(frames.length == 2){
				if(index == 0){
					return "from";
				}else{
					return "to";
				}
			}else{
				
				return 	(((frames[index].num - frames[0].num) / (frames[frames.length - 1].num - frames[0].num)) * 100) + "%"
			}
			return 1337;
		}
		
		/*
			public functions
		*/	
		public function add(keyframeName:String, object:*, properties:*=undefined, ease:*=undefined):void{
			
			//Establish the namespace for this group.
			if(animations[keyframeName] == undefined){
				animations[keyframeName] = {
					delay: 0,
					frames: [],
					duration: 0
				};
			}
			
			//Store the properties from this frame
			var tmpKeyframe:Object = {
				num: _this.currentFrame,
				props: [],
				ease: ease
			};
			
			//build each line of css
			//replace ^ character in value with property if it matches
			for(var k in properties){
				if(properties[k].indexOf("^") === -1){
					tmpKeyframe.props.push(properties[k] +";\n");
				}else{
					tmpKeyframe.props.push(properties[k].replace("^" , object[k]) +";\n");
				}
			}
			
			//push this tmpkeyframe into this animation's frames Array
			animations[keyframeName].frames.push(tmpKeyframe);
			
		}
		
		/*
			This object now does much more lifting
			.determine animation length
			.determine delay based on when the first frame appears
		*/
		public function report(keyframeName:String):void{
			
			if(animations[keyframeName].frames.length >= 2){
				var firstKeyFrame = animations[keyframeName].frames[0].num;
				var lastKeyFrame = animations[keyframeName].frames[animations[keyframeName].frames.length - 1].num;
				
				animations[keyframeName].duration = frameToTime(lastKeyFrame - firstKeyFrame);
				
				//delay is tricky cause we start at frame 1, but time starts with 0
				animations[keyframeName].delay = frameToTime(firstKeyFrame - 1);				
				
			}
			
			
			
			// Loop through added keyframes and compile the css properties we stored.		
			var reply;
			if(_precompiler == "scss"){
				reply = "@include keyframes("+keyframeName+"){\n" 
			}else if(_precompiler == "less"){
				reply = ".m-keyframes("+keyframeName+"; {\n"
			}
			
			for(var i in animations[keyframeName].frames){
				reply += "	" + frameToPerc(animations[keyframeName].frames, i) +" {\n";
				reply += "		" + animations[keyframeName].frames[i].props.join("		");			
				if(_precompiler == "scss"){
					reply += "		@include animation-timing-function(" + (animations[keyframeName].frames[i].ease || "linear") + ");\n";	
				}else if(_precompiler == "less"){
					reply += "		animation-timing-function: " + (animations[keyframeName].frames[i].ease || "linear") + ";\n";	
				}							
				reply += "	}\n";
			}
			
			if(_precompiler == "scss"){
				reply += "\n}";
			}else if(_precompiler == "less"){
				reply += "\n});";
			}
						
			trace(reply);
			
			
			//delay the output of these 10 milliseconds for each frame (for big animations).
			setTimeout(function(){
				var implement;
				
				if(_precompiler == "scss"){
					implement = ".animate-" + keyframeName + " {\n";
					implement += "	@include animation(" + keyframeName + " " + animations[keyframeName].duration + "s forwards);\n";
					implement += "	@include animation-delay(" + animations[keyframeName].delay + "s);\n"
					implement += "}";					
				}else if(_precompiler == "less"){
					implement = ".animate--" + keyframeName + " {\n";
					implement += "	.m-animation (" + keyframeName + " " + animations[keyframeName].duration + "s 1 "+animations[keyframeName].delay+"s);\n";
					implement += "}";
					
				}	   
				
				
			
				trace(implement);
				
			}, animations[keyframeName].frames.length * 10);
			
			//END and Profit!
		}
	}
}
