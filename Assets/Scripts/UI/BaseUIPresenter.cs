
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Canvas))]
public class BaseUIPresenter : MonoBehaviour
{
    public BaseUIView view;

    protected virtual void Awake()
    {
        if (view == null)
        {
            Debug.LogError("[UIController] View is null");
            return;
        }
        view.init();
        view.root.SetParent(transform, false);
    }

    public virtual void OnEnable()
    {
        view.root.gameObject.SetActive(true);
    }

    public virtual void OnDisable()
    {
        view.root.gameObject.SetActive(false);
    }

    protected void EnableSomeNode(params string[] names)
    {
        foreach (var item in view.nodes)
        {
            item.Value.gameObject.SetActive(false);
        }

        foreach (var item in names)
        {
            if (view.nodes.ContainsKey(item))
            {
                view.nodes[item].gameObject.SetActive(true);
            }
        }
    }
}
