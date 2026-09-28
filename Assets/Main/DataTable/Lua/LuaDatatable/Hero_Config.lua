local et = {}
local data_table =
 {
 ["index"] = {
["id"] = {1,"number"},
["name"] = {2,"string"},
["title"] = {3,"string"},
["faction"] = {4,"string"},
["role"] = {5,"string"},
["rarity"] = {6,"number"},
["base_firepower"] = {7,"number"},
["base_durability"] = {8,"number"},
["base_armor"] = {9,"number"},
["base_troop"] = {10,"number"},
["star"] = {11,"number"},
["owned"] = {12,"number"},
["level"] = {13,"number"},
["power"] = {14,"number"},
["skill_name"] = {15,"string"},
["skill_cooldown"] = {16,"number"},
["skill_tag"] = {17,"string"},
["skill_dmg_type"] = {18,"string"},
["skill_desc"] = {19,"string"},
["skill_rank_bonus"] = {20,"string"},
["skill_level"] = {21,"number"},
["skill_max_level"] = {22,"number"},
["portrait"] = {23,"string"},
["card"] = {24,"string"},
["avatar"] = {25,"string"},
["rank_durability"] = {26,"number"},
["rank_firepower"] = {27,"number"},
["rank_armor"] = {28,"number"},
["upgrade_cost"] = {29,"string"},
["promote_cost_1"] = {30,"string"},
["promote_cost_2"] = {31,"string"},
["shard_progress"] = {32,"string"},
["max_level"] = {33,"number"},
},
--[[
  纯UI还原，不接碎片/消耗流程
  faction: Empire/Federation/FreeArmy
  role: Output/Defense/Support
  rarity: 1普通 2稀有 3卓越 4传说
  owned: 1已拥有 0未拥有（图鉴显示暗卡+碎片进度；详情走满级预览/获取）
  power: 详情页战力数字（截图格式，不再显示"战力"前缀）
  rank_*: 军衔页"英雄xx 0 ≫ 目标"右侧满星预览值
  portrait/card/avatar: Assets/Main/Sprites/Hero/ 下的资源路径
]]
["data"] = {
	-- 已拥有（图鉴前排，对应截图）
	[1002]={1002,"塞西莉亚","甜心护士","Federation","Output",3,31,616,6,66,3,1,8,3481,"精准打击",1.0,"基础打击","物理伤害","机炮开火1次，造成20.00%的物理范围伤害","额外造成20%伤害（军衔1星）|额外伤害提升至35%（军衔2星）|额外伤害提升至60%（军衔3星）|额外伤害提升至80%（军衔4星）|额外伤害提升至120%（军衔5星）",1,1,"Assets/Main/Sprites/Hero/Hero_portrait_1002.png","Assets/Main/Sprites/Hero/Hero_card_1002.png","Assets/Main/Sprites/Hero/Hero_avatar_1002.png",1312,66,14,"4396/800","5/5","5/5","8级",80},
	[1001]={1001,"哈利","战术指挥官","Empire","Output",3,8,535,3,58,3,1,4,1578,"铁幕拦截",1.0,"基础打击","物理伤害","机炮开火1次，连续发射2发子弹，每发造成20.00%的物理伤害","额外造成15%伤害（军衔1星）|额外伤害提升至30%（军衔2星）|额外伤害提升至50%（军衔3星）|额外伤害提升至70%（军衔4星）|额外伤害提升至100%（军衔5星）",1,1,"Assets/Main/Sprites/Hero/Hero_portrait_1001.png","Assets/Main/Sprites/Hero/Hero_card_1001.png","Assets/Main/Sprites/Hero/Hero_avatar_1001.png",1317,27,11,"4396/400","5/5","5/5","4级",80},
	[1004]={1004,"诺娃","联邦飞行员","Federation","Support",2,25,50,30,10,3,1,1,420,"战术指挥",15.0,"辅助增益","能量伤害","为全队增加短时间的开火速度加成。","额外加成+10%（军衔1星）|额外加成+16%（军衔2星）|额外加成+22%（军衔3星）|额外加成+30%（军衔4星）|额外加成+40%（军衔5星）",1,1,"Assets/Main/Sprites/Hero/Hero_portrait_1004.png","Assets/Main/Sprites/Hero/Hero_card_1004.png","Assets/Main/Sprites/Hero/Hero_avatar_1004.png",120,40,22,"1200/200","0/5","0/5","1级",80},
	-- 未拥有（图鉴 0/10 碎片位；详情为满级预览 + 获取）
	[1003]={1003,"佩姬","诡笑杂耍师","FreeArmy","Output",4,28088,669114,6399,350,0,0,150,1397547,"狂飙掠影",2.0,"基础打击","能量伤害","连续发射4架爆破式飞行器，每架命中目标后爆炸造成185.60%火力的能量伤害","额外造成30%伤害|额外伤害提升至70%|额外伤害提升至120%|额外伤害提升至185%|额外伤害提升至270%",30,30,"Assets/Main/Sprites/Hero/Hero_portrait_1003.png","Assets/Main/Sprites/Hero/Hero_card_1003.png","Assets/Main/Sprites/Hero/Hero_avatar_1003.png",669114,28088,6399,"-","-","-","0/10",150},
	[1005]={1005,"博格","自由军先锋","FreeArmy","Defense",2,20,60,35,12,0,0,0,980,"顽固防守",10.0,"防御强化","物理伤害","短时间内大幅提升自身护甲，吸引敌方火力。","护甲+10%|护甲+18%|护甲+26%|护甲+36%|护甲+48%",1,1,"Assets/Main/Sprites/Hero/Hero_portrait_1005.png","Assets/Main/Sprites/Hero/Hero_card_1005.png","Assets/Main/Sprites/Hero/Hero_avatar_1005.png",980,120,80,"-","-","-","0/10",80},
	[1006]={1006,"罗克珊","红发双枪","FreeArmy","Output",3,70,35,15,6,0,0,0,2260,"追踪导弹",9.0,"基础打击","物理伤害","发射一枚追踪导弹，对命中目标造成高额伤害。","额外伤害+6%|额外伤害+12%|额外伤害+20%|额外伤害+30%|额外伤害+42%",1,1,"Assets/Main/Sprites/Hero/Hero_portrait_1006.png","Assets/Main/Sprites/Hero/Hero_card_1006.png","Assets/Main/Sprites/Hero/Hero_avatar_1006.png",920,210,60,"-","-","-","0/10",100},
	[1007]={1007,"克莱尔","夜爪魅影","Empire","Output",3,68,42,18,7,0,0,0,2180,"暗影突袭",8.0,"基础打击","物理伤害","闪现至目标身后，造成高额物理伤害并短暂隐身。","额外伤害+8%|额外伤害+16%|额外伤害+28%|额外伤害+40%|额外伤害+55%",1,1,"Assets/Main/Sprites/Hero/Hero_portrait_1007.png","Assets/Main/Sprites/Hero/Hero_card_1007.png","Assets/Main/Sprites/Hero/Hero_avatar_1007.png",880,200,55,"-","-","-","0/10",100},
	[1008]={1008,"美","帝国剑装","Empire","Defense",2,28,85,48,14,0,0,0,1520,"剑刃壁垒",12.0,"防御强化","物理伤害","展开剑阵护盾，为自身与相邻单位减伤。","减伤+8%|减伤+14%|减伤+20%|减伤+28%|减伤+38%",1,1,"Assets/Main/Sprites/Hero/Hero_portrait_1008.png","Assets/Main/Sprites/Hero/Hero_card_1008.png","Assets/Main/Sprites/Hero/Hero_avatar_1008.png",1450,90,160,"-","-","-","0/10",90},
	[1009]={1009,"艾瑞斯","联邦银发科技","Federation","Support",3,32,55,28,12,0,0,0,2410,"过载脉冲",14.0,"辅助增益","能量伤害","释放电磁脉冲，降低敌方射速并为友军充能。","冷却-4%|冷却-8%|冷却-12%|冷却-18%|冷却-25%",1,1,"Assets/Main/Sprites/Hero/Hero_portrait_1009.png","Assets/Main/Sprites/Hero/Hero_card_1009.png","Assets/Main/Sprites/Hero/Hero_avatar_1009.png",760,140,90,"-","-","-","0/10",100},
	[1010]={1010,"塞琳娜","哥特魅影","Federation","Output",2,40,38,20,8,0,0,0,1280,"暗夜低语",11.0,"基础打击","能量伤害","对随机目标造成多段能量伤害，命中后附加虚弱。","额外伤害+5%|额外伤害+10%|额外伤害+18%|额外伤害+28%|额外伤害+40%",1,1,"Assets/Main/Sprites/Hero/Hero_portrait_1010.png","Assets/Main/Sprites/Hero/Hero_card_1010.png","Assets/Main/Sprites/Hero/Hero_avatar_1010.png",720,130,50,"-","-","-","0/10",80},
	[1011]={1011,"海伦","金发女军官","Empire","Support",2,26,48,26,11,0,0,0,1180,"战术广播",13.0,"辅助增益","能量伤害","鼓舞全队，短时间内提升火力与命中。","加成+8%|加成+14%|加成+20%|加成+28%|加成+36%",1,1,"Assets/Main/Sprites/Hero/Hero_portrait_1011.png","Assets/Main/Sprites/Hero/Hero_card_1011.png","Assets/Main/Sprites/Hero/Hero_avatar_1011.png",700,120,70,"-","-","-","0/10",80},
	[1012]={1012,"黛安娜","荒野猎手","FreeArmy","Output",2,45,36,18,7,0,0,0,1360,"猎手标记",9.5,"基础打击","物理伤害","标记目标，使其受到的伤害提高。","易伤+6%|易伤+12%|易伤+18%|易伤+26%|易伤+35%",1,1,"Assets/Main/Sprites/Hero/Hero_portrait_1012.png","Assets/Main/Sprites/Hero/Hero_card_1012.png","Assets/Main/Sprites/Hero/Hero_avatar_1012.png",740,140,48,"-","-","-","0/10",80},
	[1013]={1013,"琪拉","暗巷间谍","Empire","Output",3,62,34,14,6,0,0,0,2050,"烟雾弹",7.5,"基础打击","物理伤害","投掷烟雾弹，范围内敌人命中大幅下降。","命中降低+10%|命中降低+16%|命中降低+22%|命中降低+30%|命中降低+40%",1,1,"Assets/Main/Sprites/Hero/Hero_portrait_1013.png","Assets/Main/Sprites/Hero/Hero_card_1013.png","Assets/Main/Sprites/Hero/Hero_avatar_1013.png",680,180,45,"-","-","-","0/10",90},
	[1014]={1014,"奥利维亚","海盗船长","FreeArmy","Defense",2,24,78,42,13,0,0,0,1490,"掠夺怒火",12.5,"防御强化","物理伤害","受到攻击时积累怒火，下次攻击造成范围伤害。","反击+10%|反击+18%|反击+26%|反击+36%|反击+48%",1,1,"Assets/Main/Sprites/Hero/Hero_portrait_1014.png","Assets/Main/Sprites/Hero/Hero_card_1014.png","Assets/Main/Sprites/Hero/Hero_avatar_1014.png",1380,85,140,"-","-","-","0/10",90},
	[1015]={1015,"露娜","星光偶像","Federation","Support",2,22,44,22,10,0,0,0,1080,"应援节拍",10.0,"辅助增益","能量伤害","歌声激励队友，恢复少量耐久并加速冷却。","恢复+8%|恢复+14%|恢复+20%|恢复+28%|恢复+36%",1,1,"Assets/Main/Sprites/Hero/Hero_portrait_1015.png","Assets/Main/Sprites/Hero/Hero_card_1015.png","Assets/Main/Sprites/Hero/Hero_avatar_1015.png",650,90,60,"-","-","-","0/10",70},
	[1016]={1016,"银翼","联邦突击手","Federation","Output",3,66,40,16,7,0,0,0,2320,"穿甲齐射",8.5,"基础打击","物理伤害","连续穿甲射击，无视目标部分护甲。","穿透+8%|穿透+14%|穿透+22%|穿透+32%|穿透+45%",1,1,"Assets/Main/Sprites/Hero/Hero_portrait_1016.png","Assets/Main/Sprites/Hero/Hero_card_1016.png","Assets/Main/Sprites/Hero/Hero_avatar_1016.png",820,190,52,"-","-","-","0/10",100},
	[1017]={1017,"莉可","空艇通讯官","Federation","Support",2,20,42,24,10,0,0,0,990,"空投补给",11.5,"辅助增益","能量伤害","呼叫空投，为全队恢复僚机并提供短暂护盾。","补给+8%|补给+14%|补给+20%|补给+28%|补给+38%",1,1,"Assets/Main/Sprites/Hero/Hero_portrait_1017.png","Assets/Main/Sprites/Hero/Hero_card_1017.png","Assets/Main/Sprites/Hero/Hero_avatar_1017.png",620,85,70,"-","-","-","0/10",70},
	[1018]={1018,"黑豹","帝国近卫","Empire","Defense",3,35,95,55,16,0,0,0,2680,"铁壁冲锋",13.5,"防御强化","物理伤害","向前冲锋并嘲讽敌人，期间受到伤害降低。","减伤+10%|减伤+16%|减伤+24%|减伤+34%|减伤+46%",1,1,"Assets/Main/Sprites/Hero/Hero_portrait_1018.png","Assets/Main/Sprites/Hero/Hero_card_1018.png","Assets/Main/Sprites/Hero/Hero_avatar_1018.png",1680,140,220,"-","-","-","0/10",100},
},

}
return data_table
