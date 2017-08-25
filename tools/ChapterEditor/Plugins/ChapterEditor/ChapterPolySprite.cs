using UnityEditor;
using UnityEngine;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

[ExecuteInEditMode]
public class ChapterPolySprite : ChapterDisplayObject {
	public GameObject self;

	private RenderTexture _tex = null;
	private List<Vector3> _vertices = new List<Vector3>();
	private List<Vector2> _uvs = new List<Vector2>();
	private List<int> _triangles = new List<int>();
	private Mesh _mesh = null;
	//private List<int> _selection = new List<int>();
	private Dictionary<int, bool> _selection = new Dictionary<int, bool>();
	private Dictionary<uint, uint> _texMap = new Dictionary<uint, uint>();
	private Dictionary<uint, Vector2[]> _packedUVs = new Dictionary<uint, Vector2[]>();
	private List<QuadSprite> _sprites = new List<QuadSprite>();
	//private Vector2 _moveDir;
	//private Vector2 _moveStartScreenPos;
	//private Vector2 _moveLastScreenPos;
	private Bounds? _selectBounds = null;
	//private Vector2 _alignOffset;
	private bool _updateTexAtlas = false;

	public Material _mat = null;

	public Mesh getMesh() {
		return _mesh;
	}

	void Awake() {
		self = this.gameObject;

		_mesh = new Mesh();

		_tex = new RenderTexture(1, 1, 0);
		_tex.Create();

		//_tex = Texture2D.whiteTexture;

		_mat = new Material(Shader.Find("Sprites/Default"));
		//mat.mainTexture = Resources.Load<Texture2D>("ResourceImage/room01/room1_4_3");
		_mat.mainTexture = _tex;

		if (GetComponent<Collider>() == null) {
			self.AddComponent<MeshCollider>();
		}
	}

	public override void customRender() {
		if (_updateTexAtlas) {
			_updateTexAtlas = false;

			_packedUVs.Clear();
			List<TexturePacker.Rect> rects = new List<TexturePacker.Rect>();
			Dictionary<uint, Texture2D> texs = new Dictionary<uint, Texture2D>();
			foreach (uint id in _texMap.Keys) {
				string path = ChapterManager.currentChapterRoot.textureMapping.getPractical(id);
				Texture2D tex = AssetDatabase.LoadAssetAtPath<Texture2D>(path);
				texs.Add(id, tex);
				rects.Add(new TexturePacker.Rect(id.ToString(), tex.width, tex.height));
			}

			TexturePacker.Settings settings = new TexturePacker.Settings();
			settings.maxWidth = 2048;
			settings.maxHeight = 2048;
			settings.paddingX = 2;
			settings.paddingY = 2;
			settings.rotation = true;
			TexturePacker.MaxRectsPacker packer = new TexturePacker.MaxRectsPacker(settings);
			List<TexturePacker.Page> outputs = packer.pack(rects);

			if (outputs.Count == 1) {
				TexturePacker.Page page = outputs[0];
				if (_tex != null) {
					_tex.Release();
				}
				//Debug.Log("page=" + 0 + ", width=" + page.width + ", height=" + page.height + ", name=" + page.imageName + ", rects=" + page.outputRects.Count);
				int w = page.width > 0 ? page.width : 1;
				int h = page.height > 0 ? page.height : 1;
				//Debug.Log(w + "     " + h);
				_tex = new RenderTexture(w, h, 0);
				_tex.Create();
				_mat.mainTexture = _tex;

				Graphics.SetRenderTarget(_tex);

				Vector3[] vertices = new Vector3[4];

				foreach (TexturePacker.Rect rect in page.outputRects) {
					//Debug.Log("     rect : name=" + rect.name + ", x=" + rect.x + ", y=" + rect.y + ", offX=" + rect.offsetX + ", offY=" + rect.offsetX + ", width=" + rect.width + ", height=" + rect.height);
					Vector2[] uvs = new Vector2[4];

					float lu = rect.x / (float)w;
					float ru = lu + rect.width / (float)w;
					float tv = (h - rect.y) / (float)h;
					float bv = tv - rect.height / (float)h;

					float lx = lu * 2.0f - 1.0f;
					float rx = ru * 2.0f - 1.0f;
					float ty = 1.0f - tv * 2.0f;
					float by = 1.0f - bv * 2.0f;

					if (rect.rotated) {
						vertices[0].Set(lx, ty, 0);
						vertices[1].Set(rx, ty, 0);
						vertices[2].Set(rx, by, 0);
						vertices[3].Set(lx, by, 0);

						uvs[0].Set(lu, tv);
						uvs[1].Set(ru, tv);
						uvs[2].Set(ru, bv);
						uvs[3].Set(lu, bv);
					} else {
						vertices[0].Set(lx, by, 0);
						vertices[1].Set(lx, ty, 0);
						vertices[2].Set(rx, ty, 0);
						vertices[3].Set(rx, by, 0);

						uvs[0].Set(lu, bv);
						uvs[1].Set(lu, tv);
						uvs[2].Set(ru, tv);
						uvs[3].Set(ru, bv);
					}

					//Debug.Log("info : " + vertices[0] + vertices[1] + vertices[2] + vertices[3]);

					uint id = uint.Parse(rect.name);
					_packedUVs.Add(id, uvs);

					TexturePackHelper.pack(_tex, texs[id], vertices);
				}

				Graphics.SetRenderTarget(null);

				for (int i = 0; i < _sprites.Count; i++) {
					QuadSprite qs = _sprites[i];

					Vector2[] uv;
					if (_packedUVs.TryGetValue(qs.texID, out uv)) {
						int offset = i * 4;

						_uvs[offset] = uv[0];
						_uvs[offset + 1] = uv[1];
						_uvs[offset + 2] = uv[2];
						_uvs[offset + 3] = uv[3];
					}
				}

				_mesh.uv = _uvs.ToArray();
			}
		}

		if (!gameObject.activeInHierarchy) return;

		if (_sprites.Count > 0) {
			_mat.SetPass(0);
			Graphics.DrawMeshNow(_mesh, transform.localToWorldMatrix);

			if (_selection.Count > 0 && (!Selection.gameObjects.Contains(self) || this.loclState != LockState.UNLOCK)) {
                clearSelection();
			}

			if (_selection.Count > 0) {
				Matrix4x4 defaultMatrix = Handles.matrix;
				Color defaultColor = Handles.color;

				Handles.matrix = self.transform.localToWorldMatrix;
				Handles.color = Color.green;

				foreach (var item in _selection) {
					int offset = item.Key * 4;
					Vector3 lb = _vertices[offset];
					Vector3 lt = _vertices[offset + 1];
					Vector3 rt = _vertices[offset + 2];
					Vector3 rb = _vertices[offset + 3];
					Handles.DrawLine(lb, lt);
					Handles.DrawLine(lt, rt);
					Handles.DrawLine(rt, rb);
					Handles.DrawLine(rb, lb);
				}

				Handles.color = defaultColor;
				Handles.matrix = defaultMatrix;
			}
		}
	}

