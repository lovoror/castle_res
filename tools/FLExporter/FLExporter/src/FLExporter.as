package {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import mx.utils.Base64Encoder;
	
	import adobe.utils.MMExecute;
	
	[SWF(width="100", height="100")]
	public class FLExporter extends Sprite {
		private var _running:Boolean;
		private var _tf:TextField;
		private var _loader:URLLoader;
		private var _code:String;
		private var _btn:Sprite;
		
		private var _map:Object = {};
		
		public function FLExporter() {
			_btn = new Sprite();
			_btn.graphics.beginFill(0xFF0000);
			_btn.graphics.drawRect(0, 0, 100, 100);
			this.addChild(_btn);
			
			_tf = new TextField();
			_tf.mouseEnabled = false;
			this.addChild(_tf);
			
			_running = false;
			_tf.text = "init";
			
			var bytes:ByteArray = new ByteArray();
			bytes.endian = Endian.LITTLE_ENDIAN;
			
			for (var i:int = 0; i < 256; i++) {
				var c:String = i.toString(16);
				if (c.length == 1) c = "0" + c;
				
				_map[i] = c;
			}
			
			for (var i:int = 0; i < 256; i++) {
				bytes.position = 0;
				bytes.writeByte(i);
				bytes.position = 0;
				var s:String = bytes.readUTFBytes(1);
				//if (s.length == 0) {
				trace(i, '"' + s + '"');
				//}
			}
			
			_loader = new URLLoader();
			_loader.dataFormat=URLLoaderDataFormat.TEXT;  
			_loader.addEventListener(Event.COMPLETE, _loadedHandler, false, 0, true);  
			_loader.load(new URLRequest("FlToCocos.jsfl"));
		}
		private function _loadedHandler(e:Event):void {
			_code = _loader.data;
			_loader.close();
			_loader.removeEventListener(Event.COMPLETE, _loadedHandler);
			_loader = null;
			
			_tf.text = "complete";
			
			
			// open the file with the default application
			//tempFile.openWithDefaultApplication();
			
			//ExternalInterface.call("alert",1);
			
			_btn.addEventListener(MouseEvent.CLICK, _clickHandler, false, 0, true);
		}
		private function _clickHandler(e:Event):void {
			if (!_running) {
				_running = true;
				_tf.text = "running";
				
				var data:String = MMExecute(_code + "encode();");
				
				if (data != "") {
					MMExecute(_code + 'writeBytes("' + XML(data).@path + '", "' + _convertBytesToString(_enocdeFL(XML(data))) + '");');
				}
				
				_running = false;
				_tf.text = "complete";
			}
		}
		private function _convertBytesToString(bytes:ByteArray):String {
			var c:String = "";
			bytes.position = 0;
			while (bytes.bytesAvailable > 0) {
				c += _map[bytes.readUnsignedByte()];
			}
			return c;
		}
		private function _enocdeFL(xml:XML):ByteArray {
			var stringPool:StringPool = new StringPool();
			
			var data:ByteArray = new ByteArray();
			data.endian = Endian.LITTLE_ENDIAN;
			data.writeByte(xml.@frameRate);
			
			var items:XMLList = xml.item;
			var numItems:int = items.length();
			
			data.writeShort(numItems);
			
			for (var i:int = i; i < numItems; i++) {
				var item:XML = items[i];
				var type:String = item.@type;
				
				data.writeShort(stringPool.writeString(item.@name));
				if (type == "bitmap") {
					data.writeByte(1);
				} else if (type == "movie clip") {
					data.writeByte(2);
				} else {
					data.writeByte(0);
				}
				
				if (type == "movie clip") {
					var timeline:XML = item.timeline[0];
					var layers:XMLList = timeline.layer;
					var numLayers:int = layers.length();
					
					data.writeShort(timeline.@frames);
					data.writeShort(numLayers);
					
					for (var j:int = 0; j < numLayers; j++) {
						var layer:XML = layers[j];
						
						data.writeShort(stringPool.writeString(layer.@name));
						data.writeShort(layer.@frames);
						
						var frames:XMLList = layer.frame;
						var numFrames:int = frames.length();
						
						data.writeShort(numFrames);
						
						for (var k:int = 0; k < numFrames; k++) {
							var frame:XML = frames[k];
							
							data.writeShort(frame.@index);
							
							var tween:String = frame.@tween;
							
							if (tween == "none") {
								data.writeByte(0);
							} else if (tween == "motion") {
								data.writeByte(1);
							} else if (tween == "shape") {
								data.writeByte(2);
							} else {
								data.writeByte(0);
							}
							
							var elements:XMLList = frame.element;
							var numElements:int = elements.length();
							
							data.writeShort(numElements);
							
							for (var m:int = 0; m < numElements; m++) {
								var element:XML = elements[m];
								
								data.writeShort(stringPool.writeString(element.@link));
								data.writeShort(stringPool.writeString(element.@name));
								data.writeFloat(element.@x);
								data.writeFloat(element.@y);
								data.writeFloat(element.@sx);
								data.writeFloat(element.@sy);
								data.writeFloat(element.@tx);
								data.writeFloat(element.@ty);
								data.writeFloat(element.@skewX);
								data.writeFloat(element.@skewY);
								
								var insType:String = element.@type;
								
								if (insType == "bitmap") {
									data.writeByte(1);
								} else if (insType == "symbol") {
									data.writeByte(2);
								} else {
									data.writeByte(0);
								}
								
								if (insType == "symbol") {
									var colorMode:String = element.@colorMode;
									
									if (colorMode == "none") {
										data.writeByte(0);
									} else if (colorMode == "brightness") {
										data.writeByte(1);
										
										data.writeByte(element.@r);
										data.writeByte(element.@g);
										data.writeByte(element.@b);
										data.writeByte(element.@a);
									} else if (colorMode == "tint") {
										data.writeByte(2);
										
										data.writeByte(element.@r);
										data.writeByte(element.@g);
										data.writeByte(element.@b);
										data.writeByte(element.@a);
									} else if (colorMode == "alpha") {
										data.writeByte(3);
										
										data.writeByte(element.@a);
									} else if (colorMode == "advanced") {
										data.writeByte(4);
										
										data.writeByte(element.@r);
										data.writeByte(element.@g);
										data.writeByte(element.@b);
										data.writeByte(element.@a);
									} else {
										data.writeByte(0);
									}
									
									var blendMode:String = element.@blendMode;
									if (blendMode == "normal") {
										data.writeByte(0);
									} else if (blendMode == "layer") {
										data.writeByte(1);
									} else if (blendMode == "multiply") {
										data.writeByte(2);
									} else if (blendMode == "screen") {
										data.writeByte(3);
									} else if (blendMode == "overlay") {
										data.writeByte(4);
									} else if (blendMode == "hardlight") {
										data.writeByte(5);
									} else if (blendMode == "lighten") {
										data.writeByte(6);
									} else if (blendMode == "darken") {
										data.writeByte(7);
									} else if (blendMode == "difference") {
										data.writeByte(8);
									} else if (blendMode == "add") {
										data.writeByte(9);
									} else if (blendMode == "subtract") {
										data.writeByte(10);
									} else if (blendMode == "invert") {
										data.writeByte(11);
									} else if (blendMode == "alpha") {
										data.writeByte(12);
									} else if (blendMode == "erase") {
										data.writeByte(13);
									} else {
										data.writeByte(0);
									}
								}
							}
						}
					}
				}
			}
			
			var op:ByteArray = new ByteArray();
			op.endian = Endian.LITTLE_ENDIAN;
			op.writeShort(2);
			op.writeShort(stringPool.getNum());
			op.writeBytes(stringPool.getBytes());
			op.writeBytes(data);
			
			return op;
		}
	}
}