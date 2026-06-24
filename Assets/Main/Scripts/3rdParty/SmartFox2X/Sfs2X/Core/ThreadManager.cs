using System.Collections.Generic;
using System.Threading;
using Sfs2X.Core.Sockets;
using Sfs2X.Logging;
using Sfs2X.Util;
/*
namespace Sfs2X.Core
{
  public delegate void WriteBinaryDataDelegate(PacketHeader header, ByteArray binData, bool udp);

  
  public class ThreadManager
  {
    private bool running;
    private bool inHasQueuedItems;
    private Queue<InPacket> inThreadQueue = new Queue<InPacket>(32);
    private object inQueueLocker = new object();
    private bool outHasQueuedItems;
    private Queue<OutPacket> outThreadQueue = new Queue<OutPacket>(32);
    private object outQueueLocker = new object();
    private Thread inThread;
    private Thread outThread;
    public Logger log;

    private static void Sleep(int ms)
    {
      Thread.Sleep(ms);
    }

    private void InThread()
    {
      try
      {
        while (running)
        {
          Sleep(5);
          if (inHasQueuedItems)
          {
            lock (inQueueLocker)
            {
              while (inThreadQueue.Count > 0 && running)
              {
                var item = inThreadQueue.Dequeue();
                item.Execute();
              }

              inHasQueuedItems = false;
            }
          }
        }
      }
      catch (ThreadAbortException abortException)
      {
        log.Error("InThread Abort!");
      }
      catch (System.Exception ex)
      {
        log.Error("InThread exception: " + ex.Message);
      }
      finally
      {
        log.Info("InThread exit!");
      }
      
    }

    private void OutThread()
    {
      try
      {
        while (running)
        {
          Sleep(5);
          if (outHasQueuedItems)
          {
            lock (outQueueLocker)
            {
              while (outThreadQueue.Count > 0 && running)
              {
                var outPacket = outThreadQueue.Dequeue();
                outPacket.Execute();
              }

              outHasQueuedItems = false;
            }
          }
        }
      }
      catch (ThreadAbortException abortException)
      {
        log.Error("OutThread Abort!");
      }
      catch (System.Exception ex)
      {
        log.Error("OutThread exception: " + ex.Message);
      }
      finally
      {
        log.Info("OutThread exit!");  
      }
      
      
    }

    public void Start()
    {
      if (running)
      {
        log.Error("Start thread but already started!!");  
        return;
      }
      
      running = true;
      
      inThreadQueue.Clear();
      outThreadQueue.Clear();
      
      if (inThread == null)
      {
        inThread = new Thread(InThread) {IsBackground = true};
        inThread.SetThreadName("SFSInThread");
        inThread.Start();
      }
      else
      {
        log.Error("inThread not null?!");
      }

      if (outThread != null)
      {
        log.Error("OutThread not null?!");
        return;
      }

      outThread = new Thread(OutThread) {IsBackground = true};
      outThread.SetThreadName("SFSOutThread");
      outThread.Start();
    }

    public void Stop()
    {
      // 这里修改成退出直接强制杀线程了，这里各种等待操作反倒容易出现问题
      running = false;

      try
      {
        if (outThread != null)
        {
          if (outThread.Join(100))
          {

          }
          else
          {
            outThread.Abort();
          }
        }
      }
      catch (ThreadAbortException abortException)
      {
        log.Error("Call outThread Abort!");
      }
      catch (System.Exception ex)
      {
        log.Error("Stop outThread exception: " + ex.Message);
      }
      finally
      {
        // 先停止发送线程，因为发送线程一般不会join超时
        
        try
        {
          if (inThread != null)
          {
            if (inThread.Join(200))
            {

            }
            else
            {
              inThread.Abort();
            }
          }
        }
        catch (ThreadAbortException abortException)
        {
          log.Error("Call inThread Abort!");
        }
        catch (System.Exception ex)
        {
          log.Error("Stop inThread exception: " + ex.Message);
        }
        
        inThread = null;
        outThread = null;
      
        log.Info("Stop Thread Over!!!");    
      }
      
      
    }

    private void StopThread()
    {
      running = false;
      inThread?.Join();
      outThread?.Join();
      inThread = null;
      outThread = null;
    }

    public void EnqueueDataCall(OnDataDelegate callback, ByteArray data)
    {
      var inPacket = new InPacket
      {
        Callback = callback,
        Data = data
      };
      
      lock (inQueueLocker)
      {
        inThreadQueue.Enqueue(inPacket);
        inHasQueuedItems = true;
      }
    }

    public void EnqueueCustom(ParameterizedThreadStart callback, InPacket data)
    {
      data.Callback = callback;
      lock (inQueueLocker)
      {
        inThreadQueue.Enqueue(data);
        inHasQueuedItems = true;
      }
    }

    public void EnqueueSend(WriteBinaryDataDelegate callback, PacketHeader header, ByteArray data, bool udp)
    {
      var outPacket = new OutPacket
      {
        Callback = callback,
        Header = header,
        Data = data,
        IsUdp = udp
      };
      
      lock (outQueueLocker)
      {
        outThreadQueue.Enqueue(outPacket);
        outHasQueuedItems = true;
      }
    }
  }
}
*/





