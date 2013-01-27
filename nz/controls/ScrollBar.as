/**
 * ScrollBar.as
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

package nz.controls{

  import flash.display.Sprite;
  import flash.display.Bitmap;
  import flash.display.BitmapData;
  import flash.events.Event;
  import flash.events.MouseEvent;
  import nz.events.ScrollEvent;

  public class ScrollBar extends Sprite{

    [Embed(source='__scrollBarImages/scrollBarPart00.png')]
    private static var ScrollBarPart00 : Class;
    [Embed(source='__scrollBarImages/scrollBarPart01.png')]
    private static var ScrollBarPart01 : Class;
    [Embed(source='__scrollBarImages/scrollBarPart02.png')]
    private static var ScrollBarPart02 : Class;
    [Embed(source='__scrollBarImages/scrollBarPart03.png')]
    private static var ScrollBarPart03 : Class;
    [Embed(source='__scrollBarImages/scrollTrackPart00.png')]
    private static var ScrollTrackPart00 : Class;
    [Embed(source='__scrollBarImages/scrollTrackPart01.png')]
    private static var ScrollTrackPart01 : Class;
    [Embed(source='__scrollBarImages/scrollTrackPart02.png')]
    private static var ScrollTrackPart02 : Class;

    private var minPosition:Number;
    private var maxPosition:Number;
    private var position:Number;
    private var bar:Sprite;
    private var track:Sprite;
    private var distance:Number;
    private var dragArea:Sprite;
    private var dragAreaPreX:Number;
    private var scrollSize:Number

    private const OFFSET_X:Number = 3;
    private const OFFSET_Y:Number = 1;

    public function ScrollBar(trackLength:Number, barLength:Number, scrollSize:Number){

      this.scrollSize = scrollSize;

      bar = createBar(barLength);
      addChild(bar);

      track = (bar.width > trackLength) ? createTrack(bar.width) : createTrack(trackLength);
      track.addEventListener(MouseEvent.MOUSE_DOWN, onTrackDown);
      addChild(track);

      dragArea = createDragArea();
      dragArea.width = bar.width;
      dragArea.height = bar.height;
      dragArea.addEventListener(MouseEvent.MOUSE_DOWN, onDragAreaDown);
      addChild(dragArea);

      addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

      minPosition = 0;
      maxPosition = 100;
      position = 0;
      distance = trackLength - bar.width;

    }

    private function onAddedToStage(e:Event):void{

      stage.addEventListener(MouseEvent.MOUSE_UP, onDragAreaUp);      

    }

    public function setMinMaxPosition(min:Number, max:Number):void{

      minPosition = min;
      maxPosition = max;
      position = minPosition;
      update();

    }
    
    public function setPosition(pos:Number):void{

      if (pos < minPosition) {
	position = minPosition;
      }
      else if (pos > maxPosition) {
	position = maxPosition;
      }
      else {
	position = pos;
      }
      update();

    }
 
    private function update():void{

      var prop:Number = (position - minPosition) / (maxPosition - minPosition);
      bar.x = distance * prop + OFFSET_X;
      dragArea.x = bar.x;
      dragArea.y = bar.y;

    }

    private function onTrackDown(e:MouseEvent):void{

      if (e.localX > OFFSET_X && e.localX < bar.x) {
	if (bar.x - scrollSize < OFFSET_X) {
	  bar.x = OFFSET_X;
	}
	else {
	  bar.x -= scrollSize;
	}
      }
      else if (e.localX > bar.x + bar.width && e.localX < track.width - OFFSET_X) {
	if (bar.x + scrollSize > OFFSET_X + distance) {
	  bar.x = OFFSET_X + distance;
	}
	else {
	  bar.x += scrollSize;
	}
      }
      var position:Number = (bar.x - OFFSET_X) / distance * (maxPosition - minPosition) + minPosition;
      var scrollEvent:ScrollEvent = new ScrollEvent(ScrollEvent.SCROLL, position);
      dispatchEvent(scrollEvent);

    }

    private function onDragAreaDown(e:MouseEvent):void{

      dragAreaPreX = dragArea.x;
      dragArea.startDrag();
      dragArea.addEventListener(Event.ENTER_FRAME, onDragAreaEnterFrame);

    }

    private function onDragAreaUp(e:MouseEvent):void{

      dragArea.stopDrag();
      dragArea.removeEventListener(Event.ENTER_FRAME, onDragAreaEnterFrame);
      dragArea.x = bar.x;
      dragArea.y = bar.y;

    }

    private function onDragAreaEnterFrame(e:Event):void{

      if (dragArea.x < OFFSET_X) {
	bar.x = OFFSET_X;
	position = minPosition;
      } 
      else if (dragArea.x > OFFSET_X + distance) {
	bar.x = OFFSET_X + distance;
	position = maxPosition;
      }
      else {
	bar.x = dragArea.x;
	position = (bar.x - OFFSET_X) / distance * (maxPosition - minPosition) + minPosition;
      }
      if (dragAreaPreX != dragArea.x) {
	var scrollEvent:ScrollEvent = new ScrollEvent(ScrollEvent.SCROLL, position);
	dispatchEvent(scrollEvent);
      }
      dragAreaPreX = dragArea.x;

    }

    private function createBar(barLength:Number):Sprite{

      var bar:Sprite = new Sprite();
      var bar00:Bitmap = new ScrollBarPart00();
      var bar01:Bitmap = new ScrollBarPart01();
      var bar02:Bitmap = new ScrollBarPart02();
      var bar03:Bitmap = new ScrollBarPart03();
      bar03.x = 1;
      bar03.width = barLength - 2;
      bar.addChild(bar03);
      bar01.x = 0;
      bar.addChild(bar01);
      bar02.x = barLength - bar02.width;
      bar.addChild(bar02);
      bar00.x = barLength / 2 - bar00.width / 2;
      bar.addChild(bar00);
      bar.x = OFFSET_X;
      bar.y = OFFSET_Y;

      return bar;

    }
    
    private function createTrack(trackLength:Number):Sprite{

      var track:Sprite = new Sprite();
      var track00:Bitmap = new ScrollTrackPart00();
      var track01:Bitmap = new ScrollTrackPart01();
      var track02:Bitmap = new ScrollTrackPart02();
      var trackBack:Bitmap = new Bitmap(new BitmapData(1, 1, true, 0x20FFFFFF));
      track00.x = 0;
      track.addChild(track00);
      trackBack.x = track00.width;
      trackBack.width = trackLength;
      trackBack.height = track00.height;
      track.addChild(trackBack);
      track02.x = track00.width;
      track02.width = trackLength;
      track.addChild(track02);
      track01.x = track.width;
      track.addChild(track01);

      return track;

    }

    private function createDragArea():Sprite{

      var dragAreaBitmap:Bitmap = new Bitmap(new BitmapData(1, 1, true, 0x00000000));
      var dragArea:Sprite = new Sprite();
      dragArea.addChild(dragAreaBitmap);
      dragArea.x = OFFSET_X;
      dragArea.y = OFFSET_Y;

      return dragArea;

    }


  }
}
