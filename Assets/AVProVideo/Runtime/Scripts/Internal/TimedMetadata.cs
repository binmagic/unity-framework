//-----------------------------------------------------------------------------
// Copyright 2015-2025 RenderHeads Ltd.  All rights reserved.
//-----------------------------------------------------------------------------

namespace RenderHeads.Media.AVProVideo
{
	public interface ITimedMetadata
	{
		bool HasNewTimedMetadataItem();

		TimedMetadataItem GetTimedMetadataItem();
	}

	public class TimedMetadataItem
	{
		public double PresentationTime
		{
			get
			{
				return _presentationTime;
			}
		}

		public string Text
		{
			get
			{
				return _text;
			}
		}

		internal TimedMetadataItem(double presentationTime, string text)
		{
			_presentationTime = presentationTime;
			_text = text;
		}

		private TimedMetadataItem()
		{

		}

		private double _presentationTime;
		private string _text;
	}

	public partial class BaseMediaPlayer : ITimedMetadata
	{
		public bool HasNewTimedMetadataItem()
		{
			return _hasNewTimedMetadataItem;
		}

		public TimedMetadataItem GetTimedMetadataItem()
		{
			_hasNewTimedMetadataItem = false;
			return _timedMetadataItem;
		}

		protected void UpdateTimedMetadata()
		{
			var hasUpdatedTimedMetadata = InternalHasUpdatedTimedMetadata();
			if (hasUpdatedTimedMetadata)
			{
				_timedMetadataItem = InternalGetTimedMetadataItem();
				_hasNewTimedMetadataItem = true;
			}
		}

		protected virtual bool InternalHasUpdatedTimedMetadata()
		{
			return false;
		}

		protected virtual TimedMetadataItem InternalGetTimedMetadataItem()
		{
			return null;
		}

		private TimedMetadataItem _timedMetadataItem = null;
		private bool _hasNewTimedMetadataItem = false;
	}
}
