using System;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(MeshFilter), typeof(MeshRenderer))]
public class SpriteMeshRenderer : MonoBehaviour
{
    private static readonly int Prop_MainTex = Shader.PropertyToID("_MainTex");
    private static readonly int Prop_Color = Shader.PropertyToID("_Color");

    class MeshReference
    {
        public Mesh mesh;
        public int refCount;
    }
    private static Dictionary<Sprite, MeshReference> _meshes = new Dictionary<Sprite, MeshReference>();

    private MeshFilter _meshFilter;
    private MeshRenderer _meshRenderer;
    private Material _material;

    [SerializeField] private Material _sharedMaterial;
    [SerializeField] private Sprite _sprite;

    [SerializeField] private int _sortingLayerID;
    [SerializeField] private int _sortingOrder;

    [SerializeField] private Color _color = Color.white;
    public int sortingLayerID => _sortingLayerID;
    public int sortingOrder => _sortingOrder;

    public Color color
    {
        get => _color;
        set
        {
            _color = value;
            if (_material != null)
            {
                _material.SetColor(Prop_Color, _color);
            }
        }
    }

    public Sprite sprite
    {
        get => _sprite;
        set
        {
            if (_sprite != value)
            {
                if (_meshFilter.sharedMesh != null)
                {
                    ReleaseMesh(_sprite);
                }
                
                _sprite = value;
                if (_material != null)
                {
                    _material.SetTexture(Prop_MainTex, _sprite.texture);
                }

                _meshFilter.sharedMesh = GetMesh(_sprite);
            }
        }
    }


    private bool _hasAwake;
    private void Awake()
    {
        _meshRenderer = GetComponent<MeshRenderer>();
        _meshRenderer.sortingLayerID = _sortingLayerID;
        _meshRenderer.sortingOrder = _sortingOrder;
        _meshRenderer.hideFlags = HideFlags.HideInInspector;
        if (_sharedMaterial != null)
        {
            _material = new Material(_sharedMaterial);
            if (_sprite != null)
            {
                _material.SetTexture(Prop_MainTex, _sprite.texture);
            }
            
            _material.SetColor(Prop_Color, _color);
            
            _meshRenderer.material = _material;
        }
        else
        {
            _meshRenderer.sharedMaterial = null;
        }
        
        _meshFilter = GetComponent<MeshFilter>();
        _meshFilter.hideFlags = HideFlags.HideInInspector;
        _meshFilter.sharedMesh = GetMesh(_sprite);

        _hasAwake = true;
    }

    private void OnDestroy()
    {
#if UNITY_EDITOR
        DestroyImmediate(_material);
#else
        Destroy(_material);
#endif
        
        Destroy(_material);
        ReleaseMesh(_sprite);
    }
    
    private static Mesh GetMesh(Sprite sprite)
    {
        if (sprite == null)
        {
            return null;
        }
        
        MeshReference meshRef;
        if (_meshes.TryGetValue(sprite, out meshRef))
        {
            meshRef.refCount++;
            return meshRef.mesh;
        }

        meshRef = new MeshReference {mesh = SpriteToMesh(sprite), refCount = 1};
        _meshes.Add(sprite, meshRef);
        return meshRef.mesh;
    }
    
    private static Mesh SpriteToMesh(Sprite sprite)
    {
        if (sprite == null)
            return null;
        Mesh mesh = new Mesh();
        mesh.vertices = Array.ConvertAll(sprite.vertices, i => (Vector3)i);
        mesh.uv = sprite.uv;
        mesh.triangles = Array.ConvertAll(sprite.triangles, i => (int)i);
        mesh.name = sprite.name;
        
        return mesh;
    }

    private static void ReleaseMesh(Sprite sprite)
    {
        if (sprite == null)
        {
            return;
        }
        
        MeshReference meshRef;
        if (_meshes.TryGetValue(sprite, out meshRef))
        {
            meshRef.refCount--;
            if (meshRef.refCount <= 0)
            {
#if UNITY_EDITOR
                if (Application.isPlaying)
                {
                    Destroy(meshRef.mesh);
                }
                else
                {
                    DestroyImmediate(meshRef.mesh);
                }
#else
                Destroy(meshRef.mesh);
#endif
                
                _meshes.Remove(sprite);
            }
        }
    }

#if UNITY_EDITOR
    private Material _lastMaterial;
    
    private void OnValidate()
    {
        if(!_hasAwake)
            return;
        
        if (_meshRenderer == null)
        {
            _meshRenderer = GetComponent<MeshRenderer>();
            _meshRenderer.hideFlags = HideFlags.HideInInspector;
        }

        _meshRenderer.sortingLayerID = _sortingLayerID;
        _meshRenderer.sortingOrder = _sortingOrder;
        
        if (_sharedMaterial != null)
        {
            if (_lastMaterial != _sharedMaterial)
            {
                if (_material != null)
                {
                    DestroyImmediate(_material);
                }

                _lastMaterial = _sharedMaterial;
                _material = new Material(_sharedMaterial);
                _meshRenderer.sharedMaterial = _material;
            }
        }
        else
        {
            _meshRenderer.sharedMaterial = null;
        }

        if (_material != null)
        {
            _material.SetTexture(Prop_MainTex, _sprite == null ? null : _sprite.texture);
            _material.SetColor(Prop_Color, _color);
        }

        if (_meshFilter == null)
        {
            _meshFilter = GetComponent<MeshFilter>();
            _meshFilter.hideFlags = HideFlags.HideInInspector;
            _meshFilter.sharedMesh = null;
        }

        if (_meshFilter.sharedMesh != null)
        {
            DestroyImmediate(_meshFilter.sharedMesh);
            _meshFilter.sharedMesh = null;
        }
        
        _meshFilter.sharedMesh = SpriteToMesh(_sprite);
    }
    
#endif
}





