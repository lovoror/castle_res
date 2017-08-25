using UnityEditor;
using UnityEngine;
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using DotNetDetour;
using System.Runtime.CompilerServices;

public class ChapterAtrrubiteWindow : EditorWindow {
	static float tileWidth = 0.0f;
	static float tileHeight = 0.0f;

	static int changeTileIndex = 0;
	string[] changeTileOptions = { "Top", "Bottom", "Left", "Right" };
	static int changeTileValue = 0;
	void OnGUI() {
		float winWidth = 260;
		float halfWinWidth = winWidth * 0.5f;
		
		ChapterAtrrubite att = ChapterManager.currentChapterRoot == null ? new ChapterAtrrubite() : ChapterManager.currentChapterRoot.chapterAttribute;

		EditorGUILayout.BeginHorizontal();
		GUILayout.Label("TotalWidth : " + (att.columns * att.tileWidth).ToString(), GUILayout.Width(halfWinWidth));
		GUILayout.Label("TotalHeight : " + (att.rows * att.tileHeight).ToString(), GUILayout.Width(halfWinWidth));
		EditorGUILayout.EndHorizontal();
		EditorGUILayout.BeginHorizontal();
		GUILayout.Label("Rows : " + att.rows.ToString(), GUILayout.Width(halfWinWidth));
		GUILayout.Label("Columns : " + att.columns.ToString(), GUILayout.Width(halfWinWidth));
		EditorGUILayout.EndHorizontal();

		EditorGUILayout.Space();
		tileWidth = EditorGUILayout.FloatField("TileWidth", tileWidth);
		if (tileWidth < 0.0f) tileWidth = 0.0f;
		tileHeight = EditorGUILayout.FloatField("TileHeight", tileHeight);
		if (tileHeight < 0.0f) tileHeight = 0.0f;
		if (GUILayout.Button("Apply")) {
			if (att.tileWidth != tileWidth || att.tileHeight != tileHeight) {
				att.tileWidth = tileWidth;
				att.tileHeight = tileHeight;
				SceneView.RepaintAll();
			}
		}

		EditorGUILayout.Space();
		EditorGUILayout.LabelField("Append Tiles :");
		EditorGUILayout.BeginHorizontal();
		changeTileIndex = EditorGUILayout.Popup(changeTileIndex, changeTileOptions);
		changeTileValue = EditorGUILayout.IntField(changeTileValue);
		if (GUILayout.Button("Apply") && changeTileValue != 0) {
			switch (changeTileIndex) {
				case 0: {
						int rows = att.rows + changeTileValue;
						if (rows < 0) rows = 0;
						if (att.rows != rows) {
							att.rows = rows;
							SceneView.RepaintAll();
						}

						break;
					}
				case 1: {
						int rows = att.rows + changeTileValue;
						if (rows < 0) rows = 0;
						if (att.rows != rows) {
							att.rows = rows;
							SceneView.RepaintAll();
						}

						break;
					}
				case 2: {
						int columns = att.columns + changeTileValue;
						if (columns < 0) columns = 0;
						if (att.columns != columns) {
							att.columns = columns;
							SceneView.RepaintAll();
						}

						break;
					}
				case 3: {
						int columns = att.columns + changeTileValue;
						if (columns < 0) columns = 0;
						if (att.columns != columns) {
							att.columns = columns;
							SceneView.RepaintAll();
						}

						break;
					}
				default:
					break;
			}
		}
		EditorGUILayout.EndHorizontal();

		EditorGUILayout.Space();
		if (att.showGizmo != EditorGUILayout.Toggle("Show Gizmo", att.showGizmo)) {
			att.showGizmo = !att.showGizmo;
			SceneView.RepaintAll();
		}
	}
}

public class ChapterObjectsTraverser<T> {
	public delegate bool MyDelegate(GameObject go, T data);
	private MyDelegate _myDelegate;
	public void run(MyDelegate handler, T data, bool orderUpToDown) {
		_myDelegate += handler;

		List<GameObject> roots = ChapterEditor.getSceneRoots();
		for (int i = 0; i < roots.Count; i++) {
			ChapterRoot cr = roots[i].GetComponent<ChapterRoot>();
			if (cr != null) {
				_run(roots[i], handler, data, orderUpToDown);
				break;
			}
		}

		_myDelegate -= handler;
	}

	private bool _run(GameObject root, Delegate handler, T data, bool orderUpToDown) {
		if (orderUpToDown) {
			if (_myDelegate(root, data)) {
				Transform trans = root.transform;
				for (int i = 0; i < trans.childCount; i++) {
					if (!_run(trans.GetChild(i).gameObject, handler, data, orderUpToDown)) return false;
				}
			} else {
				return false;
			}
		} else {
			Transform trans = root.transform;
			for (int i = trans.childCount - 1; i >= 0; i--) {
				if (!_run(trans.GetChild(i).gameObject, handler, data, orderUpToDown)) return false;
			}

			if (!_myDelegate(root, data)) return false;
		}

		return true;
	}
}

/*
public class TransformSort : BaseHierarchySort {
	public override int Compare(GameObject lhs, GameObject rhs) {
		Debug.Log(1);
		if (lhs == rhs) return 0;
		if (lhs == null) return -1;
		if (rhs == null) return 1;

		return EditorUtility.NaturalCompare(lhs.name, rhs.name);
	}
}
*/


	public class CustomMonitor : IMethodMonitor //自定义一个类并继承IMethodMonitor接口
	{
		public CustomMonitor() {
			Debug.Log("new cm");
		}

		[Monitor("Test", "ZZZ")] //目标方法的名称空间，类名
		private string Get() //方法签名要与目标方法一致
		{
			return "B";
		}

		[MethodImpl(MethodImplOptions.NoInlining)]
		[Original] //原函数标记
		private string Ori() //方法签名要与目标方法一致
		{
			return null; //这里写什么无所谓，能编译过即可
		}
	}

