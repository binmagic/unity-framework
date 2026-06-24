public class LoginErrorCode
{
    // 网络出错列表
    public const string ERROR_CONN_LOST = "error connect lost"; // 连接丢失
    public const string ERROR_LOGOUT = "error logout"; // 登出
    public const string ERROR_NO_NET = "error no net"; // 没有网络
    public const string ERROR_CONNECT = "error connect error";   // 连接错误

    public const string ERROR_BANID = "4";              // 封号
    public const string ERROR_IPBLACK = "43";           // ip黑名单
    public const string ERROR_DEVICEBLACK = "44";       // device黑名单


    public const string ERROR_SUCCESS = "E000";    // 成功
    public const string ERROR_NETWORK = "E101";    // 网络错误
    public const string ERROR_HTTP = "E102";        // Http错误
    public const string ERROR_JSON = "E103";        // Json格式错误
    public const string ERROR_DATA = "E104";        // 数据错误
    public const string ERROR_UNREACHABLE = "E105"; // 网络不可达
    public const string ERROR_INIT = "E106";        // PushInit 错误
    public const string ERROR_INIT_TIMEOUT = "E107";// PushInit 超时
    public const string ERROR_TIMEOUT = "E108";     // 网络超时
    public const string ERROR_MAINTENANCE = "E109"; // 服务器维护
    public const string ERROR_SERVER_STATE = "E110";
    public const string ERROR_LOAD_DATATABLE = "E111"; // 加载配置表错误
    public const string ERROR_LOAD_DATATABLE_TIMEOUT = "E112"; // 加载配置表超时
    public const string ERROR_LOGIN_TIMEOUT = "E113"; // login超时
    public const string ERROR_UPDATE_MANIFEST = "E114"; // 下载Manifest错误
    public const string ERROR_DOWNLOAD_UPDATE = "E115"; // 下载更新错误
    public const string ERROR_SERVER_LIST = "E116"; // gsl返回错误码
    public const string ERROR_LOGIN_ERROR = "E117"; // 登陆错误
    public const string ERROR_CHECK_VERSION_TIMEOUT = "E118"; // 检查版本超时
    public const string ERROR_CHECK_VERSION_FAILED = "E119"; // 检查版本失败
    public const string ERROR_SERVER_LIST_EMPTY = "E120"; // 没有返回server list
    public const string ERROR_DOWNLOAD_ZIP_ERROR = "E121";//下载压缩包错误
    public const string ERROR_DOWNLOAD_ZIP_TIMEOUT = "E122";//下载压缩包超时
}