    public int numSelection {
        get {
            return _selection.Count;
        }
    }

    public Bounds? getSelectionBounds() {
        if (_selection.Count == 0 || _selectBounds == null) {
            return null;
        } else {
            Transform rootTrans = ChapterManager.currentChapterRoot.transform;

            Bounds b = _selectBounds.Value;
            Vector3 min = b.min;
            Vector3 max = b.max;
            Vector3 lb = min;
            Vector3 lt = new Vector3(min.x, max.y);
            Vector3 rt = max;
            Vector3 rb = new Vector3(max.x, min.y);

            lb = rootTrans.InverseTransformPoint(transform.TransformPoint(lb));
            lt = rootTrans.InverseTransformPoint(transform.TransformPoint(lt));
            rt = rootTrans.InverseTransformPoint(transform.TransformPoint(rt));
            rb = rootTrans.InverseTransformPoint(transform.TransformPoint(rb));

            b = new Bounds(lb, Vector3.zero);
            b.Encapsulate(lt);
            b.Encapsulate(rt);
            b.Encapsulate(rb);

            return b;
        }
    }

	/*
    void OnDrawGizmos()
    {
        if (_selection.Count > 0 && !Selection.gameObjects.Contains(self))
        {
            _selection.Clear();
        }

        if (_selection.Count > 0)
        {
            Matrix4x4 defaultMatrix = Gizmos.matrix;
            Color defaultColor = Gizmos.color;

            Gizmos.matrix = self.transform.localToWorldMatrix;
            Gizmos.color = Color.green;

            for (int i = 0; i < _selection.Count; i++)
            {
                int offset = _selection[i] * 4;
                Vector3 lb = _vertices[offset];
                Vector3 lt = _vertices[offset + 1];
                Vector3 rt = _vertices[offset + 2];
                Vector3 rb = _vertices[offset + 3];
                Gizmos.DrawLine(lb, lt);
                Gizmos.DrawLine(lt, rt);
                Gizmos.DrawLine(rt, rb);
                Gizmos.DrawLine(rb, lb);
            }

            Gizmos.color = defaultColor;
            Gizmos.matrix = defaultMatrix;
        }
    }
    */