namespace Test {

	public class ZZZ {
		public ZZZ() {
			Debug.Log("new zzz");
		}

		public string bb() {
			return Get();
		}

		[MethodImpl(MethodImplOptions.NoInlining)]
		private string Get() {
			return "A";
		}
	}
}

public class MyWindows : EditorWindow {
	[MenuItem("Window/My Window")]
	static void Init() {
		MyWindows window = (MyWindows)EditorWindow.GetWindow(typeof(MyWindows));
		window.Show();
	}

	bool locked = false;

	private GUIStyle m_IconStyle = new GUIStyle();


	private void OnEnable() {
		Texture2D icon = Resources.Load<Texture2D>("ResourceImage/room01/room1_4_3");
		m_IconStyle.normal.background = icon;
		
		Monitor.Install();
		Debug.Log(new Test.ZZZ().bb());
	}

	void ShowButton(Rect rect) {
		Debug.Log(rect);
		locked = GUI.Toggle(rect, locked, GUIContent.none, "IN LockButton");
		rect.x -= 12.0f;
		GUI.Button(new Rect(rect.x, rect.y, 12, 12), GUIContent.none, m_IconStyle);
	}

	Vector2 _scrollPos;
	bool aa;

	void OnGUI() {
		GUIContent content = new GUIContent("a");
		GUIStyle style = new GUIStyle();
		GUILayoutOption[] options = new GUILayoutOption[0];

		for (int i = 0; i < 4; i++) {
			EditorGUI.indentLevel = i;
			EditorGUILayout.LabelField("1", style);
		}

		_scrollPos = EditorGUILayout.BeginScrollView(_scrollPos);
		aa = EditorGUILayout.Foldout(aa, "");
		aa = EditorGUILayout.Foldout(aa, "");
		EditorGUILayout.LabelField("我是佑丶小贱 我是佑丶小贱 我是佑丶小贱 我是佑丶小贱11111111222222222"); // 组中的内容

		
		//style.normal.background = null;
		for (int i = 0; i < 40; i++) {
			if (GUILayout.Button(content, style)) {
				Debug.Log(i);
			}
		}
		EditorGUILayout.EndScrollView();
	}
}

public class ChapterEditor : Editor {
	static ChapterAtrrubiteWindow _chapterAtrrubiteWindow = null;
	public static string LOCK_LAYER = "Chapter Editor Lock";
	private static EventType _lastMouseType = EventType.Used;
	private static int _lastMouseButton = -1;
	private static Vector2 _lastMouseDownPos;
	private static int _lastMouseDownHotControlID = 0;
	private static MouseDownState _mouseDownState = MouseDownState.NONE;
	private static bool _isDragging = false;
	private static Tool _lastTool = Tool.None;

    private static Vector2 _dragMoveDir;
    private static Vector2 _dragMoveStartScreenPos;
    private static Vector2 _dragMoveLastScreenPos;
    private static Vector2 _dragMoveAlignOffset;

    [InitializeOnLoadMethod]
	static void Start() {
		/*
        TexturePacker.Settings settings = new TexturePacker.Settings();
        settings.maxWidth = 2048;
        settings.maxHeight = 2048;
        settings.paddingX = 1;
        TexturePacker.MaxRectsPacker packer = new TexturePacker.MaxRectsPacker(settings);
        List<TexturePacker.Rect> inputs = new List<TexturePacker.Rect>();
        inputs.Add(new TexturePacker.Rect("img1", 10, 10));
        inputs.Add(new TexturePacker.Rect("img2", 10, 10));
        inputs.Add(new TexturePacker.Rect("img3", 10, 10));
        List<TexturePacker.Page> outputs = packer.pack(inputs);
        for (int i = 0; i < outputs.Count; i++) {
            TexturePacker.Page page = outputs[i];
            Debug.Log("page=" + i + ", width=" + page.width + ", height=" + page.height + ", name=" + page.imageName + ", rects=" + page.outputRects.Count);
            for (int j = 0; j < page.outputRects.Count; j++) {
                TexturePacker.Rect rect = page.outputRects[j];
                Debug.Log("     rect : name=" + rect.name + ", x=" + rect.x + ", y=" + rect.y + ", offX=" + rect.offsetX + ", offY=" + rect.offsetX + ", width=" + rect.width + ", height=" + rect.height);
            }
        }
        */

		//Debug.Log(window);

		addLayer(LOCK_LAYER);

        SceneView.onSceneGUIDelegate += OnSceneGUI;
        EditorApplication.update += OnUpdate;

        Camera.onPreCull += OnPreRender;
		Camera.onPostRender += OnPostRender;
	}


	static void OnPreRender(Camera cam) {
		//cam.cullingMask = 0;
	}

	static void OnPostRender(Camera cam) {

	}

	[MenuItem("ChapterEditor/New", false, 0)]
	static void New() {
		_createChapter();
	}

	[MenuItem("ChapterEditor/Open", false, 0)]
	static void Open() {
		string path = EditorUtility.OpenFilePanel("Load png Textures of Directory", "", "");
		if (path.Length > 0) {
			_clearChapter();
			_createChapter(path);
		}
		Debug.Log(path);
		// print(ww.url);
		// yield return ww;
		//gui.texture = ww.texture;
	}

	static void _clearChapter() {

	}

	static void _createChapter(string path = "") {
		_clearChapter();

		GameObject root = new GameObject();
		root.name = GameObjectUtility.GetUniqueNameForSibling(null, "ChapterRoot");
		root.layer = LayerMask.NameToLayer(LOCK_LAYER);
		root.AddComponent<ChapterRoot>();

		if (path.Length > 0) {
			//var json = JSONNode.Parse(File.ReadAllText(path));
			//Debug.Log(json);
		}
	}

