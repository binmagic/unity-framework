using System;
using UnityEngine;
using System.Collections.Generic;
using System.Linq;
using GameFramework;
using UnityEngine.Rendering;
using Object = UnityEngine.Object;

[AddComponentMenu("Mesh/Super Text Mesh", 3)]
[ExecuteInEditMode]
[DisallowMultipleComponent]
[RequireComponent(typeof(MeshFilter))]
[RequireComponent(typeof(MeshRenderer))]
public class SuperTextMesh : MonoBehaviour
{
    private Transform t;
    private MeshFilter f;
    private MeshRenderer r;
    private bool isInit;
    private const int ReserveCount = 30;
    private List<STMCharInfo> info = new List<STMCharInfo>(ReserveCount); //switching this out for an array & using temp lists makes less appear in the deep profiler, but has no effect on GC
    private List<Vector3> endVerts = new List<Vector3>(ReserveCount * 4);
    private List<Vector2> endUv = new List<Vector2>(ReserveCount * 4);
    private List<Color32> endCol32 = new List<Color32>(ReserveCount * 4);
    private List<int> tris = new List<int>(ReserveCount * 6);
    private List<STMCharInfo> charInfoPool = new List<STMCharInfo>(ReserveCount);
    private int allocIndex;
    public float alpha = 1;
    
    [TextArea(3, 10)] //[Multiline] also works, but i like this better
    public string _text = string.Empty;

    public string text
    {
        get { return this._text; }
        set
        {
            // 文字不一样的时候，才做Rebuild处理，否则有些是每秒都要更新的，浪费
            if (this._text != value)
            {
	            if (IsRtl(value))
	            {
	                value = ArabicSupport.ArabicFixer.Fix(value);
	            }
                this._text = value;
                Rebuild();
            }
        }
    }
    
    private bool IsRtl(string str)
    {
        var isRtl = false;
        foreach (var _char in str)
        {
            if ((_char >= 1536 && _char <= 1791) || (_char >= 65136 && _char <= 65279))
            {
                isRtl = true;
                break;
            }
        }
        return isRtl;
    }

    public Color32 color32
    {
        get { return this._color; }
        set
        {
            this._color = value;
            Rebuild();
        }
    }
    
    public Color32 color
    {
        get { return this._color; }
        set
        {
            this._color = value;
            Rebuild();
        }
    }

#if UNITY_EDITOR
    // needed to track font changes from the inspector
    private Font m_LastTrackedFont;
#endif

    private Action _callBack;

    private string hyphenedText; //text, with junk added to it

    [Tooltip("Font to be used by this text mesh. .rtf, .otf, and Unity fonts are supported.")]
    public Font font;

    [Tooltip("Default color of the text mesh. This can be changed with the <c> tag! See the docs for more info.")]
    public Color32 _color = Color.white;

    [Tooltip("Size in local space for letters, by default. Can be changed with the <s> tag.")]
    public float size = 1f; //size of letter in local space! not percentage of quality. letters can have diff sizes individually

    [Range(1, 500)]
    [Tooltip("Point size of text. Try to keep it as small as possible while looking crisp!")]
    public int quality = 32; //actual text size. point size

    [Tooltip("Default letter style. Can be changed with the <i> and <b> tags, using rich text.")]
    public FontStyle style = FontStyle.Normal;

    [Tooltip("Adjust line spacing between multiple lines of text. 1 is the default for the font.")]
    public float lineSpacing = 1.0f;

    [Tooltip("Adjust additional spacing between characters. 0 is default.")]
    public float characterSpacing = 0.0f;

    [Tooltip("How far tabs indent.")]
    public float tabSize = 4.0f;

    [Tooltip("Distance in local space before a line break is automatically inserted at the previous space. Disabled if set to 0.")]
    public float autoWrap; //if text on one row exceeds this, insert line break at previously available space

    [Tooltip("With auto wrap, should large words be split to fit in the box?")]
    public bool breakText = true;

