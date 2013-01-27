/**
 * PlotData.as
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

  import nz.charts.PlotStyle;

  public class PlotData{
    
    private var xArray:Array;
    private var yArray:Array;
    private var _minX:Number;
    private var _minY:Number;
    private var _maxX:Number;
    private var _maxY:Number;
    public var plotStyle:String;
    public var drawColor:uint;
     public var legend:String;

    public function PlotData(){
      xArray = [];
      yArray = [];
      _minX = _minY = _maxX = _maxY = 0;
      plotStyle = PlotStyle.WITH_LINES;
      drawColor = 0x000000;
    }

    public function push(x:Number, y:Number):void{
      if(xArray.length == 0){
	_minX = _maxX = x;
	_minY = _maxY = y;
      }else{
	_minX = Math.min(_minX, x);
	_maxX = Math.max(_maxX, x);
	_minY = Math.min(_minY, y);
	_maxY = Math.max(_maxY, y);
      }
      xArray.push(x);
      yArray.push(y);
    }

    public function x(index:int):Number{
      if(index < 0 || index >= xArray.length) return NaN;
      return xArray[index];
    }

    public function y(index:int):Number{
      if(index < 0 || index >= yArray.length) return NaN;
      return yArray[index];
    }

    public function size():int{
      return xArray.length;
    }

    public function get minX():Number{
      return _minX;
    }

    public function get maxX():Number{
      return _maxX;
    }

    public function get minY():Number{
      return _minY;
    }

    public function get maxY():Number{
      return _maxY;
    }

  }

}
