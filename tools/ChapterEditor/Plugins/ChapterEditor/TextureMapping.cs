using UnityEditor;
using UnityEngine;
using System;
using System.Collections.Generic;

[Serializable]
public class TextureMapping : ScriptableObject {
	private Dictionary<string, uint> _p2vMap = new Dictionary<string, uint>();
	private Dictionary<uint, string> _v2pMap = new Dictionary<uint, string>();
	private Dictionary<uint, int> _refCounter = new Dictionary<uint, int>();
	private uint _intIDAccumulator = 0;
	public string getPractical(uint id) {
		return _v2pMap.ContainsKey(id) ? _v2pMap[id] : "";
	}
	public uint getVirtual(string id) {
		return _p2vMap.ContainsKey(id) ? _p2vMap[id] : 0;
	}

	public uint addOrGet(string id) {
		if (_p2vMap.ContainsKey(id)) {
			return _p2vMap[id];
		} else {
			uint vid = ++_intIDAccumulator;
			_p2vMap.Add(id, vid);
			_v2pMap.Add(vid, id);
			_refCounter.Add(vid, 0);
			return vid;
		}
	}

	public int changeCount(uint id, int add) {
		if (_refCounter.ContainsKey(id)) {
			int c = _refCounter[id];
			c += add;
			_refCounter[id] = c;
			
			ChapterManager.updateProjectWindow = true;

			return c;
		} else {
			return -1;
		}
	}

	public int getCount(uint id) {
		if (_refCounter.ContainsKey(id)) {
			return _refCounter[id];
		} else {
			return 0;
		}
	}

	public int getCount(string id) {
		uint vid = getVirtual(id);
		if (_refCounter.ContainsKey(vid)) {
			return _refCounter[vid];
		} else {
			return 0;
		}
	}

	public uint changeName(string oldID, string newID) {
		if (_p2vMap.ContainsKey(oldID)) {
			uint vid = _p2vMap[oldID];
			_p2vMap.Remove(oldID);
			_p2vMap.Add(newID, vid);
			_v2pMap[vid] = newID;
			return vid;
		} else {
			return 0;
		}
	}
}