    [Tooltip("When large words are split, Should a hyphen be inserted?")]
    public bool insertHyphens = true;

    [Tooltip("The material to be used by this text mesh. Look under 'STM' in the shader menu for more compatible shaders.")]
    public Material textMat;

    public bool gradient;

    [SerializeField]
    Gradient effectGradient = new Gradient {colorKeys = new[] {new GradientColorKey(Color.black, 0), new GradientColorKey(Color.white, 1)}};

    public Gradient EffectGradient
    {
        get { return effectGradient; }
        set { effectGradient = value; }
    }

    public bool ztest = true;
    public bool outline;
    public Color outlineColor = Color.black;
    public Vector2 outlineDistance = new Vector2(0.01f, 0.01f);
    public string MaterialKey { get; set; }

    public enum Alignment
    {
        TopLeft,
        TopCenter,
        TopRight,
        MidLeft,
        MidCenter,
        MidRight,
        BotLeft,
        BotCenter,
        BotRight
    };

    public Alignment alignment = Alignment.TopLeft;

    [SerializeField]
    private float skewX;

    [SerializeField]
    private float skewY;

    [SerializeField]
    private string sortingLayer;

    [SerializeField]
    private int orderInLayer;

    private float AutoWrap
    {
        get { return autoWrap; }
    }

    private Mesh textMesh;
    private Vector3 rawTopLeftBounds;
    private Vector3 rawBottomRightBounds;
    private Vector3 topLeftBounds;
    private Vector3 topRightBounds;
    private Vector3 bottomLeftBounds;
    private Vector3 bottomRightBounds;
    private Vector3 centerBounds;

    private float lowestVert;
    private float rightestVert;
    private float _lineWidth;

    private int _lineCount;

    private float _width;

    public int LineCount => _lineCount;

//    void OnDrawGizmosSelected()
//    {
//        Gizmos.color = Color.blue;
//        RecalculateBounds();
//        Gizmos.DrawLine(topLeftBounds, topRightBounds); //top
//        Gizmos.DrawLine(topLeftBounds, bottomLeftBounds); //left
//        Gizmos.DrawLine(topRightBounds, bottomRightBounds); //right
//        Gizmos.DrawLine(bottomLeftBounds, bottomRightBounds); //bottom
//        Gizmos.DrawSphere(centerBounds, 0.1f);
//    }

    private STMCharInfo NewCharInfo(SuperTextMesh stm)
    {
        STMCharInfo i;
        if (allocIndex == charInfoPool.Count)
        {
            i = new STMCharInfo(stm);
            charInfoPool.Add(i);
            allocIndex = charInfoPool.Count;
            return i;
        }

        i = charInfoPool[allocIndex++];
        i.Reset(stm);
        return i;
    }
    
    private STMCharInfo NewCharInfo(STMCharInfo clone, CharacterInfo ch)
    {
        STMCharInfo i;
        if (allocIndex == charInfoPool.Count)
        {
            i = new STMCharInfo(clone, ch);
            charInfoPool.Add(i);
            allocIndex = charInfoPool.Count;
            return i;
        }

        i = charInfoPool[allocIndex++];
        i.Reset(clone, ch);
        return i;
    }

    private void ResetCharInfoPool()
    {
        allocIndex = 0;
    }

public void FontTextureChanged()
    {
        Rebuild();
    }

    private void Awake()
    {
        Init();
    }

    private void Init()
    {
        if (isInit)
            return;
        
        t = transform;
        f = GetComponent<MeshFilter>();
        r = GetComponent<MeshRenderer>();
        r.sortingLayerName = sortingLayer;
        r.sortingOrder = orderInLayer;
        
        for (int i = 0; i < ReserveCount; i++)
            charInfoPool.Add(new STMCharInfo(this));

        isInit = true;
    }

