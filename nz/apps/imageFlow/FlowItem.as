/**
 * FlowItem.as
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
  import flash.filters.DisplacementMapFilter;
  import flash.display.DisplayObject;

  public class FlowItem extends Sprite{

    private var content:FlowItemContent;
    private var isOver:Boolean;
    private var angle_:Number;
    private var z_:Number;
    private var centerX_:Number;
    private var destAngle:Number;
    private var destZ:Number;
    private var destCenterX:Number;
    private var maxDeltaZ:Number;
    private var maxDeltaX:Number;

    private var frameWidth:int;
    private var frameHeight:int;
    private var stageWidth:Number;
    private var vanishingPointY:Number;
    private var focusingLength:Number;

    private static const RATIO:Number = 0.3;
    private static const ERROR_X:Number = 0.1;
    private static const RANGE_ANGLE:Number = 25;
    private static const RADIAN_PER_DEGREE:Number = Math.PI / 180;

    public static const DISAPPEARED:int = -1;
    public static const NORMAL:int = 0;
    public static const APPEARED_FROM_LEFT:int = 1;
    public static const APPEARED_FROM_RIGHT:int = 2;
    
    public function FlowItem(frameWidth:int, frameHeight:int, stageWidth:Number, orgObject:DisplayObject,
			     leftFilter:DisplacementMapFilter, rightFilter:DisplacementMapFilter){

      isOver = true;
      z_ = angle_ = centerX_ = 0;
      maxDeltaX = frameWidth / 2.0;
      maxDeltaZ = frameHeight / 5.0;

      this.frameWidth = frameWidth;
      this.frameHeight = frameHeight;
      this.stageWidth = stageWidth;
      this.vanishingPointY = frameHeight * 0.8;
      this.focusingLength = frameWidth;

      var hitAreaSprite:Sprite = new Sprite();
      hitAreaSprite.mouseEnabled = false;
      hitAreaSprite.visible = false;
      addChild(hitAreaSprite);
      hitArea = hitAreaSprite;

      content = 
	new FlowItemContent(frameWidth, frameHeight, orgObject, leftFilter, rightFilter, hitAreaSprite);
      addChild(content);

    }

    public function setDestState(destCenterX:Number, destZ:Number, destAngle:Number):void{

      this.destCenterX = destCenterX;
      this.destZ = destZ;
      this.destAngle = destAngle;
      isOver = false;

    }

    public function tick():int{

      if (isOver) return NORMAL;

      var returnCode:int = NORMAL;
      var deltaX:Number = (destCenterX - centerX_) * RATIO;
      centerX_ += maskNumber(deltaX, maxDeltaX);
      z_ += maskNumber((destZ - z_) * RATIO, maxDeltaZ);
      angle_ += (destAngle - angle_) * RATIO;

      if (isOnStage() && !visible) {
	visible = true;
	returnCode = (deltaX > 0) ? APPEARED_FROM_LEFT : APPEARED_FROM_RIGHT;
      }
      else if (!isOnStage() && visible) {
	visible = false;
	returnCode = DISAPPEARED;
      }

      update();

      if (Math.abs(deltaX) < ERROR_X) {
	isOver = true;
      }

      return returnCode;

    }


    private function update():void{

      if (visible) {
	if (angle_ <= -RANGE_ANGLE) {
	  content.change(FlowItemContent.LEFT);
	}
	else if (angle_ >= RANGE_ANGLE) {
	  content.change(FlowItemContent.RIGHT);
	}
	else {
	  content.change(FlowItemContent.FRONT);
	}
      } else {
	content.change(FlowItemContent.HIDDEN);
      }

      scaleY = focusingLength / (focusingLength + z_ - frameWidth / 2 * Math.abs(Math.sin(angle_ * RADIAN_PER_DEGREE)));
      scaleX = scaleY * Math.cos(angle_ * RADIAN_PER_DEGREE);            
      x = centerX_ - frameWidth * scaleX / 2;
      y = vanishingPointY - frameHeight * scaleY / 5 - frameHeight * scaleY / 2;

    }

    private function maskNumber(value:Number, maxValue:Number):Number{

      if (value > maxValue) {
	return maxValue;
      } 
      else if (value < -maxValue) {
	return -maxValue;
      }
      else {
	return value;
      }

    }

    private function isOnStage():Boolean{
      
      return centerX_ >= 0 && centerX_ <= stageWidth;

    }
    
    public function set z(value:Number):void{

      z_ = value;
      update();

    }

    public function set centerX(value:Number):void{

      centerX_ = value;

      if (isOnStage() && !visible) {
	visible = true;
      }
      else if (!isOnStage() && visible) {
	visible = false;
      }

      update();

    }

    public function get centerX():Number{

      return centerX_;

    }

    public function set angle(value:Number):void{

      angle_ = value;
      update();

    }

    public function get angle():Number{

      return angle_;

    }

  }
}
