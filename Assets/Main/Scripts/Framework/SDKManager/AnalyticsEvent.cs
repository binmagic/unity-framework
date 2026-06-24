using System;
using System.Collections;
using System.Collections.Generic;
using Sfs2X.Entities.Data;
using LitJson;
using UnityEngine;
using UnityGameFramework.Runtime;

namespace UnityGameFramework.SDK
{
    public class AnalyticsEvent
    {
        /// <summary>
        /// firebase FIRAnalytics logEventWithName:@"first open new"
        /// </summary>
        public const string first_open_new = "first open new";

        /// <summary>
        /// 第一次进入主城  firebase打点！
        /// </summary>
        public const string app_launch = "app_launch";

        /// <summary>
        ///  appsFlayerLib打点！
        /// </summary>
        public const string trackAppLaunch = "trackAppLaunch";

        public const string EventPurchase = "purchase";

        public const string EventLevelUp = "LevelUp";

        /// <summary>
        ///  60分钟之内点击，打一个点
        /// CarBannerNode::onCarLibaoClick   carbannernode
        /// PutFreeBuildDragView::onClickGiftBtn  ccb=putfreebuilddragview2  m_giftBtn onClickGiftBtn  
        /// </summary>
        public const string click_buy_car_in_60m = "click_buy_car_in_60m";

        /// <summary>∂
        /// UIMain->upperright-礼包按钮暂时没用功能 UIComponentRight::onRechargeBtnClick   ccb=gameuifreebuildright
        /// </summary>
        public const string click_gifts = "click_gifts";

        /// <summary>
        /// UIComponentRight::onRechargeBtnClick
        ///UIMain->upperright-礼包按钮暂时没用功能 30分钟之内点击，打一个点
        /// </summary>
        public const string click_gifts_in_30m = "click_gifts_in_30m";

        /// <summary>
        /// AppLibHelper AppsFlyerTracker  params userid
        /// </summary>
        public const string setCustomerUserID = "setCustomerUserID";

        /// <summary>
        /// AppLibHelper
        /// stringdata, int _type
        /// _type == 0 //新手结束 af_tutorial_completion
        /// _type == 1  //大本六级 af_level_achieved_6level
        /// _type == 2  //登陆5次 login_5_times
        /// </summary>
        public const string tutorialComplete = "tutorialComplete";

        /// <summary>
        /// AppLibHelper string &userId, const string &userName, const string &userLevel
        /// </summary>
        public const string triggerEventLoginComplete = "triggerEventLoginComplete";


        /// <summary>
        /// AppLibHelper string &userId,const string &userName
        /// </summary>
        public const string EventCompletedRegistration = "CompletedRegistration";


        /// <summary>
        /// AppLibHelper string &userId,const string &userName
        /// </summary>
        public const string fbEventCompletedTutorial = "fbEventCompletedTutorial";

        /// <summary>
        /// FBUtil appEventSpeedUp   QueueController::getInstance()->startCCDQueue
        /// </summary>
        public const string EventSpeedUp = "SpeedUp";

        /// <summary>
        /// FBUtil appEventGiftPackage
        /// </summary>
        public const string EventGiftPackage = "GiftPackage";

        /// <summary>
        /// FBUtil appPurchaseItem
        /// </summary>
        public const string EventPurchaseItem = "Purchase_Item";

        /// <summary>
        /// FBUtil appEventFBEntrance
        /// </summary>
        public const string EventFBEntrance = "FacebookEntrance";

        /// <summary>
        /// FBUtil appEventHireWorker
        /// </summary>
        public const string EventHireWorker = "HireWorker";

        /// <summary>
        /// FBUtil appEventAllianceHonorExchange AllianceShopCell::onNewUseAction 联盟荣誉点使用?
        /// </summary>
        public const string EventAllianceHonorExchange = "AllianceHonorExchange";

        /// <summary>
        /// FBUtil appEventAllianceScoreUsagee AllianceShopCell::onNewBuyAction 联盟积分点使用?
        /// </summary>
        public const string EventAllianceScoreUsage = "AllianceScoreUsage";

        public const string EventAllianceTalkMore = "alliance_talk_more";

        public const string FBEventDone = "EventDone";

        #region FBEventDone
        public const string battle_base = "battle_base";
        public const string battle_resource = "battle_resource";
        public const string battle_rein = "battle_rein";
        public const string battle_scout = "battle_scout";

        //Todo 缺少 cmd mail.send
        //public const string social_mail_person = "social_mail_person";
        //public const string social_mail_alliance = "social_mail_alliance";

        public const string social_chat_country = "social_chat_country";
        public const string social_chat_alliance = "social_chat_alliance";

        public const string social_send_gift = "social_send_gift";
        #endregion

