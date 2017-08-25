using UnityEditor;
using UnityEngine;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

[InitializeOnLoad]
public class ChapterAssetModificationProcessor : UnityEditor.AssetModificationProcessor {
	static AssetDeleteResult OnWillDeleteAsset(string assetPath, RemoveAssetOptions option) {
		Debug.Log(111);
		Texture2D tex = AssetDatabase.LoadAssetAtPath<Texture2D>(assetPath);
		if (tex != null) {
			ChapterRoot cr = ChapterManager.currentChapterRoot;
			if (cr != null) {
				if (cr.textureMapping.getCount(assetPath) > 0) {
					return AssetDeleteResult.FailedDelete;
				}
			}
		}

		return AssetDeleteResult.DidNotDelete;
	}

	static AssetMoveResult OnWillMoveAsset(string oldPath, string newPath) {
		Texture2D tex = AssetDatabase.LoadAssetAtPath<Texture2D>(oldPath);
		if (tex != null) {
			ChapterRoot cr = ChapterManager.currentChapterRoot;
			if (cr != null) {
				cr.textureMapping.changeName(oldPath, newPath);
			}
		}

		return AssetMoveResult.DidNotMove;
	}
}