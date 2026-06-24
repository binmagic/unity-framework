using System.Collections;

/*
 * 游戏内代码写死的多语言id，每个id需要写明注释
*/
public class GameDialogDefine
{
    //选择道具
    public const string SELECT_ITEM = "120140";
    //选择
    public const string SELECT = "360005";
    //非友军{0}范围内禁止建设任何建筑
    public const string BUILD_LIMIT_OTHERBASE_RANGE = "130000";
    //基板只能在基地{0}范围内铺设
    public const string BUILD_BOARD_LIMIT_MYBASE_RANGE = "130001";
    //管道只能在基地{0}范围内铺设
    public const string BUILD_ROAD_LIMIT_MYBASE_RANGE = "130001";
    public const string BUILD = "110015";//建造
    public const string REMOVE = "130242";//删除
    public const string BOARD = "100037";//基板
    public const string ROAD = "100038";//管线
    public const string OWN = "130128";//拥有{0}
    public const string OUT = "130217";//产出
    public const string STORAGE = "130216";//库存
    public const string REPORT = "310019";//报告
    public const string TASK = "100179";//任务
    public const string COMMANDERINFO = "280024";//指挥官信息
    public const string LEVEL_NUMBER = "300665";//等级{0}
    public const string SPLIT = "150033";//{0}/{1}
    public const string COMMANDER_REPORT = "100017";//指挥官报告
    public const string UIMAINBOTTOM_COMMANDER_TIP = "130003";//指挥官切换到建造模式再次点击可以关闭建造模式
    
    public const string TIME = "100018";//时间
    public const string NEED_MINE = "100019";//需硫
    public const string NEED_BUILD_BUILDING = "130004";//先建造该建筑
    public const string GOODS = "100080";//物品
    
    public const string OIL = "100014";//燃油
    public const string METAL = "100013";//金属
    public const string NUCLEAR = "100012";//核燃料
    public const string FOOD = "100011";//食物
    public const string OXYGEN = "100010";//氧气
    public const string TRADE_PERCENT = "100009";//贸易压力(百分比)
    public const string HOUSE_PERCENT = "100008";//住房压力(百分比)
    public const string HOSPITAL_PERCENT = "100007";//医疗压力(百分比)
    public const string SCIENCE_PERCENT = "100006";//科技值(百分比)
    public const string BUILD_PERCENT = "100005";//建设压力(百分比)
    public const string ENVIRONMENT_PERCENT = "100004";//环境,默认0点,支持正负,显示的值负10-正10
    public const string WATER = "100546";//水
    public const string ELECTRICITY = "100002";//电
    public const string PEOPLE = "390098";//人口
    public const string MONEY = "100000";//资金
    public const string LACK_RESOURCE = "130072";//缺少资源:
    public const string LACK_ELECTRCITY_TIP = "130005";//指挥官电量已经不足、所有资源产出建筑将停产、请紧急处理
    public const string CAN_PUT = "130006";//可以放置
    public const string NO_PUT_REASON = "130007";//不可放置原因
    public const string INCLUD_MINEPOINT = "130008";//包含矿根点
    public const string INCLUDE_MINERANGE_POINT = "130009";//包含矿根周边
    public const string RESOURCE_BUILD_PUT_MINERANGE_POINT = "130010";//资源建筑要放在矿根周边
    public const string OUT_MYBASE_RANGE = "130011";//超出自己基地{0}格子范围
    public const string IN_OTHERBASE_RANGE = "130012";//其他玩家基地{0}格子内不能放置
    public const string NO_PUT_RANGE = "130013";//不可放置区域
    public const string INCLUDE_BUILDING = "130014";//包含建筑
    public const string INCLUDE_OTHER_BOARD = "130016";//包含其他玩家基板
    public const string INCLUDE_OTHER_ROAD = "130016";//包含其他玩家管道
    public const string INCLUDE_MY_ROAD = "130017";//包含自己管道
    public const string THIS_UPGRADING = "130018";//该{0}正在升级
    public const string UNDO = "110106";//撤销
    public const string RANDOM = "130019";//随机
    public const string NEW_BASE_RESOURCE_PERCENT = "130020";//雷达扫描着陆地点附近的资源情况如下
    public const string INCLUDE_OTHER_MINERANGE_POINT = "130009";//包含其他矿根类型周边
    public const string OUT_UNLOCK_RANGE_REASON = "130022";//不在已经锁范围内,解锁范围:({0},{1}) - ({2},{3})
    public const string UNCONNECT_BOARD_REASON = "130023";//未与建筑或基板连接
    public const string UNCONNECT_ROAD_REASON = "130023";//未与建筑、基板或管线连接
    public const string ONLY_IN_INSIDE = "120230";//只能在苍穹内放置
    public const string ONLY_OUT_INSIDE = "120231";//只能在苍穹外放置
    public const string ONLY_IN_MAIN_INSIDE = "120232";//辅建筑只能在主建筑范围内
    public const string NOT_BUILD_ON_BASE_EXPANSION = "120233";//不能建造在苍穹上
    public const string NOT_BUILD_ON_WORLD_RESOURCE = "120234";//不能建造在资源点上
    public const string ONLY_BUILD_ROAD = "120954";//该点只能铺设道路
    public const string BUILD_UN_CONNECT = "120955";//当前建筑未联通
    public const string NEED_FIRST_BUILD = "170385";//你需要先建造{0}
    public const string RESET = "150116";//重置
    public const string MONSTER = "100353";//野怪
    public const string COLLECT_RESOURCE_DESTROY = "120006";//矿跟正在销毁中
    public const string NO_PUT_ROAD = "130212";//该地区无法铺设道路
    public const string GOTO = "110003";//前往
    public const string ROAD_UN_CONNECT = "130606";//道路未连接
    public const string ROAD_REACH_BUILD_MAX = "100555";//道路已经修建达到上限无法继续放置
    public const string LEFT = "310134";//剩余
    public const string GUIDE_BUILD_ROAD = "130212";//
    public const string NO_ARRIVE_FOG = "300716";//此位置无法抵达，需预先探索沿途迷
    public const string CONFIRM = "110006";//确定
    public const string CANCEL = "110106";//取消
    
}





