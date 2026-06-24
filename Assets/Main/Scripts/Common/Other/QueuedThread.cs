using System;
using System.Collections.Generic;
using System.Threading;
using GameFramework;

public interface IQueuedThreadTask
{
    void Process();
}

public class QueuedThread
{
    private Thread thread;
    private AutoResetEvent wakeupEvent = new AutoResetEvent(false);
    private volatile bool stop;
    private Queue<IQueuedThreadTask> tasks = new Queue<IQueuedThreadTask>(10);
    private string name;

    public QueuedThread()
    {
        
    }

    public QueuedThread(string name)
    {
        this.name = name;
    }
    
    public void Start()
    {
        stop = false;
        thread = new Thread(ThreadProc) {IsBackground = true};
        thread.SetThreadName(name);
        thread.Start();
    }

    public void Stop()
    {
        stop = true;
        Wakeup();
        if (thread != null)
        {
            thread.Join();
            thread = null;
        }

        tasks.Clear();
    }

    public void AddTask(IQueuedThreadTask task)
    {
        lock (tasks)
        {
            tasks.Enqueue(task);
        }

        Wakeup();
    }
    
    private void Sleep()
    {
        wakeupEvent.WaitOne();
    }

    private void Wakeup()
    {
        wakeupEvent.Set();
    }

    private void ThreadProc()
    {
        while (!stop)
        {
            IQueuedThreadTask task = null;
            lock (tasks)
            {
                if (tasks.Count > 0)
                {
                    task = tasks.Dequeue();
                }
            }

            if (task != null)
            {
                try
                {
                    task.Process();
                }
                catch (Exception e)
                {
                    Log.Error("exception: {0}, {1}, {2}",
                        string.IsNullOrEmpty(name) ? "[THREAD]" : name , e.Message, e.StackTrace);
                }
            }
            else
            {
                if (stop)
                {
                    return;
                }
                Sleep();
            }
        }
    }
}





