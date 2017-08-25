using UnityEditor;
using UnityEngine;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

[InitializeOnLoad]
public class ChapterAssetPostprocessor : AssetPostprocessor {
	void OnPreprocessTexture() {
		TextureImporter ti = assetImporter as TextureImporter;
		ti.spritePixelsPerUnit = 1.0f;
		ti.mipmapEnabled = false;
		ti.textureType = TextureImporterType.Sprite;
		ti.textureFormat = TextureImporterFormat.RGBA32;

		if (ChapterManager.currentChapterRoot != null && ChapterManager.currentChapterRoot.textureMapping.getCount(ti.assetPath) > 0) {
			_changeTex(ChapterManager.currentChapterRoot.gameObject, ti.assetPath);
		}
	}

	private void _changeTex(GameObject go, string path) {
		ChapterPolySprite cps = go.GetComponent<ChapterPolySprite>();
		if (cps != null && cps.getTexRefCount(path) > 0) {
			cps.updateTexAtlas();
		}

		foreach (Transform trans in go.transform) {
			_changeTex(trans.gameObject, path);
		}
	}

	//void OnPostprocessTexture(Texture2D texture) {
	//Debug.Log(assetPath);
	//}
}