	[MenuItem("ChapterEditor/AtrrubiteWindow")]
	static void showChapterAtrrubiteWindow() {
		if (_chapterAtrrubiteWindow == null) {
			_chapterAtrrubiteWindow = EditorWindow.GetWindow<ChapterAtrrubiteWindow>();
			_chapterAtrrubiteWindow.position = new Rect(100, 100, 260, 200);
			_chapterAtrrubiteWindow.titleContent = new GUIContent("Atrrubites");
		}
		_chapterAtrrubiteWindow.Show();
	}

	static void addLayer(string name) {
		if (!isHasLayer(name)) {
			SerializedObject tagManager = new SerializedObject(AssetDatabase.LoadAllAssetsAtPath("ProjectSettings/TagManager.asset")[0]);
			SerializedProperty it = tagManager.GetIterator();

			while (it.NextVisible(true)) {
				if (it.name == "layers") {
					//层默认是32个，只能从第8个开始写入自己的层  
					for (int i = 8; i < it.arraySize; i++) {
						SerializedProperty dataPoint = it.GetArrayElementAtIndex(i);//获取层信息  

						Debug.Log(dataPoint.type);

						if (string.IsNullOrEmpty(dataPoint.stringValue))//如果制定层内为空，则可以填写自己的层名称  
						{
							dataPoint.stringValue = name;//设置名字  
							tagManager.ApplyModifiedProperties();//保存修改的属性  
							Tools.lockedLayers |= 1 << i;

							return;
						}
					}
				}
			}
		}
	}

	static bool isHasLayer(string layer) {
		for (int i = 0; i < UnityEditorInternal.InternalEditorUtility.layers.Length; i++) {
			if (UnityEditorInternal.InternalEditorUtility.layers[i].Contains(layer))
				return true;
		}
		return false;
	}

	public static Vector3 getScreenPos(Vector2 eventMousePos) {
		Vector3 s = eventMousePos;
		s.y = SceneView.currentDrawingSceneView.camera.pixelHeight - s.y;
		return s;
	}

	public static Vector3 getScreenToWorldPos(Vector3 pos) {
		pos = SceneView.currentDrawingSceneView.camera.ScreenToWorldPoint(pos);
		//pos.y = -pos.y;
		return pos;
	}

    static void OnUpdate() {
        if (ChapterManager.updateProjectWindow) {
			ChapterManager.updateProjectWindow = false;
            EditorApplication.RepaintProjectWindow();
        }
    }

