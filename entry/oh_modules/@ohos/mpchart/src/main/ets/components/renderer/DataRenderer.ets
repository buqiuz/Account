/*
 * Copyright (C) 2022 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import Highlight from '../highlight/Highlight';
import EntryOhos from '../data/EntryOhos';
import Renderer from '../renderer/Renderer';
import ChartAnimator from '../animation/ChartAnimator';
import Paint, { Style } from '../data/Paint';
import ViewPortHandler from '../utils/ViewPortHandler';
import IDataSet from '../interfaces/datasets/IDataSet';
import ChartInterface from '../interfaces/dataprovider/ChartInterface';
import IValueFormatter from '../formatter/IValueFormatter';
import Utils from '../utils/Utils';

/**
 * Superclass of all render classes for the different data types (line, bar, ...).
 *
 *
 */
export default abstract class DataRenderer extends Renderer {
  /**
   * the animator object used to perform animations on the chart data
   */
  protected mAnimator: ChartAnimator | null = null;
  /**
   * main paint object used for rendering
   */
  protected mRenderPaint: Paint = new Paint();
  // protected mPathPaint:PathPaint = new PathPaint();

  /**
   * paint used for highlighting values
   */
  protected mHighlightPaint: Paint = new Paint();
  protected mDrawPaint: Paint = new Paint();
  /**
   * paint object for drawing values (text representing values of chart
   * entries)
   */
  public mValuePaint: Paint = new Paint();

  constructor(animator: ChartAnimator, viewPortHandler: ViewPortHandler) {
    super(viewPortHandler);
    if (animator) {
      this.mAnimator = animator;
    }

    this.mRenderPaint = new Paint();
    this.mRenderPaint.setStyle(Style.FILL);

    this.mDrawPaint = new Paint();

    this.mValuePaint = new Paint();

    // this.mValuePaint.setColor(ChartColor.rgb(63, 63, 63));
    this.mValuePaint.setColor('#3F3F3F');
    this.mValuePaint.setTextAlign('center');
    this.mValuePaint.setTextSize(9);

    this.mHighlightPaint = new Paint();
    this.mHighlightPaint.setStyle(Style.STROKE);
    this.mHighlightPaint.setStrokeWidth(2);
    this.mHighlightPaint.setColor('#FFBB73');
  }

  protected isDrawingValuesAllowed(chart: ChartInterface): boolean {
    let chartData = chart.getData();
    if (this.mViewPortHandler && chartData) {
      return chartData.getEntryCount() < chart.getMaxVisibleCount()
      * this.mViewPortHandler.getScaleX();
    }
    return false;
  }

  /**
   * Returns the Paint object this renderer uses for drawing the values
   * (value-text).
   *
   * @return
   */
  public getPaintValues(): Paint {
    return this.mValuePaint;
  }

  /**
   * Returns the Paint object this renderer uses for drawing highlight
   * indicators.
   *
   * @return
   */
  public getPaintHighlight(): Paint {
    return this.mHighlightPaint;
  }

  /**
   * Returns the Paint object used for rendering.
   *
   * @return
   */
  public getPaintRender(): Paint {
    return this.mRenderPaint;
  }

  // public getPathPaint():PathPaint {
  //   return this.mPathPaint;
  // }

  /**
   * Applies the required styling (provided by the DataSet) to the value-paint
   * object.
   *
   * @param set
   */
  protected applyValueTextStyle(dateSet: IDataSet<EntryOhos>) {

    if (dateSet.getValueTypeface()) {
      this.mValuePaint.setFontFamily(dateSet.getValueTypeface() !);
    }
    this.mValuePaint.setTextSize(dateSet.getValueTextSize());
  }

  /**
   * Initializes the buffers used for rendering with a new size. Since this
   * method performs memory allocations, it should only be called if
   * necessary.
   */
  public abstract initBuffers();


  /**
   * Draws the actual data in form of lines, bars, ... depending on Renderer subclass.
   *
   * @param c
   */
  public abstract drawData(c: CanvasRenderingContext2D): void;

  /**
   * Loops over all Entries and draws their values.
   *
   * @param c
   */
  public abstract drawValues(c: CanvasRenderingContext2D, isHorizontalFlip?: boolean): void;

  /**
   * Draws the value of the given entry by using the provided IValueFormatter.
   *
   * @param c            canvas
   * @param formatter    formatter for custom value-formatting
   * @param value        the value to be drawn
   * @param entry        the entry the value belongs to
   * @param dataSetIndex the index of the DataSet the drawn Entry belongs to
   * @param x            position
   * @param y            position
   * @param color
   */
  public drawValue(c: CanvasRenderingContext2D, formatter: IValueFormatter, value: number, entry: EntryOhos, dataSetIndex: number, x: number, y: number, color: number, isHorizontalFlip: boolean = false): void {
    if (isHorizontalFlip) {
      c.save();
      c.scale(-1, 1);
    }
    this.mValuePaint.setColor(color);
    Utils.resetContext2DWithoutLine(c, this.mValuePaint);
    switch (this.mValuePaint.getStyle()) {
      case Style.STROKE:
        c.beginPath();
        if (this.mViewPortHandler) {
          if (isHorizontalFlip) {
            c.strokeText(formatter.getFormattedValue(value, entry, dataSetIndex, this.mViewPortHandler), -x, y);
          } else {
            c.strokeText(formatter.getFormattedValue(value, entry, dataSetIndex, this.mViewPortHandler), x, y);
          }
        }
        c.closePath();
        break;
      case Style.FILL:
      case Style.FILL_AND_STROKE:
      default:
        c.beginPath();
        if (this.mViewPortHandler) {
          if (isHorizontalFlip) {
            c.fillText(formatter.getFormattedValue(value, entry, dataSetIndex, this.mViewPortHandler), -x, y);
          } else {
            c.fillText(formatter.getFormattedValue(value, entry, dataSetIndex, this.mViewPortHandler), x, y);
          }
        }
        c.closePath();
        break;
    }
    if (isHorizontalFlip) {
      c.restore();
    }
    // this.mValuePaint.setColor(color);
    // let textPaint = new TextPaint();
    // textPaint.set(this.mValuePaint);
    // if (this.mViewPortHandler) {
    //   textPaint.setText(formatter.getFormattedValue(value, entry, dataSetIndex, this.mViewPortHandler));
    // }
    // textPaint.setX(x)
    // textPaint.setY(y)
    // return [textPaint]
  }

  /**
   * Draws any kind of additional information (e.g. line-circles).
   *
   * @param c
   */
  public abstract drawExtras(c: CanvasRenderingContext2D): void;

  /**
   * Draws all highlight indicators for the values that are currently highlighted.
   *
   * @param c
   * @param indices the highlighted values
   */
  public abstract drawHighlighted(c: CanvasRenderingContext2D, indices: Highlight[], isDraw?:boolean): void;
}