    public void SetOrderInLayer(int orderInLayer)
    {
        //orderInLayer = orderInLayer;
        r.sortingOrder = orderInLayer;
    }

    void OnEnable()
    {
        r.shadowCastingMode = ShadowCastingMode.Off;
        r.hideFlags = HideFlags.HideInInspector;
        f.hideFlags = HideFlags.HideInInspector;
        
        FontUpdateTracker.TrackText(this);
        Rebuild();
//        if (_lastText != _text)
//        {
//            Rebuild();
//            _lastText = _text;
//        }
    }

    private void OnDisable()
    {
        FontUpdateTracker.UntrackText(this);
    }

    private void OnDestroy()
    {
        if (textMesh != null)
        {
            #if UNITY_EDITOR
            DestroyImmediate(textMesh);
            #else
            Destroy(textMesh);
            #endif
        }
    }

#if UNITY_EDITOR
    void OnValidate()
    {
        if (textMesh == null)
            return;
        
       if (!font.dynamic)
        {
            if (font.fontSize > 0)
            {
                quality = font.fontSize;
            }
            else
            {
                Log.Info("You're probably using a custom font! \n Unity's got a bug where custom fonts have their size set to 0 by default and there's no way to change that! So to avoid this error, here's a solution: \n * Drag any font into Unity. Set it to be 'Unicode' or 'ASCII' in the inspector, depending on the characters you want your font to have. \n * Set 'Font Size' to whatever size you want 'quality' to be locked at. \n * Click the gear in the corner of the inspector and 'Create Editable Copy'. \n * Now, under the array of 'Character Rects', change size to 0 to clear everything. \n * Now you have a brand new font to edit that has a font size that's not zero! Yeah!");
            }

            style = FontStyle.Normal;
        }

        if (size < 0f)
        {
            size = 0f;
        }

        if (autoWrap < 0f)
        {
            autoWrap = 0f;
        }
        
        t = transform;
        f = GetComponent<MeshFilter>();
        r = GetComponent<MeshRenderer>();
        r.sortingLayerName = sortingLayer;
        r.sortingOrder = orderInLayer;

        if (font != m_LastTrackedFont)
        {
            Font newFont = font;
            font = m_LastTrackedFont;
            FontUpdateTracker.UntrackText(this);
            font = newFont;
            FontUpdateTracker.TrackText(this);

            m_LastTrackedFont = newFont;
        }
        
        Rebuild();
    }
#endif
    
    public void SetCallBack(Action callBack)
    {
        _callBack = callBack;
    }

    public void Rebuild()
    {
        if (font == null)
        {
            font = Resources.GetBuiltinResource<Font>("Arial.ttf");
        }

        Init();

        ResetCharInfoPool();
        RebuildTextInfo();
        ApplyAlignment();
        SetMesh();
        ApplyMaterial();
        RecalculateBounds();
        
        _callBack?.Invoke();
    }

