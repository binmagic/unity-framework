using System.Collections.Generic;
using System.Text;
using GameFramework;
using UnityEngine;

public class ObjectPoolMgr
{
	public ObjectPoolMgr()
	{
		root = new GameObject("ObjectPoolRoot");
		Object.DontDestroyOnLoad(root);
	}
	
    public ObjectPool GetPool(string prefabPath, ResourceManager resourceManager)
    {
	    ObjectPool pool;
        if (!poolList.TryGetValue(prefabPath, out pool))
        {
	        pool = new ObjectPool(this, prefabPath, resourceManager);
	        poolList.Add(prefabPath, pool);
        }
        return pool;
    }

    public void ClearPool(string prefabPath)
    {
	    ObjectPool pool;
        if (!poolList.TryGetValue(prefabPath, out pool))
        {
            return;
        }
        pool.Clear();
        poolList.Remove(prefabPath);
    }

    public void ClearAllPool(bool now = false)
    {
        foreach (ObjectPool objectPool in poolList.Values)
        {
            objectPool.Clear(now);
        }
        poolList.Clear();
    }

    public void ClearUnusedPool(bool now = false)
    {
	    var keys = new List<string>();
	    foreach (var i in poolList)
	    {
		    if (i.Value.Clear())
		    {
			    keys.Add(i.Key);
		    }
	    }

	    for (int i = 0; i < keys.Count; i++)
	    {
		    poolList.Remove(keys[i]);
	    }
    }

    public void DebugOutput()
    {
	    // 输出日志：每个池的对象数量，总对象数量
	    int totalPoolObj = 0;
	    int totalObj = 0;
	    StringBuilder builder = new StringBuilder();
	    foreach (var i in poolList)
	    {
		    var prefabPath = i.Key;
		    var pool = i.Value;

		    totalPoolObj += pool.GetPoolCount();
		    totalObj += pool.GetObjCount();
		    
		    builder.AppendLine($"pool: {prefabPath}, pool obj count: {pool.GetPoolCount()}, total obj count: {pool.GetObjCount()}");
	    }
	    
	    Log.Info($"ObjectPoolMgr: total pool obj count: {totalPoolObj}, total obj count: {totalObj}\n" + builder.ToString());
    }

    public void TryCleanPool()
    {
        foreach (var i in poolList)
        {
	        if (i.Value.TryClean())
	        {
		        unusedPool.Add(i.Key);
	        }
        }

        if (unusedPool.Count > 0)
        {
	        foreach (var i in unusedPool)
	        {
		        poolList.Remove(i);
	        }
	        unusedPool.Clear();
        }
    }
    
    public Transform Root
    {
	    get { return root.transform; }
    }

    public static readonly float CleanPoolTime = 60f;

    private GameObject root;
    private Dictionary<string, ObjectPool> poolList = new Dictionary<string, ObjectPool>(64);
    private List<string> unusedPool = new List<string>(64);
}

public class ObjectPool
{
	private ObjectPoolMgr mgr;
	private VEngine.Asset request;
	private Stack<GameObject> pool = new Stack<GameObject>();
	private int objCount;
	private float lastDespawnTime = float.MaxValue;
	
	//zlh note: 原来由于多个update执行顺序的问题 instancingList关联的pool在某帧有可能被错误的Clear了 导致Spawn异常 这里加个容错处理
	//单纯加个instanceCount可能会因上层重复调用Destroy导致计数异常，先用个map代替吧, 每个请求的instanceRequest都是唯一的
	private readonly Dictionary<InstanceRequest, bool> _instanceRecord = new Dictionary<InstanceRequest, bool>(8);

	public void AddInstanceRecord(InstanceRequest req)
	{
		if (req != null)
		{
			_instanceRecord[req] = true;
		}
	}

	public void RemoveInstanceRecord(InstanceRequest req)
	{
		if (req != null)
		{
			_instanceRecord.Remove(req);
		}
	}
	
	public bool IsAssetLoaded
	{
		get { return request == null || request.isDone; }
	}