    static void OnSceneGUI(SceneView scene) {
		if (scene.camera.GetComponent<SceneViewCamera>() == null) {
			scene.camera.gameObject.AddComponent<SceneViewCamera>();
		}
		// Debug.Log(scene.camera.cullingMask);
		//SceneView.lastActiveSceneView.camera.cullingMask = 0;
		//Cursor.visible = true;
		//Cursor.lockState = CursorLockMode.Confined;
		//Tools.current = Tool.None;
		//Tools.viewTool = ViewTool.None;
		//Debug.Log(DragAndDrop.visualMode);
		//EditorGUIUtility.AddCursorRect(new Rect(-10000, -10000, 20000, 20000), MouseCursor.Link);
		//Debug.Log(GUIUtility.GetControlID(FocusType.Keyboard));

		Event e = Event.current;
		if (e != null) {
			bool use = false;
			bool notUse = false;
			bool repaint = false;

			//Debug.Log(GUIUtility.hotControl + "   " + e.type);
			switch (e.type) {
				case EventType.KeyDown: {
						switch (e.keyCode) {
							case KeyCode.LeftArrow: {
									if (e.shift) {
										if (ChapterManager.currentChapterRoot != null) {
											moveSelectionGameObjects(-1.0f * ChapterManager.currentChapterRoot.chapterAttribute.tileWidth, 0.0f);
										}
									} else {
										moveSelectionGameObjects(-1.0f, 0.0f);
									}
								}

								break;
							case KeyCode.RightArrow:
								if (e.shift) {
									if (ChapterManager.currentChapterRoot != null) {
										moveSelectionGameObjects(1.0f * ChapterManager.currentChapterRoot.chapterAttribute.tileWidth, 0.0f);
									}
								} else {
									moveSelectionGameObjects(1.0f, 0.0f);
								}

								break;
							case KeyCode.UpArrow:
								if (e.shift) {
									if (ChapterManager.currentChapterRoot != null) {
										moveSelectionGameObjects(0.0f, 1.0f * ChapterManager.currentChapterRoot.chapterAttribute.tileHeight);
									}
								} else {
									moveSelectionGameObjects(0.0f, 1.0f);
								}

								break;
							case KeyCode.DownArrow:
								if (e.shift) {
									if (ChapterManager.currentChapterRoot != null) {
										moveSelectionGameObjects(0.0f, -1.0f * ChapterManager.currentChapterRoot.chapterAttribute.tileHeight);
									}
								} else {
									moveSelectionGameObjects(0.0f, -1.0f);
								}

								break;
							case KeyCode.Delete: {
									GameObject[] objs = Selection.gameObjects;
									for (int i = 0; i < objs.Length; i++) {
										GameObject go = objs[i];
										ChapterPolySprite cps = go.GetComponent<ChapterPolySprite>();
										if (cps == null) {
											DestroyImmediate(go);
										} else {
											cps.deleteSelection();
										}
									}
                                    e.Use();

									//notUse = true;
									break;
								}
							default:
								break;
						}

						break;
					}
				case EventType.MouseDown: {
						object win = SceneHierarchyWindowHelper.get_lastInteractedHierarchyWindow();
						object tv = SceneHierarchyWindowHelper.getTreeView(win);
						Debug.Log(TreeViewHelper.getGUI(tv));

						if (e.button != 0) break;

						ChapterManager.isMouseLeftButtonDown = true;
						
						_isDragging = false;
						_lastMouseDownPos = e.mousePosition;
						_lastMouseDownHotControlID = GUIUtility.hotControl;
						//GUIUtility.hotControl = GUIUtility.GetControlID(FocusType.Passive);
						//Debug.Log(e.shift);
						GUIUtility.hotControl = 0;

						if (_lastMouseDownHotControlID == 0) {
							_mouseDownState = MouseDownState.NONE;
						} else {
                            PickData pd = _pick(scene, e.mousePosition);
							GameObject go = pd.pickGameObject;
							if (go == null) {
								_mouseDownState = MouseDownState.PICK_NONE;
							} else {
                                if (Selection.gameObjects.Length > 0) {
									if (Selection.gameObjects.Length == 1) {
										if (Selection.activeGameObject == go) {
											ChapterPolySprite cps = go.GetComponent<ChapterPolySprite>();
											if (cps == null) {
												_mouseDownState = MouseDownState.PICK_NRM_SINGLE;
											} else {
												int idx = cps.testSelect(getScreenPos(e.mousePosition));
												if (cps.getSelectionContains(idx)) {
													_mouseDownState = MouseDownState.PICK_SINGLE;

                                                    _dragMoveStart(getScreenPos(e.mousePosition));
													
													//cps.startMove(getScreenPos(e.mousePosition));
												} else {
													_mouseDownState = MouseDownState.PICK_NONE;
												}
											}
										} else {
											_mouseDownState = MouseDownState.PICK_NONE;
										}
									} else {
                                        GameObject findGo = null;
                                        foreach (GameObject sgo in Selection.gameObjects) {
                                            if (sgo == go) {
                                                findGo = sgo;
                                                break;
                                            }
                                        }
                                        if (findGo == null) {
                                            _mouseDownState = MouseDownState.PICK_NONE;
                                        } else {
                                            ChapterPolySprite cps = findGo.GetComponent<ChapterPolySprite>();
                                            if (cps == null) {
                                                _mouseDownState = MouseDownState.PICK_MULTI;
                                            } else {
                                                if (cps.isSelection(pd.pickPolySpriteIndex)) {
                                                    _mouseDownState = MouseDownState.PICK_MULTI;
                                                } else {
                                                    _mouseDownState = MouseDownState.PICK_NONE;
                                                }
                                            }

                                            if (_mouseDownState == MouseDownState.PICK_MULTI) {
                                                _dragMoveStart(getScreenPos(e.mousePosition));
                                            }
                                        }
									}
								} else {
									_mouseDownState = MouseDownState.PICK_NONE;
								}
							}
						}

						break;
					}
				case EventType.MouseUp: {
						if (e.button != 0) break;
						//GUIUtility.hotControl = 0;

						ChapterManager.isMouseLeftButtonDown = false;

						if (_isDragging) {
							_isDragging = false;

							if (_lastMouseDownHotControlID != 0) {
								switch (_mouseDownState) {
									case MouseDownState.PICK_NONE: {
											float minX, maxX, minY, maxY;
											if (_lastMouseDownPos.x < e.mousePosition.x) {
												minX = _lastMouseDownPos.x;
												maxX = e.mousePosition.x;
											} else {
												minX = e.mousePosition.x;
												maxX = _lastMouseDownPos.x;
											}
											if (_lastMouseDownPos.y < e.mousePosition.y) {
												minY = _lastMouseDownPos.y;
												maxY = e.mousePosition.y;
											} else {
												minY = e.mousePosition.y;
												maxY = _lastMouseDownPos.y;
											}
                                            
                                            PickData pd = PickData.createPickGameObjectsData(getScreenPos(new Vector2(minX, minY)), getScreenPos(new Vector2(maxX, maxY)), e.control ? SelectType.ADD_OR_REMOVE : SelectType.SINGLE);
											new ChapterObjectsTraverser<PickData>().run(_pickGameObjects, pd, false);

                                            pd.pickGameObjects.AddRange(HandleUtility.PickRectObjects(new Rect(minX, minY, maxX - minX, maxY - minY)));
                                            Selection.objects = pd.pickGameObjects.ToArray();

                                            repaint = true;

											break;
										}
									case MouseDownState.PICK_SINGLE:
                                    case MouseDownState.PICK_MULTI: {
                                            _dragMoveEnd();

											break;
										}
									default:
										break;
								}
							}
						} else {
							if (_lastMouseDownHotControlID != 0) {
                                PickData pd = _pick(scene, e.mousePosition);

                                if (e.control) {
                                    if (pd.pickGameObject != null) {
                                        ChapterPolySprite cps = pd.pickGameObject.GetComponent<ChapterPolySprite>();
                                        if (pd.pickPolySpriteIndex != -1) {
                                            cps.select(pd.pickPolySpriteIndex, SelectType.ADD_OR_REMOVE);
                                        }
                                        if (cps.numSelection > 0) {
                                            if (!Selection.gameObjects.Contains(pd.pickGameObject)) {
                                                List<GameObject> gos = new List<GameObject>(Selection.gameObjects);
                                                gos.Add(pd.pickGameObject);
                                                Selection.objects = gos.ToArray();
                                            }
                                        } else {
                                            if (Selection.gameObjects.Contains(pd.pickGameObject)) {
                                                List<GameObject> gos = new List<GameObject>(Selection.gameObjects);
                                                gos.Remove(pd.pickGameObject);
                                                Selection.objects = gos.ToArray();
                                            }
                                        }
                                    }
                                } else {
                                    Selection.activeGameObject = null;
									
									if (pd.pickGameObject != null) {
                                        Selection.activeGameObject = pd.pickGameObject;
                                        if (pd.pickPolySpriteIndex != -1) {
                                            pd.pickGameObject.GetComponent<ChapterPolySprite>().select(pd.pickPolySpriteIndex, SelectType.SINGLE);
                                        }
                                    }
                                }

								//Debug.Log(Selection.activeGameObject);
								repaint = true;
								e.Use();

								/*
                                GameObject go = HandleUtility.PickGameObject(e.mousePosition, true);
                                //Debug.Log(go);
                                Selection.activeGameObject = go;
                                
                                if (go != null)
                                {
                                    ChapterPolySprite cps = go.GetComponent<ChapterPolySprite>();
                                    if (cps != null)
                                    {
                                        cps.select(getScreenPos(e.mousePosition), null, e.control ? SelectType.ADD_OR_REMOVE : SelectType.SINGLE);
                                    }
                                }
                                */
							}
						}

						break;
					}
				case EventType.MouseDrag: {
						if (e.button != 0) break;

						if (_lastMouseDownHotControlID != 0) {
							if (!_isDragging) {
								_isDragging = Vector2.Distance(_lastMouseDownPos, e.mousePosition) > 5.0f;
								repaint = true;
							}
                            
							switch (_mouseDownState) {
								case MouseDownState.PICK_SINGLE:
                                case MouseDownState.PICK_MULTI: {
                                        if (_isDragging && ChapterManager.currentChapterRoot != null) {
                                            Matrix4x4 m = ChapterManager.currentChapterRoot.transform.worldToLocalMatrix;
                                            Vector2 end = e.mousePosition;
                                            Vector2 start = end - e.delta;
                                            Vector3 start3 = m.MultiplyPoint(getScreenToWorldPos(getScreenPos(start)));
                                            Vector3 end3 = m.MultiplyPoint(getScreenToWorldPos(getScreenPos(end)));
                                            
                                            _dragMoving(end3.x - start3.x, end3.y - start3.y, getScreenPos(e.mousePosition));
                                        }

										break;
									}
								default:
									break;
							}
						}

						break;
					}
				case EventType.DragPerform: {
						if (DragAndDrop.objectReferences.Length > 0) {
							Texture2D tex = DragAndDrop.objectReferences[0] as Texture2D;
							if (tex != null) {
                                if (Selection.gameObjects.Length == 1) {
                                    GameObject go = Selection.activeGameObject;
                                    if (go != null) {
                                        ChapterPolySprite ps = go.GetComponent<ChapterPolySprite>();
                                        if (ps != null) {
                                            if (ps.loclState == LockState.UNLOCK) {
                                                Vector3 pos = getScreenToWorldPos(getScreenPos(e.mousePosition));
                                                pos = go.transform.worldToLocalMatrix.MultiplyPoint(pos);
                                                ps.add(pos, tex);
                                                Selection.activeGameObject = go;
                                            } else {
                                                EditorApplication.Beep();
                                            }
                                        }
                                    }
                                } else {
                                    EditorApplication.Beep();
                                }

                                use = true;
                            }
						}
						//moveSelectionGameObjects(200.0f, 0.0f);
						//Debug.Log(e.type);
						break;
					}
				case EventType.Repaint: {
						if (_isDragging && _mouseDownState == MouseDownState.PICK_NONE) {
							Matrix4x4 defaultMatrix = Handles.matrix;
							Handles.matrix = scene.camera.transform.localToWorldMatrix;

							Vector3 start = getScreenToWorldPos(getScreenPos(_lastMouseDownPos));
							Vector3 end = getScreenToWorldPos(getScreenPos(e.mousePosition));
							Matrix4x4 w2l = scene.camera.transform.worldToLocalMatrix;
							start = w2l.MultiplyPoint(start);
							end = w2l.MultiplyPoint(end);

							Vector3[] verts = new Vector3[4];
							verts[0] = new Vector3(start.x, start.y, 500);
							verts[1] = new Vector3(end.x, start.y, 500);
							verts[2] = new Vector3(end.x, end.y, 500);
							verts[3] = new Vector3(start.x, end.y, 500);
							Handles.DrawSolidRectangleWithOutline(verts, new Color(0.5f, 0.5f, 1, 0.1f), new Color(1, 1, 1, 0.5f));

							Handles.matrix = defaultMatrix;

							repaint = true;
						}

						break;
					}
				default:
					break;
			}

			//if (e.isMouse && e.type != EventType.MouseMove) Debug.Log(e.type);
			//scene.camera.orthographic = true;
			//scene.camera.orthographicSize = 100.0f;

			//Debug.Log(scene.camera.transform.localScale);
			//e.modifiers = EventModifiers.None;
			//if (DragAndDrop.objectReferences.Length > 0) Debug.Log(DragAndDrop.objectReferences[0]);
			//scene.LookAtDirect(Vector3.zero, new Quaternion());
			//scene.position = new Rect(0, 0, 0, 0);
			//HandleUtility.PickRectObjects(new Rect(-10000, -10000, 20000, 20000));

			//if (Event.current.type == EventType.MouseDown) Event.current.Use();
			//if (Event.current.type == EventType.MouseMove) Event.current.Use();

			if (e.isMouse) {
				//_lastMouseType = e.type;
				// _lastMouseButton = e.button;
				// _lastMousePos = e.mousePosition;
			}

            bool hasPoly = false;
			GameObject[] gameObjects = Selection.gameObjects;
			for (int i = 0; i < gameObjects.Length; i++) {
				if (gameObjects[i].GetComponent<ChapterPolySprite>() != null) {
					hasPoly = true;
					break;
				}
			}
			if (hasPoly) {
				if (Tools.current != Tool.None) {
					_lastTool = Tools.current;
				}
				Tools.current = Tool.None;
			} else {
				if (Tools.current == Tool.None) {
					if (_lastTool == Tool.None) {
						_lastTool = Tool.Rect;
					}
					Tools.current = _lastTool;
				}
			}

			if (repaint) scene.Repaint();
			if (use || (!notUse && e.isKey)) e.Use();
		}
	}

