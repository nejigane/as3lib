/**
 * FlowItemFactory.as
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

  import flash.display.Bitmap;
  import flash.display.BitmapData;
  import flash.display.BitmapDataChannel;
  import flash.filters.DisplacementMapFilter;
  import flash.filters.DisplacementMapFilterMode;
  import flash.display.DisplayObject;

  public class FlowItemFactory {

    private var frameWidth:int;
    private var frameHeight:int;
    private var stageWidth:Number;
    private var rightFilter:DisplacementMapFilter;
    private var leftFilter:DisplacementMapFilter;

    private static const RATIO:Number = 0.3;
    private static const ERROR_X:Number = 0.1;
    private static const RANGE_ANGLE:Number = 25;
    private static const RADIAN_PER_DEGREE:Number = Math.PI / 180;
    
    public function FlowItemFactory(frameWidth:int, frameHeight:int, stageWidth:Number){

      this.frameWidth = frameWidth;
      this.frameHeight = frameHeight;
      this.stageWidth = stageWidth;
      
      createMapFilters();

    }

    public function createFlowItem(orgObject:DisplayObject):FlowItem{
      
      var flowItem:FlowItem = 
	new FlowItem(frameWidth, frameHeight, stageWidth, orgObject, leftFilter, rightFilter);

      return flowItem;
      
    }

    private function createMapFilters():void{

      var leftBD:BitmapData = new BitmapData(frameWidth, frameHeight * 2, true, 0x00000000);
      var rightBD:BitmapData = new BitmapData(frameWidth, frameHeight * 2, true, 0x00000000);

      for (var i:int = 0; i < frameWidth; ++i) {
        var colorDen:uint = frameHeight * (8 * frameWidth - 3 * i);
        for (var j:int = 0; j < frameHeight * 2; ++j) {
          var colorValue:uint = 0xFF000080 + 160 * i * (3 * j - 2 * frameHeight) / colorDen;
          leftBD.setPixel32(i, j, colorValue);
          rightBD.setPixel32(frameWidth - i - 1, j, colorValue);
        }
      }

      leftFilter =
        new DisplacementMapFilter(leftBD, null,
                                  BitmapDataChannel.RED, BitmapDataChannel.BLUE,
                                  0, 8 * frameHeight / 5,
                                  DisplacementMapFilterMode.COLOR, 0, 0);
      rightFilter =
        new DisplacementMapFilter(rightBD, null,
                                  BitmapDataChannel.RED, BitmapDataChannel.BLUE,
                                  0, 8 * frameHeight / 5,
                                  DisplacementMapFilterMode.COLOR, 0, 0);

    }

    
  }
}
