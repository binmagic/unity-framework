using Coffee.UIParticleExtensions;
using UnityEngine;
using UnityEngine.UI;
using DG.Tweening;
namespace Coffee.UIExtensions
{
    [ExecuteInEditMode]
    [RequireComponent(typeof(RectTransform))]
    [RequireComponent(typeof(CanvasRenderer))]
    public class UITrail : MaskableGraphic
    {
        private Mesh bakedMesh;
        private Mesh resultMesh;
        private TrailRenderer trailRenderer;
        
        public Material mat;
        
        //private MaterialPropertyBlock prop;

        protected override void OnEnable()
        {
            base.OnEnable();

            UIParticleUpdater.Register(this);
            bakedMesh = new Mesh();
            bakedMesh.MarkDynamic();
            resultMesh = new Mesh();
            resultMesh.MarkDynamic();
            
            trailRenderer = GetComponent<TrailRenderer>();
            //mat = new Material(trailRenderer.sharedMaterial);
            //prop = new MaterialPropertyBlock();
            this.color = new Color(1, 1, 1, 0);
            
            SetMaterialDirty();
        }
   

        protected override void OnDisable()
        {
            base.OnDisable();
            UIParticleUpdater.Unregister(this);
            #if UNITY_EDITOR
            if (!Application.isPlaying)
            {
                DestroyImmediate(bakedMesh);
                DestroyImmediate(resultMesh);  
            }
            else
            #endif
            {
                Destroy(bakedMesh);
                Destroy(resultMesh);
            }
        }

        protected override void UpdateMaterial()
        {
            
        }

        public void Refresh()
        {
            // bake mesh
            var camera = BakingCamera.GetCamera(canvas);
            trailRenderer.BakeMesh(bakedMesh, camera, true);

            var ci = new CombineInstance[1];
            ci[0] = new CombineInstance{mesh = bakedMesh, transform = transform.worldToLocalMatrix};
            resultMesh.CombineMeshes(ci, false, true);
            
            // set mesh
            canvasRenderer.SetMesh(resultMesh);
            
            // update material
            //trailRenderer.GetPropertyBlock(prop);
            
            canvasRenderer.materialCount = 1;
            canvasRenderer.SetMaterial(mat, 0);
        }
    }
}





