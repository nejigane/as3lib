/**
 * PlotScale.as
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

package nz.charts{

  import flash.display.DisplayObject;
  import flash.display.Sprite;
  import flash.display.Bitmap;
  import flash.display.BitmapData;
  import flash.geom.Point;
  import flash.geom.Rectangle;
  import flash.text.TextField;
  import flash.text.TextFieldAutoSize;
  import flash.text.TextFormat;
  import nz.charts.PlotData;
  import nz.charts.PlotStyle;
  import nz.charts.PlotLegendBox;

  public class PlotScale extends Sprite{

    private var tickDigit:int;
    private var tickSignificand:Number;
    private var scaleValues:Array;
    private var formatter:TextFormat;

    public static const HORIZONTAL:String = 'horizontal';
    public static const VERTICAL:String = 'vertical';

    public function PlotScale(min:Number, max:Number, scaleLength:Number, type:String){

      formatter = new TextFormat();
      formatter.font = "Verdana";
      formatter.size = 10;

      calculateTickSize(min, max);
      calculateScaleValues(min, max);

      var tickLength:Number = scaleLength / (scaleValues.length - 1);

      var digitText:TextField = createDigitText(tickDigit);

      var i:int;
      if (type == HORIZONTAL) {
	for (i = 0; i < scaleValues.length; ++i) {
	  var scaleTextHorizontal:TextField = createScaleText(scaleValues[i]);
	  scaleTextHorizontal.x = tickLength * i - scaleTextHorizontal.width / 2;
	  addChild(scaleTextHorizontal);
	}
	digitText.x = scaleLength;
	digitText.y = 15;
      }
      else {
	for (i = 0; i < scaleValues.length; ++i) {
	  var scaleTextVertical:TextField = createScaleText(scaleValues[i]);
	  scaleTextVertical.x = -scaleTextVertical.width;
	  scaleTextVertical.y = scaleLength - tickLength * i - scaleTextVertical.height / 2;
	  addChild(scaleTextVertical);
	}
	digitText.x = -digitText.width;
	digitText.y = -30;
      }

      addChild(digitText);

    }

    private function createDigitText(digitNum:int):TextField{

      var textContent:String = "";
      if (digitNum < 0) {
	textContent = "x10^(" + String(digitNum) + ")";
      }
      else if (digitNum == 1) {
	textContent = "x10";
      }
      else if (digitNum > 1) {
	textContent = "x10^" + String(digitNum);
      }

      var digitText:TextField = new TextField();
      digitText.defaultTextFormat = formatter;
      digitText.text = textContent;
      digitText.autoSize = TextFieldAutoSize.LEFT;

      return digitText;

    }

    private function createScaleText(scaleValue:Number):TextField{

      var scaleString:String;
      if (scaleValue == 0 || tickSignificand >= 1) {
	scaleString = String(scaleValue);
      }
      else {
	scaleString = scaleValue.toFixed(1);
      }

      var scaleText:TextField = new TextField();
      scaleText.defaultTextFormat = formatter;
      scaleText.text = scaleString;
      scaleText.autoSize = TextFieldAutoSize.LEFT;

      return scaleText;

    }

    private function calculateScaleValues(min:Number, max:Number):void{

      var minScale:int = Math.floor(min / tickSignificand / Math.pow(10, tickDigit));
      var maxScale:int = Math.ceil(max / tickSignificand / Math.pow(10, tickDigit));

      scaleValues = [];
      for (var num:int = minScale; num <= maxScale; ++num) {
	scaleValues.push(num * tickSignificand);
      }

    }

    private function calculateTickSize(min:Number, max:Number):void{

      var diff:Number = max <= min ? 1 : max - min;

      tickDigit = 0;
      while (diff >= 10) {
	diff /= 10;
	++tickDigit;
      }
      while (diff < 1) {
	diff *= 10;
	--tickDigit;
      }
      
      if (diff >= 5) {
	tickSignificand = 1;
      }
      else if (diff >= 2) {
	tickSignificand = 5;
	--tickDigit;
      }
      else {
	tickSignificand = 2;
	--tickDigit;
      }

      if (tickDigit < 0) {
	tickSignificand *= 0.1;
	++tickDigit;
      }
      else if (tickDigit < 3) {
	tickSignificand *= Math.pow(10, tickDigit);
	tickDigit = 0;
      }

    }

    public function getMinScaleValue():Number{

      return scaleValues[0] * Math.pow(10, tickDigit);

    }

    public function getMaxScaleValue():Number{

      return scaleValues[scaleValues.length - 1] * Math.pow(10, tickDigit);

    }

  }

}
