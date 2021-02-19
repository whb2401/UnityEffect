using UnityEngine;
using System.Collections.Generic;
using UnityEngine.UI;

[CreateAssetMenu(fileName = "UIView", menuName = "UIView/UIView", order = 1)]
public class BaseUIView : ScriptableObject
{
    public GameObject uiPrefab;

    public Dictionary<string, Button> buttons = new Dictionary<string, Button>();

    public Dictionary<string, Image> images = new Dictionary<string, Image>();

    public Dictionary<string, Text> texts = new Dictionary<string, Text>();

    public Dictionary<string, BaseUINode> nodes = new Dictionary<string, BaseUINode>();

    public Transform root
    {
        get;
        private set;
    }
    
    public virtual void init()
    {
        if (uiPrefab == null)
        {
            Debug.LogError("[UIView] Prefab is null please connect it");
            return;
        }

        Clear();

        root = Instantiate(uiPrefab).transform;
        root.gameObject.name = root.gameObject.name.Replace("(Clone)", "");

        var btns = root.GetComponentsInChildren<Button>(true);
        for (int i = 0; i < btns.Length; i++)
        {
            buttons[GetGameObjectPath(btns[i].transform, root)] = btns[i];
        }

        var imgs = root.GetComponentsInChildren<Image>(true);
        for (int i = 0; i < imgs.Length; i++)
        {
            images[GetGameObjectPath(imgs[i].transform, root)] = imgs[i];
        }

        var txts = root.GetComponentsInChildren<Text>(true);
        for (int i = 0; i < txts.Length; i++)
        {
            texts[GetGameObjectPath(txts[i].transform, root)] = txts[i];
        }

        var uiNodes = root.GetComponentsInChildren<BaseUINode>(true);
        for (int i = 0; i < uiNodes.Length; i++)
        {
            nodes[GetGameObjectPath(uiNodes[i].transform, root)] = uiNodes[i];
        }
    }

    public virtual void Clear()
    {
        Destroy(root);
        buttons.Clear();
        images.Clear();
        texts.Clear();
        nodes.Clear();
    }

    public string GetGameObjectPath(Transform src, Transform root)
    {
        string path = src.name;
        while (src != root)
        {
            src = src.parent;
            path = src.name + "/" + path;
        }
        return path;
    }
}