    void RebuildTextInfo()
    {
        lowestVert = size;
        rightestVert = 0f;
        _lineCount = 0;
        info.Clear();
        for (int i = 0; i < text.Length; i++)
        {
            info.Add(NewCharInfo(this));
        }
        
        font.RequestCharactersInTexture(text, quality, style);
        for (int i = 0; i < text.Length; i++)
        {
            font.GetCharacterInfo(text[i], out info[i].ch, quality, style);
        }
        
        Vector3 pos = new Vector3(0f, 0f, 0f);

        if (AutoWrap > 0f)
        {
            hyphenedText = string.Copy(text);

            float lineWidth = info.Count > 0 ? info[0].indent : 0f;
            int indexOffset = 0;
            for (int i = 0, iL = hyphenedText.Length; i < iL; i++)
            {
                CharacterInfo spaceCh;
                font.GetCharacterInfo(' ', out spaceCh, quality, style);
                CharacterInfo hyphenCh;
                font.RequestCharactersInTexture("-", quality, style);
                font.GetCharacterInfo('-', out hyphenCh, quality, style);
                if (hyphenedText[i] == '\n')
                {
                    //is this character a line break?
                    lineWidth = 0f; //new line, reset
                }
                else if (hyphenedText[i] == '\t')
                {
                    // linebreak with a tab...
                    lineWidth += 0.5f * tabSize * info[i].size;
                }
                else
                {
                    lineWidth += info[i].Advance(characterSpacing, info[i].ch.size).x;
                }

                //TODO: watch out for natural hyphens going over bounds limits
                if (lineWidth > AutoWrap)
                {
                    int myBreak = hyphenedText.LastIndexOf(' ', i); //safe spot to do a line break, can be a hyphen
                    int myHyphenBreak = hyphenedText.LastIndexOf('-', i);
                    int myTabBreak = hyphenedText.LastIndexOf('\t', i); //can break at a tab, too!
                    int myActualBreak = Mathf.Max(new int[] {myBreak, myHyphenBreak, myTabBreak}); //get the largest of all 3
                    int lastBreak = hyphenedText.LastIndexOf('\n', i); //last place a ine break happened
                    if (!breakText && myActualBreak != -1 && myActualBreak > lastBreak)
                    {
                        //is there a space to do a line break? (and no hyphens...) AND we're not breaking text up at all
                        //
                        if (myActualBreak == myHyphenBreak)
                        {
                            //the break is at a hyphen
                            hyphenedText = hyphenedText.Insert(myActualBreak + 1, '\n'.ToString());
                            info.Insert(myActualBreak + 1, NewCharInfo(info[myActualBreak], spaceCh));
                            i = myActualBreak + 1; //go back
                            //if(AutoWrap < info[i - indexOffset].size){ //otherwise, it'll loop foreverrr
                            //	i += 1;
                            //}
                            iL += 1;
                            indexOffset += 1;
                        }
                        else
                        {
                            hyphenedText = hyphenedText.Remove(myActualBreak, 1); //this is wrong, don't remove the space ooops
                            hyphenedText = hyphenedText.Insert(myActualBreak, '\n'.ToString());
                            i = myActualBreak;
                        }

                        lineWidth = info[i].indent; //reset
                    }
                    else if (i != 0)
                    {
                        //split it here! but not if it's the first character
                        if (insertHyphens)
                        {
                            hyphenedText = hyphenedText.Insert(i, "-\n");
                            info.Insert(i, NewCharInfo(info[i - indexOffset], spaceCh));
                            info.Insert(i, NewCharInfo(info[i - indexOffset], hyphenCh));
                            if (AutoWrap < info[i - indexOffset].size)
                            {
                                //otherwise, it'll loop foreverrr
                                i += 2;
                            }

                            iL += 2;
                            indexOffset += 2;
                        }
                        else
                        {
                            hyphenedText = hyphenedText.Insert(i, "\n");
                            info.Insert(i, NewCharInfo(info[i - indexOffset], spaceCh));
                            if (AutoWrap < info[i - indexOffset].size)
                            {
                                //otherwise, it'll loop foreverrr
                                i += 1;
                            }

                            iL += 1;
                            indexOffset += 1;
                        }

                        lineWidth = info[i].indent; //reset
                    } //no need to check for following space, it'll come up anyway
                }
            }
        }
        else
        {
            hyphenedText = text;
        }
        
        //get position
        int currentLineCount = 0;
        for (int i = 0, iL = hyphenedText.Length; i < iL; i++)
        {
            info[i].pos = pos;
            info[i].line = currentLineCount;
            
            if (hyphenedText[i] == '\n')
            {
                //start new row at the X position of the indent character
                pos = new Vector3(0, pos.y, 0); //assume left-orintated for now. go back to start of row
                pos -= new Vector3(0, quality * lineSpacing, 0) * (size / quality); //drop down
                currentLineCount++;
            }
            else if (hyphenedText[i] == '\t')
            {
                //tab?
                pos += new Vector3(quality * 0.5f * tabSize, 0, 0) * (info[i].size / quality);
            }
            else
            {
                // Advance character position
                pos += info[i].Advance(characterSpacing, quality);
            }

            lowestVert = Mathf.Min(lowestVert, pos.y);
            rightestVert = Mathf.Max(rightestVert, info[i].BottomRightVert.x);
        }

        _lineCount = currentLineCount + 1;
    }