    private static PickData _pick(SceneView scene, Vector2 pos) {
        PickData pd = new PickData();
        pd.ray = scene.camera.ScreenPointToRay(getScreenPos(pos));
        new ChapterObjectsTraverser<PickData>().run(_pickGameObject, pd, false);

        if (pd.pickGameObject == null) {
            pd.pickGameObject = HandleUtility.PickGameObject(pos, true);
        }

        return pd;
    }

	private static bool _pickGameObject(GameObject go, PickData data) {
		if (!go.activeInHierarchy) return true;

		ChapterPolySprite cps = go.GetComponent<ChapterPolySprite>();
		if (cps == null) {
			Collider col = go.GetComponent<Collider>();
			if (col != null) {
				RaycastHit hit;
				if (col.Raycast(data.ray, out hit, Mathf.Infinity)) {
					data.pickGameObject = go;

					return false;
				}
			}
		} else {
			if (cps.loclState == LockState.UNLOCK) {
				Collider col = go.GetComponent<Collider>();
				if (col != null) {
					RaycastHit hit;
					if (col.Raycast(data.ray, out hit, Mathf.Infinity)) {
						data.pickGameObject = go;
						data.pickPolySpriteIndex = Mathf.FloorToInt(hit.triangleIndex * 0.5f);

						return false;
					}
				}
			}
		}

		return true;
	}

