--[[

## MsgDefines.lua 分析

**文件位置**：`Assets/Main/LuaScripts/Net/Config/MsgDefines.lua`

### 作用

`MsgDefines.lua` 是**网络协议命令常量表**——把每条网络消息定义为一个可读的 Lua 常量名，值是与服务器约定的协议字符串（SFS2X 的 command string）。共 ~1774 行，注册了项目全部的网络协议。

```lua
MsgDefines = {
    Init = "init",
    MailGet = "mail.read",
    ArmyAdd = "army.add",
    PushTaskNew = "push.task.new",
    ...
}
return ConstClass("MsgDefines", MsgDefines)
```

### 加载方式

在 `Global.lua:158` 中作为**全局变量**一次性加载：

```lua
MsgDefines = require "Net.Config.MsgDefines"
```

通过 `ConstClass()` 包装后变成**只读表**——调试模式下如果写入或访问不存在的 key 会报错，防止拼写错误。因为是全局变量，项目任何地方都可以直接使用 `MsgDefines.XXX`，不需要额外 require。

### 使用场景

`MsgDefines` 在整个项目中有三种用途：

**1. 发送消息时作为命令标识**

```lua
SFSNetwork.SendMessage(MsgDefines.LeaveWorld)
SFSNetwork.SendMessage(MsgDefines.ItemUse, itemId, count)
```

**2. 在 MsgMap.lua 中注册消息路由**

```lua
-- MsgMap.lua
[MsgDefines.Init] = "Net.Msgs.InitMessage",
[MsgDefines.MailGet] = "Net.Msgs.MailGetMessage",
```

**3. C# 侧分发时匹配**

C# `NetworkManager` 收到 SFS2X 消息后，拿到命令字符串（如 `"init"`），传给 Lua 的 `SFSNetwork.HandleMessage(cmd, t)`，这里的 `cmd` 就是 `MsgDefines` 中定义的值。

### 命名规则

| 前缀 | 含义 | 方向 |
|------|------|------|
| `Push*` | 服务器主动推送 | 服务器 → 客户端 |
| `Get*` | 客户端请求数据 | 客户端 → 服务器 |
| 无前缀/动词 | 客户端发起操作 | 客户端 → 服务器（响应走同一个 cmd） |

### 与 MsgMap 的关系

```
MsgDefines.lua          MsgMap.lua              Net/Msgs/XxxMessage.lua
─────────────          ──────────              ────────────────────────
常量名 → 协议字符串     常量名 → 处理类路径       处理类：序列化/反序列化
```

三者合在一起构成完整的消息系统：
- `MsgDefines` 定义**有哪些协议**（常量字典）
- `MsgMap` 定义**谁来处理**（路由表）
- `Net/Msgs/*.lua` 定义**怎么处理**（具体逻辑）

### 总结一句话

`MsgDefines.lua` = 全局只读的**协议命令常量表**，把服务器协议字符串（如 `"mail.read"`）映射为可读的 Lua 常量名（如 `MsgDefines.MailGet`），供发送消息和路由分发时统一引用，避免全项目散落硬编码字符串。
]]


