/**
 * PlotLegendBox.as
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

  public class PlotLegendBox extends Sprite{

    public function PlotLegendBox(plotDataArray:Array){

      var formatter:TextFormat = new TextFormat();
      formatter.font = "Verdana";
      formatter.size = 12;

      for (var i:int = 0; i < plotDataArray.length; ++i) {
	var data:PlotData = plotDataArray[i];

	if (data.legend) {
	  var scaleText:TextField = new TextField();
	  scaleText.defaultTextFormat = formatter;
	  scaleText.text = data.legend;
	  scaleText.autoSize = TextFieldAutoSize.LEFT;
	  scaleText.x = 35;
	  scaleText.y = i * 20 + 5;
	  addChild(scaleText);
	}

	graphics.lineStyle(1, data.drawColor);

	switch (data.plotStyle) {

	case PlotStyle.WITH_LINES:
	  graphics.lineStyle(2, data.drawColor);
	  graphics.moveTo(10, i * 20 + 14);
	  graphics.lineTo(30, i * 20 + 14);
	  break;

	case PlotStyle.WITH_LINES_POINTS:
	  graphics.lineStyle(2, data.drawColor);
	  graphics.moveTo(10, i * 20 + 14);
	  graphics.lineTo(30, i * 20 + 14);
	  graphics.beginFill(data.drawColor);
	  graphics.drawCircle(20, i * 20 + 14, 3);
	  graphics.endFill();
	  break;

	case PlotStyle.WITH_POINTS:
	  graphics.beginFill(data.drawColor);
	  graphics.drawCircle(20, i * 20 + 14, 3);
	  graphics.endFill();
	  break;

	}
      }

      graphics.lineStyle(1);
      graphics.drawRect(0, 0, width + 20, plotDataArray.length * 20 + 10);

    }

  }
}