    void RecalculateBounds()
    {
        topLeftBounds = rawTopLeftBounds;
        topRightBounds = new Vector3(rawBottomRightBounds.x, rawTopLeftBounds.y, rawTopLeftBounds.z);
        bottomLeftBounds = new Vector3(rawTopLeftBounds.x, rawBottomRightBounds.y, rawBottomRightBounds.z);
        bottomRightBounds = rawBottomRightBounds;

        var rot = t.rotation;
        topLeftBounds = rot * topLeftBounds;
        topRightBounds = rot * topRightBounds;
        bottomLeftBounds = rot * bottomLeftBounds;
        bottomRightBounds = rot * bottomRightBounds;

        var scale = t.lossyScale;
        topLeftBounds.Scale(scale);
        topRightBounds.Scale(scale);
        bottomLeftBounds.Scale(scale);
        bottomRightBounds.Scale(scale);

        var pos = t.position;
        topLeftBounds = pos - topLeftBounds; //do this last, so previous transforms are based around 0
        topRightBounds = pos - topRightBounds;
        bottomLeftBounds = pos - bottomLeftBounds;
        bottomRightBounds = pos - bottomRightBounds;

        centerBounds = Vector3.Lerp(topLeftBounds, bottomRightBounds, 0.5f);
    }

    void ApplyAlignment()
    {
        float maxX = 0;
        for (int i = 0; i < info.Count; i++)
        {
            float x = info[i].TopRightVert.x;
            if (x > maxX)
            {
                maxX = x;
            }
        }

        _width = maxX;
        
        Vector3 offset = Vector3.zero;
        switch (alignment)
        {
            case Alignment.BotLeft:
                offset += new Vector3(0, lowestVert, 0);
                break;
            case Alignment.BotCenter:
                offset += new Vector3(maxX * 0.5f, lowestVert, 0);
                break;
            case Alignment.BotRight:
                offset += new Vector3(maxX, lowestVert, 0);
                break;
            case Alignment.MidLeft:
                offset += new Vector3(0, lowestVert * 0.5f, 0);
                break;
            case Alignment.MidCenter:
                offset += new Vector3(maxX * 0.5f, lowestVert * 0.5f, 0);
                break;
            case Alignment.MidRight:
                offset += new Vector3(maxX, lowestVert * 0.5f, 0);
                break;
            case Alignment.TopLeft:
                offset += new Vector3(0, 0, 0);
                break;
            case Alignment.TopCenter:
                offset += new Vector3(maxX * 0.5f, 0, 0);
                break;
            case Alignment.TopRight:
                offset += new Vector3(maxX, 0, 0);
                break;
        }

        for (int i = 0, iL = info.Count; i < iL; i++)
        {
            info[i].pos -= offset;
        }
        rawTopLeftBounds = new Vector3(offset.x, offset.y - size, offset.z); //scale to show proper bunds even when parent is scaled weird
        rawBottomRightBounds = new Vector3(AutoWrap > 0f ? offset.x - AutoWrap : offset.x - rightestVert, 
            offset.y - lowestVert, 
            offset.z);
    }