	//这个地方加一个处理,做一个常驻,这样在其他地方使用objectPool的地方可以直接使用,不然代码还要各种判定处理,在确认没有用之后可以直接调用 alwayshold = false, 
	private bool _alwaysHold = false;
	public bool AlwaysHold
	{
		set { _alwaysHold = value; }
		get { return _alwaysHold; }
	}

	public ObjectPool(ObjectPoolMgr mgr, string prefabPath, ResourceManager resourceManager)
	{
		this.mgr = mgr;
		request = resourceManager.LoadAssetAsync(prefabPath, typeof(GameObject));
		if (request == null)
		{
			CommonUtils.LogErrorWithPost($"#ResourceManager# ObjectPool Constructor request is null! prefabPath:{prefabPath}");
		}
	}
	
	public GameObject Spawn(Transform parent = null)
	{
		if (request == null)
		{
			CommonUtils.LogErrorWithPost($"#ResourceManager# Pool Spawn: !!!request == null!!! why????");
			return null;
		}

		lastDespawnTime = float.MaxValue;
		if (pool.Count > 0)
		{
			GameObject gameObject = pool.Pop();
			gameObject.transform.SetParent(parent, false);
			gameObject.SetActive(true);
			return gameObject;
		}

		//非正常状态
		if (request.asset == null || request.status != VEngine.LoadableStatus.SuccessToLoad)
		{
			CommonUtils.LogErrorWithPost($"#ResourceManager# Pool Spawn: request Invalid! pathOrURL: {request.pathOrURL} status: {request.status}");
		}
		
		// Debug.Log($"****newInst: {request.asset.name}");
		GameObject go = Object.Instantiate(request.asset, parent) as GameObject;
		if (go == null)
		{
			CommonUtils.LogErrorWithPost($"#ResourceManager# Pool Spawn: Object.Instantiate error! go is null! pathOrURL: {request.pathOrURL} status: {request.status}");
		}
		
		objCount++;
		return go;
	}

	public void DeSpawn(GameObject obj, bool backToPool = true)
	{
		lastDespawnTime = Time.realtimeSinceStartup;
		if (backToPool || _alwaysHold)
		{
			obj.SetActive(false);
			obj.transform.SetParent(mgr.Root, false);
			pool.Push(obj);
		}
		else
		{
			obj.Destroy();
			objCount--;
		}
	}

	public bool Clear(bool now = false)
	{
		while (pool.Count != 0)
		{
			var go = pool.Pop();
			if (now)
			{
				Object.DestroyImmediate(go, false);
			}
			else
			{
				Object.Destroy(go);
			}

			objCount--;
		}
		pool.Clear();

		
#if false && !FINAL_RELEASE //之前的异常情况猜想验证 非正式包打印下log
		if (request != null && objCount == 0 && _instanceRecord.Count > 0)
		{
			var traceback = "";
			if (GameEntry.Lua != null && GameEntry.Lua.Env != null)
			{
				traceback = XLua.LuaDLL.Lua.Traceback(GameEntry.Lua.Env.L);
			}
			CommonUtils.LogErrorWithPost($"#ResourceManager# #zlh# guess right!!! the issue was indeed here before. prefabPath:{request?.pathOrURL} lua traceback: {traceback}");
		}
#endif
		
		if (request != null && objCount == 0 && _instanceRecord.Count == 0)
		{
			request.Release();
			request = null;
			return true;
		}

		return false;
	}

	public bool TryClean()
	{
		if (Time.realtimeSinceStartup - lastDespawnTime >= ObjectPoolMgr.CleanPoolTime)
		{
			if (_alwaysHold == false)
				Clear();
		}

		return objCount <= 0 && (request == null || request.isDone);
	}

	public int GetPoolCount()
	{
		return pool.Count;
	}

	public int GetObjCount()
	{
		return objCount;
	}

	public void SetPriority(int v)
	{
		if (request != null)
		{
			request.SetPriority(v);
		}
	}
	
	
}





