/**
 * Plot.as
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
  import nz.charts.PlotScale;
  import nz.charts.PlotStyle;
  import nz.charts.PlotLegendBox;

  public class Plot extends Sprite{

    private var frame:Sprite;
    private var titleName:TextField;
    private var xAxisName:TextField;
    private var yAxisName:Bitmap;
    private var ratioX:Number;
    private var ratioY:Number;
    private var xAxisScale:PlotScale;
    private var yAxisScale:PlotScale;
    private var chartWidth:Number;
    private var chartHeight:Number;
    private var dataQueue:Array;
    private var radius:Number;
    private var legendBox:PlotLegendBox;
    private var showLegend_:Boolean;
    
    private const X_OFFSET:int = 70;
    private const Y_OFFSET:int = 50;
    private const RADIUS_RATIO:int = 200;
    private const TITLE_FONT_SIZE:int = 16;
    private const AXIS_TITLE_FONT_SIZE:int = 14;
    private const FONT_FAMILY:String = "Verdana";

    public function Plot(chartWidth:Number, chartHeight:Number){

      this.chartWidth = chartWidth;
      this.chartHeight = chartHeight;
      radius = (chartWidth > chartHeight) ? chartHeight / RADIUS_RATIO : chartWidth / RADIUS_RATIO; 
      dataQueue = [];

      graphics.lineStyle();
      graphics.drawRect(0, 0, chartWidth + X_OFFSET * 2, chartHeight + Y_OFFSET * 2);

      frame = createFrame();
      frame.x = X_OFFSET;
      frame.y = Y_OFFSET;
      addChild(frame);

      var titleFormat:TextFormat = new TextFormat();
      titleFormat.font = FONT_FAMILY;
      titleFormat.size = TITLE_FONT_SIZE;

      titleName = new TextField();
      titleName.defaultTextFormat = titleFormat;
      titleName.text = "";
      titleName.autoSize = TextFieldAutoSize.LEFT;
      titleName.x = width / 2;
      titleName.y = 20;
      addChild(titleName);
      
      var axisTitleFormat:TextFormat = new TextFormat();
      axisTitleFormat.font = FONT_FAMILY;
      axisTitleFormat.size = AXIS_TITLE_FONT_SIZE;

      xAxisName = new TextField();
      xAxisName.defaultTextFormat = axisTitleFormat;
      xAxisName.text = "";
      xAxisName.autoSize = TextFieldAutoSize.LEFT;
      xAxisName.x = width / 2;
      xAxisName.y = height - 25;
      addChild(xAxisName);

      yAxisName = new Bitmap();
      yAxisName.rotation = -90;
      yAxisName.x = 5;
      yAxisName.y = height / 2;
      addChild(yAxisName);

      showLegend_ = true;

    }

    public function setTitle(name:String):void{

      titleName.text = name;
      titleName.x = width / 2 - titleName.width / 2;

    }
    
    public function setXAxis(axisName:String):void{

      xAxisName.text = axisName;
      xAxisName.x = width / 2 - xAxisName.width / 2;

    }

    public function setYAxis(axisName:String):void{

      var axisText:TextField = new TextField();
      axisText.defaultTextFormat = xAxisName.defaultTextFormat;
      axisText.text = axisName;
      axisText.autoSize = TextFieldAutoSize.LEFT;
      var axisBitmapData:BitmapData = new BitmapData(axisText.width, axisText.height);
      axisBitmapData.draw(axisText);
      yAxisName.bitmapData = axisBitmapData;
      yAxisName.y = height / 2 + axisText.width / 2;
      addChild(yAxisName);

    }

    public function draw(data:PlotData):void{

      dataQueue.push(data);
      update();

    }

    private function update():void{

      if (dataQueue.length == 0) return;

      var totalMinX:Number = dataQueue[0].minX;
      var totalMaxX:Number = dataQueue[0].maxX;
      var totalMinY:Number = dataQueue[0].minY;
      var totalMaxY:Number = dataQueue[0].maxY;
      for (var i:int = 1; i < dataQueue.length; ++i) {
	totalMinX = Math.min(totalMinX, dataQueue[i].minX);
	totalMaxX = Math.max(totalMaxX, dataQueue[i].maxX);
	totalMinY = Math.min(totalMinY, dataQueue[i].minY);
	totalMaxY = Math.max(totalMaxY, dataQueue[i].maxY);
      }

      graphics.clear();
      graphics.lineStyle();
      if (legendBox) {
	removeChild(legendBox);
	legendBox = null;
      }
      if (showLegend_) {
	legendBox = new PlotLegendBox(dataQueue);
	legendBox.x = chartWidth + X_OFFSET * 1.5;
	legendBox.y = chartHeight / 2 + Y_OFFSET - legendBox.height / 2;
	addChild(legendBox);
	graphics.drawRect(0, 0, chartWidth + X_OFFSET * 2 + legendBox.width, chartHeight + Y_OFFSET * 2);
      }
      else {
	graphics.drawRect(0, 0, chartWidth + X_OFFSET * 2, chartHeight + Y_OFFSET * 2);
      }

      if (xAxisScale) {
	removeChild(xAxisScale);
	xAxisScale = null;
      }
      xAxisScale = new PlotScale(totalMinX, totalMaxX, chartWidth, PlotScale.HORIZONTAL);
      xAxisScale.x = frame.x;
      xAxisScale.y = frame.y + frame.height;
      addChild(xAxisScale); 

      if(yAxisScale) {
	removeChild(yAxisScale);
	yAxisScale = null;
      }
      yAxisScale = new PlotScale(totalMinY, totalMaxY, chartHeight, PlotScale.VERTICAL);
      yAxisScale.x = frame.x; 
      yAxisScale.y = frame.y;
      addChild(yAxisScale); 

      ratioX = chartWidth / (xAxisScale.getMaxScaleValue() - xAxisScale.getMinScaleValue());
      ratioY = chartHeight / (yAxisScale.getMaxScaleValue() - yAxisScale.getMinScaleValue());

      frame.graphics.clear();
      frame.graphics.lineStyle(2);
      frame.graphics.drawRect(0, 0, chartWidth, chartHeight);

      for (var j:int = 0; j < dataQueue.length; ++j) {
	var data:PlotData = dataQueue[j];

	switch (data.plotStyle) {

	case PlotStyle.WITH_LINES:
	  drawLines(data);
	  break;

	case PlotStyle.WITH_LINES_POINTS:
	  drawLines(data);
	  drawPoints(data);
	  break;

	case PlotStyle.WITH_POINTS:
	  drawPoints(data);
	  break;

	}

      }

    }

    private function drawPoints(data:PlotData):void{

      frame.graphics.lineStyle(1, data.drawColor);
      frame.graphics.beginFill(data.drawColor);
      frame.graphics.drawCircle((data.x(0) - xAxisScale.getMinScaleValue()) * ratioX,
				chartHeight - (data.y(0) - yAxisScale.getMinScaleValue()) * ratioY, radius);
      for (var i:int = 1; i < data.size(); ++i) {
	frame.graphics.drawCircle((data.x(i) - xAxisScale.getMinScaleValue()) * ratioX,
				  chartHeight - (data.y(i) - yAxisScale.getMinScaleValue()) * ratioY, radius);
      }
      frame.graphics.endFill();

    }
    
    private function drawLines(data:PlotData):void{

      frame.graphics.lineStyle(1, data.drawColor);
      frame.graphics.moveTo((data.x(0) - xAxisScale.getMinScaleValue()) * ratioX,
			    chartHeight - (data.y(0) - yAxisScale.getMinScaleValue()) * ratioY);
      for (var i:int = 1; i < data.size(); ++i) {
	frame.graphics.lineTo((data.x(i) - xAxisScale.getMinScaleValue()) * ratioX, 
			      chartHeight - (data.y(i) - yAxisScale.getMinScaleValue()) * ratioY);
      }
      frame.graphics.moveTo((data.x(0) - xAxisScale.getMinScaleValue()) * ratioX, 
			    chartHeight - (data.y(0) - yAxisScale.getMinScaleValue()) * ratioY);

    }

    private function createFrame():Sprite{

      var frameMask:Sprite = new Sprite();
      frameMask.graphics.lineStyle(1);
      frameMask.graphics.beginFill(0);
      frameMask.graphics.drawRect(0, 0, chartWidth, chartHeight);
      frameMask.graphics.endFill();

      var frame:Sprite = new Sprite();
      frame.addChild(frameMask);
      frame.mask = frameMask;
      frame.graphics.lineStyle(2);
      frame.graphics.drawRect(0, 0, chartWidth, chartHeight);

      return frame;

    }

    public function set showLegend(value:Boolean):void{
      showLegend_ = value;
      update();
    }

    public function get showLegend():Boolean{
      return showLegend_;
    }

  }

}
