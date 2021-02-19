using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class TestUIPresenter : BaseUIPresenter
{
    public Button BtnA
    {
        get
        {
            return view.buttons["Test/ButtonA"];
        }
    }
    public Button BtnB
    {
        get
        {
            return view.buttons["Test/ButtonB"];
        }
    }

    public Text TestText
    {
        get
        {
            return view.texts["Test/Text"];
        }
    }

    public Image TestImage
    {
        get
        {
            return view.images["Test/Image"];
        }
    }

    private void Start()
    {
        BtnA.onClick.AddListener(() =>
        {
            TestText.text = "click btnA, zoom image to 1";
            StopAllCoroutines();
            StartCoroutine(ScaleNode(TestImage.transform, 1f));
        });

        BtnB.onClick.AddListener(() =>
        {
            TestText.text = "click btnB, zoom image to 0";
            StopAllCoroutines();
            StartCoroutine(ScaleNode(TestImage.transform, 0f));
        });


    }

    IEnumerator ScaleNode(Transform node, float scale)
    {
        var willScale = scale;
        var rawScale = node.transform.localScale;
        var targetScale = Vector3.one * willScale;
        var progress = 0f;
        while (progress < 1f)
        {
            progress += Time.deltaTime;
            node.localScale = Vector3.Lerp(rawScale, targetScale, progress);
            yield return 0;
        }
        node.localScale = targetScale;
    }
}
