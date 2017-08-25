using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(ChapterLayer))]
public class ChapterLayerEditor : Editor {
	void OnEnable() {
	}
	public override void OnInspectorGUI() {
		EditorGUILayout.LabelField("Create Layer :");
		EditorGUILayout.BeginHorizontal();
		if (GUILayout.Button("Prev")) {
			//SerializedProperty go = so.FindProperty("self");
			//Debug.Log(go.objectReferenceValue);
		}

		if (GUILayout.Button("Next")) {

		}

		if (GUILayout.Button("Child")) {

		}
		EditorGUILayout.EndHorizontal();
		EditorGUILayout.Space();

		if (GUILayout.Button("Create Poly Sprite")) {
            ChapterLayer layer = target as ChapterLayer;
            GameObject go = layer.gameObject;

			GameObject ps = new GameObject();
			ps.name = GameObjectUtility.GetUniqueNameForSibling(go.transform, "PolySprite");
			ps.layer = LayerMask.NameToLayer(ChapterEditor.LOCK_LAYER);
			ps.AddComponent<ChapterPolySprite>();
			ps.transform.parent = go.transform;
		}
	}
}