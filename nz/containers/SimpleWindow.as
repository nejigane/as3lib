/**
 * SimpleWindow.as
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

package nz.containers{

  import flash.display.DisplayObject;
  import flash.display.Sprite;
  import flash.display.Bitmap;
  import flash.display.BitmapData;
  import flash.display.SimpleButton;
  import flash.text.TextField;
  import flash.text.TextFormat;
  import flash.events.Event;
  import flash.events.MouseEvent;

  public class SimpleWindow extends Sprite{
    
    [Embed(source='__windowImages/windowPart00.png')]
    private static var WindowPart00 : Class;
    [Embed(source='__windowImages/windowPart01.png')]
    private static var WindowPart01 : Class;
    [Embed(source='__windowImages/windowPart02.png')]
    private static var WindowPart02 : Class;
    [Embed(source='__windowImages/windowPart03.png')]
    private static var WindowPart03 : Class;
    [Embed(source='__windowImages/windowPart04.png')]
    private static var WindowPart04 : Class;
    [Embed(source='__windowImages/windowPart05.png')]
    private static var WindowPart05 : Class;
    [Embed(source='__windowImages/windowPart06.png')]
    private static var WindowPart06 : Class;
    [Embed(source='__windowImages/windowPart07.png')]
    private static var WindowPart07 : Class;

    [Embed(source='__windowImages/button00.png')]
    private static var Button00 : Class;
    [Embed(source='__windowImages/button01.png')]
    private static var Button01 : Class;
    [Embed(source='__windowImages/button02.png')]
    private static var Button02 : Class;
    [Embed(source='__windowImages/button03.png')]
    private static var Button03 : Class;

    private const LEFT_F:int = 7;
    private const RIGHT_F:int = 8;
    private const UPPER_F:int = 25;
    private const LOWER_F:int = 8;
    private const MIN_W:int = 100;
    private const MIN_H:int = 10;
    private const BUTTON_H:int = 15;
    private const BUTTON_W:int = 15;
    private const TITLE_OFFSET:int = 5;

    private var windowParts:Array;
    private var title:TextField;
    private var closeButton:SimpleButton;
    private var background:Sprite;
    private var innerContainer:Sprite;

    public var customButton:SimpleButton;

    public function SimpleWindow(){

      windowParts = [new WindowPart00(), new WindowPart01(), new WindowPart02(),
		     new WindowPart03(), new WindowPart04(), new WindowPart05(),
		     new WindowPart06(), new WindowPart07()];
      for (var i:int = 0; i < windowParts.length; ++i) {
	addChild(windowParts[i]);
      }

      var buttonImages:Array = [new Button00(), new Button01(), new Button02(), new Button03()];
      closeButton = createButton(buttonImages[0], buttonImages[1]);
      addChild(closeButton);
      customButton = createButton(buttonImages[2], buttonImages[3]);
      addChild(customButton);
      title = createTitle();
      addChild(title);
      background = createBackground();
      addChild(background);
      innerContainer = createInnerContainer();
      addChild(innerContainer);

      update();

      addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
      addEventListener(MouseEvent.MOUSE_UP, onMouseUp);

    }

    public function addCloseButtonEventListener(func:Function):void{

      closeButton.addEventListener(MouseEvent.CLICK, func);

    }

    public function removeCloseButtonEventListener(func:Function):void{

      closeButton.removeEventListener(MouseEvent.CLICK, func);

    }
    
    public function addCustomButtonEventListener(func:Function):void{

      customButton.addEventListener(MouseEvent.CLICK, func);

    }

    public function removeCustomButtonEventListener(func:Function):void{

      customButton.removeEventListener(MouseEvent.CLICK, func);

    }

    public function setTitle(name:String):void{

      title.text = name;

    }

    public function setContent(content:DisplayObject):void{

      if (innerContainer.numChildren > 1) {
	innerContainer.removeChildAt(innerContainer.numChildren - 1);
      }
  
      if (content.mask) {
	innerContainer.mask.width = content.mask.width;
	innerContainer.mask.height = content.mask.height;
      }
      else {
	innerContainer.mask.width = content.width;
	innerContainer.mask.height = content.height;
      }
      innerContainer.addChild(content);
      update();

    }

    public function update():void{

      var contentWidth:Number = 
	innerContainer.mask.width > MIN_W ? innerContainer.mask.width : MIN_W;
      var contentHeight:Number = 
	innerContainer.mask.height > MIN_H ? innerContainer.mask.height : MIN_H;
      var windowPartConf:Array = 
	[[0, 0, LEFT_F, UPPER_F],
	 [0, UPPER_F + contentHeight, LEFT_F, LOWER_F],
	 [LEFT_F + contentWidth, UPPER_F + contentHeight, RIGHT_F, LOWER_F],
	 [LEFT_F + contentWidth, 0, RIGHT_F, UPPER_F],
	 [0, UPPER_F, LEFT_F, contentHeight],
	 [LEFT_F, 0, contentWidth, UPPER_F],
	 [LEFT_F + contentWidth, UPPER_F, RIGHT_F, contentHeight],
	 [LEFT_F, UPPER_F + contentHeight, contentWidth, LOWER_F]];

      for (var i:int = 0; i < windowParts.length; ++i) {
	windowParts[i].x = windowPartConf[i][0];
	windowParts[i].y = windowPartConf[i][1];
	windowParts[i].width = windowPartConf[i][2];
	windowParts[i].height = windowPartConf[i][3];
      }

      background.width = contentWidth;
      background.height = contentHeight;
      closeButton.x = LEFT_F + contentWidth - BUTTON_W;
      title.width = (contentWidth - BUTTON_W * 2 - TITLE_OFFSET * 2);

    }
    
    private function onMouseDown(e:MouseEvent):void{

      parent.setChildIndex(this, parent.numChildren - 1);
      if ((e.target === this && e.localY < UPPER_F) || e.target === title) {
	startDrag();
      }

    }

    private function onMouseUp(e:MouseEvent):void{

      stopDrag();

    }

    private function createButton(upState:DisplayObject, otherState:DisplayObject):SimpleButton{

      var button:SimpleButton = new SimpleButton(upState, otherState, otherState, otherState);
      button.width = BUTTON_W;
      button.height = BUTTON_H;
      button.x = LEFT_F;
      button.y = (UPPER_F-BUTTON_H) / 2;
      button.useHandCursor = true;

      return button;

    }

    private function createTitle():TextField{

      var title:TextField = new TextField();
      title.x = LEFT_F + BUTTON_W + TITLE_OFFSET;
      title.y = 3;
      title.height = UPPER_F - 3;

      var titleFormat:TextFormat = new TextFormat();
      titleFormat.bold = true;
      titleFormat.font = "Verdana";
      title.defaultTextFormat = titleFormat;
      title.selectable = false;
      title.text = "";

      return title;

    }

    private function createBackground():Sprite{

      var backBitmap:Bitmap = new Bitmap(new BitmapData(1, 1, false));
      var background:Sprite = new Sprite();
      background.addChild(backBitmap);
      background.x = LEFT_F;
      background.y = UPPER_F;

      return background;
    }

    private function createInnerContainer():Sprite{

      var maskBitmap:Bitmap = new Bitmap(new BitmapData(1, 1, false));
      var maskSprite:Sprite = new Sprite();
      maskSprite.addChild(maskBitmap);
      var innerContainer:Sprite = new Sprite();
      innerContainer.x = LEFT_F;
      innerContainer.y = UPPER_F;
      innerContainer.addChild(maskSprite);
      innerContainer.mask = maskSprite;

      return innerContainer;
    }

  }
}