	private static bool _pickGameObjects(GameObject go, PickData data) {
		if (!go.activeInHierarchy) return true;

		Collider col = go.GetComponent<Collider>();
		if (col != null) {
			ChapterPolySprite cps = go.GetComponent<ChapterPolySprite>();
			if (cps == null) {
				// go.transform.position;
			} else if (cps.loclState == LockState.UNLOCK) {
				if (cps.select(data.regionLeftTop, data.regionRightBottom, data.selectType)) {
					data.pickGameObjects.Add(go);
				}
			}
		}

		return true;
	}

	private static IEnumerable<GameObject> _sceneRoots() {
		HierarchyProperty prop = new HierarchyProperty(HierarchyType.GameObjects);
		int[] expanded = new int[0];
		while (prop.Next(expanded)) {
			yield return prop.pptrValue as GameObject;
		}
	}

	public static List<GameObject> getSceneRoots() {
		List<GameObject> objs = new List<GameObject>();

		foreach (GameObject root in _sceneRoots()) {
			objs.Add(root);
		}
		return objs;
	}

	static void moveSelectionGameObjects(float x, float y) {
		GameObject[] gos = Selection.gameObjects;
		for (int i = 0; i < gos.Length; i++) {
			moveGameObject(gos[i], x, y);
		}
	}

	static void moveGameObject(GameObject target, float x, float y) {
        ChapterPolySprite cps = target.GetComponent<ChapterPolySprite>();
        if (cps == null) {
            target.transform.Translate(x, y, 0.0f);
        } else {
            cps.move(x, y);
        }
	}

    private static void _moveGameObjectsWithChapterRootSpace(GameObject[] gos, float x, float y) {
        foreach (GameObject go in gos) {
            ChapterPolySprite cps = go.GetComponent<ChapterPolySprite>();
            if (cps != null) {
                Vector3 p = go.transform.InverseTransformPoint(ChapterManager.currentChapterRoot.transform.TransformPoint(new Vector3(x, y, 0.0f)));
                cps.move(p.x, p.y);//, getScreenPos(e.mousePosition));
            }
        }
    }

    private static void _dragMoveEnd() {
        _dragMoveDir.Set(0, 0);
        if (_dragMoveAlignOffset.sqrMagnitude > 0) {
            _moveGameObjectsWithChapterRootSpace(Selection.gameObjects, _dragMoveAlignOffset.x, _dragMoveAlignOffset.y);

            _dragMoveAlignOffset.Set(0, 0);
        }
    }

    private static void _dragMoveStart(Vector2 screenPos) {
        _dragMoveDir.Set(0, 0);
        _dragMoveStartScreenPos = screenPos;
        _dragMoveLastScreenPos = screenPos;
    }

    private static void _dragMoving(float x, float y, Vector2 screenPos) {
        _dragMoveLastScreenPos = screenPos;
        if ((_dragMoveLastScreenPos - _dragMoveStartScreenPos).sqrMagnitude < 100) {
            _dragMoveDir.Set(_dragMoveDir.x + x, _dragMoveDir.y + y);
        } else {
            _dragMoveDir.Set(x, y);
            _dragMoveStartScreenPos = _dragMoveLastScreenPos;
        }

        _moveGameObjectsWithChapterRootSpace(Selection.gameObjects, x, y);
    }

