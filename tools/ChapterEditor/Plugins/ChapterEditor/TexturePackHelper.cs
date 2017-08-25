using UnityEditor;
using UnityEngine;
using System;

public class TexturePackHelper {
	private static Mesh _mesh = new Mesh();
	private static int[] _triangles = { 0, 1, 2, 0, 2, 3 };
	private static Vector2[] _uvs = { new Vector2(), new Vector2(0, 1), new Vector2(1, 1), new Vector2(1, 0) };
	private static Material _mat = new Material(Shader.Find("InternalTexturePack"));

	public static void pack(RenderTexture rt, Texture2D tex, Vector3[] vertices) {
		_mesh.vertices = vertices;
		_mesh.uv = _uvs;
		_mesh.triangles = _triangles;

		_mat.mainTexture = tex;
		_mat.SetPass(0);
		Graphics.DrawMeshNow(_mesh, Matrix4x4.identity);
	}
}