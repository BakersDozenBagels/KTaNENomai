using UnityEngine;
using System;

[ExecuteInEditMode, RequireComponent(typeof(Camera))]
public class BloomEffect : MonoBehaviour
{

    const int BoxDownPrefilterPass = 0;
    const int BoxDownPass = 1;
    const int BoxUpPass = 2;
    const int ApplyBloomPass = 3;
    const int DebugBloomPass = 4;

    public Shader bloomShader, _lerpShader, _nomaiShader;

    [Range(0, 10)]
    public float intensity = 1;

    [Range(1, 16)]
    public int iterations = 4;

    [Range(0, 10)]
    public float threshold = 1;

    [Range(0, 1)]
    public float softThreshold = 0.5f;

    public bool debug;

    RenderTexture[] textures = new RenderTexture[16];

    [NonSerialized]
    Material bloom, lerp;

    private Camera _duplicate, _orig;
    private RenderTexture _dupTexture;

    private void Start()
    {
        if(_dupTexture == null)
            _dupTexture = new RenderTexture(1, 1, 0);
        if(_duplicate == null)
        {
            _orig = GetComponent<Camera>();
            GameObject o = new GameObject("CamHolder");
            o.transform.parent = transform;
            o.transform.localPosition = Vector3.zero;
            o.transform.localEulerAngles = Vector3.zero;
            _duplicate = o.AddComponent<Camera>();
            _duplicate.CopyFrom(_orig);
            _duplicate.clearFlags = CameraClearFlags.Color;
            _duplicate.backgroundColor = new Color(0f, 0f, 0f, 0f);
            _duplicate.tag = "Untagged";
            _duplicate.targetTexture = _dupTexture;
            _duplicate.enabled = false;
        }
    }

    void OnRenderImage(RenderTexture trueSource, RenderTexture destination)
    {
        if(_duplicate == null)
        {
            Graphics.Blit(trueSource, destination);
            return;
        }

        _duplicate.fieldOfView = _orig.fieldOfView;

        if(lerp == null)
        {
            lerp = new Material(_lerpShader);
            lerp.hideFlags = HideFlags.HideAndDontSave;
        }

        if(bloom == null)
        {
            bloom = new Material(bloomShader);
            bloom.hideFlags = HideFlags.HideAndDontSave;
        }

        RenderTexture dupTex = RenderTexture.GetTemporary(trueSource.width, trueSource.height, 256, trueSource.format);
        _duplicate.targetTexture = dupTex;

        _duplicate.RenderWithShader(_nomaiShader, "RenderType");

        lerp.SetTexture("_LerpTex", dupTex);

        RenderTexture source = RenderTexture.GetTemporary(trueSource.width, trueSource.height, 0, trueSource.format);

        Graphics.Blit(trueSource, source, lerp, -1);

        _duplicate.targetTexture = _dupTexture;
        RenderTexture.ReleaseTemporary(dupTex);

        float knee = threshold * softThreshold;
        Vector4 filter;
        filter.x = threshold;
        filter.y = filter.x - knee;
        filter.z = 2f * knee;
        filter.w = 0.25f / (knee + 0.00001f);
        bloom.SetVector("_Filter", filter);
        bloom.SetFloat("_Intensity", Mathf.GammaToLinearSpace(intensity));

        int width = source.width / 2;
        int height = source.height / 2;
        RenderTextureFormat format = source.format;

        RenderTexture currentDestination = textures[0] =
            RenderTexture.GetTemporary(width, height, 0, format);
        Graphics.Blit(source, currentDestination, bloom, BoxDownPrefilterPass);
        RenderTexture currentSource = currentDestination;

        int i = 1;
        for(; i < iterations; i++)
        {
            width /= 2;
            height /= 2;
            if(height < 2)
            {
                break;
            }
            currentDestination = textures[i] =
                RenderTexture.GetTemporary(width, height, 0, format);
            Graphics.Blit(currentSource, currentDestination, bloom, BoxDownPass);
            currentSource = currentDestination;
        }

        for(i -= 2; i >= 0; i--)
        {
            currentDestination = textures[i];
            textures[i] = null;
            Graphics.Blit(currentSource, currentDestination, bloom, BoxUpPass);
            RenderTexture.ReleaseTemporary(currentSource);
            currentSource = currentDestination;
        }

        if(debug)
        {
            Graphics.Blit(currentSource, destination, bloom, DebugBloomPass);
        }
        else
        {
            bloom.SetTexture("_SourceTex", trueSource);
            Graphics.Blit(currentSource, destination, bloom, ApplyBloomPass);
        }
        RenderTexture.ReleaseTemporary(currentSource);
        RenderTexture.ReleaseTemporary(source);
        _duplicate.targetTexture = null;
    }
}