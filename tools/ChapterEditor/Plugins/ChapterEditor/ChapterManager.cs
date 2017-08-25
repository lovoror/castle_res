using UnityEditor;
using UnityEngine;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

public class ChapterManager {
	public static bool updateProjectWindow = false;
	public static ChapterRoot currentChapterRoot = null;
	public static bool isMouseLeftButtonDown = false;

	public static void listRemoveOrderIndices<T>(List<T> list, List<int> orderIndices, int numPerUnit) {
		int num = orderIndices.Count;

		for (int i = 0; i < num; i++) {
			int idx = orderIndices[i];

			if (i + 1 < num) {
				int next = orderIndices[i + 1] - 1;

				for (int j = idx; j < next; j++) {
					int idx1 = j * numPerUnit;
					int idx2 = (j + 1) * numPerUnit;

					for (int k = 0; k < numPerUnit; k++) {
						list[idx1 + k] = list[idx2 + k];
					}
				}
			} else {
				int next = list.Count / numPerUnit - 1;
				for (int j = idx; j < next; j++) {
					int idx1 = j * numPerUnit;
					int idx2 = (j + 1) * numPerUnit;

					for (int k = 0; k < numPerUnit; k++) {
						list[idx1 + k] = list[idx2 + k];
					}
				}
			}
		}

		num *= numPerUnit;
		list.RemoveRange(list.Count - num, num);
	}

	public static void quickSort<T>(List<T> array, int left, int right) where T : IComparable {
		if (left < right) {
			int middle = getMiddleFroQuickSort<T>(array, left, right);

			quickSort<T>(array, left, middle - 1);
			quickSort<T>(array, middle + 1, right);
		}
	}

	private static int getMiddleFroQuickSort<T>(List<T> array, int left, int right) where T : IComparable {
		T key = array[left];
		while (left < right) {
			while (left < right && key.CompareTo(array[right]) < 0) {
				right--;
			}
			if (left < right) {
				T temp = array[left];
				array[left] = array[right];
				//Console.WriteLine("array[{0}]:{1} ---->  arry[{2}]:{3}", left, temp, right, array[right]);
				left++;
			}

			while (left < right && key.CompareTo(array[left]) > 0) {
				left++;
			}
			if (left < right) {
				T temp = array[right];
				array[right] = array[left];
				//Console.WriteLine("array[{0}]:{1} ----> arry[{2}]:{3}", right, temp, left, array[left]);
				right--;
			}
			array[left] = key;
		}
		//Console.WriteLine("find the middle value {0} and the index {1}", array[left], left);
		return left;
	}
}

public enum MouseDownState {
	NONE,
	PICK_NONE,
	PICK_SINGLE,
	PICK_MULTI,
    PICK_NRM_SINGLE
}

public enum SelectType {
	SINGLE,
	ADD,
	REMOVE,
	ADD_OR_REMOVE
}

public enum LockState {
    UNLOCK,
    LOCK,
    INDIRECT_LOCK
}

public class PickData {
	public Ray ray;
	public GameObject pickGameObject = null;
	public int pickPolySpriteIndex = -1;
	public List<GameObject> pickGameObjects = null;
	public Vector3 regionLeftTop;
	public Vector3 regionRightBottom;
	public SelectType selectType;

	public static PickData createPickGameObjectData(Ray ray) {
		PickData pd = new PickData();
		pd.ray = ray;
		return pd;
	}

	public static PickData createPickGameObjectsData(Vector3 lt, Vector3 rb, SelectType type) {
		PickData pd = new PickData();
		pd.regionLeftTop = lt;
		pd.regionRightBottom = rb;
		pd.selectType = type;
		pd.pickGameObjects = new List<GameObject>();
		return pd;
	}
}
