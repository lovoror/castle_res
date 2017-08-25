using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(ChapterRoot))]
public class ChapterRootEditor : Editor {
	void OnEnable() {
	}
	public override void OnInspectorGUI() {
		if (GUILayout.Button("Create Layer")) {
            ChapterRoot root = target as ChapterRoot;
            GameObject go = root.gameObject;

			GameObject layer = new GameObject();
			layer.name = GameObjectUtility.GetUniqueNameForSibling(go.transform, "ChapterLayer");
			layer.layer = LayerMask.NameToLayer(ChapterEditor.LOCK_LAYER);
			layer.AddComponent<ChapterLayer>();
			layer.transform.parent = go.transform;
		}
	}
}