    //actually update the mesh attached to the meshfilter
    void SetMesh()
    {
        if (textMesh == null)
        {
            textMesh = new Mesh();
            textMesh.MarkDynamic();
        }
        
        textMesh.Clear();
        if (text.Length > 0)
        {
            endVerts.Clear();
            endUv.Clear();
            endCol32.Clear();
            tris.Clear();
            
            int vertCount = hyphenedText.Length * 4;
            int indexCount = hyphenedText.Length * 6;
            if (outline)
            {
                vertCount *= 5;
                indexCount *= 5;
            }
            
            if (endVerts.Capacity < vertCount)
                endVerts.Capacity = vertCount;
            if (endUv.Capacity < vertCount)
                endUv.Capacity = vertCount;
            if (endCol32.Capacity < vertCount)
                endCol32.Capacity = vertCount;
            if (tris.Capacity < indexCount)
                tris.Capacity = indexCount;
            
            for (int i = 0, iL = hyphenedText.Length; i < iL; i++)
            {
                var cinfo = info[i];
                endVerts.Add(cinfo.TopLeftVert);
                endVerts.Add(cinfo.TopRightVert);
                endVerts.Add(cinfo.BottomRightVert);
                endVerts.Add(cinfo.BottomLeftVert);
                endUv.Add(cinfo.ch.uvTopLeft);
                endUv.Add(cinfo.ch.uvTopRight);
                endUv.Add(cinfo.ch.uvBottomRight);
                endUv.Add(cinfo.ch.uvBottomLeft);
                endCol32.Add(color);
                endCol32.Add(color);
                endCol32.Add(color);
                endCol32.Add(color);
            }

            ModityMesh(endVerts, endUv, endCol32);
            
            // skew
            for (int i = 0; i < endVerts.Count; i++)
            {
                var v = endVerts[i];
                endVerts[i] = new Vector3(v.x + v.y * skewX, v.y + v.x * skewY, v.z);
            }

            for (int i = 0; i < endVerts.Count / 4; i++)
            {
                tris.Add(4 * i + 0);
                tris.Add(4 * i + 1);
                tris.Add(4 * i + 2);
                tris.Add(4 * i + 0);
                tris.Add(4 * i + 2);
                tris.Add(4 * i + 3);
            }
            
            textMesh.SetVertices(endVerts);
            textMesh.SetUVs(0, endUv);
            textMesh.SetColors(endCol32);
            textMesh.subMeshCount = 1;
            textMesh.SetTriangles(tris, 0);
        }
        f.sharedMesh = textMesh; //I dont think this has to be set multiple times but w/e
    }
    private static int mainTexId = Shader.PropertyToID("_MainTex");
    private static int mixAlphaID = Shader.PropertyToID("mixAlpha");
    private static int keyAlphaID = Shader.PropertyToID("_Alpha");
    void ApplyMaterial()
    {
        var mat = FontUpdateTracker.GetMaterial(this);
        if (mat != null)
        {
            mat.SetTexture(mainTexId, font.material.mainTexture);
            alpha = Mathf.Clamp(alpha,0, 1);
            mat.SetFloat(mixAlphaID, alpha);
            r.sharedMaterial = mat; 
        }
    }
    private  MaterialPropertyBlock matBlock;
    public void OnUpdate(float alpha)
    {
        if(matBlock==null)
        {
            matBlock = new MaterialPropertyBlock();
        }
        matBlock.SetFloat(keyAlphaID, alpha);
        r.SetPropertyBlock(matBlock);

    }

    private void ModityMesh(List<Vector3> verts, List<Vector2> uvs, List<Color32> colors)
    {
        if (gradient)
        {
            int nCount = verts.Count;
            float bottom = verts[0].y;
            float top = verts[0].y;
            for (int i = nCount - 1; i >= 1; --i)
            {
                float y = verts[i].y;
                if (y > top) top = y;
                else if (y < bottom) bottom = y;
            }

            float height = 1f / (top - bottom);

            for (int i = 0; i < nCount; i++)
            {
                colors[i] = colors[i] * effectGradient.Evaluate((verts[i].y - bottom) * height);
            }
        }

        if (outline)
        {
            var start = 0;
            var end = verts.Count;
            ApplyShadow(verts, uvs, colors, outlineColor, start, verts.Count, outlineDistance.x, outlineDistance.y);

            start = end;
            end = verts.Count;
            ApplyShadow(verts, uvs, colors, outlineColor, start, verts.Count, outlineDistance.x, -outlineDistance.y);

            start = end;
            end = verts.Count;
            ApplyShadow(verts, uvs, colors, outlineColor, start, verts.Count, -outlineDistance.x, outlineDistance.y);

            start = end;
            end = verts.Count;
            ApplyShadow(verts, uvs, colors, outlineColor, start, verts.Count, -outlineDistance.x, -outlineDistance.y);
        }
    }
    
