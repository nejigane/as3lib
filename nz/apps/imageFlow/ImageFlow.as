/**
 * ImageFlow.as
 *
 * @author      Yu Nejigane
 * @link        http://nzgn.net/
 *
 * Copyright (c) 2008 Yu Nejigane
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

package nz.apps.imageFlow{

  import flash.display.Sprite;
  import flash.display.DisplayObject;
  import flash.display.GradientType;
  import flash.geom.Matrix;
  import flash.events.Event;
  import flash.events.MouseEvent;
  import flash.text.TextField;
  import flash.text.TextFormat;
  import flash.text.TextFormatAlign;

  import nz.controls.ScrollBar;
  import nz.events.ScrollEvent;

  public class ImageFlow extends Sprite{

    private var centerIndex:int;
    private var stageWidth:Number;
    private var stageHeight:Number;
    private var centerOffset:Number;
    private var leftOffset:Number;
    private var rightOffset:Number;
    private var interval:Number;
    private var imageTitle:TextField;
    private var imageTitleArray:Array = [];
    private var flowItems:Array = [];
    private var scrollBar:ScrollBar;
    private var backwardZ:Number;
    private var flowItemFactory:FlowItemFactory;

    public function ImageFlow(frameWidth:int, frameHeight:int){

      stageWidth = frameWidth * 2.5;
      stageHeight = frameHeight * 1.2 + 70;

      centerOffset = stageWidth * 0.5;
      leftOffset = stageWidth * 0.5 - frameWidth * 2 / 3;
      rightOffset = stageWidth * 0.5 + frameWidth * 2 / 3;
      interval = frameWidth / 6;
      centerIndex = 0;
      backwardZ = frameHeight * 0.75;

      graphics.lineStyle();
      graphics.beginFill(0x000000);
      graphics.drawRect(0, 0, stageWidth, stageHeight);
      graphics.endFill();

      addChild(createImageTitle(stageWidth, stageHeight));
      addChild(createShadow(stageWidth, stageHeight));

      scrollBar = new ScrollBar(stageWidth * 0.8, 40, 20);
      scrollBar.x = stageWidth * 0.5 - scrollBar.width * 0.5;
      scrollBar.y = stageHeight - scrollBar.height - 20;
      addChild(scrollBar);

      mask = addChild(createMask(stageWidth, stageHeight));

      flowItemFactory = new FlowItemFactory(frameWidth, frameHeight, stageWidth);

    }

    public function addItem(item:DisplayObject, title:String, onDoubleClick:Function = null):void{

      var flowItem:FlowItem = flowItemFactory.createFlowItem(item);
      if (flowItems.length == 0) {
     	flowItem.centerX = centerOffset;
      	flowItem.z = 0;
	flowItem.angle = 0;
      	imageTitle.text = title;
      }
      else{
	flowItem.centerX = rightOffset + (flowItems.length - 1) * interval;
	flowItem.z = backwardZ;
	flowItem.angle = 60;
      }
      imageTitleArray.push(title);
      flowItem.addEventListener(MouseEvent.CLICK, onClick);
      if (onDoubleClick != null) {
	flowItem.doubleClickEnabled = true;
	flowItem.addEventListener(MouseEvent.DOUBLE_CLICK, onDoubleClick);
      }
      flowItems.push(flowItem);
      addChildAt(flowItem, 0);

    }

    public function startFlow():void{

      addEventListener(Event.ENTER_FRAME, onEnterFrame);
      scrollBar.setMinMaxPosition(0, flowItems.length - 1);
      scrollBar.addEventListener(ScrollEvent.SCROLL, onScroll);

    }

    private function onEnterFrame(e:Event):void{

      var i:int;

      for (i = 0; i < centerIndex; ++i) {
	if (flowItems[i].tick() == FlowItem.APPEARED_FROM_RIGHT) {
	  flowItems[i].angle = flowItems[i-1].angle < -90 ? flowItems[i-1].angle : flowItems[i-1].angle - 5;
	}
      }

      flowItems[centerIndex].tick();

      for (i = flowItems.length - 1; i > centerIndex; --i) {
	if (flowItems[i].tick() == FlowItem.APPEARED_FROM_LEFT) {
	  flowItems[i].angle = flowItems[i+1].angle > 90 ? flowItems[i+1].angle : flowItems[i+1].angle + 5;
	}
      }

    }

    private function onScroll(e:ScrollEvent):void{

      var index:int = Math.floor(e.position);
      if (index != centerIndex) {
	resetDestination(index);
      }

    }

    private function onClick(e:MouseEvent):void{

      var clickedIndex:int;
      for (var i:int = 0; i < flowItems.length; ++i) {
	if (flowItems[i] === e.target) {
	  clickedIndex = i;
	  break;
	}
      }
      if (clickedIndex != centerIndex) {
	resetDestination(clickedIndex);
	scrollBar.setPosition(clickedIndex);
      }

    }

    private function resetDestination(selectedIndex:int):void{

      var i:int;
      for(i = 0; i < selectedIndex; ++i){
	flowItems[i].setDestState(leftOffset - (selectedIndex - i - 1) * interval,
				  backwardZ, -60);
	setChildIndex(flowItems[i], i);
      }

      flowItems[selectedIndex].setDestState(centerOffset, 0, 0);
      setChildIndex(flowItems[selectedIndex], flowItems.length - 1);

      for(i = flowItems.length - 1; i > selectedIndex; --i){
	flowItems[i].setDestState(rightOffset + (i - selectedIndex - 1) * interval,
				  backwardZ, 60);
	setChildIndex(flowItems[i], flowItems.length - i + selectedIndex - 1);
      }

      centerIndex = selectedIndex;
      imageTitle.text = imageTitleArray[selectedIndex];

    }
    
    private function createImageTitle(stageWidth:Number, stageHeight:Number):TextField{

      var titleFormat:TextFormat = new TextFormat();
      titleFormat.bold = true;
      titleFormat.color = 0xFFFFFF;
      titleFormat.size = 12;
      titleFormat.font = "Verdana";
      titleFormat.align = TextFormatAlign.CENTER;

      imageTitle = new TextField();
      imageTitle.x = 10;
      imageTitle.y = stageHeight - 70;
      imageTitle.width = stageWidth - 20;
      imageTitle.height = 20;
      imageTitle.defaultTextFormat = titleFormat;

      return imageTitle;

    }

    private function createShadow(stageWidth:Number, stageHeight:Number):Sprite{

      var gradBoxL:Matrix = new Matrix();
      var gradBoxR:Matrix = new Matrix();
      gradBoxL.createGradientBox(stageWidth / 4, stageHeight, 0, 0, 0);
      gradBoxR.createGradientBox(stageWidth / 4, stageHeight, 0, 3 * stageWidth / 4, 0);

      var shadow:Sprite = new Sprite();
      shadow.graphics.lineStyle();
      shadow.graphics.beginGradientFill(GradientType.LINEAR,
      					[0x000000, 0x000000],
      					[0.7, 0],
      					[0x00, 0xFF],
      					gradBoxL);
      shadow.graphics.drawRect(0, 0, stageWidth / 4, stageHeight);
      shadow.graphics.endFill();
      shadow.graphics.beginGradientFill(GradientType.LINEAR,
					[0x000000, 0x000000],
					[0, 0.7],
					[0x00, 0xFF],
					gradBoxR);
      shadow.graphics.drawRect(3 * stageWidth / 4, 0, stageWidth / 4, stageHeight);
      shadow.graphics.endFill();
      shadow.mouseEnabled = false;

      return shadow;
      
    }

    private function createMask(stageWidth:Number, stageHeight:Number):Sprite{

      var maskSprite:Sprite = new Sprite();
      maskSprite.graphics.lineStyle();
      maskSprite.graphics.beginFill(0x000000);
      maskSprite.graphics.drawRect(0, 0, stageWidth, stageHeight);
      maskSprite.graphics.endFill();

      return maskSprite;
      
    }

  }

}