        public static void TutorialComplete(string data, int _type)
        {
            if (_type == 0)
            {
                GameEntry.Sdk.LogEvent(AnalyticsEvent.fbEventCompletedTutorial, GameEntry.Data.Player.Uid);
            }
            else if (_type == 1)
            {
                //af_level_achieved_6level 无调用
                //GameEntry.Sdk.LogEvent(AnalyticsEvent.fbEventCompletedTutorial, GameEntry.Data.Player.Uid);
            }
            else if (_type == 2)
            {
                //login_5_times  无调用
                //GameEntry.Sdk.LogEvent(AnalyticsEvent.fbEventCompletedTutorial, GameEntry.Data.Player.Uid);
            }
        }

        public static void FirstOpenAppsflyer()
        {
            GameEntry.Sdk.LogEvent(AnalyticsEvent.trackAppLaunch);
            GameEntry.Sdk.LogEvent(AnalyticsEvent.setCustomerUserID, GameEntry.Data.Player.Uid);
        }

        public static void Login(ISFSObject msg, String userId, String userName)
        {
            if (msg.ContainsKey("first_login"))
            {
                //recordStepByReyunRegisterHttp(platform,idfa);
                GameEntry.Sdk.LogEvent(AnalyticsEvent.EventCompletedRegistration, userId, userName);
                //AppLibHelper::googleRemarketingReporter("completedRegistration");
            }
            if (msg.ContainsKey("two_days_login"))
            {
                SendAdjustTrack("two_days_login");
            }
            GameEntry.Sdk.LogEvent(AnalyticsEvent.triggerEventLoginComplete, userId, userName);
        }

        public static void TriggerEventPurchase(string cost, string key, string orderId, string uid)
        {
            //AppLibHelper::triggerEventPurchase
            GameEntry.Sdk.LogEvent(AnalyticsEvent.EventPurchase, cost, key, orderId, uid);
        }

        private static string preLv = "";
        public static void LevelUp(string lv)
        {
            if (preLv != lv)
            {
                preLv = lv;
                GameEntry.Sdk.LogEvent(AnalyticsEvent.EventLevelUp, lv);
            }
        }

        public static void ClickBuyIn60m(string id, string name)
        {
            GameEntry.Sdk.LogEvent(AnalyticsEvent.click_buy_car_in_60m, GameEntry.Data.Player.Uid, id, name);
        }

        public static void SpeedUp(int user_level, int castle_level, int type, int spend)
        {
            GameEntry.Sdk.LogEvent(AnalyticsEvent.EventSpeedUp, user_level, castle_level, type, spend);
        }

        public static void GiftPackage(String entracnce, String name, int id, int user_castle, int user_level)
        {
            GameEntry.Sdk.LogEvent(AnalyticsEvent.EventGiftPackage, entracnce, name, id, user_castle, user_level);
        }

        public static void AllianceHonorExchange(String name, string id, int user_castle, int user_level, int rank)
        {
            GameEntry.Sdk.LogEvent(AnalyticsEvent.EventAllianceHonorExchange, name, id, user_castle, user_level, rank);
        }

        public static void AllianceScoreUsage(String name, String id, int rank)
        {
            GameEntry.Sdk.LogEvent(AnalyticsEvent.EventAllianceScoreUsage, name, id, rank);
        }

        public static void AllianceChat(string eventName)
        {
            // 联盟说话超过十句打点
            if (eventName == social_chat_alliance)
            {
                int count = GameEntry.Setting.GetPrivateInt("AllianceTalkCount",0);
                ++count;
                GameEntry.Setting.SetPrivateInt("AllianceTalkCount", count);
                if (count == 10)
                {
                    if (GameEntry.Data.Player != null)
                    {
                        GameEntry.Sdk.LogEvent(AnalyticsEvent.EventAllianceTalkMore, GameEntry.Data.Player.Uid);
                    }
                }
            }
            else if (eventName == social_chat_country)
            {
                EventDone(social_chat_country, "");
            }
        }

        // fbEventDone
        public static void EventDone(String eventName, String data)
        {
            //FBEventDone
            GameEntry.Sdk.LogEvent(FBEventDone, eventName, GameEntry.Data.Player.Uid);
        }

        //2d 无调用
        //public static void HireWorker(int user_castle, int user_level)
        //{

        //}

        //Todo 缺少 界面 cmd hot.item.buy  azequipmentlistview FBItemDesDetailView::onTouchEnded itemdescdetailview
        //LuaController::checkIsNewDescMode
        //public static void PurchaseItem(int type, int user_level, int castle_level, int item_id, String item_name, int item_price, int item_count, int spend, String entrance)
        //{
        //    //hot.item.buy
        //    GameEntry.Sdk.LogEvent(AnalyticsEvent.EventPurchaseItem, type, user_level, castle_level, item_id, item_name, item_price, item_count, spend, entrance);
        //}

        //Todo 缺少 ActivityController::rewardRecordHandle
        //public static void FBEntrance(string entrance)
        //{
        //    //FBUtilies::appEventFBEntrance("request");
        //    //FBUtilies::appEventFBEntrance("feed");
        //    GameEntry.Sdk.LogEvent(AnalyticsEvent.EventFBEntrance, entrance);
        //}



        public static void SendAdjustTrack(string track, string eventValue = "")
        {
            //AppLibHelper::sendAdjustTrack
            //Adjust sdk
        }

    }
}





