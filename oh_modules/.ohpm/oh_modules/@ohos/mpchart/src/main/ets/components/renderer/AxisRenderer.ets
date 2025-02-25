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

import AxisBase from '../components/AxisBase'
import Renderer from '../renderer/Renderer'
import Paint, { Style } from '../data/Paint'
import Utils from '../utils/Utils'
import Transformer from '../utils/Transformer'
import ViewPortHandler from '../utils/ViewPortHandler'
import MPPointD from '../utils/MPPointD'

/**
 * Baseclass of all axis renderers.
 *
 */
export default abstract class AxisRenderer extends Renderer {
  /** base axis this axis renderer works with */
  protected mAxis: AxisBase | null = null;
  /** transformer to transform values to screen pixels and return */
  protected mTrans: Transformer | null = null;
  /**
   * paint object for the grid lines
   */
  protected mGridPaint: Paint = new Paint();
  /**
   * paint for the x-label values
   */
  protected mAxisLabelPaint: Paint = new Paint();
  /**
   * paint for the line surrounding the chart
   */
  protected mAxisLinePaint: Paint = new Paint();
  /**
   * paint used for the limit lines
   */
  protected mLimitLinePaint: Paint = new Paint();

  constructor(viewPortHandler: ViewPortHandler, axis: AxisBase, trans?: Transformer) {
    super(viewPortHandler)
    this.mTrans = trans ? trans : null;
    this.mAxis = axis;

    if (this.mViewPortHandler != null) {
      this.mAxisLabelPaint = new Paint();

      this.mGridPaint = new Paint();
      this.mGridPaint.setColor(Color.Gray);
      this.mGridPaint.setStrokeWidth(1);
      this.mGridPaint.setStyle(Style.STROKE);
      this.mGridPaint.setGlobalAlpha(90 / 255);

      this.mAxisLinePaint = new Paint();
      this.mAxisLinePaint.setColor(Color.Black)
      this.mAxisLinePaint.setStrokeWidth(1)
      this.mAxisLinePaint.setStyle(Style.STROKE)

      this.mLimitLinePaint = new Paint();
      this.mLimitLinePaint.setStyle(Style.STROKE)
    }
  }

  /**
   * Returns the Paint object used for drawing the axis (labels).
   *
   * @return
   */
  public getPaintAxisLabels(): Paint {
    return this.mAxisLabelPaint;
  }


  /**
   * Returns the Paint object that is used for drawing the grid-lines of the
   * axis.
   *
   * @return
   */
  public getPaintGrid(): Paint {
    return this.mGridPaint;
  }

  /**
   * Returns the Paint object that is used for drawing the axis-line that goes
   * alongside the axis.
   *
   * @return
   */
  public getPaintAxisLine(): Paint {
    return this.mAxisLinePaint;
  }

  /**
   * Returns the Transformer object used for transforming the axis values.
   *
   * @return
   */
  public getTransformer(): Transformer | null {
    return this.mTrans;
  }


  /**
   * Computes the axis values.
   *
   * @param min - the minimum value in the data object for this axis
   * @param max - the maximum value in the data object for this axis
   */
  public computeAxis(min: number, max: number, inverted: boolean) {

    // calculate the starting and entry point of the y-labels (depending on
    // zoom / contentrect bounds)
    if (this.mTrans && this.mViewPortHandler != null && this.mViewPortHandler.contentWidth() > 10 && !this.mViewPortHandler.isFullyZoomedOutY()) {

      let p1: MPPointD | undefined = this.mTrans.getValuesByTouchPoint(this.mViewPortHandler.contentLeft(), this.mViewPortHandler.contentTop());
      let p2: MPPointD | undefined = this.mTrans.getValuesByTouchPoint(this.mViewPortHandler.contentLeft(), this.mViewPortHandler.contentBottom());

      if (!!p1 && !!p2) {
        if (!inverted) {

          min = p2.y;
          max = p1.y;
        } else {

          min = p1.y;
          max = p2.y;
        }

        MPPointD.recycleInstance(p1);
        MPPointD.recycleInstance(p2);
      }
    }

    this.computeAxisValues(min, max);
  }