	void OnDestroy() {
		TextureMapping texMapping = ChapterManager.currentChapterRoot.textureMapping;

		foreach (var qs in _sprites) {
			texMapping.changeCount(qs.texID, -1);
		}

		if (_tex != null) {
			_tex.Release();
			_tex = null;
		}
	}

    public uint getTexRefCount(string id) {
        TextureMapping texMapping = ChapterManager.currentChapterRoot.textureMapping;
        uint texID = texMapping.getVirtual(id);
        return _texMap.ContainsKey(texID) ? _texMap[texID] : 0;
    }

    public void updateTexAtlas() {
        _updateTexAtlas = true;
    }

    public bool getSelectionContains(int index) {
		return _selection.ContainsKey(index);
	}

	public void add(Vector3 pos, Texture2D tex) {
		string path = AssetDatabase.GetAssetPath(tex);
		TextureMapping texMapping = ChapterManager.currentChapterRoot.textureMapping;
		uint texID = texMapping.getVirtual(path);
		if (_texMap.ContainsKey(texID)) {
			_texMap[texID]++;
		} else {
			texID = texMapping.addOrGet(path);
			_texMap.Add(texID, 1);
			_updateTexAtlas = true;
		}

		texMapping.changeCount(texID, 1);

		int w = tex.width;
		int h = tex.height;
		float halfW = w * 0.5f;
		float halfH = h * 0.5f;
		float lx = pos.x - halfW;
		float rx = pos.x + halfW;
		float by = pos.y - halfH;
		float ty = pos.y + halfH;
		_vertices.Add(new Vector3(lx, by, 0.0f));
		_vertices.Add(new Vector3(lx, ty, 0.0f));
		_vertices.Add(new Vector3(rx, ty, 0.0f));
		_vertices.Add(new Vector3(rx, by, 0.0f));

		Vector2[] uv;
		if (_packedUVs.TryGetValue(texID, out uv)) {
			_uvs.Add(uv[0]);
			_uvs.Add(uv[1]);
			_uvs.Add(uv[2]);
			_uvs.Add(uv[3]);
		} else {
			_uvs.Add(new Vector2());
			_uvs.Add(new Vector2());
			_uvs.Add(new Vector2());
			_uvs.Add(new Vector2());
		}

		int offset = _sprites.Count * 4;
		_triangles.Add(offset);
		_triangles.Add(offset + 1);
		_triangles.Add(offset + 2);
		_triangles.Add(offset);
		_triangles.Add(offset + 2);
		_triangles.Add(offset + 3);

		//QuadSprite qs = new QuadSprite();
		QuadSprite qs = ScriptableObject.CreateInstance<QuadSprite>();
		qs.texID = texID;
		qs.pos.Set(pos.x, pos.y);
		_sprites.Add(qs);

		updateMesh();
		select(_sprites.Count - 1, SelectType.SINGLE);
	}

    public void move(float x, float y) {
		if (_selection.Count > 0) {
			Vector2 offPot = new Vector2(x, y);

			foreach (var item in _selection) {
				int offset = item.Key * 4;
				Vector3 lb = _vertices[offset];
				Vector3 lt = _vertices[offset + 1];
				Vector3 rt = _vertices[offset + 2];
				Vector3 rb = _vertices[offset + 3];
				lb.x += x;
				lb.y += y;
				lt.x += x;
				lt.y += y;
				rt.x += x;
				rt.y += y;
				rb.x += x;
				rb.y += y;
				_vertices[offset] = lb;
				_vertices[offset + 1] = lt;
				_vertices[offset + 2] = rt;
				_vertices[offset + 3] = rb;

				_sprites[item.Key].pos += offPot;
			}

			updateMesh();

			Bounds b = _selectBounds.Value;
			b.center += new Vector3(x, y);
			_selectBounds = b;
		}
	}

	public int testSelect(Vector3 screenPos) {
		Collider col = self.GetComponent<Collider>();
		if (col != null) {
			Ray ray = SceneView.lastActiveSceneView.camera.ScreenPointToRay(screenPos);

			RaycastHit hit;
			if (col.Raycast(ray, out hit, Mathf.Infinity)) {
				return Convert.ToInt32(Math.Floor(hit.triangleIndex * 0.5));
			}
		}

		return -1;
	}

