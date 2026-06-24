using System.Collections;

namespace Sfs2X.Core
{
  // 我们基本上都是扩展消息，所以这里新整一个event类型，没有必要每次都放到hash表里然后来回取。浪费！
  public class ExtensionEvent : BaseEvent
  {
    public string cmd;
    public object rawData;

    public ExtensionEvent(string type, string c, object rd)
      : base(type, null)
    {
      cmd = c;
      rawData = rd;
    }
  }
}





