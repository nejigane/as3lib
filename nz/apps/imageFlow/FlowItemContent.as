/**
 * FlowItemContent.as
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
  import flash.display.Bitmap;
  import flash.display.BitmapData;
  import flash.display.BlendMode;
  import flash.display.DisplayObject;
  import flash.filters.DisplacementMapFilter;
  import flash.geom.Point;
  import flash.geom.Rectangle;
  import flash.geom.Matrix;
  import flash.geom.ColorTransform;

  public class FlowItemContent extends Bitmap{

    private var orgObject:DisplayObject;
    private var destDrawScale:Number;
    private var destDrawX:Number;
    private var destDrawY:Number;
    private var hitAreaPoints:Array;
    private var shapeType:int;
    private var targetHitArea:Sprite;
    private var rightFilter:DisplacementMapFilter;
    private var leftFilter:DisplacementMapFilter;
    private var frameWidth:int;
    private var frameHeight:int;

    private static const SHADOW_OPACITY:Number = 0.3;
    public static const HIDDEN:int = -1;
    public static const LEFT:int = 0;
    public static const FRONT:int = 1;
    public static const RIGHT:int = 2;

    public function FlowItemContent(frameWidth:int, frameHeight:int, orgObject:DisplayObject, 
				    leftFilter:DisplacementMapFilter, rightFilter:DisplacementMapFilter,
				    targetHitArea:Sprite){

      this.orgObject = orgObject;      
      this.frameWidth = frameWidth;
      this.frameHeight = frameHeight;
      this.leftFilter = leftFilter;
      this.rightFilter = rightFilter;
      this.targetHitArea = targetHitArea;

      destDrawX = destDrawY = 0;
      if (orgObject.width / frameWidth >= orgObject.height / frameHeight) {
        destDrawScale = frameWidth / orgObject.width;
        destDrawY = frameHeight - orgObject.height * destDrawScale;
      }
      else {
        destDrawScale = frameHeight / orgObject.height;
        destDrawX = (frameWidth - orgObject.width * destDrawScale) / 2;
      }

      hitAreaPoints = [];
      hitAreaPoints[LEFT] = [];
      hitAreaPoints[FRONT] = [];
      hitAreaPoints[RIGHT] = [];
      hitAreaPoints[FRONT].push(new Point(destDrawX, destDrawY));
      hitAreaPoints[FRONT].push(new Point(destDrawX + orgObject.width * destDrawScale, destDrawY));
      hitAreaPoints[FRONT].push(new Point(destDrawX + orgObject.width * destDrawScale,
					  destDrawY + orgObject.height * destDrawScale));
      hitAreaPoints[FRONT].push(new Point(destDrawX, destDrawY + orgObject.height * destDrawScale));
      for (var i:int = 0; i < hitAreaPoints[FRONT].length; ++i) {
	hitAreaPoints[LEFT].push(mapPoint(hitAreaPoints[FRONT][i], true));
	hitAreaPoints[RIGHT].push(mapPoint(hitAreaPoints[FRONT][i], false));
      }

      shapeType = HIDDEN;
      change(FRONT);

    }

    public function change(shapeType:int):void{
      
      if (this.shapeType == shapeType) return;

      switch (shapeType) {

      case HIDDEN:
	bitmapData = null;
	clearHitArea();
	break;

      case FRONT:
	drawFrontalContent();
	drawHitArea(hitAreaPoints[FRONT]);
	break;

      case LEFT:
	if (this.shapeType != FRONT) drawFrontalContent();
	bitmapData.applyFilter(bitmapData, 
			       new Rectangle(0, 0, frameWidth, frameHeight * 2),
			       new Point(),
			       leftFilter);
	drawHitArea(hitAreaPoints[LEFT]);
	break;

      case RIGHT:
	if (this.shapeType != FRONT) drawFrontalContent();	
	bitmapData.applyFilter(bitmapData, 
			       new Rectangle(0, 0, frameWidth, frameHeight * 2),
			       new Point(),
			       rightFilter);
	drawHitArea(hitAreaPoints[RIGHT]);
	break;
	
      default:
	return;
      
      }

      this.shapeType = shapeType;
    }

    private function drawFrontalContent():void{

      bitmapData = null;
      bitmapData = new BitmapData(frameWidth, frameHeight * 2, true, 0x00000000);
      bitmapData.draw(orgObject,
		      new Matrix(orgObject.scaleX * destDrawScale, 0,
				 0, orgObject.scaleY * destDrawScale,
				 destDrawX, destDrawY),
		      null, null,
		      new Rectangle(0, 0, frameWidth, frameHeight));
      bitmapData.draw(orgObject,
		      new Matrix(orgObject.scaleX * destDrawScale, 0,
				 0, -orgObject.scaleY * destDrawScale,
				 destDrawX, frameHeight + orgObject.height * destDrawScale),
		      new ColorTransform(SHADOW_OPACITY, SHADOW_OPACITY, SHADOW_OPACITY, 1.0),
		      BlendMode.ADD,
		      new Rectangle(0, frameHeight, frameWidth, frameHeight)); 

    }

    private function drawHitArea(points:Array):void{

      targetHitArea.graphics.clear();
      targetHitArea.graphics.lineStyle();
      targetHitArea.graphics.beginFill(0xffffff);
      targetHitArea.graphics.moveTo(points[0].x, points[0].y);
      for (var i:int = 1; i < points.length; ++i) {
	targetHitArea.graphics.lineTo(points[i].x, points[i].y);
      }
      targetHitArea.graphics.endFill();

    }
    
    private function clearHitArea():void{

      targetHitArea.graphics.clear();
	
    }

    private function mapPoint(org:Point, isLeft:Boolean):Point{

      var mapX:Number = org.x;
      var mapY:Number = 
	(8 * frameWidth * org.y - 3 * org.x * org.y + 2 * org.x * frameHeight) / (8 * frameWidth);
      if (!isLeft) {
	mapX = frameWidth - mapX;
      }
      
      return new Point(mapX, mapY);

    }

  }
}
