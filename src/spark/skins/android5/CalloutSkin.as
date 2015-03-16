////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////

package spark.skins.android5
{
	import flash.display.BlendMode;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	
	import mx.core.DPIClassification;
	import mx.core.mx_internal;
	import mx.events.EffectEvent;
	import mx.events.FlexEvent;

	import spark.components.Callout;
	import spark.components.ContentBackgroundAppearance;
	import spark.components.Group;
	import spark.core.SpriteVisualElement;
	import spark.effects.Fade;
	import spark.primitives.RectangularDropShadow;
	import spark.skins.mobile.supportClasses.MobileSkin;
	
	use namespace mx_internal;
	
	/**
	 *  The default skin class for the Spark Callout component in mobile
	 *  applications.
	 * 
	 *  <p>The <code>contentGroup</code> lies above a <code>backgroundColor</code> fill
	 *  which frames the <code>contentGroup</code>. The position and size of the frame 
	 *  adjust based on the host component <code>arrowDirection</code>, leaving
	 *  space for the <code>arrow</code> to appear on the outside edge of the
	 *  frame.</p>
	 * 
	 *  <p>The <code>arrow</code> skin part is not positioned by the skin. Instead,
	 *  the Callout component positions the arrow relative to the owner in
	 *  <code>updateSkinDisplayList()</code>. This method assumes that Callout skin
	 *  and the <code>arrow</code> use the same coordinate space.</p>
	 *  
	 *  @see spark.components.Callout
	 *  
	 *  @langversion 3.0
	 *  @productversion Flex 4.6
	 */ 
	public class CalloutSkin extends MobileSkin
	{
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Constructor. 
		 * 
		 *  @langversion 3.0
		 *  @playerversion AIR 3
		 *  @productversion Flex 4.6
		 */
		public function CalloutSkin()
		{
			super();
			
			dropShadowAlpha = 0.8;
			
			switch (applicationDPI)
			{
				case DPIClassification.DPI_640:
				{
					dropShadowBlurX = 32;
					dropShadowBlurY = 32;
					dropShadowDistance = 8;
					
					break;
				}
				case DPIClassification.DPI_480:
				{
					dropShadowBlurX = 24;
					dropShadowBlurY = 24;
					dropShadowDistance = 6;
					
					break;
				}
				case DPIClassification.DPI_320:
				{
					dropShadowBlurX = 16;
					dropShadowBlurY = 16;
					dropShadowDistance = 4;
					
					break;
				}
				case DPIClassification.DPI_240:
				{
					dropShadowBlurX = 12;
					dropShadowBlurY = 12;
					dropShadowDistance = 3;
					
					break;
				}
				case DPIClassification.DPI_120:
				{
					dropShadowBlurX = 6;
					dropShadowBlurY = 6;
					dropShadowDistance = 1;
					
					break;
				}
				default:
				{
					// default DPI_160
					dropShadowBlurX = 8;
					dropShadowBlurY = 8;
					dropShadowDistance = 2;
					
					break;
				}
			}
		}
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		
		/** 
		 *  @copy spark.skins.spark.ApplicationSkin#hostComponent
		 */
		public var hostComponent:Callout;
		
		/**
		 *  Enables a RectangularDropShadow behind the <code>backgroundColor</code> frame.
		 *  
		 *  @langversion 3.0
		 *  @playerversion AIR 3
		 *  @productversion Flex 4.6
		 */
		protected var dropShadowVisible:Boolean = true;
		
		/**
		 *  @private
		 *  Tracks changes to the skin state to support the fade out tranisition 
		 *  when closed;
		 */
		mx_internal var isOpen:Boolean;
		
		private var backgroundGradientHeight:Number;
		
		private var contentMask:Sprite;
		
		private var backgroundFill:SpriteVisualElement;
		
		private var dropShadow:RectangularDropShadow;
		
		private var dropShadowBlurX:Number;
		
		private var dropShadowBlurY:Number;
		
		private var dropShadowDistance:Number;
		
		private var dropShadowAlpha:Number;
		
		private var fade:Fade;
		
		//--------------------------------------------------------------------------
		//
		//  Skin parts
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @copy spark.components.SkinnableContainer#contentGroup
		 */
		public var contentGroup:Group;
		
		//--------------------------------------------------------------------------
		//
		//  Overridden methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		override protected function createChildren():void
		{
			super.createChildren();
			
			if (dropShadowVisible)
			{
				dropShadow = new RectangularDropShadow();
				dropShadow.angle = 90;
				dropShadow.distance = dropShadowDistance;
				dropShadow.blurX = dropShadowBlurX;
				dropShadow.blurY = dropShadowBlurY;
				//dropShadow.tlRadius = dropShadow.trRadius = dropShadow.blRadius =  dropShadow.brRadius = backgroundCornerRadius;
				dropShadow.mouseEnabled = false;
				dropShadow.alpha = dropShadowAlpha;
				addChild(dropShadow);
			}
			
			// background fill placed above the drop shadow
			backgroundFill = new SpriteVisualElement();
			addChild(backgroundFill);
			
			// contentGroup
			if (!contentGroup)
			{
				contentGroup = new Group();
				contentGroup.id = "contentGroup";
				addChild(contentGroup);
			}
			
			
		}
		
		/**
		 * @private
		 */
		override protected function commitProperties():void
		{
			super.commitProperties();			
			
			// always invalidate to accomodate arrow direction changes
			invalidateSize();
			invalidateDisplayList();
		}
		
		
		/**
		 * @private
		 */
		override protected function measure():void
		{
			super.measure();
			
			// count the contentGroup size and frame size
			measuredMinWidth = contentGroup.measuredMinWidth;
			measuredMinHeight = contentGroup.measuredMinHeight;
			
			measuredWidth = contentGroup.getPreferredBoundsWidth();
			measuredHeight = contentGroup.getPreferredBoundsHeight();
		}
		
		/**
		 *  @private
		 *  SkinnaablePopUpContainer skins must dispatch a 
		 *  FlexEvent.STATE_CHANGE_COMPLETE event for the component to properly
		 *  update the skin state.
		 */
		override protected function commitCurrentState():void
		{
			super.commitCurrentState();
			
			var isNormal:Boolean = (currentState == "normal");
			var isDisabled:Boolean = (currentState == "disabled")
			
			// play a fade out if the callout was previously open
			if (!(isNormal || isDisabled) && isOpen)
			{
				if (!fade)
				{
					fade = new Fade();
					fade.target = this;
					fade.duration = 200;
					fade.alphaTo = 0;
				}
				
				// BlendMode.LAYER while fading out
				blendMode = BlendMode.LAYER;
				
				// play a short fade effect
				fade.addEventListener(EffectEvent.EFFECT_END, stateChangeComplete);
				fade.play();
				
				isOpen = false;
			}
			else
			{
				isOpen = isNormal || isDisabled;		
				// handle re-opening the Callout while fading out
				if (fade && fade.isPlaying)
				{
					// Do not dispatch a state change complete.
					// SkinnablePopUpContainer handles state interruptions.
					fade.removeEventListener(EffectEvent.EFFECT_END, stateChangeComplete);
					fade.stop();
				}		
				if (isDisabled)
				{
					// BlendMode.LAYER to allow CalloutArrow BlendMode.ERASE
					blendMode = BlendMode.LAYER;		
					alpha = 0.5;
				}
				else
				{
					// BlendMode.NORMAL for non-animated state transitions
					blendMode = BlendMode.NORMAL;	
					if (isNormal)
						alpha = 1;
					else
						alpha = 0;
				}		
				stateChangeComplete();
			}
		}
		
		/**
		 * @private
		 */
		override protected function drawBackground(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.drawBackground(unscaledWidth, unscaledHeight);
			
			var backgroundColor:Number = getStyle("primaryAccentColor");
			var backgroundAlpha:Number = getStyle("backgroundAlpha");
			
			var bgFill:Graphics = backgroundFill.graphics;
			bgFill.clear();
			
			// draw content background styles
			var contentBackgroundAppearance:String = getStyle("contentBackgroundAppearance");
			
			if (contentBackgroundAppearance != ContentBackgroundAppearance.NONE)
			{
				var contentBackgroundAlpha:Number = getStyle("contentBackgroundAlpha");
				var contentWidth:Number = contentGroup.getLayoutBoundsWidth();
				var contentHeight:Number = contentGroup.getLayoutBoundsHeight();
				
				// all appearance values except for "none" use a mask
				if (!contentMask)
					contentMask = new SpriteVisualElement();
				
				contentGroup.mask = contentMask;
				
				// draw contentMask in contentGroup coordinate space
				var maskGraphics:Graphics = contentMask.graphics;
				maskGraphics.clear();
				maskGraphics.beginFill(0, 1);
				maskGraphics.drawRect(0, 0, contentWidth, contentHeight);
				maskGraphics.endFill();
				
				// draw the contentBackgroundColor
				bgFill.beginFill(getStyle("contentBackgroundColor"), contentBackgroundAlpha);
				bgFill.drawRect(contentGroup.getLayoutBoundsX(), contentGroup.getLayoutBoundsY(), contentWidth, contentHeight);
				bgFill.endFill();
			}
			else
			{
				// remove the mask
				if (contentMask)
				{
					contentGroup.mask = null;
					contentMask = null;
				}
			}
		}
		
		/**
		 * @private
		 */
		override protected function layoutContents(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.layoutContents(unscaledWidth, unscaledHeight)
			
			if (dropShadow)
			{
				setElementSize(dropShadow, unscaledWidth, unscaledHeight);
				setElementPosition(dropShadow, 0, 0);
			}		
			setElementSize(contentGroup, unscaledWidth, unscaledHeight);
			setElementPosition(contentGroup, 0, 0);
			
			// mask position is in the contentGroup coordinate space
			if (contentMask)
				setElementSize(contentMask, unscaledWidth, unscaledHeight);
		}
		
		override public function styleChanged(styleProp:String):void
		{
			super.styleChanged(styleProp);
			
			var allStyles:Boolean = !styleProp || styleProp == "styleName";
			
			if (allStyles || (styleProp == "contentBackgroundAppearance"))
				invalidateProperties();
			
			if (allStyles || (styleProp == "backgroundAlpha"))
			{
				var backgroundAlpha:Number = getStyle("backgroundAlpha");
				
				// Use BlendMode.LAYER to allow CalloutArrow to erase the dropShadow
				// when the Callout background is transparent
				blendMode = (backgroundAlpha < 1) ? BlendMode.LAYER : BlendMode.NORMAL;
			}
		}

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------
		
		private function stateChangeComplete(event:Event=null):void
		{
			if (fade && event)
				fade.removeEventListener(EffectEvent.EFFECT_END, stateChangeComplete);
			
			// SkinnablePopUpContainer relies on state changes for open and close
			dispatchEvent(new FlexEvent(FlexEvent.STATE_CHANGE_COMPLETE));
		}
	}
}
