using UnityEditor;
using UnityEngine;
using System;
using System.Collections.Generic;

[Serializable]
public class ChapterAtrrubite : ScriptableObject {
	public int rows = 0;
	public int columns = 0;

	public float tileWidth = 0.0f;
	public float tileHeight = 0.0f;

	public bool showGizmo = true;

	public float getColumn(float x) {
		return x / tileWidth;
	}
	public float getRow(float y) {
		return y / tileHeight;
	}
}