    private void ApplyShadow(List<Vector3> verts, List<Vector2> uvs, List<Color32> colors, Color32 c, int start, int end, float x, float y)
    {
        Vector3 v;

        for (int i = start; i < end; ++i)
        {
            v = verts[i];
            verts.Add(v);
            colors.Add(colors[i]);
            uvs.Add(uvs[i]);

            v.x += x;
            v.y += y;
            
            colors[i] = c;
            verts[i] = v;
        }
    }
    
    public float GetHeight()
    {
        return lowestVert;
    }

    public float GetWidth()
    {
        return _width;
    }

    //设置文本的透明度 文字和描边都设置
    public void SetColorAlpha(float a)
    {
        if (matBlock == null)
        {
            matBlock = new MaterialPropertyBlock();
        }
        matBlock.SetFloat(keyAlphaID, a);
        r.SetPropertyBlock(matBlock);

        //color.a = (byte) Mathf.Round(Mathf.Clamp01(a) * (float) byte.MaxValue);
        //if (outline)
        //{
        //    outlineColor.a = a;
        //}
        //Rebuild();
    }
}

public class STMCharInfo
{
    public CharacterInfo ch; //contains uv data, point size (quality), style, etc
    public Vector3 pos; //where the bottom-left corner is
    public int line; //what line this text is on
    public float indent; //distance from left-oriented margin that a new row will start from
    public float size; //localspace size

    public Vector3 TopLeftVert
    {
        //return position in local space
        get { return RelativePos(new Vector3(ch.minX, ch.maxY, 0f)); }
    }

    public Vector3 TopRightVert
    {
        //return position in local space
        get { return RelativePos(new Vector3(ch.maxX, ch.maxY, 0f)); }
    }

    public Vector3 BottomRightVert
    {
        //return position in local space
        get { return RelativePos(new Vector3(ch.maxX, ch.minY, 0f)); }
    }

    public Vector3 BottomLeftVert
    {
        //return position in local space
        get { return RelativePos(new Vector3(ch.minX, ch.minY, 0f)); }
    }

    public Vector3 Middle
    {
        get { return RelativePos(new Vector3((ch.minX + ch.maxX) * 0.5f, (ch.minY + ch.maxY) * 0.5f, 0f)); }
    }

    public Vector3 RelativePos(Vector3 yeah)
    {
        return pos + yeah * (size / ch.size); //ch.size is quality
    }

    public Vector3 RelativePos2(Vector3 yeah)
    {
        //for quads
        return pos + yeah * size; //ch.size is quality
    }

    public Vector3 Advance(float extraSpacing, float myQuality)
    {
        //for getting letter position and autowrap data
        return new Vector3(ch.advance + (extraSpacing * size), 0, 0) * (size / myQuality);
    }

    public STMCharInfo(SuperTextMesh stm)
    {
        Reset(stm);
    }

    public STMCharInfo(STMCharInfo clone, CharacterInfo ch)
    {
        Reset(clone, ch);
    }

    public void Reset(STMCharInfo clone, CharacterInfo ch)
    {
        this.ch = ch;
        this.pos = clone.pos;
        this.line = clone.line;
        this.indent = clone.indent;
        this.size = clone.size;
    }

