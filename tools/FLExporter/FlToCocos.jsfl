function convertColorValue(c) {
	return parseInt(255 * c / 100.0); 
}

function encode() {
	var doc = fl.getDocumentDOM();
	var items = doc.library.items;

	fl.outputPanel.clear();

	var folderURI = fl.browseForFolderURL("Select a folder"); 
	fl.trace(folderURI);
	
	var opData = "<root";
	opData += " frameRate=\"" + doc.frameRate + "\"";
	opData += " path=\"" + folderURI + "\"";
	opData += ">";

	for(var i in items) {
		var item = items[i];
		var type = item.itemType;
		
		if (type == "graphic") {
			type = "movie clip";
		}
		
		if (type == "movie clip") {
			opData += "\n <item name=\"" + item.name + "\" type=\"" + type + "\">";
			
			var timeline = item.timeline;
			
			var layers = timeline.layers;
			
			//fl.trace("[Movie Clip Name] : " + item.name);
			
			var numLayers = timeline.layerCount;
			var numFrames = timeline.frameCount;
			
			opData += "\n  <timeline frames=\"" + numFrames + "\">";
			
			var idAccumulator = 1;
			
			fl.trace("[Library Item] : " + item.name);
			//fl.trace("[Movie Clip Frames] : " + numFrames);
			//fl.trace("[Movie Clip Layers] : " + numLayers);
			for (var j = numLayers - 1; j >= 0; j--) {
				var layer = layers[j];
				if (!layer.visible) continue;
				//fl.trace("[Layer Name] : " + layer.name);
				
				var frames = layer.frames;
				var numFrames = frames.length;
				
				opData += "\n   <layer name=\"" + layer.name + "\" frames=\"" + numFrames + "\">";
				
				//var objs = {};
				
				fl.trace("New Layer==================================  " + layer.name + "\n");
				
				for (var k = 0; k < numFrames; k++) {
					var frame = frames[k];
					
					var tweenType = frame.tweenType;
					
					if (tweenType == "none") {
						
					} else if (tweenType == "motion") {
						//fl.trace("++++++++++++++++  " + frame.tweenInstanceName);
					}
					
					var elements = frame.elements;
					var numElemetns = elements.length;
					
					var isKeyFrame = frame.startFrame == k;
					//fl.trace("[Is Key Frame] : " + isKeyFrame);
					
					if (isKeyFrame) {
						opData += "\n    <frame";
						opData += " index=\"" + k + "\"";
						opData += " tween=\"" + tweenType + "\"";
						opData += ">";
					}
					
					if (isKeyFrame) {
						fl.trace("[Frame Tween Type] : " + tweenType);
						fl.trace("[Frame Elements] : " + numElemetns);
						fl.trace(frame.duration);
						
						for (var m = 0; m < numElemetns; m++) {
							var element = elements[m];
							
							var transPoint = element.getTransformationPoint();
							
							opData += "\n     <element";
							opData += " link=\"" + element.libraryItem.name + "\"";
							opData += " name=\"" + element.name + "\"";
							opData += " x=\"" + element.transformX + "\"";
							opData += " y=\"" + -element.transformY + "\"";
							opData += " sx=\"" + element.scaleX + "\"";
							opData += " sy=\"" + element.scaleY + "\"";
							opData += " tx=\"" + -transPoint.x + "\"";
							opData += " ty=\"" + transPoint.y + "\"";
							opData += " skewX=\"" + element.skewX + "\"";
							opData += " skewY=\"" + element.skewY + "\"";
							
							//if (element.id1 == undefined) {
							//	fl.trace("////////////////");
							//	element.id1 = idAccumulator++;
							//}
							
							//if (objs[element] == null) {
							//	objs[element] = true;
							//	fl.trace("New Element +++++++++++++");
							//} else {
							//	fl.trace("Always Element ------------");
							//}
							//fl.trace("Element Depth ===============" + element.index);
							
							var instanceType = element.instanceType;
							
							opData += " type=\"" + instanceType + "\"";
							
							if (instanceType == "bitmap") {
								
							} else if (instanceType == "symbol") {
								fl.trace("[Symbol Element] : " + element.symbolType);
								
								var colorMode = element.colorMode;
								
								opData += " colorMode=\"" + colorMode + "\"";
								
								opData += " blendMode=\"" + element.blendMode + "\"";
								opData += " r=\"" + convertColorValue(element.colorRedPercent) + "\"";
								opData += " g=\"" + convertColorValue(element.colorGreenPercent) + "\"";
								opData += " b=\"" + convertColorValue(element.colorBluePercent) + "\"";
								opData += " a=\"" + convertColorValue(element.colorAlphaPercent) + "\"";
								if (colorMode == "alpha") {
									//opData += " cap=\"" + element.colorAlphaPercent + "\"";
								}
							}
							
							fl.trace("[Element Library Name] : " + element.libraryItem.name);
							fl.trace("[Element Type] : " + instanceType);
							
							opData += ">";
							opData += "\n     </element>";
						}
						
						fl.trace("");
					}
					
					if (isKeyFrame) {
						opData += "\n    </frame>";
					}
				}
				
				opData += "\n   </layer>";
				
				//fl.trace("");
			}
			
			opData += "\n  </timeline>";
			opData += "\n </item>";
		} else if (type == "bitmap") {
			opData += "\n <item name=\"" + item.name + "\" type=\"" + type + "\">";
			opData += "\n </item>";
			
			if (folderURI != null) {
				item.exportToFile(folderURI + "/" + item.name + ".png", 100);
			}
		}
	}

	opData += "\n</root>";

	//if (folderURI != null) {
		//FLfile.write(folderURI + "/model.fl", opData);
	//}

	fl.trace("");

	fl.trace(opData);
	
	if (folderURI == null) {
		opData = "";
	}
	
	fl.trace(FLfile.uriToPlatformPath(folderURI + "//model.fl"));
	
	return opData;
}

function writeBytes(path, data) {
	//path = "file:///C|/Users/Sephiroth/Desktop/aaaaaa/zzz";
	//data = "01001e1a006163745f626173655f656e640200006163745f626173655f69646c650200006163745f626173655f706572736973740200006163745f626173655f73746172740200006163745f666972655f656e640200006163745f666972655f706572736973740200006163745f666972655f737461727402000053796d626f6c203102000053796d626f6c203202000053796d626f6c203402000053796d626f6c203502000053796d626f6c20355f3102000053796d626f6c203602000053796d626f6c20365f31020000e596b7e781ab5fe68c81e7bbad020000e596b7e781ab5fe695b4e4bd934d43020000e596b7e781ab5fe6adbbe4baa1020000e596b7e781ab5fe587bae7949f020000e5ba95e5baa7e9ab98e585890200004269746d61702031014269746d61702032014269746d61702034014269746d61702035014269746d6170203601e5ba95e5baa75f3101e5ba95e5baa7e9ab98e585895f3101";
	//path = "C:\Users\Sephiroth\Desktop\aaaaaa\aefwe啊\model.fl";
	path = FLfile.uriToPlatformPath(path + "/model.fl");
	//fl.trace(FLfile.uriToPlatformPath("file:///C|/Users/Sephiroth/Desktop/aaaaaa/zzz/model.fl"));
	
	var finalPath = "";
	for (var c in path) {
		finalPath += c;
		if (c == "\\") finalPath += "\\";
	}
	
	fl.trace(JSFLExt.writeBinary(path, data));
}