  /**
   * Sets up the axis values. Computes the desired number of labels between the two given extremes.
   *
   * @return
   */
  protected computeAxisValues(min: number, max: number) {
    let yMin = min;
    let yMax = max;

    if (this.mAxis) {
      let labelCount = this.mAxis.getLabelCount();
      let range = Math.abs(yMax - yMin);

      if (labelCount == 0 || range <= 0 || range == Number.POSITIVE_INFINITY) {
        this.mAxis.mEntries = new Array<number>();
        this.mAxis.mCenteredEntries = new Array<number>();
        this.mAxis.mEntryCount = 0;
        return;
      }

      // Find out how much spacing (in y value space) between axis values
      let rawInterval: number = range / labelCount;
      let interval: number = Utils.roundToNextSignificant(rawInterval);

      // If granularity is enabled, then do not allow the interval to go below specified granularity.
      // This is used to avoid repeated values when rounding values for display.
      if (this.mAxis.isGranularityEnabled())
        interval = interval < this.mAxis.getGranularity() ? this.mAxis.getGranularity() : interval;

      // Normalize interval
      let intervalMagnitude = Utils.roundToNextSignificant(Math.pow(10, Math.floor(Math.log10(interval))));
      let intervalSigDigit = Math.floor((interval / intervalMagnitude));
      if (intervalSigDigit > 5) {
        // Use one order of magnitude higher, to avoid intervals like 0.9 or 90
        // if it's 0.0 after floor(), we use the old value
        interval = Math.floor(10.0 * intervalMagnitude) == 0.0
          ? interval
          : Math.floor(10.0 * intervalMagnitude);

      }

      let n = this.mAxis.isCenterAxisLabelsEnabled() ? 1 : 0;

      // force label count
      if (this.mAxis.isForceLabelsEnabled()) {

        interval = range / (labelCount - 1);
        this.mAxis.mEntryCount = labelCount;

        if (this.mAxis.mEntries.length < labelCount) {
          // Ensure stops contains at least numStops elements.
          this.mAxis.mEntries = new Array<number>(labelCount);
        }

        let v = min;

        for (let i = 0; i < labelCount; i++) {
          this.mAxis.mEntries[i] = v;
          v += interval;
        }

        n = labelCount;

        // no forced count
      } else {

        let first = interval == 0.0 ? 0.0 : Math.ceil(yMin / interval) * interval;
        if (this.mAxis.isCenterAxisLabelsEnabled()) {
          first -= interval;
        }

        let last = interval == 0.0 ? 0.0 : Utils.nextUp(Math.floor(yMax / interval) * interval);

        let f: number = 0;
        let i: number = 0;

        if (interval != 0.0 && last != first) {
          for (f = first; f <= last; f += interval) {
            ++n;
          }
        }
        else if (last == first && n == 0) {
          n = 1;
        }

        this.mAxis.mEntryCount = n;

        if (this.mAxis.mEntries.length < n) {
          // Ensure stops contains at least numStops elements.
          this.mAxis.mEntries = new Array<number>(n);
        }

        for (f = first, i = 0; i < n; f += interval, ++i) {

          if (f == 0.0) // Fix for negative zero case (Where value == -0.0, and 0.0 == -0.0)
            f = 0.0;

          this.mAxis.mEntries[i] = f;
        }
      }

      // set decimals
      if (interval < 1) {
        this.mAxis.mDecimals = Math.floor(Math.ceil(-Math.log10(interval)));
      } else {
        this.mAxis.mDecimals = 0;
      }

      if (this.mAxis.isCenterAxisLabelsEnabled()) {

        if (this.mAxis.mCenteredEntries.length < n) {
          this.mAxis.mCenteredEntries = new Array<number>(n);
        }

        let offset: number = interval / 2;

        for (let i = 0; i < n; i++) {
          this.mAxis.mCenteredEntries[i] = this.mAxis.mEntries[i] + offset;
        }
      }
    }
  }

  /**
   * Draws the axis labels to the screen.
   *
   * @param c
   */
  public abstract renderAxisLabels(c: CanvasRenderingContext2D, isHorizontalFlip: boolean, isLeftAxis: boolean): void;

  /**
   * Draws the grid lines belonging to the axis.
   *
   * @param c
   */
  public abstract renderGridLines(c: CanvasRenderingContext2D): void;

  /**
   * Draws the line that goes alongside the axis.
   *
   * @param c
   */
  public abstract renderAxisLine(c: CanvasRenderingContext2D, extraLine?: number): void;

  /**
   * Draws the LimitLines associated with this axis to the screen.
   *
   * @param c
   */
  public abstract renderLimitLines(c: CanvasRenderingContext2D, isHorizontalFlip: boolean): void;
}