    public void Reset(SuperTextMesh stm)
    {
        this.ch = new CharacterInfo();
        this.ch.style = stm.style;
        this.pos = new Vector3();
        this.line = 0;
        this.indent = 0;
        this.size = stm.size;
    }
}

/// <summary>
///   Utility class that is used to help with Text update.
/// </summary>
/// <remarks>
/// When Unity rebuilds a font atlas a callback is sent to the font. Using this class you can register your text as needing to be rebuilt if the font atlas is updated.
/// </remarks>
static class FontUpdateTracker
{
    class FontMaterial
    {
        public Font font;
        public Material matZTestOn;
        public Material matZTestOff;
    }
    
    static Dictionary<Font, HashSet<SuperTextMesh>> m_Tracked = new Dictionary<Font, HashSet<SuperTextMesh>>();
    static Dictionary<Font, FontMaterial> m_FontMaterial = new Dictionary<Font, FontMaterial>();
    
    /// <summary>
    /// Register a Text element for receiving texture atlas rebuild calls.
    /// </summary>
    /// <param name="t">The Text object to track</param>
    public static void TrackText(SuperTextMesh t)
    {
        if (t.font == null)
            return;

        HashSet<SuperTextMesh> exists;
        m_Tracked.TryGetValue(t.font, out exists);
        if (exists == null)
        {
            // The textureRebuilt event is global for all fonts, so we add our delegate the first time we register *any* Text
            if (m_Tracked.Count == 0)
                Font.textureRebuilt += RebuildForFont;

            exists = new HashSet<SuperTextMesh>();
            m_Tracked.Add(t.font, exists);
        }

        if (!exists.Contains(t))
            exists.Add(t);
        
        if (!m_FontMaterial.TryGetValue(t.font, out var fontMat) && t.textMat != null)
        {
            fontMat = new FontMaterial();
            fontMat.matZTestOn = new Material(t.textMat);
            fontMat.matZTestOn.SetFloat("_ZTest", (int)CompareFunction.LessEqual);
            fontMat.matZTestOff = new Material(t.textMat);
            fontMat.matZTestOff.SetFloat("_ZTest", (int)CompareFunction.Disabled);
            m_FontMaterial.Add(t.font, fontMat);
        }
    }

    private static void RebuildForFont(Font f)
    {
        HashSet<SuperTextMesh> texts;
        m_Tracked.TryGetValue(f, out texts);

        if (texts == null)
            return;

        foreach (var text in texts)
            text.FontTextureChanged();
    }

    public static Material GetMaterial(SuperTextMesh t)
    {
        if (m_FontMaterial.TryGetValue(t.font, out var mat))
        {
            return t.ztest ? mat.matZTestOn : mat.matZTestOff;
        }
        return null;
    }

    /// <summary>
    /// Deregister a Text element from receiving texture atlas rebuild calls.
    /// </summary>
    /// <param name="t">The Text object to no longer track</param>
    public static void UntrackText(SuperTextMesh t)
    {
        if (t.font == null)
            return;

        HashSet<SuperTextMesh> texts;
        m_Tracked.TryGetValue(t.font, out texts);

        if (texts == null)
            return;

        texts.Remove(t);

        if (texts.Count == 0)
        {
            m_Tracked.Remove(t.font);
            if (m_FontMaterial.TryGetValue(t.font, out var fontMat))
            {
                DestroyImmediate(fontMat.matZTestOn);
                DestroyImmediate(fontMat.matZTestOff);

                m_FontMaterial.Remove(t.font);
            }

            // There is a global textureRebuilt event for all fonts, so once the last Text reference goes away, remove our delegate
            if (m_Tracked.Count == 0)
                Font.textureRebuilt -= RebuildForFont;
        }
    }
    
    static private void DestroyImmediate(Object obj)
    {
        if (obj != null)
        {
            if (Application.isEditor) Object.DestroyImmediate(obj);
            else Object.Destroy(obj);
        }
    }
}





