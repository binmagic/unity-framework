using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using GameFramework;
using DG.Tweening;

//namespace LS.UnityEngine.UI {

	public class DefaultNewButtonCurve
	{
		public static UIButtonCurve defaultButtonCurve;
		public static EaseFunction defaultPressedEase;
		public static EaseFunction defaultOtherEase;

		public static VEngine.Asset reqAsset;

		// 只需要在游戏初始化的时候调用一次即可
		public static void LoadDefaultCurve(string curvePath)
		{
			if (reqAsset != null)
			{
				reqAsset.Release();
			}
			
			reqAsset = GameEntry.Resource.LoadAssetAsync(curvePath, typeof(UIButtonCurve));
			reqAsset.completed += delegate (VEngine.Asset request)
			{
				if (!request.isError)
				{
					defaultButtonCurve = (UIButtonCurve) request.asset;
					
					defaultPressedEase = new EaseFunction(new DG.Tweening.Core.Easing.EaseCurve(defaultButtonCurve.m_PressedCurve).Evaluate);
					defaultOtherEase = new EaseFunction(new DG.Tweening.Core.Easing.EaseCurve(defaultButtonCurve.m_PressedCurve).Evaluate);
				}
				else
				{
					var errorStr = $"LoadTable error {request.pathOrURL} {request.error}";
					GameEntry.Lua.Call("CSharpCallLuaInterface.SendErrorMessageToServer", errorStr);
					Log.Error(errorStr);
				}
			};
		}

		public static void ReleaseDefaultCurve()
		{
			if (reqAsset != null)
			{
				reqAsset.Release();
				reqAsset = null;
			}
		}
		
	}

	[AddComponentMenu("UI/NewButton", 31)]
	public class NewButton : Button
	{
		[Tooltip("需使用“SpriteGray”材质球")]
		[SerializeField]
		private Material m_GrayMaterial;

		[SerializeField]
		private bool m_UseGrayMaterial = false;
		[SerializeField]
		private bool m_DoubleEffect = true;
		
		[SerializeField]
		private UIButtonCurve m_buttonCurve;

		
		private void SetGrayMaterial( SelectionState state) {

			if (targetGraphic == null)
			{
                Log.Info("button target graphic is none !");
				return;
			}

			if (m_GrayMaterial == null)
			{
                Log.Info("button gray material is none !");
				return;
			}

			if (state == SelectionState.Disabled)
			{
				if (interactable)
					targetGraphic.material = null;
				else
					targetGraphic.material = m_GrayMaterial;
			}
			else
			{
				if (m_UseGrayMaterial)
				{
					if ("SpriteGray" == targetGraphic.material.name)
					{
						targetGraphic.material = null;
					}
				}
			}

		}

		protected override void DoStateTransition(SelectionState state, bool instant)
		{
			if (m_UseGrayMaterial) //使用材质
				SetGrayMaterial(state);

			//base.DoStateTransition(state, instant);
			Color color;
			Sprite newSprite;
			string triggername;
			switch (state)
			{
				case Selectable.SelectionState.Normal:
					color = this.colors.normalColor;
					newSprite = (Sprite) null;
					triggername = this.animationTriggers.normalTrigger;
					break;
				case Selectable.SelectionState.Highlighted:
#if UNITY_EDITOR
					color = this.colors.normalColor;
					newSprite = (Sprite) null;
					triggername = this.animationTriggers.normalTrigger;
#else
					color = this.colors.highlightedColor;
					newSprite = this.spriteState.highlightedSprite;
					triggername = this.animationTriggers.highlightedTrigger;
#endif
					break;
				case Selectable.SelectionState.Pressed:
					color = this.colors.pressedColor;
					newSprite = this.spriteState.pressedSprite;
					triggername = this.animationTriggers.pressedTrigger;
					break;
				case Selectable.SelectionState.Disabled:
					color = this.colors.disabledColor;
					newSprite = this.spriteState.disabledSprite;
					triggername = this.animationTriggers.disabledTrigger;
					break;
				case Selectable.SelectionState.Selected:
					color = this.colors.selectedColor;
					newSprite = this.spriteState.selectedSprite;
					triggername = this.animationTriggers.selectedTrigger;
					break;
				default:
					color = Color.black;
					newSprite = (Sprite) null;
					triggername = string.Empty;
					break;
			}

			if (!this.gameObject.activeInHierarchy)
				return;
			switch (this.transition)
			{
				case Selectable.Transition.ColorTint:
					this.StartColorTween(color * this.colors.colorMultiplier, instant);
					break;
				case Selectable.Transition.SpriteSwap:
					this.DoSpriteSwap(newSprite);
					break;
				case Selectable.Transition.Animation:
					this.TriggerAnimation(triggername);
					// if (m_DoubleEffect)
					// 	this.StartColorTween(color * this.colors.colorMultiplier, instant);
					break;
			}
		}

		private new void StartColorTween(Color targetColor, bool instant)
		{
			if ( this.targetGraphic == null)
				return;
			this.targetGraphic.CrossFadeColor(targetColor, !instant ? this.colors.fadeDuration : 0.0f, true, true);
		}

		private new void DoSpriteSwap(Sprite newSprite)
		{
			if ( this.image == null)
				return;
			this.image.overrideSprite = newSprite;
		}

		private bool GetPressedCurveInfo(out Vector3 pressedScale, out float pressedTime, out EaseFunction func)
		{
			// 如果button 有自己的曲线，那么就使用自己的曲线；否则使用公共默认的曲线
			if (m_buttonCurve != null)
			{
				pressedScale = m_buttonCurve.m_PressedScale;
				pressedTime = m_buttonCurve.m_DoPressedTime;
				func = new EaseFunction(new DG.Tweening.Core.Easing.EaseCurve(m_buttonCurve.m_PressedCurve).Evaluate);
			}
			else
			{
				if (DefaultNewButtonCurve.defaultButtonCurve == null)
				{
					pressedScale = Vector3.one;
					pressedTime = 1;
					func = null;
					return false;
				}
				
				pressedScale = DefaultNewButtonCurve.defaultButtonCurve.m_PressedScale;
				pressedTime = DefaultNewButtonCurve.defaultButtonCurve.m_DoPressedTime;
				func = DefaultNewButtonCurve.defaultPressedEase;
			}

			return true;
		}

		private bool GetOtherCurveInfo(out Vector3 otherScale, out float otherTime, out EaseFunction func)
		{
			otherScale = Vector3.one;
			
			// 如果button 有自己的曲线，那么就使用自己的曲线；否则使用公共默认的曲线
			if (m_buttonCurve != null)
			{
				otherTime = m_buttonCurve.m_DoOtherTime;
				func = new EaseFunction(new DG.Tweening.Core.Easing.EaseCurve(m_buttonCurve.m_OtherCurve).Evaluate);
			}
			else
			{
				if (DefaultNewButtonCurve.defaultButtonCurve == null)
				{
					otherTime = 1;
					func = null;
					return false;
				}

				otherTime = DefaultNewButtonCurve.defaultButtonCurve.m_DoOtherTime;
				func = DefaultNewButtonCurve.defaultOtherEase;
			}

			return true;
		}
		
		private new void TriggerAnimation(string triggername)
		{
			if (this.transition != Selectable.Transition.Animation || string.IsNullOrEmpty(triggername))
				return;
			
			Sequence seq;
			DOTween.Kill(gameObject);
			switch (triggername)
			{
				case "Pressed":
					seq = DOTween.Sequence();
					
					if (GetPressedCurveInfo(out Vector3 pressedScale, out float pressedTime, out EaseFunction func))
					{
						seq.Append(this.gameObject.transform.DOScale(pressedScale, pressedTime)
							.SetEase(func));
					}
					
					break;
				
				default:
					seq = DOTween.Sequence();
					
					if (GetOtherCurveInfo(out Vector3 otherScale, out float otherTime, out EaseFunction otherFunc))
					{
							seq.Append(this.gameObject.transform.DOScale(otherScale, otherTime)
								.SetEase(otherFunc));
					}

					break;
			}
			// this.animator.ResetTrigger(this.animationTriggers.normalTrigger);
			// this.animator.ResetTrigger(this.animationTriggers.pressedTrigger);
			// this.animator.ResetTrigger(this.animationTriggers.highlightedTrigger);
			// this.animator.ResetTrigger(this.animationTriggers.disabledTrigger);
			// this.animator.ResetTrigger(this.animationTriggers.selectedTrigger);
			// this.animator.SetTrigger(triggername);
		}
		
	}

	

//}