MsgDefines = {
    PushDesertFightWinLv = "push.desert.fight.win.lv", --玩家最高打过几级地
    PushDragonScoreSync = "push.dragon.score.sync",
    PushDragonResult = "push.dragon.result",
    PushDragonBattlePeriodChange = "push.dragon.battle.period.change",
    PushZendeskNotice = "push.zendesk.notice",
    --获取公告
    GetAllianceNotice = "get.alliance.notice",
    --R4 R5 创建公告
    UpdateAllianceNotice = "update.alliance.notice",
    --R4 R5 加急公告
    AdvAllianceNotice = "adv.alliance.notice",
    PushPtGoldUpdate = "push.pt.gold.update",
    --跨服打地活动
    GetCrossDesertInfo = "get.new.cross.desert.info", --跨服打地活动
    GetCrossDesertBox = "collect.new.cross.desert.box", --领取打地宝箱
    PushCrossDesertScore = "push.new.cross.desert.score", --推送积分
    GetCrossDesertRank = "get.new.cross.desert.user.rank", --获取个人联盟贡献排行榜
    --获得加急公告时间
    GetAdvNoticeTime = "get.adv.notice.time",
    --点赞点踩 - cd同聊天，客户端自己限制
    LikeAllianceNotice = "like.alliance.notice",
    --评论完成
    CommentAllianceNotice = "comment.alliance.notice",
    --删除公告
    DelAllianceNotice = "del.alliance.notice",
    --推送
    --（发布公告/修改公告/加急公告）
    PushAlNoticeUpdate = "push.al.notice.update",
    --删除公告
    PushAlNoticeDel = "push.al.notice.del",

    PushDeclareAlliancePositionInfo = "push.declare.alliance.position.info",

    TestMsg = "test",
    ShowStatusItem = "show.status.item",
    ChapterTask = "chapter.task",
    TaskRewardGet = "task.reward.get",
    TaskRewardGetDayAct = "task.reward.get.day.act", -- 批量领取七日活动任务奖励
    TaskRewardBatch = "task.reward.batch", -- 批量任务领取奖励
    PushTaskChapterTask = "push.task.chapterTask",
    Init = "init",
    AlPointFind = "al.point.find",

    ClientEvent = "client.event",
    ClientLog = "client.log",
    GetFirstChargeInfo = "get.first.charge.info", --获取首充信息
    ReceiveFirstChargeDayReward = "receive.first.charge.day.reward", --领取每日奖励
    PushFirstChargeUpdate = "push.first.charge.update", --购买首充后推送

    --信用值系统
    PayCreditUpdate = "push.pay.credit.update",
    PayCreditStat = "pay.credit.stat",
    
    PushUserAppsflyer = "push.user.appsflyer",
    
    -- 邮件
    MailGet = "mail.read",
    MailGetMuti = "chat.get.system.mails",
    MailGetPersonMail = "chat.get.person.mails",
    PushMail = "push.mail",
    MailDelete = "mail.delete",
    MailBatchDel = "mail.delete.batch",
    MailReadStatus = "mail.read.status",
    MailReadStatusBatch = "mail.read.status.betch",
    MailDialogRead = "chatMail.read",
    MailDialogDelete = "chatMail.delete",
    MailSend = "mail.send",
    MailReward = "mail.reward", -- 领取奖励
    MailRewardBatch = "mail.reward.batch", -- 批量领取奖励
    MailAddFavor = "mail.save", -- 加入收藏
    MailCancelFavor = "mail.cancel.save",
    MailGetFightReportDetail = "get.fight.report.detail", -- 文字战报
    AutoJoinAllianceMail = "auto.join.alliance.by.mail", --邮件一键换盟
    MailGetNeedDelList = "get.del.mail.list",
    PushNeedDelMail = "push.del.mail",

    PushExchangeNew = "exchange.new",
    PayRecord = "pay.action",
    PayBeforeCheck = "pay.before.check",
    PayPtGold = "pay.ptGold",
    PayIOS = "pay.ios",
    PaySteam = "pay.steam",
    ExchangeInfo = "exchange.info",
    PayTstore = "pay.tstore",
    PayAmazon = "pay.amazon",
    PayTest = "pay.test",
    Pay = "pay",
    ItemUse = "item.use",
    UseResItemMulti = "use.res.item.multi.new", --" use.res.item.multi",--批量使用资源道具
    PushItemUpdate = "push.item.update", --道具变化推送
    PushItemAdd = "push.item.add",
    UIShopBuy = "item.buy",
    TradingCenter = "get.r.exchange.info",
    FeiJiQiFei = "take.off.the.plane",
    CallThePlane = "call.the.plane",
    TradingSell = "resource.sell.money",
    TradingBuy = "money.buy.resource",
    ScienceResearchNew = "science.research.new",
    PushScienceChange = "push.science.change",
    AlSearch = "al.search",
    AlApply = "al.apply",
    AlBeLeaderCheck = "check.can.choose.leader",
    AlCrLastTime = "al.cr.last.time",
    AlCancelApply = "al.cancelapply",
    PushPlayerAllianceRank = "player.rank",
    LoginOther = "login.other",
    BecomeAlLeader = "apply.wait.merge.alliance.leader",
    PushAlWaitMergeStatus = "push.update.wait.merge",
    PushRecommendAlMember = "push.recommend.user.list",
    AlInviteRecommendUser = "invite.wait.merge.alliance.user",
    GetAlMemberRecommendList = "get.recommend.user.list",
    GetCommonShopInfo = "user.get.shop.info",
    GetCommonShopInfoMulti = "get.shop.info.multi",
    BuyCommonShopGoods = "user.shop.buy.new",
    RefreshCommonShop = "user.shop.refresh",

    GetAllianceMergeList = "get.apply.merge.alliance.info",
    ApplyMergeToAlliance = "apply.merge.alliance",
    CancelAllianceMergeApply = "cancel.apply.merge.alliance",
    HandleAllianceMergeApply = "handle.merge.alliance.apply",
    AutoJoinAlliance = "auto.join.alliance",
    AlLeave = "al.leave",
    AlDismiss = "al.dismiss",
    ArmyAdd = "army.add",
    PushArmyChange = "push.army.change",
    SoldierUp = "soldier.up",
    FindMonster = "find.monster",
    FindMonsterInCity = "find.monster.in.city",
    ChangeGameToVertical = "change.game.to.vertical",

    PushFightReward = "push.fight.reward",
    AllianceWarCancel = "alliance.team.cancel",
    AllianceWarRetreat = "alliance.team.retreat",
    GetAllianceWarList = "alliance.team.ls",
    AllianceTeamDirectMove = "alliance.team.direct.move",
    PushAllianceBaseInfo = "push.al.update",
    PushAllianceMarchCreate = "push.alliance.march.create",
    PushAllianceMarchRefresh = "push.alliance.march.refresh",
    PushAllianceMarchRemove = "push.alliance.march.remove",
    GetAllianceAutoInviteInfo = "get.alliance.auto.invite.info",
    AcceptAllianceAutoInvite = "agree.alliance.auto.invite",
    PushNewAllianceAutoInvite = "push.alliance.auto.invite.add",
    AllianceMoveCity = "move.city.to.alliance",
    RefuseAllianceMoveInvite = "ignore.move.city.invite",
    InviteMoveCity = "send.alliance.move.city.invite",
    PushAllianceMoveInvite = "push.alliance.move.city.invite",
    FormationName = "formation.name.save.fb",
    FormationSave = "formation.save.template",
    SaveFormationTempHero = "user.save.formation.temp.hero",
    DefenseInfoSave = "save.defense.info",
    PushArmyFormationUpdate = "push.formation.update.new",
    PushFormationStaminaUpdate = "push.formation.stamina.update.new",
    PushFormationStatusAdd = "push.formation.status.add",
    PushFormationStatusDel = "push.formation.status.del",
    PushBuildingStatusAdd = "push.building.status.add",
    PushBuildingStatusDel = "push.building.status.del",
    QueueCcdMNew = "queue.ccd.m.new",
    HospitalCure = "hospital.cure",
    FarmerIrrigate = "farm.irrigation",
    QueueFinish = "queue.finish",
    QueueFinishBatch = "queue.finish.batch",
    PushHospitalChange = "push.hospital.change",
    BuildCcdMNew = "build.ccd.m.new",
    ItemBuyAndUse = "item.buyAndUse",
    GetNewUserInfo = "get.new.user.info",
    NickNameChange = "user.modify.nickName",
    --账号首次免费改信息
    NickNameChangeFree = "user.modify.nickName.free",
    NickNameCheck = "user.check.nickName",
    PlayerRankList = "server.rank",
    PlayerKillRankList = "kill.rank",
    PlayerBaseRankList = "building.rank",
    AllianceRankList = "alliance.rank",
    AllianceRankLimit = "alliance.rank.limit",
    AllianceKillRankList = "kill.al.rank",
    DesertForceServerRank = "desert.force.server.rank",
    RankGetByRange = "rank.get.by.range",
    CampPveHeroInfo = "get.camp.pve.hero.info", --pve阵营爬塔的阵容信息
    AllianceGiftList = "alliance.reward.list",
    AllianceGiftInfo = "alliance.reward.info",
    AllianceGiftGetReward = "alliance.reward.receive",
    GetAllianceStorageInfo = "get.alliance.resource.store.info",
    PushAlGiftNum = "push.alliance.reward.new",
    PushTaskNew = "push.task.new",
    PushTrebuchetAttack = "push.trebuchet.attack",
    PushTaskComplete = "push.task.complete",
    DailyQuestLs = "daily.quest.ls",
    --PushNewDailyTask = "push.new.daily.task",
    AlHelpAll = "al.help.all",
    AllianceCallHelp = "al.call.help",
    AllianceRenderHelp = "al.render.help",
    AllianceShowHelp = "al.show.help",
    PushAlHelpNew = "push.al.help.new",
    PushAlHelpUpdate = "push.al.help.update",
    PushAlApply = "push.al.apply",
    AlHelpFromAll = "al.help.from.all",
    DailyQuestReward = "daily.quest.reward",
    DailyQuestRewardMulti = "daily.quest.reward.multi",
    DailyQuestGetAllReward = "receive.daily.task.and.stage.reward",
    AlRank = "al.rank",
    AllianceDeleteOffical = "al.offical.process",
    AllianceKickMember = "al.kick",
    AllianceLeaderReplace = "al.leader.replace",
    AllianceLeaderTrans = "al.leader.trans",
    AllianceSetRank = "al.setrank",
    PushAllianceLeaderTrans = "push.al.leader.trans",
    PushAllianceOfficialPosChange = "push.update.al.official.info",
    SetAllianceOfficialPos = "al.set.offical",
    ParsePushSet = "parse.push.set",
    PushSetting = "push.setting",
    AlShopShow = "al.shop.show",
    AlShopBuyAl = "al.shop.buy.al",
    AlShopBuyUsr = "al.shop.buy.usr",
    SetCountryFlag = "set.countryflag",
    ChatLock = "chat.lock",
    ChatUnLock = "chat.unlock",
    PushAlScienceUpdate = "push.al.science",
    PushAlScienceUpdate1 = "push.al.science.update",
    AlScienceRecommend = "al.science.recommend",
    AlScienceResearch = "al.science.research",
    AlScienceGoldDonate = "al.science.donate.gold",
    AlScienceDonate = "al.science.donate",
    AllScienceRefresh = "science.data.refresh",
    AlScienceNumFresh = "al.science.refreshNum",
    AlScienceFresh = "al.science.fresh",
    AlNameGet = "al.name.get", --创建联盟自动填装名称和简称
    AlliancePayHeapReward = "alliance.pay.heap.reward", --联盟累充
    UpdateAlliancePayHeap = "update.alliance.pay.heap", --更新联盟累充数据
    PushAllianceMemberPayHeap = "push.alliancemember.pay.heap", --推送联盟成员累充数据
    PushAllianceRechargeInit = "push.alliance.recharge.init", --进退联盟是同步数据
    NewAccount = "new_account",
    UserAgreeTos = "user.agree.tos", --用户同意隐私条款
    UserBind = "user.bind",
    UserCleanPost = "user.clean.post",
    UserBindCancel = "bind.cancel",
    BindCancelVerifyCode = "bind.cancel.verify.code", -- 这个是发验证码的消息

    AlCreate = "al.create",
    AlName = "al.name",
    AlAbbr = "al.abbr",
    AccountBind = "az.account.bind",
    AccountChangePassword = "account.change.password",
    AccountForgetPassword = "account.forget.password",
    AccountResetPassword = "account.reset.password",
    CheckAccountMailVerifyCode = "check.account.mail.verify.code",
    CheckAccountPassword = "check.account.password",
    AccountLogin = "az.account.login", --***新的登陆规则，旧登陆弃用***
    AccountLoginSendVerifyCode = "account.login.send.verify.code",
    AccountVerifyDevice = "account.verify.device",
    AccountDeleteVerifyDevice = "account.delete.verify.device",
    AccountLoginNew = "account.login.new",
    AccountGetAllServer = "account.get.all.server",
    AccountChangeMail = "az.account.changemail",
    AccountVerify = "account.mail.bind.verify",
    UpdatePic = "user.update.picVer",
    PushPicVerUpdate = "push.picVer.update",
    PinOldPwdCheck = "check.old.password",
    PinSetPwd = "set.user.password",
    PinPwdCheck = "user.password.check",
    PinPwdCheckFrequency = "set.check.password.frequency",
    PinPwdForget = "forget.user.password",
    PushAccountChangePwd = "az.account.password.changed",
    PushAccountFirmed = "az.account.mailconfirmed",
    PushCheckPasswordStatus = "push.check.password.status",
    WorldFavoDel = "world.favo.del",
    WorldFavoGet = "world.favo.get",
    WorldFavoAdd = "world.favo.add",
    WorldGetAllianceMark = "get.alliance.world.mark.info",
    WorldAddAllianceMark = "alliance.world.mark.add",
    WorldDelAllianceMark = "alliance.world.mark.del",
    WorldAddAllianceMarkPush = "push.alliance.worldmark.add",
    WorldDelAllianceMarkPush = "push.alliance.worldmark.del",
    PushAllianceTechRecommend = "push.al.science.recommend",
    AllianceLeaderElect = "be.alliance.leader.candidate",
    GetAlLeaderCandidates = "get.alliance.leader.candidate.info",
    AllianceInviteAccept = "al.acceptinvite",
    AllianceInviteRefuse = "al.refuseinvite",
    AllianceLeaderVote = "vote.alliance.leader.candidate",
    AllianceSysStateChange = "push.sys.alliance.state", --联盟盟主投票阶段变化
    HeroStarUp = "hero.star.up",
    DailyTaskReward = "daily.task.reward", --领取每日任务奖励
    PushDailyQuest = "push.daily.quest", --每日任务完成推送
    GetAlLeaderElectCandidates = "get.alliance.vote.info",
    AlLeaderElectSignUp = "register.for.alliance.election",
    AlLeaderElectChangeSlogan = "modify.alliance.vote.declaration",
    AlLeaderElectVote = "vote.for.alliance.election",
    PushAllianceLogMember = "push.alliance.log.member",
    ViewAllianceLog = "view.alliance.log",

    --新英雄相关
    HeroAdvance = "hero.qua.up",
    HeroAdvanceMulti = "hero.qua.up.mult.new", --一键进阶
    HeroReset = "hero.reset.lv",
    HeroLvUp = "hero.exp",
    HeroLvBeyond = "upgrade.hero", --英雄突破
    HeroRankUpgrade = "upgrade.hero.rank", --英雄军阶升级
    PushHeroLottery = "push.refresh.hero.lottery", --招募登录初始数据push
    PushHeroLotterySwitch = "push.refresh.hero.switch", --push阵营切换信息
    LotteryHeroCard = "lottery.hero.card", --招募英雄
    LotteryHeroSwitch = "lottery.hero.card.switch", --切换阵营
    HeroSkillUpgrade = "survival.hero.skill.upgrade", --技能升级
    HeroMedalExchange = "dig.hero.skill.levelup.item.exchange", --勋章兑换
    HeroExchange = "hero.exchange", --特定英雄碎片兑换

    --功勛
    ClaimAlContributeBoxReward = "accept.exploit.personal.reward",
    GetAlContributeRankList = "get.exploit.rank",
    GetAlContributeExploitReward = "receive.exploit.rank.reward",
    AlContributeUpdateSelfExploit = "push.exploit.rank.update",

    UserDayActInfo = "user.day.act.info", --七日请求
    PushTaskDayAct = "push.task.day.act", --七日推送
    PushTaskDayActScore = "push.task.day.act.score", --七日积分推送
    UserDayActReward = "user.day.act.reward", --请求领奖七日盒子
    ActivityPanelInfo = "activity.panel.info", --获取活动中心列表数据
    ActivityPushMessage = "push.hero.target.achieved", --活动-积分类活动，领奖状态刷新 服务器主动推送
    GetHeroEventCalendar = "get.hero.event.calendar", --军备日历
    ChooseHeroEvent = "choose.hero.event", --选择军备事件
    BarterShopExchange = "exchange.by.activity", --兑换活动-兑换
    GetThemeActivityInfo = "get.theme.activity.info",
    ClaimThemeActNoticeReward = "receive.theme.activity.reward",
    AcceptPersonalReward = "accept.personal.reward",
    ActivityEventInfoGet = "hero.event.info.get",
    ActivityEventRankReward = "hero.event.ranking.get",
    ActivityTodayPersonalRank = "hero.server.inside.ranking",
    PushCollectExtraReward = "push.collect.extra.reward",
    PushNewActivity = "push.new.activity",
    PushActivityEvent = "push.new.score.event",
    StrongestCommandTotalRank = "kingdom.season.contribution.rank",
    StrongestCommandGetTodayReward = "accept.kingdompersonal.reward",
    AllianceChangeAttributes = "al.attr",
    AcceptAllianceApply = "al.acceptapply",
    RefuseAllianceApply = "al.refuseapply",
    AlApplyList = "al.applylist",
    HeroTalentPageReset = "hero.talent.page.reset",
    HeroTalentPageRename = "hero.talent.page.rename",
    HeroTalentPageSwitch = "hero.talent.page.switch",
    HeroAddTalent = "hero.add.talent",
    PushEditHero = "push.edit.hero",
    AllianceDonateRankDay = "al.donate.rank.today",
    AllianceDonateRankWeek = "al.donate.rank.week",
    AllianceDonateRankAll = "al.donate.rank.all",
    UserSyntheticHero = "user.synthetic.hero",
    AccountResendMail = "az.account.sendmailagain",
    --FarmFarming = "farm.farming",
    --FeedAnimal = "farm.feed.animal",
    PushResourceDataUpdate = "push.resource.item.update",
    --GetUserInfoMulti = "get.user.info.multi", 	-- 获取玩家信息
    PurchaseOrderFinish = "purchase.order.finish", -- 交付订单
    PushPurchaseOrder = "push.purchase.order", -- 推送订单
    FreeBuildingFoldUpNew = "free.building.fold.up.new", -- 收起建筑
    PurchaseOrderRefresh = "purchase.order.refresh", --居民订单时间刷新
    PurchaseOrderDelete = "purchase.order.delete", --删除居民订单
    PurchaseOrderImmediateRefresh = "purchase.order.immediate.refresh", -- 钻石秒居民订单

    GetMysteriousActParamInfo = "get.mysterious.activity.info",
    GetMysteriousLotteryRes = "mysterious.activity.lottery",
    GetMysteriousRewardRes = "receive.mysterious.activity.stage.reward",
    GetMysteriousRankInfo = "get.mysterious.rank",
    GetMysteriousNewActivityInfo = "get.mysterious.new.activity.info",
    MysteriousNewActivityLottery = "mysterious.new.activity.lottery",
    ReceiveMysteriousNewActivityLotteryReward = "receive.mysterious.new.activity.lottery.reward",
    ReceiveMysteriousNewActivityStageReward = "receive.mysterious.new.activity.stage.reward",

    GetStoryInfo = "get.story.info",
    StartStoryPveLevel = "start.story.pve.level",
    ReceiveStoryStageReward = "receive.story.stage.reward",
    PushStoryTimeUpdate = "push.story.time.update",
    GetStoryTimeReward = "get.story.time.reward",
    ReceiveStoryTimeReward = "receive.story.time.reward",
    GetStoryRank = "get.story.rank",
    SkipStoryPveLevel = "skip.story.pve.level",
    -------------------------------------------------------------
    --ChatBan   = "chat.ban", 				-- 聊天禁言
    --ChatUnban = "chat.unban",				-- 解除禁言
    --ChatLock	= "chat.lock",				-- 屏蔽玩家
    --ChatUnlock	= "chat.unlock",				-- 解除屏蔽玩家
    --ReportPicVer      = "report.picVer",			--举报头像
    --ChatReport = "chat.report",				--举报聊天消息
    --ChatRoomInvitee  = "chat.room.invitee", 		--获取联盟成员协议		
    --SearchPlayer      = "search.player",			--搜索玩家		
    GetRedPack = "get.red.pack", --领取红包
    RedPacketsRvdId = "redPackets.rvd.id", --获取红包ids 登录时调用更新本地缓存	获取领取过的红包
    --RedPacketsStatus = "redPackets.status",	--获取红包状态
    --ChatRoomCreate	= "chat.room.mk.v2",		-- 创建房间		
    --ChatRoomDismiss  = "chat.room.dismiss",		--解散房间

    --ChatShareCountry  = "chat.country",	    --往国家频道发送消息（分享）
    --ChatShareAlliance = "al.msg",			    --往联盟频道发送消息（分享）
    --ChatSharePerson   = "chat.room.send",		--往私聊频道发送消息（分享）
    ReportChat = "chat.report", --举报

    ChatRoomCreate = "chat.room.mk.v2", -- 创建房间
    ChatRoomDismiss = "chat.room.dismiss", --解散房间
    -------------------------------------------------------------

    AllianceCompeteWeekResult = "al.battle.week.vs.info", --联盟军备周结算结果
    AllianceCompeteRankList = "al.battle.rank.info", --联盟日、周排行榜信息
    AllianceCompeteWeeklySummary = "al.battle.week.result.info", --联盟军备本周内日结算数据
    GetMyLeagueMatchInfo = "get.alliance.duel.season.info",
    GetCurSeasonLeagueMatchGroupInfo = "get.alliance.duel.group.info",
    GetLastSeasonLeagueMatchGroupInfo = "get.alliance.duel.last.season.group.info",
    PushLeagueMatchBaseInfo = "push.alliance.duel.season.time",
    LeagueMatchDrawLots = "alliance.duel.draw",
    GetLeagueMatchRewardInfo = "get.alliance.duel.reward.info",
    GetLeagueMatchWarmRewardInfo = "get.alliance.duel.warm.up.reward.info",
    GetAlBattleRushDetail = "al.battle.rush.detail",
    PushAlBattleRush = "push.alliance.battle.rush",
    GetAlBattleDayVsInfo = "al.battle.day.vs.info",

    --	 EarthOrderEnd = "earth.order.end",--主动结束地球订单
    GroceryOrderEnd = "grocery.order.get.reward", --主动结束杂货店订单

    --	 GetEarthOrder = "get.earth.order",--获取地球订单 //type 0 正常生成， 1 使用道具，2 特殊生成
    GetGroceryOrder = "get.grocery.order", --获取杂货店订单
    --	 EarthOrderFillOne = "earth.order.fill.one",--交付一个地球订单资源道具
    --	 PushEarthOrder = "push.earth.order",--推送一个地球订单
    UnLockPlanZone = "unlock.plan.zone", --解锁一个计划区(花费钻石）
    SetOnePlan = "set.one.plan", --设置一个计划区
    ChangeAutoPlant = "survival.factory.auto.plan", --切换自动生产道具
    GatherProduct = "gather.product", --收取缓存区的产物
    SynFoodFactory = "syn.food.factory", --刷新加工厂信息
    FactoryAutoReceipt = "survival.factory.auto.receipt", --工厂自动生产开关
    FreeBuildingUpNew = "free.building.up.new", --建筑升级消息
    FreeBuildingExpendDome = "free.building.expend.dome", --建筑扩苍穹
    AllianceSearchUser = "al.searchuser", --获取邀请玩家
    AllianceInvitePlayer = "al.invite", -- 邀请玩家入盟
    SoldResourceItem = "ri.sell", -- 卖资源道具
    PushInitBuild = "push.init.build", -- 推送赠送建筑信息
    AllianceRewardHideName = "alliance.reward.hide.name",
    AllianceGiftRemove = "alliance.reward.remove",
    AllianceAllGiftRemove = "alliance.reward.allremove",
    AllianceReceiveAllGift = "alliance.reward.allreceive",
    PushBuildUpgradeFinish = "push.build.upgrade.finish", -- 推送建筑升级完成
    FactoryAddSpeed = "factory.speed.create",
    PushQueueAdd = "push.queue.add",
    PushDefendFormationUpdateNew = "push.defend.formation.update.new",
    PushHeroData = "push.hero.data",
    PushArmyInfo = "army.info",
    PushCommonNotice = "push.common.notice",
    PushServerToStop = "push.server.tostop",
    PushBuildingInfo = "push.building.info", --推送建筑消息
    PushAddBuilding = "push.add.building", --推送新增建筑消息
    UserResupplyBuilding = "user.resupply.building", --资源运输
    UserResSynNew = "user.res.syn.new", --收资源
    PushAlJoin = "push.al.join", --加入联盟push
    PushAllianceLeave = "push.al.leave", --被离开联盟push
    PushArmyReturn = "push.army.return", --编队返回
    PushUserAllianceTeamRetreat = "push.user.alliance.team.retreat", --遣返集结队员
    PlayerMonthPayInfo = "player.pay.tag.info", -- 获取角色月付的金额
    ClientNotifySetting = "client.setting", -- 获取角色月付的金额
    PushPlayerInfo = "player.info", -- 在某些时候推送玩家信息
    CrossServerList = "cross.server.ls", -- 获取所有服务器的信息
    CityDefenceAdd = "buy.citydef.add",

    PushDefenceWallUpdate = "push.defend.wall.update",
    PushUserBuildStaminaChange = "push.user.build.stamina.change",
    PushUserRoadStaminaChange = "push.user.road.stamina.change",
    PushResourceInfo = "push.resource.info", --采集资源更新
    UserChangePic = "pic.change", --更换玩家头像
    AllianceAssistanceInfo = "alliance.assistance.info", --获取增援信息
    AssistanceTeamRetreat = "assistance.team.retreat",
    PushAssistanceTeamLeaderChange = "push.assistance.team.leader.change", --更新增援队长
    ChangeAssistanceTeamLeader = "change.assistance.team.leader", --更换增援队长
    WorldMv = "world.mv", --迁城
    WorldAlMove = "world.mv.near.al.leader", --联盟迁城
    AlMoveInviteGetPoints = "get.alliance.center.point",
    PushAlLeaderPointChange = "push.alliance.leader.point.change",
    PushItemDel = "push.item.del", --扣除道具
    ReceiveBuildingGrowValReward = "receive.building.growval.reward", --收取道具
    UserRecoverBuildingStamina = "user.recover.building.stamina", --使用钞票恢复耐久
    GetRankPreviewMessage = "rank.get.preview", --获取排行榜各条属性第一的数据
    GetRank = "rank.get", --通用排行榜数据
    GetAllianceSeasonScoreRank = "get.alliance.season.score.rank", --获取宣战赛季同组联盟赛季积分排行
    DetectInfoGet = "get.detect.info", --获取探测信息
    DetectPowerUpgrade = "upgrade.detect.power", --提升探测强度
    DetectEventRewardReceive = "receive.detect.event.reward", --领取事件奖励
    DetectEventLauraRewardReceive = "receive.detect.laura.reward", --领取7日劳拉皮肤奖励
    BatchDetectEventRewardReceive = "batch.receive.detect.event.reward", --批量领取雷达奖励
    DetectEventCompletePush = "push.detect.event.complete", -- 事件完成推送
    UnlockBuildingQueue = "unlock.building.queue", --解锁新的建筑队列
    PushBuildUnlockAdd = "push.build.unlock.add",
    UserNewbieRobotUnlock = "user.newbie.robot.unlock", --引导免费试用建筑队列

    GetDawnDayActInfo = "get.dawn.day.act.info", --黎明曙光
    ReceiveDawnDayActReward = "receive.dawn.day.act.reward",
    PushDawnDayActScore = "push.dawn.day.act.score",

    StatTT = "stat.tt", --做过的引导（只用于服务器打日志）
    SaveGuide = "save.guide", --保存引导
    PushPickGarbageReward = "push.pick.garbage.reward",
    ChangeMoodStr = "change.mood.str", --改名卡
    FreeBuildingUpgradeFinish = "free.building.upgrade.finish", --建筑升级完成
    MoveCityToWorld = "move.city.to.world", --新手主城迁入世界
    CityPickGarbageFinish = "city.pick.garbage.finish", --捡垃圾
    CityPickGarbage = "city.pick.garbage", --捡垃圾new
    ReceiveCityGarbageReward = "receive.city.garbage.reward", --捡垃圾new
    LoginInitCommand = "login.init", --重连成功后后端push的消息
    FreeBuildingPlaceMainBuilding = "free.building.place.main.building", --落大本
    VipInfo = "vip.info", --请求Vip最新信息
    PushVipInfo = "push.vip.info", --
    ChangeVIPShow = "change.vip.show", --更改聊天vip显示开关
    VipGetRewardInfo = "vip.get.reward.info", --请求Vip免费礼包信息
    VipAddLoginScore = "vip.add.login.score", --领取vip每日点数奖励
    VipGetEveryDayReward = "vip.get.every.day.reward", --领取每日免费VIP奖励
    CityWorldFight = "world.city.fight", --新手主城战斗
    PushCityFightResult = "push.city.fight.result", --新手主城战斗结果
    BuildCityBuilding = "build.city.building", --建筑0升级1消息
    ClaimFirstPayReward = "firstpay.reward", --领取首充奖励
    FirstPayRewardStatePush = "push.first.pay.reward", --充值后更新首充状态
    DefenceFailPush = "push.city.defend.alliance.subsidy",
    GarbageRewardInfo = "garbage.reward.info", --单人捡垃圾获取奖励内容
    FreeSpeedQueue = "free.speed.queue", --免费加速队列
    CityUnlockFog = "city.unlock.fog", --解锁迷雾
    PushCityFightResult = "push.city.fight.result", --单人地图战斗结果
    PushEffectChange = "push.effect.change",
    PushBatchEffectChange = "push.batch.effect.change",
    PushStatus = "status.push",
    PushCityPointRefresh = "push.city.point.refresh", --刷新主城点信息（增加不是覆盖）
    FindMainBuildInitPosition = "find.main.build.init.position", --随机主城位置
    FreeBuildingPlaceNew = "free.building.place.new", --放置建筑
    FreeBuildingReplaceNew = "free.building.replace.new", --重放建筑
    BuildWorldMoveNew = "build.world.move.new",
    WormBuildWorldMove = "worm.build.world.move", --巨龙迁城
    GetDragonBossDamage = "get.dragon.boss.damage", --巨龙Boss伤害
    GetDragonBossHealth = "get.dragon.boss.health", --巨龙Boss血量
    PushDragonServerEffectUpdate = "push.dragon.server.effect.update", --巨龙Buff推送
    GetDragonBattlePeriods = "get.dragon.battle.battle.periods", --巨龙成员投票结果
    DragonSelectBattlePeriod = "dragon.battle.select.battle.period", --巨龙投票
    CheckFormation = "check.formation",  --检测编队
    PushDragonPlayerNum = "push.dragon.player.num", --巨龙人数同步

    --移动建筑
    GetArenaInfo = "user.get.arena.info", --获取竞技场信息；0，基础信息；1，挑战列表信息
    GetArenaBattleHistory = "user.get.arena.record", --战斗历史记录
    SetArenaDefenseArmy = "user.arena.save.defend.army", --设置防守阵容
    GetArenaUserEffect = "user.arena.get.effect",
    BuyArenaTicket = "user.arena.buy.ticket", --购买挑战道具
    StartArenaBattle = "user.arena.fight", --开始竞技场战斗
    PushArenaHistoryTime = "push.user.arena.get.fight", --竞技场最近一次被打时间
    RefreshArenaChallenge = "user.arena.refresh", --刷新竞技场列表
    UserGetArenaReport = "user.get.arena.report",
    --跨服竞技场
    GetCrossArenaInfo = "user.get.arena.cross.info", --获取跨服竞技场信息；0，基础信息；1，挑战列表信息
    GetCrossArenaBattleHistory = "user.get.arena.cross.record", --跨服战斗历史记录
    SetCrossArenaDefenseArmy = "user.arena.cross.save.defend.army", --设置跨服防守阵容
    GetCrossArenaUserEffect = "user.arena.cross.get.effect",
    BuyCrossArenaTicket = "user.arena.cross.buy.ticket", --跨服竞技场购买道具
    StartCrossArenaBattle = "user.arena.cross.fight", --开始跨服竞技场战斗
    PushCrossArenaHistoryTime = "push.user.arena.cross.get.fight", --跨服竞技场最近一次被打时间
    RefreshCrossArenaChallenge = "user.arena.cross.refresh", --刷新跨服竞技场列表
    UserGetCrossArenaReport = "user.get.arena.cross.report", --user.get.arena.report
    --跨服竞技场End

    GetAllAllianceMineList = "world.get.alliance.building",
    BuildAllianceMine = "world.build.alliance.building",
    PushAllianceMineAdd = "push.alliance.building",
    PushAllianceMineDel = "push.alliance.building.del",
    GetAllMarchesOfAlMine = "world.get.alliance.building.march",
    PushAlMineScoreChange = "push.user.alBuild.point",

    PushMonthCard = "push.month.card", --月卡激活推送
    ClaimGolloesDailyReward = "month.card.reward", --领取咕噜月卡每日奖励
    ClaimGolloesFreeReward = "receive.golloes.daily.free.reward", --每日免费咕噜奖励
    ActiveGolloesFunc = "active.golloes.func", --激活咕噜功能
    PushGolloesData = "push.golloes.data", --推送咕噜数据
    ClaimGolloesReward = "receive.golloes.reward", --领取咕噜探索/商队奖励
    GolloesTradeCheckTarget = "golloes.caraven.count.check", --咕噜商队次数检查
    GetGolloesCaravanRecord = "get.golloes.caravan.record",

    GetPaidLotteryData = "get.recharge.roll.info", --获取累充转盘活动信息
    ClaimPaidLotteryTicket = "receive.recharge.roll.stage.reward", --领取累充转盘奖励
    BeginPaidLotteryRoll = "recharge.roll.lottery", --抽奖
    PushPaidLotteryScoreChange = "push.recharge.roll.score", --积分变化推送

    GetAllianceTaskInfo = "get.alliance.task.info",
    ClaimAllianceTaskReward = "receive.alliance.task.reward",
    StartAllianceAutoRally = "user.create.auto.join.team",
    UpdateAutoJoinTeamSetting = "update.auto.join.team.setting",
    StopAllianceAutoRally = "user.cancel.auto.join.team",
    GetAllianceAutoJoinRallyInfo = "user.get.auto.join.team.info",

    PushNewTreasure = "push.new.artifact",
    UseTreasureSkill = "use.artifact.skill",

    SendAllianceRecruit = "send.alliance.recruit",

    WorldGetAllianceCityDetail = "world.get.alliance.city.detail",
    PushAllianceCityDefendChange = "push.alliance.city.defend.change",
    PushAllianceBuildDefendChange = "push.alliance.build.defend.change",
    GetAllAlCityInfo = "world.get.all.alliance.city.info",
    GiveUpAlCity = "world.give.up.alliance.city",
    PushGiveUpAlCity = "push.alliance.city.give.up",
    PushGiveUpAlCityFail = "push.alliance.city.give.up.fail",
    PushAlCityInfoUpdate = "push.alliance.city.info.update",

    -- 联盟农场活动
    AllianceOrderGetInfo = "get.alliance.order.info", -- 获取订单信息
    AllianceOrderGetRank = "get.alliance.order.rank", -- 获取排行榜
    AllianceOrderReceive = "receive.alliance.order", -- 接受订单
    AllianceOrderGiveUp = "giveup.alliance.order", -- 放弃订单
    AllianceOrderFill = "fill.alliance.order", -- 填充订单物品
    AllianceOrderReceiveAndFill = "receive.and.fill.order", -- 接受并完成可以完成的订单
    AllianceOrderGetReward = "get.reward.alliance.order", -- 获取奖励
    AllianceOrderUpdateStage = "push.alliance.order.stage.reward", -- 更新阶段
    AllianceOrderAddToken = "add.alliance.order.token.num", -- 增加领取次数
    -- 个人农场活动
    IndividualOrderGetInfo = "get.individuel.order.info", -- 获取订单信息
    IndividualOrderFill = "fill.individuel.order", -- 填充订单物品
    IndividualOrderGetReward = "receive.individuel.order.stage.reward", -- 领取阶段奖励
    IndividualOrderReset = "refresh.individuel.order", -- 刷新订单
    --
    PushMarchContinueWin = "push.march.continue.win", -- 连杀
    PushAllNotice = "push.all.notice",
    GetWorldCityInfo = "world.get.alliance.city.info",
    BuildRoadDestroyNew = "build.road.destroy.new", --删除路
    PushInitRoad = "push.init.road", --推送路
    PushUserRoadRemove = "push.user.road.remove", --推送删除路
    PushUserRoadStateUpdate = "push.user.road.state.update", --推送更改路状态
    BuildRoadCreateNew = "build.road.create.new", --修路
    PushRobotEffectChange = "push.robot.effect.change",
    UserRobotOccupy = "user.robot.occupy",
    UserRobotDismiss = "user.robot.dismiss",
    PushUserCollectRewardCreate = "push.user.collect.reward.create",
    PushUserCollectRewardRemove = "push.user.collect.reward.remove",
    GatherCollectReward = "gather.collect.reward",
    PlayerAddExpMessage = "push.player.add.exp",
    PlayerReceiveLevelRewardMessage = "receive.player.level.reward",
    GetPlayerLevelRewardInfoMessage = "get.player.level.reward.info",
    PushPurchaseOrderUpdate = "push.purchase.order.update",
    PushBuildFoldUp = "push.build.fold.up",
    PushBuildingConnectStatus = "push.building.connect.status",
    WorldGetAllianceCityEffect = "world.get.alliance.city.effect",
    GetDragonSeverEffect = "get.dragon.server.effect",
    PushAllianceJoin = "push.alliance.join",
    PushAllianceGiftCd = "push.al.gift.cd",
    PushAllianceSign = "push.al.sign",
    RefreshCityGarbage = "refresh.city.garbage", --刷新垃圾
    UserGetAllResourceItem = "user.get.all.resource.items",
    PushUserRewardGet = "push.user.reward.get",

    PushStorageShopUnlock = "push.trade.bank.unlock", --建筑完成推送交易行解锁
    PushStorageShopSoldSucc = "push.trade.bank.sold.out", --交易成功推送
    PushStorageShopUpdate = "push.trade.bank.update",
    StorageShopGetShopList = "trade.bank.random.show.info", --查看交易板信息,0世界，1联盟
    StorageShopUnlockSlot = "unlock.trade.bank.slot", --交易行解锁槽位
    StorageShopAddGoods = "put.on.trade.bank.item", --交易行添加商品
    StorageShopRemoveGoods = "clean.trade.bank.item", --下架
    StorageShopBuyGoods = "buy.trade.bank.item", --购买
    StorageShopGetShopInfo = "show.trade.bank.page", --获取某玩家交易站数据
    StorageShopClaimMoney = "collect.trade.bank.item", --领取金币
    StorageShopGolloesBuy = "quick.buy.trade.bank.item", --系统回收
    ShareCdCheck = "check.share.trade.bank", --交易行分享前检查

    HeroStationSaveMessage = "save.hero.station",
    HeroStationUpdateMessage = "push.hero.station.update",
    HeroStationUseSkillMessage = "use.hero.station.skill",
    PushModifyPicAuthority = "push.modfiy.pic.authority",
    UserGetOrderInfo = "user.get.order.info",
    WorldChangeAllianceCityName = "world.change.alliance.city.name",
    WorldCheckAllianceCityName = "world.check.alliance.city.name",
    RadarRallyGetBossCount = "get.rally.boss.count",
    PushDailyKillBossNumber = "push.daily.kill.boss.number", --有奖励的怪剩余次数
    FiveStar = "praise.receive",

    ACT_CHAMPIONBATTLE_REDPOINT_PUSH = "elite.redPoint.push", --冠军对决入口红点推送显示协议
    ACT_CHAMPIONBATTLE_DATA_REFRESH_PUSH = "championBattle.data.refresh.push", --冠军对决总数据推送

    ACT_CHAMPIONBATTLE_DATA_REFRESH = "championBattle.data.refresh", --冠军对决总数据

    ACT_CHAMPIONBATTLE_REWARD_VIEW = "championBattle.reward.view", --冠军对决奖励预览
    ACT_CHAMPIONBATTLE_REWARD = "championBattle.reward", --冠军对决领取宝箱请求  
    ACT_CHAMPIONBATTLE_SINGUP = "championBattle.singup", --冠军对决请求报名

    ACT_CHAMPIONBATTLE_REPORT_LIST = "elite.new.self.fight.list", --冠军对决战报列表 
    ACT_CHAMPIONBATTLE_REPORT_DESC = "eliteNew.main.viewreport", --冠军对决战报详细信息
    ACT_CHAMPIONSTRONGEST_REPORT_LIST = "elite.new.strongest.fight.list", --冠军对决八強賽\四強賽\半決賽战报列表

    ACT_CHAMPIONBATTLE_BET_VIEW = "championBattle.bet.view", --冠军对决-押注数据请求
    ACT_CHAMPIONBATTLE_BET = "championBattle.bet", --冠军对决-下注请求
    ACT_CHAMPIONBATTLE_BET_RECORD = "championBattle.bet.record", --冠军对决-押注记录
    ACT_CHAMPIONBATTLE_SAVE_FORMATION = "elite.new.saveformation", --冠军对决-保存formation
    ACT_CHAMPIONBATTLE_SAVE_FORMATION_PUSH = "elite.new.formation.push", --冠军对决-formation推送
    ACT_CHAMPIONBATTLE_GET_RANK_DATA = "championBattle.get.rank.data",
    ACT_CHAMPIONBATTLE_GET_GROUP_DATA = "championBattle.get.group.data",
    FindResourcePoint = "find.resource.point", --寻找金矿
    PiggyBankUpdate = "push.piggy.bank.update", --存钱罐更新
    PushActScoreObtain = "push.act.score.obtain", --活动积分更新
    ServerTrendsInfo = "server.trends.info", --天下大势
    ServerTrendsReward = "server.trends.reward", --天下大势 领取任务奖励
    PushTrendsRedNum = "push.trends.red.num", --天下大势 主界面入口红点消息
    ServerTrendsRank = "server.trends.rank", --天下大势联盟排行榜
    GrowthPlanGetInfo = "growth.plan.info", --成长计划获取信息
    GrowthPlanGetReward = "receive.growth.plan.reward", --成长计划领取奖励
    UserStartFixBuilding = "user.start.fix.building", --开始修复废墟
    UserFinishFixBuilding = "user.finish.fix.building", --修复废墟完成

    BuyFreeWeeklyPackage = "receive.week.free.reward",
    BuyInKonbini = "buy.in.konbini", --小卖部买东西

    GetWeekCardList = "get.week.card.info",
    ClaimWeekCardReward = "receive.week.card.reward",
    AllClaimWeekCardReward = "receive.super.week.card.reward", --一键领取
    ClaimWeekCardFreeReward = "receive.week.card.daily.free.reward",
    PushWeekCardInfoChange = "push.week.card",
    PushWeekSuperCardInfoChange = "push.super.week.card",
    SetWeekCardCustomRewards = "week.card.select.goods",

    PushPrePareRedPacket = "push.prepare.red.packet", --达成条件推送联盟红包
    PushNewSysRedPacket = "push.new.sys.red.packet",
    SendRedPack = "send.red.pack", --往聊天频道发红包
    GetAllianceRedPacket = "get.alliance.red.packet",
    RedPacketStatus = "redPackets.status", --查看红包状态

    TankPowerRank = "tank.power.rank",
    TankDiscountLevelUp = "tank.discount.levelup",
    FindEnemyPoint = "find.enemy.point", --寻找敌人
    GarageRefit = "tank.reform", --车库改造
    GarageRefitNewAddExp = "tank.new.addexp", --无人机建筑(旧车库) 升级
    GarageRefitUpdate = "push.update.user.tank", --车库改造推送
    GarageRefitUpdateNew = "push.update.user.tanknew", -- 无人机建筑(旧车库) 升级推送
    GarageRefitTalentStudy = "tank.talent.study", --无人机建筑(旧车库) 天赋学习
    GetUserGuardArmy = "get.user.guard.army", --获取警察局信息

    PlayerCareerSelect = "choose.career", -- 选择职业
    PlayerCareerLevelUp = "career.up.level", -- 升级职业
    PushCareerFreeChangeTime = "push.career.free.change.time", -- 升级职业
    SetAllianceCareerPos = "set.alliance.career.pos", --联盟委任职业
    GetWorldNewInfo = "get.world.news.info", --获取世界新闻
    PushBuildDelete = "push.build.del",
    PushQueueDelete = "push.queue.del",

    GetAllianceAlertInfo = "get.alliance.alert.info", --请求所有被打成员(盟友/联盟城)
    GetAllianceAlertMarch = "get.alliance.alert.march", --请求查看被打详情信息
    PushAllianceAlertInfoCreate = "push.alliance.alert.info.create", --盟友/联盟成被打第一次推送
    PushAllianceAlertInfoRemove = "push.alliance.alert.info.remove",

    UserGetPVEStage = "user.get.pve.stage",
    UserFinishPVETrigger = "user.finish.pve.trigger",
    UserFinishPVELevel = "user.finish.pve.level",
    PushHeroLevelUp = "push.hero.leveup",
    UserStartPVELevel = "user.start.pve.level",
    UserResetPVEHero = "user.reset.pve.hero",
    UserStartMonumentPVE = "user.start.monument.pve",
    UserSweepMonumentPVE = "user.sweep.monument.pve",
    StartLandLockPVE = "start.land.lock.pve",
    UserStartPVETest = "user.start.pve.test",
    UserStartGuidePve = "user.start.guide.pve",
    BattlePveStart = "user.start.barrel.pve",
    UserStartBarrelPush = "user.start.barrel.push",
    UserStartBarrelDetect = "user.start.barrel.detect",
    UserStartBarrelPushBatch = "user.start.barrel.push.batch",

    --	 UpdateEarthOrderRefreshTime = "update.earth.order.refresh.time",--切换职业后的地球订单推送
    GetBindMailReward = "get.bind.mail.reward", --获取账号绑定奖励

    GetMineCaveInfo = "get.mine.cave.info",
    RefreshMineCaveList = "refresh.mine.cave",
    ClaimMineCaveReward = "receive.mine.occupy.task.reward",
    GetMineCavePlunderLog = "get.mine.cave.record",
    PushNewMineCavePlunderLog = "push.new.mine.record",
    SetMineCaveCross = "set.mine.cave.cross",

    --挖宝活动
    GetDigActivityInfo = "get.dig.activity.info",
    GetDigActivityInfoVertical = "get.dig.activity.info.vertical",
    DigOneBlock = "start.activity.dig",
    DigOneBlockVertical = "start.activity.dig.vertical",
    StartAutoDig = "auto.activity.dig",
    StartAutoDigVertical = "auto.activity.dig.vertical",
    SelectFinalDigReward = "choose.dig.big.reward",
    BuyDigTool = "buy.activity.dig.goods",
    GetDigActivityRankInfo = "get.dig.rank",
    GetDigLevelReward = "get.dig.activity.level.reward",
    GetDigActivityReward = "get.dig.activity.reward",

    GetJigsawActivityInfo = "get.jigsaw.info",
    BeginJigsawChallenge = "jigsaw.start",
    FinishJigsawPuzzle = "jigsaw.finish",
    GetJigsawRankInfo = "get.jigsaw.rank",

    GetUserFightPve = "user.fight.pve.monster", -- PVE战斗
    BeginPvpCaveFight = "mine.cave.fight", -- 矿洞PVE战斗
    PveDiffFight = "user.select.fight.pve.monster", -- 选择难度PVE战斗
    GetHeroMonthCardInfo = "get.hero.month.card.info", --获取英雄月卡信息
    GetHeroMonthCardReward = "receive.hero.month.card.reward", --领取奖励英雄月卡
    GetHeroMonthCardAllReward = "receive.all.hero.month.card.reward", --领取奖励英雄月卡
    BuyHeroMonthCardPush = "push.hero.month.card.unlock", --购买英雄月卡推送

    GetMonthPayActInfo = "get.month.pay.act.info", --获取活动信息，
    ReceiveMonthPayActReward = "receive.month.pay.act.reward", -- 领取积分阶段奖励
    PushMonthPayActUpdate = "push.month.pay.act.update", --奖励解锁推送
    ReceiveAllMonthPayReward = "receive.all.month.pay.act.reward", --一键领取所有奖励

    GetMonthLoginActInfo = "get.month.login.act.info", --获取活动信息，
    ReceiveMonthLoginActReward = "receive.month.login.act.reward", -- 领取积分阶段奖励
    PushMonthLoginActUpdate = "push.month.login.act.update", --奖励解锁推送
    ReceiveAllMonthLoginReward = "receive.all.month.login.act.reward", --一键领取所有奖励
    ReceiveDailyMonthLoginReward = "receive.daily.month.login.act.reward", --获取底部奖励

    UnlockUserLand = "unlock.user.land", -- 解锁地块
    FinishUserLand = "finish.user.land", -- 清理地块
    PushUnlockLand = "push.unlock.land", -- 解锁地块推送
    ReceiveLandReward = "receive.land.reward", -- 领取地块宝箱
    StartLandLockBridgeLevel = "start.land.lock.bridge.level", --进入地块修桥关

    FinishBridgeLevel = "finish.bridge.level", --修桥关结束

    UseCareerSkill = "use.career.skill", -- 使用职业技能
    UserNpcQuestion = "user.npc.question",
    PushFactoryStatusUpdate = "push.factory.status.update",
    UserGetTradeBankRecords = "user.get.trade.bank.records", --获取交易场交易记录
    PushActBossTransUpdate = "push.act.boss.trans.update",

    --puzzle start
    GetPuzzleActivityInfo = "get.puzzle.activity.info", --获取拼图信息
    ReceivePuzzleTaskReward = "receive.puzzle.task.reward", --领取拼图任务奖励
    ReceivePuzzleReward = "receive.puzzle.reward", --领取拼图奖励
    PushPuzzleTaskFinish = "push.puzzle.task.finish", --任务完成推送
    CreatePuzzleBoss = "create.puzzle.boss", --召唤拼图boss
    GetPuzzleBossMarch = "get.puzzle.boss.march", --获取自己联盟召唤的boss数据
    UserGetPuzzleBossRank = "user.get.puzzle.boss.rank", --获取拼图boss伤害排行榜
    GetPuzzleBossRankRewardInfo = "get.puzzle.boss.rank.reward.info", --获取排行奖励信息
    --puzzle end
    UserGetActBossRank = "user.get.act.boss.rank",
    UserGetActBossMarch = "user.get.act.boss.march",
    FinishSampling = "finish.sampling", --采样结束
    StartPickGarbage = "start.pick.garbage",
    StartDetectEventPve = "start.detect.event.pve", --开启pve
    ResetDetectEvent = "reset.detect.event",

    GetRechargeInfo = "get.recharge.info",
    ReceiveRechargeReward = "receive.recharge.reward",
    PushRechargeScore = "push.recharge.score",
    PushNewRecharge = "push.new.recharge",

    AllianceDeclareWarCreate = "alliance.declare.war.create",
    AllianceDeclareWarGet = "alliance.declare.war.get",
    AllianceDeclareWarCancel = "alliance.declare.war.cancel",
    PushNewAllianceDeclareWar = "push.new.alliance.declare.war",
    ResetDetectEvent = "reset.detect.event",
    AllianceGetCityDeclareTimes = "alliance.get.city.declare.times", --获取今日宣战次数
    AllianceDeclareWarReward = "alliance.declare.war.reward",
    GetAllianceCityFirstKillReward = "get.alliance.city.first.kill.reward",

    StartPveMonster = "start.pve.monster", --进入pve关卡   与"start.land.lock.pve"类似
    ReceivePveMonsterReward = "receive.pve.monster.reward",
    PushPveMonsterUpdate = "push.pve.monster.update",
    PushPveMonsterAdd = "push.pve.monster.add",

    GetHeroLotteryInfo = "get.hero.lottery.info",

    FindMonsterBoss = "find.monster.boss",

    GetLuckyRollInfo = "get.lucky.roll.info", --获取转盘信息
    PushLuckyRollNotice = "push.lucky.roll.notice.new", --有人中大奖的推送
    GetLuckyRollNotice = "get.luck.roll.notice", --有人中大奖的推送
    LuckyRollChooseItem = "lucky.roll.choose.item", --选择道具
    ReceiveLuckyRollDailyReward = "receive.lucky.roll.daily.reward", --领取转盘每日免费奖励
    LuckyRollLottery = "lucky.roll.lottery", --抽奖
    ReceiveLuckyRollStageReward = "receive.lucky.roll.stage.reward", --领取阶段奖励
    GetLuckRollRank = "get.luck.roll.rank",
    UserRecoverPlayerStamina = "user.recover.player.stamina",
    SelectPveBuff = "user.select.pve.buff",
    ChoosePveBuff = "choose.pve.buff",

    BuyItemAndResource = "buy.item.and.resource",

    UseHeroEffectSkill = "use.hero.effect.skill",
    UseHeroEffectSkillMulti = "use.hero.effect.skill.multi",
    PayForHeroEntrust = "pay.for.hero.entrust",
    PushNewEntrust = "push.new.entrust",

    UserChatStat = "chat.stat",
    PushDetectEvent = "push.detect.event.info",

    UserGetMineCaveReport = "get.mine.cave.report",

    -- 星珲探险活动
    --AdventureGetInfo = "user.get.explorer.pve.info",
    --AdventureSetArmy = "user.set.explorer.pve.army",
    --AdventureStart = "user.start.explorer.pve",
    --AdventureGetLevel = "user.get.now.explorer.pve.level",
    --AdventureRaid = "user.hang.raid.explorer.pve",
    --AdventureReset = "user.reset.explorer.pve",
    --AdventureGetRecord = "user.get.explorer.pve.record",
    --AdventureGetRecordDetail = "user.get.explorer.record.detail",
    --AdventureSelect = "user.select.explorer.pve",

    FirstJoinAlliance = "first.join.alliance", --答题后把结果传服务器

    --{{{战令
    GetBattlePassInfo = "get.battlepass.info", --获取battlepass
    ReceiveBattlePassTaskReward = "receive.battlepass.task.reward", --领取任务奖励经验
    ReceiveBattlePassStageReward = "receive.battlepass.stage.reward", --领取阶段奖励
    ReceiveBattlePassExtraReward = "receive.battlepass.extra.reward", --领取额外奖励
    ReceiveBattlePassAllReward = "receive.battlepass.all.reward", --一键领奖（领取所以的等级奖励和额外奖励)
    BuyBattlePassLevel = "buy.battle.pass.level", --钻石购买等级
    PushBattlePassUpdate = "push.battlepass.update", --推送更新
    PushBattlePassTaskUpdate = "push.battlepass.task.update", --推送更新battlepass任务进度和状态
    PushAllBattlePassTask = "push.all.battlepass.task", --推送所有battlepass任务
    --}}}

    GetSeasonPassInfo = "get.season.battlepass.info",
    ClaimSeasonPassTaskReward = "receive.season.battlepass.task.reward",
    ClaimSeasonPassLevelReward = "receive.season.battlepass.stage.reward",
    ClaimSeasonPassExtraReward = "receive.season.battlepass.extra.reward",
    PushSeasonPassInfoUpdate = "push.season.battlepass.update",
    PushSeasonPassTaskUpdate = "push.season.battlepass.task.update",
    ClaimAllSeasonPassReward = "receive.season.battlepass.all.reward",

    ChooseBaseTalent = "choose.base.talent",
    ResetBaseTalent = "reset.base.talent",
    PushBaseTalent = "push.base.talent",
    RefreshBaseTalent = "refresh.base.talent",

    SetHeroOfficial = "set.hero.official", -- 设置英雄官职
    HeroIntensify = "hero.intensify", -- 英雄阵营强化
    HeroIntensifyRandomEffect = "hero.intensify.random.effect", -- 英雄阵营强化随机
    UserGetQuestionnaireList = "user.get.questionnaire.list", --调查问卷
    PushUserQuestionnaire = "push.user.questionnaire",
    UserNpcQuestionnaire = "user.npc.questionnaire",
    UserCancelFactoryPanel = "user.cancel.factory.panel", --取消工厂计划区
    UserGetServerEffect = "user.get.server.effect",
    PushUserGMOff = "push.user.gm.off",
    GetHeroBountyInfo = "get.hero.bounty.info",
    StartHeroBountyTask = "start.hero.bounty.task",
    ReceiveHeroBountyTaskReward = "receive.hero.bounty.task.reward",
    RefreshHeroBountyTask = "refresh.hero.bounty.task",
    PushPveStaminaUpdate = "push.pve.stamina.update", --- 推送pve体力
    SyncPveResource = "sync.pve.resource", --- 同步pve资源
    GetCrossServerInfo = "get.cross.server.info",
    --{{{咕噜卡牌
    GetGolloesCardInfo = "get.golloes.card.info", --获取咕噜卡牌信息
    FlipGolloesCard = "flip.golloes.card", --翻卡
    FlipAllGolloesCard = "flip.all.golloes.card", --一键翻卡
    RefreshGolloesCard = "refresh.golloes.card", --刷新
    GetGolloesCardRank = "get.golloes.card.rank", --获取排行榜
    --}}}
    JwtFunction = "jwt.function",
    LevelExploreGetInfo = "get.explore.pve.info",
    LevelExploreGetDetail = "get.explore.pve.detail.info",
    LevelExploreSweep = "sweep.pve.level",
    LevelExploreStart = "start.explore.pve",
    GetAllianceInfo = "get.al.info",
    PveTriggerCost = "pve.trigger.cost", --pve trigger消耗
    PayTriggerResItem = "pay.trigger.res.item", --交付trigger资源
    ReceivePVETriggerReward = "receive.pve.trigger.reward", --领取trigger奖励
    ClearPVETriggerRewardCD = "clear.pve.trigger.reward.cd", --清领取trigger奖励CD
    GetTriggerReward = "get.trigger.reward", --获得trigger奖励信息，用来检查仓库
    PushPveLevelFinish = "push.pve.level.finish", --pve推送完成关卡
    IDCardAuthenticate = "id.card.authenticate", --身份证验证
    UpgradeTriggerBuilding = "upgrade.trigger.building", --升级trigger生产建筑
    PushFoldCrossWormTime = "push.fold.cross.worm.time", --跨服虫洞收起时间
    PushFoldSubWormTime = "push.fold.sub.worm.time", --原服虫洞收起时间
    PveActGetInfo = "get.activity.level.info",
    PveActTaskReward = "receive.activity.level.task.reward",
    PveActStageReward = "receive.activity.level.stage.reward",
    PveActUpdateTask = "push.activity.level.task.update",
    PveActGetRank = "get.activity.level.rank",
    PveActScoreUpdate = "push.activity.level.score.update",
    PveActRankUpdate = "push.activity.level.rank.status",

    PushWorldEffect = "world.effect.push",

    CrossGetAlliancePoint = "cross.get.alliance.point",

    GetSevenDayActInfo = "get.seven.day.act.info", --获取七日活动信息
    PushSevenDayActScore = "push.seven.day.act.score", --增加积分推送
    ReceiveSevenDayActReward = "receive.seven.day.act.reward", --领取七日活动阶段奖励

    PushDefendWallCompensate = "push.defend.wall.compensate", --伤兵补偿
    UserGetDefendWallCompensate = "user.get.defend.wall.compensate", --领取伤兵

    PushCrossAlert = "push.cross.alert",

    GetChallengeActInfo = "get.challenge.act.info", --获取挑战活动信息
    ChooseChallengeActDifficulty = "choose.challenge.act.difficulty", --选择难度
    CallChallengeActBoss = "call.challenge.act.boss", --召唤boss
    CallChallengeActHelp = "call.challenge.act.help", --请求帮助打boss
    PushCallChallengeActHelp = "push.call.challenge.act.help", --有人请求帮助给盟友推送
    GetChallengeActTaskInfo = "get.challenge.act.task.info", --获取联盟挑战任务信息
    ReceiveChallengeActTaskReward = "receive.challenge.act.task.reward", --领取任务奖励
    ReceiveMonsterTowerStageReward = "receive.challenge.act.stage.reward", --巨兽追捕领奖面板领奖
    GetChallengeActLevelRewardInfo = "get.challenge.act.level.reward.info", --获取通关等级对应的奖励列表
    GetChallengeActMemberInfo = "get.challenge.act.member.info", --获取盟友的挑战信息
    ReceivePveTriggerDropItem = "receive.pve.trigger.drop.item", --拾取掉落道具
    PushChallengeBossKilled = "push.challenge.boss.killed", --挑战boss被击杀推送
    UBStoreUpgrade = "ub.store.upgrade", --建筑升级交资源
    PushUBUpgradeStockDel = "push.ub.upgrade.stock.del", --推送删除建筑升级交资源
    HeroDecomposePiece = "hero.decompose.piece",
    WorldGetMarchInfos = "world.get.march.infos", --获取视口内玩家行军数据
    GetGarbageInfo = "get.garbage.info", --获取世界垃圾信息

    GetNoticeList = "get.notice.list", --拉取公告列表
    PushNewNotice = "push.new.notice", --新公告推送
    ReadNotice = "read.notice", --标记公告已读
    ReceiceNoticeReward = "receice.notice.reward", --领取公告奖励
    PushDeleteNotice = "push.delete.notice", --删除公告推送
    BackBuildingCollectTime = "back.building.collect.time", --引导特殊让产金币建筑拥有金币

    UserGetAllDesert = "user.get.all.desert",
    UserGiveUpDesert = "user.give.up.desert",
    UserCancelGiveUpDesert = "user.cancel.give.up.desert",
    PushUserGetDesert = "push.user.get.desert",
    PushUserLostDesert = "push.user.lost.desert",

    FormationMarchTime = "formation.march.time",
    UserCollectDesertRes = "user.collect.desert.res",
    PushWorldDesertFirstOccupyUpdate = "push.world.desert.first.occupy.update", --更新地块首战

    PushSeasonBalanceRemind = "push.season.balance.remind", --赛季机器人红点
    SeasonBalanceViewOpen = "season.balance.view.open", --赛季活动主界面打开
    SeasonBalancePackageViewOpen = "season.balance.package.view.open", --盟主发礼包界面打开
    SeasonBalanceGiveRecord = "season.balance.give.record", --获取奖励发放记录
    SeasonBalanceMemberList = "season.balance.member.list", --已发放奖励选择成员列表预览
    SeasonBalanceGiveAlliesPackages = "season.balance.give.allies.packages", --发送盟主此次设置获奖礼包成员列表
    SeasonBalanceReceivePackage = "season.balance.receive.package", --赛季结算成员领取请求-成员领取奖励

    GetActivityDropInfo = "get.activity.drop.info",
    PushActivityItemDropCount = "push.activity.item.drop.count",
    PushActivityDropReward = "push.activity.drop.reward",

    CoverSkin = "conver.skin", --兑换皮肤
    WearSkin = "wear.skin", --穿戴皮肤
    TakeOffSkin = "takeoff.skin", --换下皮肤

    HeroPosterExchange = "hero.poster.exchange",
    PushSkinUpdate = "push.skin.update",
    CheckAttackBoss = "check.attack.boss",

    SetAutoFarm = "set.auto.farm",
    CollectAutoFarm = "collect.auto.farm",

    ChainPayGetInfo = "get.continuous.package.info",
    ChainPayReceiveReward = "receive.continuous.package.reward",
    ChainPayUpdateState = "push.continuous.package.state",
    ChainPayRefresh = "refresh.continuous.package",
    GetAllChapterInfo = "get.all.chapter.info",

    GetDiscountShopInfo = "get.discount.shop.info",
    RefreshDisCountShop = "refresh.discount.shop",
    BuyInDiscountShop = "buy.in.discount.shop",
    ReceiveShopFreeReward = "receive.discount.shop.free.reward",

    GetSevenDayLoginInfo = "get.seven.day.login.info", --获取七日登录活动信息
    ReceiveSevenDayLoginReward = "receive.seven.day.login.reward", --领取主题活动奖励
    UserModifySex = "user.modify.sex", --改变性别
    GetActivityGiftBoxInfo = "get.activity.gift.box.info", --获取活动信息
    OpenActivityGiftBox = "open.activity.gift.box", --开启宝箱
    ActivityGiftBoxLottery = "activity.gift.box.lottery", --抽奖
    GetActivityGiftBoxLotteryCount = "get.activity.gift.box.lottery.count", --获取今日宝箱抽取次数
    GetGiftBoxRank = "get.gift.box.rank", --礼盒排行榜
    GetGiftBoxProgressReward = "get.activity.gift.box.reward", --礼盒开启次数对应阶段奖励

    PushExtraDesertNum = "push.extra.desert.num",
    SeasonForceBattlePassReward = "season.force.battle.pass.reward",
    SeasonForceReward = "season.force.reward",
    SeasonForceGetAllReward = "season.force.get.all.reward",
    SeasonForceGetReward = "season.force.get.reward",
    PushSeasonForceRewardAdd = "push.season.force.reward.add",
    SeasonForceGetBattlePassReward = "season.force.get.battle.pass.reward",
    ReceiveSeasonForceStageReward = "receive.season.force.stage.reward",
    ReceiveAllSeasonForceStageReward = "receive.all.season.force.stage.reward",
    -- 赛季周BUFF
    SeasonWeekBuffGetInfo = "get.season.week.buff.info",
    SeasonWeekBuffReceiveReward = "receive.season.week.buff.reward",
    SeasonWeekBuffUpdate = "push.season.week.buff.update",

    FindDesertPoint = "find.desert.point", --找赛季地块

    -- 专精
    MasteryLearn = "learn.desert.talent.new",
    MasteryChangePlan = "change.desert.talent.page",
    MasteryUseSkill = "use.desert.talent.skill",
    MasteryUpdate = "push.desert.talent.level.info",
    ResetDesertTalentOtherPage = "reset.desert.talent.other.page", --重重其他页天赋
    ChangeDesertTalentPageName = "change.desert.talent.page.name", --天赋页改名
    DesertTalentPageNameCheck = "desert.talent.page.name.check", --改名检查
    PushDesertTalentExtraPageNum = "push.desert.talent.extra.page.num", --额外页数量推送

    -- npc city
    GetNpcCityInfo = "get.npc.city.info",
    GetNpcCityChat = "get.npc.city.msg",
    PushNpcCityDefendChange = "push.npc.city.defend.change",
    PushNpcCityNewChat = "push.npc.city.new.msg",

    -- S3 荣耀
    GetDeclareWarInfo = "get.declare.war.info",
    DomainAlWarPanel = "domain.al.war.panel",
    DomainAlDeclareWar = "domain.al.declare.war",
    PushAlDomainFightOpen = "push.al.domain.fight.open",
    DomainAlMatchVs = "domain.al.match.vs",
    DomainAlSetAvoidTime = "domain.al.set.avoid.time",
    DomainAlHis = "domain.al.his",
    DomainAlWarMemberScoreHis = "domain.al.war.member.score.his",
    DomainAlWarResult = "domain.al.war.result",
    AlBattleEvent = "al.battle.event",
    AlFightActInfo = "al.fight.act.info",
    AlFightActInfoRecord = "al.fight.act.info.record",
    AlFightActMemberScore = "al.fight.act.member.score",
    SeasonContributionInfo = "season.contribution.info",
    GetDeclareTargetAlliancePosition = "get.declare.target.alliance.position",

    GetSeasonWeekCardInfo = "get.season.week.card.info", --获取赛季周卡信息
    ReceiveSeasonWeekCardReward = "receive.season.week.card.reward", --领取赛季周卡奖励
    PushSeasonWeekCardUpdate = "push.season.week.card.update", --周卡购买后推送
    GetLastSeasonHeroRecordInfo = "get.last.season.hero.record.info",
    PushDesertCollectTimeUpdate = "push.desert.collect.time.update",
    DesertForceSelfRank = "desert.force.self.rank",
    GetDeadArmyRecord = "get.dead.army.record", --获取报废士兵信息
    GetGuideDetectEventInfo = "get.guide.detect.event.info", --获取引导雷达事件（胡迪尔）信息
    PushFinishGuideEvent = "push.finish.guide.event", --引导事件完成推送
    GetAllianceSeasonRank = "get.alliance.season.rank",
    GetSkinActivityInfo = "get.skin.activity.info", --获取皮肤活动信息
    ReceiveSkinActivityReward = "receive.skin.activity.reward", --领取皮肤活动奖励
    SkinActivityRewardStatePush = "push.skin.activity.reward.state", --皮肤活动可领奖推送
    SendContactGiftSearch = "send.contact.gift.search", --模糊搜索指定服玩家信息
    SendGiftByActivity = "send.gift.by.activity", --赠送礼物
    PushFoldAlFlagTime = "push.fold.al.fortress.time",
    GetAlFlagDestroyTime = "get.al.flag.destroy.time",
    PushFoldAlFortressTime = "push.fold.al.flag.time",
    WorldFoldUpAllianceBuilding = "world.fold.up.alliance.building",
    WorldFixAllianceBuilding = "world.fix.alliance.building",

    -- 跨服虫洞C口
    UserSaveCrossDefendHero = "user.save.cross.defend.hero",
    UserFillCrossWormArmy = "user.fill.cross.worm.army",
    PushCrossFillArmyTimes = "push.cross.fill.army.times",
    UserGetCrossWormRes = "user.get.cross.worm.res",
    PushCrossWormRes = "push.cross.worm.res",
    PushCrossResSync = "push.cross.res.sync",

    CarEquipExp = "car.equip.exp",
    EquipUpQuality = "equip.up.quality",
    WearCarEquip = "wear.car.equip",
    TakeOffEquip = "take.off.car.equip",
    NewCarEquipPush = "push.new.car.equips",
    EquipEffectChangePush = "push.equip.effect.change",
    PushAreaHotNewAdd = "push.area.hot.news.add", --推送区域热点消息
    MonsterSiegeActivityInfo = "monster.siege.activity.info", --黑骑士活动数据
    MonsterSiegeStart = "monster.siege.start", --联盟开启怪物攻城
    MonsterSiegeRewardInfo = "monster.siege.reward.info", --怪物攻城奖励信息
    MonsterSiegeSelectTime = "monster.siege.select.time", --预约开启时间
    PushMonsterAttack = "push.monster.attack", --推送怪物攻城信息
    PushAllianceAttackerAdd = "push.alliance.attacker.add", --仇人系统数据更新
    GetWorldAttackerInfo = "get.world.attacker.info", --获取仇人系统位置

    -- 捐兵活动
    GetDonateArmyActivityInfo = "get.donate.army.activity.info", --获取捐兵活动信息
    GetDonateArmyScoreInfo = "get.donate.army.score.info", --获取对决双方联盟成员积分信息
    ReceiveDonateArmyTaskReward = "receive.donate.army.task.reward", --领取捐兵活动任务奖励
    DonateArmy = "donate.army", --捐士兵
    ReceiveDonateArmyStageReward = "receive.donate.army.stage.reward", --领取捐兵贡献奖励
    PushDonateArmyTaskUpdate = "push.donate.army.task.update", --捐兵任务进度或状态变化推送
    GetDonateArmyInfoMessage = "get.pirate.siege.info", -- 捐兵世界信息面板
    GetDonateArmyRankMessage = "get.pirate.siege.rank.info", -- 捐兵战斗排行榜

    PirateSiegeOpen = "pirate.siege.open", -- 开启捐兵海盗攻城
    PushPirateSiegeBattleStart = "push.pirate.siege.battle.start", -- 开启成功推送

    --官职
    GetKingdomPositions = "get.kingdom.positions", --获取王座职位
    KingdomPositionAppoint = "kingdom.position.appoint", --官职任命
    ChooseKing = "choose.king", --任命国王
    GetKingInfo = "get.king.info", --获取国王信息
    ModifyKingDeclaration = "modify.king.declaration", --修改宣言
    GetKingdomPresentInfo = "get.kingdom.present.info", --获取王座礼包信息
    GetKingdomPresentRecord = "get.kingdom.present.record", --获取王座礼包发放记录
    KingSendPresent = "king.send.present", --发放王座礼包
    GetKingHistory = "get.history.king.record", --获取历任国王信息
    PushUserKingdomPositionUpdate = "push.user.kingdom.position.update",
    TransferKing = "transfer.king", --转让国王

    HeroEvolveActivityInfo = "get.hero.evolve.activity.info",
    HeroEvolveActivityChooseHero = "hero.evolve.choose.hero",
    HeroEvolveActivityHeroEvolve = "hero.evolve",
    BuildingBreakChooseDirection = "building.break.choose.direction", --建筑突破
    BuildingBreakChangeDirection = "building.break.change.direction", --建筑重新选择方向
    PushBuildingBreakFreeTime = "push.building.break.free.time", --获得免费次数推送
    GetHeroMedalShopInfoCmd = "get.hero.medal.shop.info", --获取英雄纪念章商店信息
    ReceiveHeroMedalShopDailyReward = "receive.hero.medal.shop.daily.reward", --领取英雄纪念章商店每日奖励
    UserHeroMedalShopBuy = "user.hero.medal.shop.buy", --英雄纪念章商店购买

    GetDesertForceGroupRank = "get.desert.force.group.rank",

    GetRefreshDesertActivityInfo = "get.refresh.desert.activity.info",
    KingRefreshDesert = "king.refresh.desert",
    KingRefreshDesertPush = "push.king.refresh.desert",
    StartTimeBridgeLevel = "start.time.bridge.level", --通过时间礼包进入关卡
    GetTimeBridgeInfo = "get.time.bridge.info", --获取时间礼包信息(刷新)
    PushTimeBridgeInfo = "push.time.bridge.info", --时间礼包关卡完成推送
    ReceiveTimeBridgeReward = "receive.time.bridge.reward", --时间礼包领奖
    -- 新捐兵活动
    GetALVSDonateArmyActivityInfo = "get.donate.army.activity.info.v2", --获取捐兵活动信息
    ReceiveALVSDonateArmyTaskReward = "receive.donate.army.task.reward.v2", --领取捐兵活动任务奖励
    ALVSDonateArmy = "donate.army.v2", --捐士兵
    ReceiveALVSDonateArmyStageReward = "receive.donate.army.stage.reward.v2", --领取捐兵贡献奖励
    PushALVSDonateArmyTaskUpdate = "push.donate.army.task.update.v2", --捐兵任务进度或状态变化推送
    GetALVSDonateArmyDeclareWarList = "get.donate.army.declare.war.list", --捐兵宣战联盟列表
    ALVSDonateArmyDeclareWar = "donate.army.declare.war",
    ALVSDonateArmyRandomMatchEnemy = "donate.army.random.match.enemy", --随机匹配新捐兵联盟对手
    PushALVSDonateArmyMatchSuccess = "push.donate.army.match.success", --匹配到对手推送
    PushALVSDonateArmyBattleStart = "push.donate.army.battle.start", --盟主开启迎战后推送
    GetALVSDonateArmyBattleInfo = "get.donate.army.battle.info", -- 获取对决信息
    ALVSDonateArmyOpenAttack = "donate.army.open.attack", -- 获取对决信息
    PushDonateArmyDefenceResult = "push.donate.army.defence.result", -- 联盟中心状态变化

    PveTaskRewardGetAll = "pve.task.reward.get.all", --pve悬赏任务一键领取
    GetPvePushLevelInfo = "get.pve.push.level.info", --获取悬赏任务

    MissileInfoGet = "al.missile.info",
    MissileInfoPush = "push.update.al.missile",
    MissileCreate = "al.missile.create",
    MissileAttackPush = "push.user.main.alliance.missile.attack",

    GetMigrateServers = "get.migrate.servers", --获取移民列表
    MigrateToServer = "migrate.server", --移民到指定服务器
    GetMigrateItem = "get.migrate.item", --获取移民服详细内容
    MigrateApply = "migrate.apply", --移民申请
    MigrateApplyList = "migrate.apply.list", --移民列表
    MigrateApprove = "migrate.approve", --移民审批
    MigrateSetPowerLimit = "migrate.set.power.limit", --移民设置战力上限
    PushMigrateNewApply = "push.migrate.new.apply",
    MigrateActivityInfo = "migrate.activity.info",

    GetBalloonPuzzleInfo = "get.balloon.puzzle.info",
    ReceiveBalloonPuzzleReward = "receive.balloon.puzzle.reward",

    GetAllianceBossActivityInfo = "get.alliance.boss.activity.info",
    AllianceBossDonate = "alliance.boss.donate",
    CallAllianceBoss = "call.alliance.boss",
    AllianceBossSelectTime = "alliance.boss.select.time",
    PushAllianceBossCreate = "push.alliance.boss.create",
    PushAllianceBossDamageUpdate = "push.alliance.boss.damage.update",
    ReceiveAllianceBossFreeReward = "receive.alliance.boss.free.reward",
    GetAllianceBossDonateRank = "get.alliance.boss.donate.rank",
    GetAllianceBossDamageRank = "alliance.boss.damage.rank",
    GetAllianceBossRewardInfo = "alliance.boss.reward.info",
    StartPrologueBridgeLevel = "start.prologue.bridge.level",
    PushFinishPrologueBridge = "push.finish.prologue.bridge",
    PrepareFillArmy = "prepare.fill.army",
    PushDeclareWarExitAllianceRecord = "push.declare.war.exit.alliance.record",
    --	 EarthOrderFillBatch = "earth.order.fill.batch",--批量交地球订单资源道具
    IndividualOrderFillBatch = "fill.individuel.order.batch", -- 批量填充订单物品
    PushPlayerNitrogen = "push.player.nitrogen",
    SpeedUpMarchNitrogen = "speed.up.march.nitrogen",
    PlaceBauble = "place.bauble", --放置新装饰建筑(消耗道具创建新的建筑)
    UpgradeBauble = "upgrade.bauble", --升级装饰建筑
    ReplaceBauble = "replace.bauble", --重新放置收起的装饰建筑
    MoveBauble = "move.bauble", --移动装饰建筑
    FoldUpBauble = "fold.up.bauble", --收起装饰建筑
    BaubleLottery = "bauble.lottery", --抽装饰建筑
    GetAllianceActMineMember = "get.alliance.act.mine.member",
    GetActMinePlunderRes = "get.act.mine.plunder.res",
    DragonActivityInfo = "dragon.activity.info", --获取巨龙活动信息
    DragonAssignPlayerInfo = "dragon.assign.player.info", --指派出战成员信息
    DragonAutoAssignPlayer = "dragon.auto.assign.player", --自动设置出战成员
    DragonRevokeAllPlayer = "dragon.revoke.all.player", --取消所有出战成员
    DragonAssignPlayer = "dragon.assign.player", --指派成员出战
    DragonRevokePlayer = "dragon.revoke.player", --取消成员出战
    DragonBattleSignUp = "dragon.battle.sign.up", --报名
    DragonBattleModifyBattlePeriod = "dragon.battle.modify.battle.period", --修改报名场次
    GetDragonBattleTimes = "get.dragon.battle.times", --查看报名可选时段
    DragonBattleInfo = "dragon.battle.info", --战场联盟积分信息
    DragonBattleScoreInfo = "dragon.battle.score.info", --战场积分详细信息
    DragonRewardInfo = "dragon.reward.info", --获取奖励信息
    DragonBattleHistory = "dragon.battle.history", --历史记录
    ExitDragonServer = "exit.dragon.server",
    DragonBattleMemberApply = "dragon.battle.member.apply",

    GetUploadPicActivityInfo = "get.upload.pic.activity.info", --获取上传头像活动信息
    ReceiveUploadPicActivityReward = "receive.upload.pic.activity.reward", --领取上传头像活动奖励

    GetAllianceCityKillRank = "get.alliance.city.kill.rank",
    GetAllianceCityRecordRedPoint = "get.alliance.city.record.red.point",
    GetAllianceCityKillReward = "get.alliance.city.kill.reward",

    ------------------------------------------------------------------
    -- 上面是aps消息，不要动也不要删除（删除的话就加注释）；SU新加的消息要放到这条线的下面！！！

    PushUserOff = "push.user.off", --账号被顶掉
    BindGaid = "bind.gaid",
    BuildMainCity = "build.main.city",
    CheckDeviceChange = "check.device.change",

    SUGetGarbageInfo = 'survival.queue.gather.show.reward', --请求垃圾信息
    SUDispatchGirlToCollect = 'survival.queue.gather.start',
    SUCancelCollectGarbage = 'survival.queue.gather.cancel',
    SUFinishGarbageCollect1 = 'survival.queue.gather.finish.type1',
    SUFinishGarbageCollect2 = 'survival.queue.gather.finish.type2',
    SUConfirmGarbageCollect = 'survival.queue.gather.finish.reward',
    SURandomReward = 'push.survival.random.reward.receive',
    GirlCollectSpeedUp = "survival.queue.gather.speed",

    SU_PushPveTrigger = "push.survival.pve.trigger", -- 更新trigger状态
    SU_HeartBeat = "survival.pve.heartbeat", -- 心跳消息
    SU_ItemExchange = "survival.item.exchange", -- 兑换道具

    BagCommonModify = 'survival.grid.modify',
    BagGetGridData = 'survival.grid.get',
    BagPushUpdateGrid = 'push.survival.grid',
    BagRemove = 'survival.grid.remove',
    BagGridMoveAll = 'survival.grid.move.package',
    BagGridSingleMove = 'survival.grid.move.single',
    BagGridStackAll = 'survival.grid.stack.package',
    BagSplit = 'survival.grid.move.split',
    BagSort = 'survival.grid.move.sort',
    BagDebugAdd = 'survival.grid.add.debug',
    SyncEquipDurable = 'survival.sync.equip.durable',
    BluePrintCraft = 'survival.bluePrint.craft',
    SurvivalRewardItemUse = 'survival.reward.item.use',
    SU_ZombieBuildingDamage = "survival.zombie.building.damage",


    SU_Pve_Level_Start = "survival.pve.level.start", -- 申请关卡信息
    SU_Pve_Level_Finish = " survival.pve.level.finish", -- 结束关卡-仅用来临时测试
    SU_PveTriggerUpdate = "survival.pve.trigger.update", -- 更新关卡信息
    SU_PveTriggerSubmitItem = "survival.pve.trigger.submit.item", -- 道具提交
    SU_AreaStart = "survival.area.start",
    LW_AreaFinish = "survival.area.finish",
    --SU_PushSurvivalAreaFinish = "push.survival.area.finish",
    SU_PushSurvivalAreaFinish = "push.survival.area.complete",
    SU_PushSurvivalTriggerRewardEmpty = "push.survival.trigger.reward.empty",
    SU_PvePlayerInfoUpdate = "survival.player.info.update", -- 更新人物信息
    SU_SurvivalGridSyncCount = "survival.grid.sync.count", -- 使用道具
    SU_SurvivalPlayerDead = "survival.player.dead", -- 人物死亡
    SU_SurvivalPlayerRevive = "survival.player.revive", -- 人物复活
    SU_PushPlayerInfo = "push.survival.player.info", -- player info push
    SU_ZombieEventStart = "survival.zombie.event.start", --开启丧尸攻城
    SU_ZombieInit = "survival.zombie.init", --生成丧尸攻城的僵尸
    SU_ZombieEventFinish = "survival.zombie.event.finish", --丧尸工程结束


    SU_Pve_SetCurLevelId = "survival.pve.set.curlevelid",

    SU_SurvivalMistressEventFinish = "survival.npc.event.finish", -- 美女交互事件完成
    SU_SurvivalMistressEvevtSubmit = "survival.npc.event.submit", -- 美女交互提交物品
    SU_SurvivalMistressGift = "survival.npc.gift", -- 美女送礼物
    SU_SurvivalMistressAction = "survival.npc.action", -- 美女喝酒
    SU_SurvivalMistressActionRefresh = "survival.npc.action.refresh", -- 美女喝酒倒计时结束后恢复次数
    SU_SurvivalMistressLevelUp = "survival.npc.leve.up", -- 好感度升级
    SU_SurvivalMistressExchange = "survival.npc.exchange", -- 警徽兑换美女
    SU_SurvivalMistressReceive = "survival.npc.receive", -- 领取
    SU_BuildUse = "survival.building.use", -- 建筑使用
    SU_SaveMainCityRoleTeam = "survival.save.base.formation", -- 保存主城内编队
    SU_GuideToAddLove = "survival.guide.save", -- 引导触发增加好感度
    SU_PushNpcGift = "push.survival.npc.gift", -- 美女解锁
    SU_NpcTap = "survival.npc.tap", --点美女领好感度
    SU_BuildRepair = "survival.zombie.building.repair", -- 建筑修复
    SU_UpdateEvent = "survival.pve.event.update", -- 更新事件状态
    SU_FinishQuest = "survival.pve.dialog.task", -- 通知服务器任务完成
    SU_GiveNpcItem = "survival.pve.task.give.item", -- 交物资给npc
    SU_Shower = "survival.player.shower", -- 触发洗澡
    SU_Pee = "survival.player.pee", -- 小便
    SU_Poo = "survival.player.poo", -- 大便

    --驻扎
    SU_PUSH_SURVIVAL_DATA = "push.survival.data", --驻扎数据推送
    SU_SURVIVAL_BUILDING_PEOPLE_STATION = "survival.building.people.station", --驻扎建筑
    SU_PUSH_SURVIVAL_RES_FOOD = "push.survival.resource.food", --食物推送
    SU_SurvivalStoryScene = "survival.story.scene", --切换推图关卡

    --每日体力气泡
    SU_EnergyBubble = "survival.get.energy",

    -- 获取躲避球的英雄战力
    GetBarrelHeroInfo = "survival.pve.formation.info",

    PushDailyKillDrakeBossNumber = "push.daily.kill.drake.boss.number", --推送德雷克活动boos参与击杀次数
    GetUserDrakeBoss = "get.user.drake.boss", --获得上一次召唤的未被击杀的德雷克boss

    SU_BuildUnlock = "survival.building.unlock", -- 0级建筑到1时初始的解锁状态
    PushTimeCompetitionRank = "push.survival.individual.stage.rank",
    TimeCompetitionRank = "survival.individual.stage.rank", --限时排行排名数据
    TimeCompeRankGetReward = "survival.individual.stage.rank.reward", --限时排行获得奖励

    PushHeroDelete = "push.hero.delete", -- 删除英雄的消息

    SU_DetectDialog = "survival.detect.dialog", --直接完成雷达
    SU_DialogStep = "survival.dialog.step", --对话完成
    SU_DetectSummon = "survival.detect.summon", -- 主动刷一批雷达

    DailyMustBuyList = "daily.must.list", --每日必买列表
    DailyMustBuyReward = "daily.must.reward", --每日必买领取奖励

    -- world
    GetViewLevelWorldInfo = "world.get.new",
    PushWorldMarchWorldGet = "push.world.march.world.get.new",
    PushWorldMarchNew = "push.world.march.new",
    PushWorldMarchDel = "push.world.march.del",
    PushBattleFinish = "push.battle.finish",
    PushWorldDesertUpdate = "push.world.desert.update",
    PushWorldPointUpdate = "push.world.point.update",
    PushBattleRoundInfo = "push.battle.round.info",
    PushUserDefenceChange = "push.user.defend.change",
    PushWorldMove = "push.world.mv",
    PushWorldMarchError = "push.world.march.err",
    WorldMarchFormationNew = "world.march.formation.new", --创建行军
    WorldMarchChange = "world.march.change", --更改行军目标
    WorldGetDetail = "world.get.detail.new",
    LeaveWorld = "user.leave.world",
    --- 派遣任务相关协议
    --主动请求
    DispatchGetTasks = "get.dispatch.mission.info", --个人任务列表
    DispatchGetAllianceTasks = "get.alliance.dispatch.mission.info", --盟友任务列表,盟友任务列表只能主动请求,不参与红点,不主动推送
    DispatchStart = "start.dispatch.mission", --派遗英雄
    DispatchReward = "receive.dispatch.mission.reward", --收菜
    DispatchSteal = "steal.dispatch.mission", --偷菜
    DispatchAssist = "assist.dispatch.mission", --协助
    DispatchTaskRefresh = "refresh.dispatch.mission",
    DispatchGetLog = "get.dispatch.mission.record",
    PushDispatchGetLog = "push.dispatch.mission.record.add",
    DispatchRewardAll = "receive.dispatch.mission.reward.all",
    DispatchRefreshSuper = "refresh.dispatch.mission.legend",
    --- 派遣任务相关协议end
    --英雄穿装备
    HeroEquipInstall = "hero.equip.install",
    --英雄脱装备
    HeroEquipUninstall = "hero.equip.uninstall",
    --英雄装备升级
    HeroEquipUpgrade = "hero.equip.upgrade",
    --英雄装备晋升
    HeroEquipPromoteUp = "hero.equip.promote.up",
    --英雄装备分解
    HeroEquipDecompose = "hero.equip.decompose",
    --获得新英雄装备推送
    PushUserHeroEquipAdd = "push.user.hero.equip.add",
    --开启生成英雄装备
    StartProductHeroEquip = "start.product.hero.equip",
    --英雄材料合成
    HeroEquipMaterialCompose = "hero.equip.material.compose",
    --英雄材料分解
    HeroEquipMaterialDecompose = "hero.equip.material.decompose",

    PushHeroSPEquipAdd = "push.user.hero.equip.unique.add",
    HeroSPEquipUnlock = "hero.equip.unique.unlock",
    HeroSPEquipUpgrade = "hero.equip.unique.upgrade",
    HeroSPEquipItemExchange = "hero.equip.unique.item.exchange",
    HeroEquipEvolution = "hero.equip.evolution",
	GetHeroEquipRankBySlot = "get.hero.equip.rank.by.slot",
	GetHeroEquipRank = "get.hero.equip.rank",

    PushMonsterMaxDmg = "push.act.monster.new.max.dmg", --boss最大伤害弹窗

    StrongestConsulInfo = "strongest.consul.info", --最强指挥官
    StrongestConsulReward = "strongest.consul.reward",
    StrongestConsulRank = "strongest.consul.rank",
    StrongestConsulScorePush = "strongest.consul.score.push",

    UserGetHeroBattleInfo = "user.get.hero.battle.info", --登陆作战
    GetHeroBattleRank = "get.hero.battle.rank",
    UserSetHeroBattleArmy = "user.set.hero.battle.army", --设置阵营阵容
    UserSelectHeroBattleStart = "user.select.hero.battle.start",
    UserSelectHeroBattlePve = "user.select.hero.battle.pve",
    HeroBattleSetTargetChapter = "hero.battle.set.target.chapter",
    UserSelectHeroLevelRewardInfo = "user.select.hero.level.reward.info",
    UserDetectOneKeyReceiveReward = "user.detect.one.key.receive.reward.event",
    UserDetectOneKeyOverEvent = "user.detect.one.key.over.event",


    DetectEventHelpStart = "detect.event.help.start",
    DetectEventHelpEnd = "detect.event.help.end",
    DetectEventRescueStart = "detect.event.rescue.start",
    DetectEventRescueEnd = "detect.event.rescue.end",
    AutoFinishDetectEvent = "auto.finish.detect.event",
    ReceiveDetectLevelReward = "receive.detect.level.reward",

    -- npc city
    GetNpcCityInfo = "get.npc.city.info",
    GetNpcCityChat = "get.npc.city.msg",
    PushNpcCityDefendChange = "push.npc.city.defend.change",
    PushNpcCityNewChat = "push.npc.city.new.msg",
    RankLike = "rank.like",
    --生存战备
    PersonalArmsGetRankReward = "get.person.arms.group.rank.reward", --获取战备排行奖励
    PersonalArmsGetRank = "get.person.arms.group.rank", --获取战备排行榜
    PushNewDetectEvent = "push.new.detect.event",

    --个人卡车
    GetMyStationData = "train.data", --我的火车站信息
    PushMyStationData = "push.train.data", --我的火车站信息
    CollectStationFirstReward = "train.first.open.reward", --火车站首次领奖
    ChangeTrain = "train.change", --换火车
    DepartureTrain = "train.send", --发车
    AttackTrain = "train.attack", --抢劫火车
    CollectTrainReward = "train.reward", --到站领奖
    GetTrainList = "train.list", --请求火车列表
    ReinforceTrain = "train.supply.army", --增援火车
    GetMarchPos = "get.march.pos", --获取一个行军的位置
    TrainChangeSuper = "train.change.super", --超级刷新
    --联盟火车
    AllianceTrainInfo = "alliance.train.info", --联盟火车活动信息
    AllianceTrainInviteList = "alliance.train.invite.list", --可选火车司机列表
    AllianceTrainAssign = "alliance.train.assign", --任命司机
    AllianceTrainBuy = "alliance.train.buy", --使用道具兑换火车
    AllianceTrainAssignArmy = "alliance.train.assign.army", --火车驻军修改
    AllianceTrainAttack = "alliance.train.attack", --抢火车
    AllianceTrainLineUp = "alliance.train.lineUp", --排队
    AllianceTrainRefresh = "alliance.train.refresh", --刷新联盟火车奖励
    AllianceTrainFormation = "alliance.train.formation", --获取我的联盟火车攻防阵容 1攻2守
    AllianceTrainBattleRecord = "alliance.train.battle.record", --获取火车战斗记录列表
    AllianceTrainBattleDetail = "alliance.train.battle.detail", --获取火车战斗详细信息

    GetAllianceWelfareInfo = "get.alliance.welfare.info",
    ReceiveAllianceWelfareStageReward = "receive.alliance.welfare.stage.reward",
    ReceiveAllianceWelfareDailyReward = "receive.alliance.welfare.daily.reward",

    PushAlTrainInfoNew = "push.al.train.info.new", --新增联盟火车
    PushAlTrainInfoUpdate = "push.al.train.info.update", --更新联盟火车
    PushAlTrainInfoDel = "push.al.train.info.del", --删除联盟火车
    PushAlTrainBuyGiftInfo = "push.al.train.buy.gift.info", --购买火车礼包结果
    PushAlTrainPlatformCreate = "push.al.train.platform.create", --新增站台
    PushAlTrainPlatformUpdate = "push.al.train.platform.update", --更新站台
    WeaponInfoView = "weapon.info.view", --请求对方无人机信息（货车）

    AlLeaveItem = "al.leave.item", --退出联盟
    AlKickBatch = "al.kick.batch", --联盟踢出成员
    AlMemberLeave = "push.al.member.leave", --推送移除联盟成员

    RescueDogSubmitItem = "rescue.dog.submit.item", --救狗提交线索
    PushRescueDog = "push.rescue.dog", --救狗成功推送
    PushMarchEmoji = "push.march.emoji", -- 推送行军表情
    SendMarchEmoji = "send.march.emoji", -- 发送行军表情

    MoveCrossServer = "move.cross.server", --进入伊甸园
    PushUserCrossFightQuit = "push.user.cross.fight.quit",
    GetMarchPlunderRes = "get.march.plunder.res", --获取今日掠夺资源数量

    PushUserRewardControl = "push.usr.reward.control",

    RallyBossTaskReward = "kill.boss.task.reward.get",

    --爱情通讯
    SurvivalHeroMessage = "survival.hero.message",
    SurvivalHeroMessagePowerRefresh = "survival.hero.message.power.refresh",
    SurvivalHeroMessagePowerBuy = "survival.hero.message.power.buy",
    SurvivalHeroMessageReward = "survival.hero.message.reward",
    SurvivalHeroMessageUnlockImage = "push.unlock.heromessage.image",
    -----英雄小人
    SurvivalDebugReward = "survival.debug.reward", -- 测试协议,仅供展示用
    PushSurvivalVisitor = "push.survival.visitor", -- 推送小人数据
    SurvivalVisitorReward = "survival.visitor.reward", -- 小人点击领取协议
    SurvivalHeroSkinSwitch = "survival.hero.skin.switch",
    SurvivalHeroSkinUnlock = "survival.hero.skin.unlock",
    PushSurvivalHeroSkin = "push.survival.hero.skin",
    GetMonthDetectCard = "get.month.detect.card", -- 情报月卡面板信息
    ReceiveMonthDetectCardReward = "receive.month.detect.card.reward", --  领取情报月卡奖励
    MonthDetectCardScore = "month.detect.card.score", -- 积分变化推送

    GetWeekDiscountCard = "get.week.discount.card", -- 情报周卡面板信息
    SelectWeekDiscountCard = "select.week.discount.card", -- 选择自选特惠周卡
    ReceiveWeekDiscountCardReward = "receive.week.discount.card.reward", --  领取自选特惠任务奖励
    WeeklyDiscountCardPush = "weekly.discount.card.push", -- 积分变化推送
    SmallPeopleUpgradeRank = "upgrade.hero.career.rank", --小人升星

    --首都争霸
    GetKingdomActScoreInfo = "get.kingdom.act.score.info", --获取王座活动积分信息
    PushKingdomActScoreUpdate = "push.kingdom.act.score.update", --个人积分变化推送
    ReceiveKingdomActScoreReward = "receive.kingdom.act.score.reward", --领取积分阶段奖励
    GetKingdomActScoreRank = "get.kingdom.act.score.rank", --获取王座积分排行
    GetKingdomActScoreRankReward = "get.kingdom.act.score.rank.reward", --获取王座积分奖励信息
    GetThroneFightRecord = "get.throne.fight.record", --获取王座战斗记录
    PushThroneAssistanceFull = "push.throne.assistance.full", --王座 当驻防人数超过上限时，多余的部队自动加速遣返
    PushMarchWinCount = "push.march.win.count", --王座 队伍连胜次数
    GetTowerFightRecord = "get.tower.fight.record", --炮塔战争记录

    --雷达虚拟玩家直接侦查
    RadarNpcDirectScout = "survival.npc.direct.scout",
    SurvivalHeroSkinUnlock = "survival.hero.skin.unlock",
    UserHeroSkinShopInfo = "user.hero.skin.shop.info",
    UserHeroSkinShopBuy = "user.hero.skin.shop.buy",
    GiftVouchersRewardList = "gift.vouchers.reward.list",
    RevGiftVouchersReward = "rev.gift.vouchers.reward",
    RevGiftVouchersFreeReward = "rev.gift.vouchers.free.reward",
    PushUserGiftVouchers = "push.user.gift.vouchers",
    
    --跨服王座-旧消息
    GetCrossThroneActivityInfo = "get.cross.throne.activity.info",
    GetCrossThroneUserRank = "get.cross.throne.user.rank",
    GetCrossThroneUserRankReward = "get.cross.throne.user.rank.reward",
    GetCrossThroneAllianceRank = "get.cross.throne.alliance.rank",
    GetCrossThroneAllianceRankReward = "get.cross.throne.alliance.rank.reward",
    GetCrossThroneAllBuilding = "get.cross.throne.all.building",
    GetCrossThroneSelfAllianceScore = "get.cross.throne.self.alliance.score",
    PushCrossThroneBuild = "push.cross.throne.build",

    --跨服王座-新消息
    GetServerBattleMainInfo = "server.battle.maininfo",
    GetServerBattleScoreInfo = "server.battle.score.info",
    GetServerBattleScorePersonRank = "server.battle.score.person.rank",
    GetServerBattleScoreAllianceRank = "server.battle.score.ali.rank",
    GetServerCrossBattleMainInfo = "server.cross.battle.maininfo",
    GetServerBattleWinReward = "server.battle.win.reward",
    GetServerBattleCrossReward = "server.battle.cross.reward",
    GetServerBattleRank = "server.battle.rank",
    PushServerBattleScore = "push.server.battle.score",
    GetServerBattleWinRewardNew = "server.battle.win.reward.new",

    PushReceiveReward = "push.receive.reward",
    TreasureRewardRecord = "treasure.reward.record",

    SurvivalHeroCollectionRewardView = "survival.hero.collection.reward.view",
    SurvivalHeroCollectionReward = "survival.hero.collection.reward",
    GetDailyPackageInfos = "custom.daily.package.preview",
    DailyPackageSelectHero = "custom.daily.package.select",

    PackageChooseEquip = "custom.package.choose.equip",

    GetActivityRedPacketInfo = "activity.red.packet.info",
    PushActivityRedPacketScore = "push.red.packet.score",
    ReceiveActivityRedPacketReward = "activity.red.packet.reward",
    ActivityRedPacketChoose = "custom.package.choose.red.packet",

    PushDigTreasureReward = "push.dig.treasure.reward",
    GetDigTreasureReward = "get.dig.treasure.reward",
    ReceiveAllianceBossAllianceReward = "receive.alliance.boss.alliance.reward",
    ClickCreateTreasureDetect = "click.create.treasure.detect",
    GetTreasureInfo = "get.treasure.info",
    GetAllianceTreasure = "get.alliance.treasure",
    PushTreasureRemove = "push.treasure.remove",

    ActivityRallyBossInfo = "activity.rally.boss.info",
    ActivityRallyBossUpdateStage = "activity.rally.boss.update.stage",
    CustomChooseReward = "custom.package.choose.reward",

    PlaceBauble = "place.bauble", --放置新装饰建筑(消耗道具创建新的建筑)
    UpgradeBauble = "upgrade.bauble", --升级装饰建筑
    MoveBauble = "move.bauble", --移动装饰建筑

    UserFailPveLevel = "user.fail.pve.level", -- 打点用,战斗主线关卡失败发送关卡id和战力
    GetLikeInfo = "get.like.info",
    MailLike = "mail.like",
    AddLike = "add.like",
    PushAddLike = "push.add.like",

    GetSeasonDeclareRewardInfo = "get.season.declare.reward.info",
    PushSeasonDeclareResult = "push.season.declare.result",
    GetActWorldResInfo = "get.act.world.res.info",
    --小人招募相关
    SmallPeopleRecruitInfo = "lottery.hero.career.info", --招募模块小人的信息
    SmallPeopleRecruit = "lottery.hero.career.buy", --招募小人
    SmallPeopleRecruitRefresh = "lottery.hero.career.refresh", --刷新小人
    SmallPeopleUseItemRefresh = "lottery.hero.career.refresh.item", --使用道具刷新小人

    RecycleSkinItem = "recycle.skin.item",
    ReceiveDiscountShopStageReward = "receive.discount.shop.stage.reward",
    GetSeasonDeclareResultRewardInfo = "get.season.declare.result.reward.info", --请求联盟宣战个人贡献奖励详情
    AllianceDeclareWarGetResultReward = "alliance.declare.war.get.result.reward", --联盟宣战，个人贡献奖励领取协议

    GetDiscountShopRank = "get.discount.shop.rank",

    UpdateAllianceVote = "update.alliance.vote", --创建联盟投票公告
    GetAllianceVote = "get.alliance.vote", --获取投票公告
    VoteAllianceNotice = "vote.alliance.notice", --参与联盟投票
    CommentAllianceVote = "comment.alliance.vote", --联盟投票评论完成
    LikeAllianceVote = "like.alliance.vote", --联盟投票点赞点踩 - cd同聊天，客户端自己限制
    DelAllianceVote = "del.alliance.vote", --删除投票公告
    PushDelAllianceVote = "push.al.vote.del", --push删除投票公告

    -----好友
    GetFriendList = "get.friend.list", --好友列表
    GetFriendApplyList = "get.friend.apply.list", --申请列表
    FriendApply = "friend.apply", --添加好友
    FriendApplyRefuse = "friend.apply.refuse", --拒绝好友申请
    FriendApplyAgree = "friend.apply.agree", --同意好友申请
    DeleteFriend = "delete.friend", --删除好友
    SetFriendAlias = "set.friend.alias", --设置好友备注
    CheckFriendAlias = "check.friend.alias", --检查好友备注
    PushFriendApplyAdd = "push.friend.apply.add", --被申请推送
    PushSelfFriendApplyRefuse = "push.self.friend.apply.refuse", --自己的申请被拒绝推送
    PushFriendAdd = "push.friend.add", --新好友推送
    PushFriendDelete = "push.friend.delete", --删除好友推送
    CreateGroupChatCheck = "create.group.chat.check", --创建群聊、群聊拉人检测

    SetChatLevelLimit = "set.chat.level.limit",

    --信用值系统
    PayCreditUpdate = "push.pay.credit.update",
    PayCreditStat = "pay.credit.stat",

    DonateRankReward = "get.donate.rank.reward",
    DailyAllianceDonaterRank = "get.daily.alliance.donate.rank",
    WeekAllianceDonaterRank = "get.week.alliance.donate.rank",

    GiveUpActivityGiftBox = "give.up.activity.gift.box",

    PushDestroyAllianceCenter = "push.destroy.alliance.center",

    --改装车部件
    GetCarComponInfo = "get.car.compon.info", --获取所有组件数据
    CarComponUpgrade = "car.compon.upgrade", --合成
    CarComponUpgradeAll = "car.compon.upgrade.all", --一键合成
    CarComponInstall = "car.compon.install", --装备
    CarComponInstallAll = "car.compon.install.all", --一键装备
    PushUserCarComponUpdate = "push.user.car.compon.update", --组件数据更新
    CarComponRedPointPush = "car.compon.red.point.push", --红点推送

    GetSeasonGroupServerInfo = "get.season.group.server.info",

    ClientTriggerTask = "client.trigger.task", --完成任务

    ChampionReceiveServerReward = 'championBattle.receive.server.reward',

    ChampionFireWork = 'championBattle.firework.use',

    ChampionBattleBetRefresh = 'championBattle.bet.info',

    ChampionBattleMatch = 'championBattle.bet.match',
    ChampionBattleBetRecord = 'championBattle.bet.record',
    ChampionBattleMatchRecord = 'championBattle.match.record',
    ChampionBattleBetCancel = 'championBattle.bet.cancel',
    ChampionChangeFormationOrder = 'elite.new.formation.change.order',
    ChampionBattleClaimBetReward = 'championBattle.bet.receive.reward',
    ChampionBattleSettingMsg = 'championBattle.setting.msg',
    ChampionBattleFinalRank = 'championBattle.final.rank',
    ChampionBattleMsgPush = 'championBattle.msg.push',
    ChampionFireWorkPush = 'championBattle.firework.push',
    PushSurvivalDialog = "push.survival.dialog",--推送送小人的任务
    
    FlipFunGetInfo = 'flip.fun.get.info',
    FlipFunDailyReward = 'flip.fun.daily.reward',
    FlipFunStart = 'flip.fun.start',
    FlipFunFlip = 'flip.fun.flip',
    FlipFunHelp = 'flip.fun.help',
    FlipFunHelpRecord = 'flip.fun.help.record',
    PushFlipFunHelp = 'push.flip.fun.help',
    FlipFunShare = 'flip.fun.share',

    GetMonopolyActivityInfo = "get.monopoly.activity.info",
    RollMonopolyActivity = "roll.monopoly.activity",
    BuyActivityMonopolyGoods = "buy.activity.monopoly.goods",
    RevMonopolyStageReward = "rev.monopoly.stage.reward",
    RevMonopolyDailyReward = "rev.monopoly.daily.reward",

    GetChildhoodTreasureInfo = "get.childhood.treasure.info",
    PushChildhoodTreasureSync = "push.childhood.treasure.sync",
    GetDirectTreasureReward = "get.direct.treasure.reward",
    
    GetUserAllianceCandyInfo = "get.user.alliance.candy.info",
    DonateUserAllianceCandy = "donate.user.alliance.candy",
    PushUserAlCandyData = "push.user.al.candy.data",

    PushShareMsg = "push.share.msg",
    PushShareMsgUpdate = "push.share.msg.update",
    PushShareMsgDelete = "push.share.msg.delete",
    ShareMsg = "share.msg.get",
    DesertTreasureShare = "desert.treasure.share",
    GetVerticalInviteActInfo = "get.vertical.invite.act.info",
    GetVerticalInviteMembers = "get.vertical.invite.members", -- 获取竖屏邀请成员列表
    SendVerticalInvite = "send.vertical.invite", -- 发送竖屏邀请
    ReceiveVerticalInviteStageReward = "receive.vertical.invite.stage.reward", -- 领取竖屏邀请阶段奖励
    AcceptVerticalInvite = "accept.vertical.invite", -- 接收竖屏邀请
    ExchangeMsg = 'activity.trade.exchange',
    SwapRequestMsg = 'activity.trade.swap.request',
    SwapRequestCancelMsg = 'activity.trade.swap.request.cancel',
    SwapMsg = 'activity.trade.swap',
    SwapRequestListMsg = 'activity.trade.swap.request.list',
    SwapRecordMsg = 'activity.trade.swap.record',
    PushTradeUpdateMsg = 'push.activity.trade.update',
    PushTradeCancelMsg = 'push.activity.trade.cancel',
    SwapTradeClear = 'activity.trade.clear',
    SwapTradeShare = 'activity.trade.share',
    UserDeletePicFromOld = "user.del.pic.from.old", --删除玩家上传头像,
    UserChangePicFromOld="user.change.pic.from.old",    --上传头像替换
    BattleUserScoreRanklist = 'server.battle.user.score.rank', --跨服王座积分排行
    PushVerticalInviteAccept = 'user.vertical.invite.act.accept', --在线的时候,有人接受了邀请,推送
    GetAllianceVerticalInviteActInfo = 'get.alliance.vertical.act.info', --获取联盟邀请领奖活动信息
    ReceiveAllianceVerticalStageReward = 'receive.alliance.vertical.stage.reward', --领取联盟邀请领奖活动奖励
    PushUserAllianceInviteUpdate = 'push.user.alliance.invite.update', --推送联盟邀请领奖活动更新
    AllyOutfire = 'ally.out.fire', -- 灭火
    PushUserDefendWallOutFire = 'push.user.defend.wall.out.fire', -- 灭火推送
}
return ConstClass("MsgDefines", MsgDefines)