using UnityEditor;
using UnityEngine;
using System;
using System.Collections.Generic;

[ExecuteInEditMode]
public class ChapterRoot : ChapterDisplayObject {
	public ChapterAtrrubite chapterAttribute = null;
	public TextureMapping textureMapping = null;

	void Awake() {
		if (chapterAttribute == null) {
			chapterAttribute = ScriptableObject.CreateInstance<ChapterAtrrubite>();
			textureMapping = ScriptableObject.CreateInstance<TextureMapping>();
		}
	}

    public override void customRender() {
		if (chapterAttribute.showGizmo && chapterAttribute.rows > 0 && chapterAttribute.columns > 0) {
			Matrix4x4 defaultMatrix = Handles.matrix;
			Color defaultColor = Handles.color;

			float w = chapterAttribute.tileWidth * chapterAttribute.columns;
			float h = chapterAttribute.tileHeight * chapterAttribute.rows;

			Handles.matrix = this.gameObject.transform.localToWorldMatrix;
			Handles.color = Color.green;

			Vector3 beginPoint = new Vector3();
			Vector3 endPoint = new Vector3();

			beginPoint.x = 0.0f;
			for (int r = 0; r <= chapterAttribute.rows; r++) {
				beginPoint.y = -chapterAttribute.tileHeight * r;
				endPoint.x = w;
				endPoint.y = beginPoint.y;

				Handles.DrawLine(beginPoint, endPoint);
			}

			beginPoint.y = 0.0f;
			for (int c = 0; c <= chapterAttribute.columns; c++) {
				beginPoint.x = chapterAttribute.tileWidth * c;
				endPoint.x = beginPoint.x;
				endPoint.y = -h;

				Handles.DrawLine(beginPoint, endPoint);
			}

			Handles.color = defaultColor;
			Handles.matrix = defaultMatrix;
		}
	}
}