    public static void renderedObjects() {
        if (!Event.current.shift || !ChapterManager.isMouseLeftButtonDown) {
            _dragMoveDir.Set(0, 0);
            _dragMoveStartScreenPos = _dragMoveLastScreenPos;
        }
        _dragMoveAlignOffset.Set(0, 0);

        Bounds? totalBounds = null;
        int numSelection = 0;
        foreach (GameObject go in Selection.gameObjects) {
            ChapterPolySprite cps = go.GetComponent<ChapterPolySprite>();
            if (cps != null) {
                Bounds? b = cps.getSelectionBounds();
                if (b != null) {
                    numSelection += cps.numSelection;

                    if (totalBounds == null) {
                        totalBounds = b;
                    } else {
                        Bounds b2 = totalBounds.Value;
                        b2.Encapsulate(b.Value.min);
                        b2.Encapsulate(b.Value.max);
                        totalBounds = b2;
                    }
                }
            }
        }

        Matrix4x4 defaultMatrix = Handles.matrix;
        Color defaultColor = Handles.color;

        if (ChapterManager.currentChapterRoot != null) {
            Transform rootTrans = ChapterManager.currentChapterRoot.transform;

            if (totalBounds != null) {
                Handles.matrix = rootTrans.localToWorldMatrix;
                Handles.color = Color.blue;

                Bounds b = totalBounds.Value;
                Vector3 min = b.min;
                Vector3 max = b.max;
                Vector3 lb = min;
                Vector3 lt = new Vector3(min.x, max.y);
                Vector3 rt = max;
                Vector3 rb = new Vector3(max.x, min.y);

                if (_dragMoveDir.sqrMagnitude > 0.0f || numSelection > 1) {
                    Handles.DrawLine(lb, lt);
                    Handles.DrawLine(lt, rt);
                    Handles.DrawLine(rt, rb);
                    Handles.DrawLine(rb, lb);
                }

                if (_dragMoveDir.sqrMagnitude > 0.0f && numSelection > 0) {
                    Handles.matrix = rootTrans.localToWorldMatrix;
                    Handles.color = Color.red;

                    ChapterAtrrubite att = ChapterManager.currentChapterRoot.chapterAttribute;

                    int row = 0;
                    int column = 0;
                    int dirX = 0;
                    int dirY = 0;

                    if (_dragMoveDir.x > 0) {
                        float c = att.getColumn(rt.x);
                        column = Mathf.FloorToInt(c);
                        if (c < Mathf.Round(c)) {
                            column++;
                        }
                        dirX = 1;
                    } else if (_dragMoveDir.x < 0) {
                        float c = att.getColumn(lt.x);
                        column = Mathf.FloorToInt(c);
                        if (c < Mathf.Round(c)) {
                            column++;
                        }
                        dirX = -1;
                    }

                    if (_dragMoveDir.y > 0) {
                        float r = att.getRow(-lt.y);
                        row = Mathf.FloorToInt(r);
                        if (r < Mathf.Round(r)) {
                            row++;
                        }
                        dirY = 1;
                    } else if (_dragMoveDir.y < 0) {
                        float r = att.getRow(-lb.y);
                        row = Mathf.FloorToInt(r);
                        if (r < Mathf.Round(r)) {
                            row++;
                        }
                        dirY = -1;
                    }

                    if (dirX == 0) {
                        if (dirY != 0) {
                            Handles.color = Color.red;

                            float y = -att.tileHeight * row;
                            Handles.DrawLine(new Vector3(lb.x, y), new Vector3(rb.x, y));

                            Vector3 p = new Vector3(lb.x, y);
                            if (dirY > 0) {
                                _dragMoveAlignOffset = p - lt;
                            } else {
                                _dragMoveAlignOffset = p - lb;
                            }
                        }
                    } else if (dirY == 0) {
                        Handles.color = Color.red;

                        float x = att.tileWidth * column;
                        Handles.DrawLine(new Vector3(x, rt.y), new Vector3(x, rb.y));

                        Vector3 p = new Vector3(x, rt.y);
                        if (dirX > 0) {
                            _dragMoveAlignOffset = p - rt;
                        } else {
                            _dragMoveAlignOffset = p - lt;
                        }
                    } else {
                        Handles.color = Color.red;

                        float x = att.tileWidth * column;
                        float y = -att.tileHeight * row;

                        Vector3 p = new Vector3(x, y);

                        if (dirX > 0) {
                            Handles.DrawLine(new Vector3(x - (rt.x - lt.x), y), new Vector3(x, y));

                            if (dirY > 0) {
                                Handles.DrawLine(new Vector3(x, y), new Vector3(x, y - (rt.y - rb.y)));

                                _dragMoveAlignOffset = p - rt;
                            } else {
                                Handles.DrawLine(new Vector3(x, y), new Vector3(x, y + (rt.y - rb.y)));

                                _dragMoveAlignOffset = p - rb;
                            }
                        } else {
                            Handles.DrawLine(new Vector3(x, y), new Vector3(x + (rt.x - lt.x), y));
                            if (dirY > 0) {
                                Handles.DrawLine(new Vector3(x, y), new Vector3(x, y - (rt.y - rb.y)));

                                _dragMoveAlignOffset = p - lt;
                            } else {
                                Handles.DrawLine(new Vector3(x, y), new Vector3(x, y + (rt.y - rb.y)));

                                _dragMoveAlignOffset = p - lb;
                            }
                        }
                    }
                }
            }
        }

        Handles.color = defaultColor;
        Handles.matrix = defaultMatrix;
    }
}

[InitializeOnLoad]
public class ChapterProjectWindow {
    static ChapterProjectWindow() {
        EditorApplication.projectWindowItemOnGUI += onProjectWindowItemOnGUI;
    }

    static void onProjectWindowItemOnGUI(string guid, Rect selectionRect) {
        string path = AssetDatabase.GUIDToAssetPath(guid);
        var obj = AssetDatabase.LoadAssetAtPath<UnityEngine.Object>(path);
        Texture2D tex = obj as Texture2D;
        if (tex != null) {
            if (ChapterManager.currentChapterRoot != null) {
                int count = ChapterManager.currentChapterRoot.textureMapping.getCount(path);
                bool icons = selectionRect.height > 20;

                if (!icons) {
                    GUIContent content = new GUIContent(count.ToString());
                    GUIStyle style = new GUIStyle();
                    //style.normal.background = tex;
                    style.normal.textColor = count <= 0 ? Color.gray : Color.blue;

                    Vector2 size = style.CalcSize(content);
                    //Debug.Log(size);

                    GUI.Label(new Rect(selectionRect.x + selectionRect.width - size.x, selectionRect.y + (selectionRect.height - size.y) * 0.5f, size.x, size.y), content, style);
                    //GUI.Label(new Rect(selectionRect.x, selectionRect.y + selectionRect.height - size.y, size.x, size.y), content, style);
                }
                //Debug.Log(Event.current.type);
                //Event.current.Use();
            }
        }
        //Debug.Log(obj);
    }
}

[InitializeOnLoad]
public class ChapterHierarchyWindow {
    static ChapterHierarchyWindow() {
        EditorApplication.hierarchyWindowItemOnGUI += OnHierarchyGUI;
    }

