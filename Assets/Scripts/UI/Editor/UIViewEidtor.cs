using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using UnityEngine.UI;

[CanEditMultipleObjects]
[CustomEditor(typeof(BaseUIView))]
public class UIViewEidtor : Editor
{
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();

        var uiview = target as BaseUIView;
        if (uiview.uiPrefab == null)
        {
            return;
        }

        var obj = ScriptableObject.CreateInstance<MyObject>();
        var btns = uiview.uiPrefab.GetComponentsInChildren<Button>(true);
        var imgs = uiview.uiPrefab.GetComponentsInChildren<Image>(true);
        var txts = uiview.uiPrefab.GetComponentsInChildren<Text>(true);
        var nodes = uiview.uiPrefab.GetComponentsInChildren<BaseUINode>(true);
        obj.btnNames = new string[btns.Length];
        obj.imgNames = new string[imgs.Length];
        obj.txtNames = new string[txts.Length];
        obj.nodeNames = new string[nodes.Length];
        var sObj = new SerializedObject(obj);
        var btnNames = sObj.FindProperty("btnNames");
        var imgNames = sObj.FindProperty("imgNames");
        var txtNames = sObj.FindProperty("txtNames");
        var nodeNames = sObj.FindProperty("nodeNames");

        for (int i = 0; i < btns.Length; i++)
        {
            btnNames.GetArrayElementAtIndex(i).stringValue = uiview.GetGameObjectPath(btns[i].transform, uiview.uiPrefab.transform);
        }
        for (int i = 0; i < imgs.Length; i++)
        {
            imgNames.GetArrayElementAtIndex(i).stringValue = uiview.GetGameObjectPath(imgs[i].transform, uiview.uiPrefab.transform);
        }
        for (int i = 0; i < txts.Length; i++)
        {
            txtNames.GetArrayElementAtIndex(i).stringValue = uiview.GetGameObjectPath(txts[i].transform, uiview.uiPrefab.transform);
        }
        for (int i = 0; i < nodes.Length; i++)
        {
            nodeNames.GetArrayElementAtIndex(i).stringValue = uiview.GetGameObjectPath(nodes[i].transform, uiview.uiPrefab.transform);
        }

        EditorGUILayout.PropertyField(btnNames, new GUIContent("全部UI按钮"));
        EditorGUILayout.PropertyField(imgNames, new GUIContent("全部UI图片"));
        EditorGUILayout.PropertyField(txtNames, new GUIContent("全部UI文字"));
        EditorGUILayout.PropertyField(nodeNames, new GUIContent("全部UI节点"));
        DestroyImmediate(obj);

    }

    public class MyObject : ScriptableObject
    {
        public string[] btnNames;
        public string[] imgNames;
        public string[] txtNames;
        public string[] nodeNames;
    }
}