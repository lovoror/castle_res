using System;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using System.Linq;
using System.Text;
using System.Reflection;

public class SceneHierarchyWindowHelper {
	private static Dictionary<string, List<MemberInfo>> _members;

	[InitializeOnLoadMethod]
	private static void init() {
		_members = new Dictionary<string, List<MemberInfo>>();

		Type type = typeof(EditorWindow).Assembly.GetType("UnityEditor.SceneHierarchyWindow");

		/*
		string newline = "\r\n";
		string msg = "";

		msg += "public static" + newline;
		MethodInfo[] ms = type.GetMethods(BindingFlags.Public | BindingFlags.Static);
		foreach (var mi in ms) {
			msg += mi + newline;
		}

		msg += newline + "private static" + newline;
		ms = type.GetMethods(BindingFlags.NonPublic | BindingFlags.Static);
		foreach (var mi in ms) {
			msg += mi + newline;
		}

		msg += newline + "public ins" + newline;
		ms = type.GetMethods(BindingFlags.Public | BindingFlags.Instance);
		foreach (var mi in ms) {
			msg += mi + newline;
		}

		msg += newline + "private ins" + newline;
		ms = type.GetMethods(BindingFlags.NonPublic | BindingFlags.Instance);
		foreach (var mi in ms) {
			msg += mi + newline;
		}
		*/

		Assembly assembly = Assembly.GetExecutingAssembly(); // 获取当前程序集
		Type type1 = typeof(EditorWindow).Assembly.GetType("UnityEditor.TreeView");
		MemberInfo[] mis1 = type1.GetMembers(BindingFlags.Instance | BindingFlags.Static | BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.DeclaredOnly);
		foreach (MemberInfo mi in mis1) {
			string msg = mi + "	" + mi.MemberType;
			if (mi.MemberType == MemberTypes.Property) {
				PropertyInfo pi = (PropertyInfo)mi;
				msg += "		" + pi.CanRead + "  " + pi.CanWrite;

			}

			Debug.Log(msg);
		}

		//Debug.Log(msg);

		MemberInfo[] mis = type.GetMembers(BindingFlags.Instance | BindingFlags.Static | BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.DeclaredOnly);
		foreach (MemberInfo mi in mis) {
			//mi.MethodHandle.GetFunctionPointer().ToPointer();
			List<MemberInfo> members;
			_members.TryGetValue(mi.Name, out members);
			if (members == null) {
				members = new List<MemberInfo>();
				_members.Add(mi.Name, members);
			}
			members.Add(mi);
		}
	}

	public static object get_lastInteractedHierarchyWindow() {
		List<MemberInfo> members;
		_members.TryGetValue("get_lastInteractedHierarchyWindow", out members);
		if (members == null) {
			return null;
		} else {
			return ((MethodInfo)members[0]).Invoke(null, null);
		}
	}

	public static object getTreeView(object target) {
		if (target == null) return null;

		List<MemberInfo> members;
		_members.TryGetValue("treeView", out members);
		if (members == null) {
			return null;
		} else {
			return ((PropertyInfo)members[0]).GetValue(target, null);
		}
	}
}