	public void deleteSelection() {
		if (_selection.Count > 0) {
			TextureMapping texMapping = ChapterManager.currentChapterRoot.textureMapping;

			foreach (var item in _selection) {
				QuadSprite qs = _sprites[item.Key];
				if (_texMap.ContainsKey(qs.texID)) {
					uint value = _texMap[qs.texID];
					if (value > 1) {
						_texMap[qs.texID] = value - 1;
					} else {
						_texMap.Remove(qs.texID);
					}
				}

				texMapping.changeCount(qs.texID, -1);
			}

			List<int> indices = _selection.Keys.ToList();
			ChapterManager.quickSort(indices, 0, indices.Count - 1);
			ChapterManager.listRemoveOrderIndices(_vertices, indices, 4);
			ChapterManager.listRemoveOrderIndices(_uvs, indices, 4);

			int num = indices.Count * 6;
			_triangles.RemoveRange(_triangles.Count - num, num);

			ChapterManager.listRemoveOrderIndices(_sprites, indices, 1);

			_selection.Clear();

			updateMesh();
			updateSelectBounds();
		}
	}

	public int select(Vector3 screenPos, SelectType type) {
		int idx = testSelect(screenPos);
		select(idx, type);
		return idx;
	}

	public bool select(Vector3 screenLtPos, Vector3 screenRbPos, SelectType type) {
		if (screenRbPos == null) {
			return select(screenLtPos, type) != -1;
		} else {
			Matrix4x4 l2w = self.transform.localToWorldMatrix;
			Camera cam = SceneView.lastActiveSceneView.camera;

			List<int> indices = new List<int>();
			for (int i = 0; i < _sprites.Count; i++) {
				Vector2 pos = _sprites[i].pos;
				Vector3 p = cam.WorldToScreenPoint(l2w.MultiplyPoint(pos));
				//Debug.Log(p);
				if (p.x >= screenLtPos.x && p.x <= screenRbPos.x && p.y <= screenLtPos.y && p.y >= screenRbPos.y) {
					indices.Add(i);
				}
			}

			select(indices, type);

			return _selection.Count > 0;
		}
	}

	public void select(int index, SelectType type) {
		if (index >= 0) {
			switch (type) {
				case SelectType.SINGLE: {
						_selection.Clear();
						_selection[index] = true;

						break;
					}
				case SelectType.ADD: {
						if (!_selection.ContainsKey(index)) _selection[index] = true;

						break;
					}
				case SelectType.REMOVE: {
						_selection.Remove(index);

						break;
					}
				case SelectType.ADD_OR_REMOVE: {
						if (!_selection.Remove(index)) {
							_selection[index] = true;
						}

						break;
					}
				default:
					break;
			}

			updateSelectBounds();
		}
	}

	public void select(List<int> indices, SelectType type) {
		switch (type) {
			case SelectType.SINGLE: {
					_selection.Clear();
					foreach (int i in indices) {
						_selection[i] = true;
					}

					break;
				}
			case SelectType.ADD: {
					foreach (int i in indices) {
						if (!_selection.ContainsKey(i)) _selection[i] = true;
					}

					break;
				}
			case SelectType.REMOVE: {
					foreach (int i in indices) {
						_selection.Remove(i);
					}

					break;
				}
			case SelectType.ADD_OR_REMOVE: {
					foreach (int i in indices) {
						if (!_selection.Remove(i)) {
							_selection[i] = true;
						}
					}

					break;
				}
			default:
				break;
		}

		updateSelectBounds();
	}

    public bool isSelection(int idx) {
        return _selection.ContainsKey(idx);
    }

    public void clearSelection() {
        if (_selection.Count > 0) {
            _selection.Clear();
            updateSelectBounds();
        }
    }

	void updateMesh() {
		if (_mesh != null) {
			if (_mesh.triangles.Length > _triangles.Count) {
				_mesh.triangles = _triangles.ToArray();
				_mesh.vertices = _vertices.ToArray();
				_mesh.uv = _uvs.ToArray();
			} else {
				_mesh.vertices = _vertices.ToArray();
				_mesh.uv = _uvs.ToArray();
				_mesh.triangles = _triangles.ToArray();
			}

			MeshCollider col = self.GetComponent<MeshCollider>();
			if (col != null) {
				col.sharedMesh = null;
				col.sharedMesh = _mesh;
			}
		}
	}

	void updateSelectBounds() {
		_selectBounds = null;

		if (_selection.Count > 0) {
			Bounds b = new Bounds();
			bool first = true;

			foreach (var item in _selection) {
				int offset = item.Key * 4;
				Vector3 lb = _vertices[offset];
				Vector3 lt = _vertices[offset + 1];
				Vector3 rt = _vertices[offset + 2];
				Vector3 rb = _vertices[offset + 3];

				if (first) {
					first = false;
					b = new Bounds(lb, Vector3.zero);
					b.Encapsulate(lt);
					b.Encapsulate(rt);
					b.Encapsulate(rb);
				} else {
					b.Encapsulate(lb);
					b.Encapsulate(lt);
					b.Encapsulate(rt);
					b.Encapsulate(rb);
				}
			}

			_selectBounds = b;
		}
	}
}
