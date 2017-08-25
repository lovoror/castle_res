package {
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	public class StringPool {
		private var _bytes:ByteArray;
		private var _num:int;
		private var _map:Object;
		
		public function StringPool() {
			_bytes = new ByteArray();
			_bytes.endian = Endian.LITTLE_ENDIAN;
			
			_num = 0;
			_map = {};
		}
		public function getNum():int {
			return _num;
		}
		public function getBytes():ByteArray {
			return _bytes;
		}
		public function writeString(s:String):int {
			var value:* = _map[s];
			if (value == null) {
				_map[s] = _num;
				
				_bytes.writeUTFBytes(s);
				_bytes.writeByte(0);
				
				value = _num;
				_num++;
			}
			
			return value;
		}
	}
}