    static void OnHierarchyGUI(int instanceID, Rect selectionRect) {
        //if (Event.current.type == EventType.Repaint) Event.current.Use();

        GameObject go = EditorUtility.InstanceIDToObject(instanceID) as GameObject;
        ChapterDisplayObject cdo = go.GetComponent<ChapterDisplayObject>();
        if (cdo != null) {
            LockState ls = cdo.loclState;
            GUIContent content = new GUIContent(ls != LockState.UNLOCK ? "lock" : "free");
            GUIStyle style = new GUIStyle();
            //style.normal.background = tex;
            Color c;
            if (ls == LockState.LOCK) {
                c = Color.red;
            } else if (ls == LockState.INDIRECT_LOCK) {
                c = new Color(1.0f, 1.0f, 0.0f);
            } else {
                c = Color.green;
            }
            style.normal.textColor = c;

            Vector2 size = style.CalcSize(content);
            //Debug.Log(size);

            if (GUI.Button(new Rect(selectionRect.x + selectionRect.width - size.x, selectionRect.y + (selectionRect.height - size.y) * 0.5f, size.x, size.y), content, style)) {
                cdo.lockOrUnlockNode();
            }
        }

        
        //GUI.Label(new Rect(selectionRect.x + selectionRect.width - size.x, selectionRect.y + (selectionRect.height - size.y) * 0.5f, size.x, size.y), content, style);
    }
}

    [InitializeOnLoad]
public class CustomContextMenu {
	static bool _MenuOpened = false;
	static GameObject _ClickedOBject = null;
	static Vector2 _MenuPosition;
	static CustomContextMenu() {
		//EditorApplication.hierarchyWindowItemOnGUI += OnHierarchyGUI;
		//EditorApplication.update += OnUpdate;
	}

	static void OnHierarchyGUI(int instanceID, Rect selectionRect) {
		// Whether this object was right clicked
		if (Event.current != null) {
			if (Event.current.type == EventType.mouseUp && Event.current.button == 1) {
				// Find what object this is
				GameObject clickedObject = EditorUtility.InstanceIDToObject(instanceID) as GameObject;

				if (clickedObject) {
					//Debug.Log("Clicked " + clickedObject.name);
					_ClickedOBject = clickedObject;
					_MenuPosition = Event.current.mousePosition;
					//_MenuOpened = true;
					// Consume the event to remove Unity's default context menu
					//Event.current.Use();
				}
			} else if (_MenuOpened) {
				if (Event.current.type == EventType.mouseDown && Event.current.button == 0) {
					_MenuOpened = false;
					EditorApplication.RepaintHierarchyWindow();
				}
			}
		}
		if (_MenuOpened) {
			if (GUI.Button(new Rect(_MenuPosition.x, _MenuPosition.y, 150, 20f), "Delete")) {
				_MenuOpened = false;
				// GameObject.Destroy(_ClickedObject);
			}
		}
	}

	static void OnUpdate() {
	}
}

public class HierarchyTools : MonoBehaviour {
}

    [ExecuteInEditMode]
public class SceneViewCamera : MonoBehaviour {
	private ChapterObjectsTraverser<object> _traverser = null;
	private Mesh _mesh = new Mesh();

	void Awake() {
		_traverser = new ChapterObjectsTraverser<object>();
	}

	void OnRenderObject() {
		ChapterManager.currentChapterRoot = null;
		List<GameObject> rootObjs = ChapterEditor.getSceneRoots();

        HierarchyTools ht = null;
        foreach (GameObject go in rootObjs) {
            HierarchyTools ht1 = go.GetComponent<HierarchyTools>();
            if (ht1 != null) {
                if (ht == null) {
                    ht = ht1;
                } else {
                    DestroyImmediate(ht);
                }
            }
        }
        if (ht == null) {
            GameObject go = new GameObject();
            go.name = "1";
            go.AddComponent<HierarchyTools>();
            Debug.Log(go.transform.parent);
        } else if (ht.gameObject != rootObjs[0]) {

        }

        foreach (GameObject go in rootObjs) {
			ChapterRoot root = go.GetComponent<ChapterRoot>();
			if (root != null) {
				ChapterManager.currentChapterRoot = root;
				break;
			}
		}
		/*
        GL.Clear(true, true, Color.black);

        GameObject go = Selection.activeGameObject;
        if (go != null)
        {
            ChapterPolySprite cps = go.GetComponent<ChapterPolySprite>();
            if (cps != null)
            {
                cps._mat.SetPass(0);
                Graphics.DrawMeshNow(cps.getMesh(), go.transform.localToWorldMatrix);
            }
        }
        */

		_traverser.run(_draw, null, true);

        ChapterEditor.renderedObjects();

        SceneView.lastActiveSceneView.Repaint();
	}

	bool _draw(GameObject go, object data) {
		ChapterDisplayObject dis = go.GetComponent<ChapterDisplayObject>();
		if (dis == null) {
			SpriteRenderer sr = go.GetComponent<SpriteRenderer>();
			if (sr != null) {
				Sprite s = sr.sprite;
				if (s != null) {
					Vector2[] v2 = s.vertices;
					ushort[] t2 = s.triangles;


					Vector3[] v3 = new Vector3[v2.Length];
					for (int i = 0; i < v2.Length; i++) {
						v3[i] = v2[i];
					}
					int[] t3 = new int[t2.Length];
					for (int i = 0; i < t2.Length; i++) {
						t3[i] = t2[i];
					}

					_mesh.vertices = v3;
					_mesh.uv = s.uv;
					_mesh.triangles = t3;

					sr.sharedMaterial.mainTexture = s.texture;
					sr.sharedMaterial.SetPass(0);
					Graphics.DrawMeshNow(_mesh, go.transform.localToWorldMatrix);
				}
			}
		} else {
			dis.customRender();
		}

		return true;
	}
}