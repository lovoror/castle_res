using System;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using System.Linq;
using System.Text;
using System.Reflection;

public class TreeViewHelper {
	private static Dictionary<string, List<MemberInfo>> _members;

	[InitializeOnLoadMethod]
	private static void init() {
		_members = new Dictionary<string, List<MemberInfo>>();

		Type type = typeof(EditorWindow).Assembly.GetType("UnityEditor.TreeView");
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

	public static object getGUI(object target) {
		if (target == null) return null;

		List<MemberInfo> members;
		_members.TryGetValue("gui", out members);
		if (members == null) {
			return null;
		} else {
			return ((PropertyInfo)members[0]).GetValue(target, null);
		}
	}
}