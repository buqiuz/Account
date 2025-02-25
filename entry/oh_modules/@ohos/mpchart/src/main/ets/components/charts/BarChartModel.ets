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

import { XAxis } from '../components/XAxis';
import { AxisDependency } from '../components/YAxis';
import BarData from '../data/BarData';
import BarEntry from '../data/BarEntry';
import MyRect from '../data/Rect';
import BarHighlighter from '../highlight/BarHighlighter';
import Highlight from '../highlight/Highlight';
import IHighlighter from '../highlight/IHighlighter';
import BarDataProvider from '../interfaces/dataprovider/BarDataProvider';
import IBarDataSet from '../interfaces/datasets/IBarDataSet';
import BarChartRenderer from '../renderer/BarChartRenderer';
import { LogUtil } from '../utils/LogUtil';
import Transformer from '../utils/Transformer';
import BarLineChartBase from './BarLineChartBaseModel';
import ChartModel from './ChartModel';

export default class BarChartModel extends BarLineChartBase<BarData> implements BarDataProvider {
  public context2d: CanvasRenderingContext2D | null = null;

  public invalidateHighlight() {
    this.invalidate();
  }

  public invalidate(): void {
    if (this.context2d) {
      super.onDraw(this.context2d);
    }
  }

  public setContext2D(context2d: CanvasRenderingContext2D) {
    this.context2d = context2d;
  }

  public onChartSizeChanged(newWidth: number, newHeight: number, oldWidth: number, oldHeight: number) {
    super.onSizeChanged(newWidth, newHeight, oldWidth, oldHeight);
  }

  public onDraw(c: CanvasRenderingContext2D): void {
    super.onDraw(c);
  }

  /**
   * flag that indicates whether the highlight should be full-bar oriented, or single-value?
   */
  protected mHighlightFullBarEnabled: boolean = false;
  /**
   * if set to true, all values are drawn above their bars, instead of below their top
   */
  private mDrawValueAboveBar: boolean = true;
  /**
   * if set to true, a grey area is drawn behind each bar that indicates the maximum value
   */
  private mDrawBarShadow: boolean = false;
  private mFitBars: boolean = false;

  public constructor() {
    super();
    this.init();
  }

  // @Override
  protected init(): void {
    super.init();

    this.mRenderer = new BarChartRenderer(this, this.mAnimator!, this.mViewPortHandler);

    this.setHighlighter(new BarHighlighter(this));

    let xAxis: XAxis | null = this.getXAxis();
    if (xAxis) {
      xAxis.setSpaceMin(0.5);
      xAxis.setSpaceMax(0.5);
    }
  }

  // @Override
  protected calcMinMax(): void {
    if (!this.mData) {
      return;
    }
    if (this.mXAxis) {
      if (this.mFitBars) {
        this.mXAxis.calculate(this.mData.getXMin() - this.mData.getBarWidth() / 2, this.mData.getXMax() + this.mData.getBarWidth() / 2);
      } else {
        this.mXAxis.calculate(this.mData.getXMin(), this.mData.getXMax());
      }
    }
    // calculate axis range (min / max) according to provided data
    if (this.mAxisLeft) {
      this.mAxisLeft.calculate(this.mData.getYMin(AxisDependency.LEFT), this.mData.getYMax(AxisDependency.LEFT));
    }
    if (this.mAxisRight) {
      this.mAxisRight.calculate(this.mData.getYMin(AxisDependency.RIGHT), this.mData.getYMax(AxisDependency.RIGHT));
    }
  }

  /**
   * Returns the Highlight object (contains x-index and DataSet index) of the selected value at the given touch
   * point
   * inside the BarChart.
   *
   * @param x
   * @param y
   * @return
   */
  // @Override
  public getHighlightByTouchPoint(x: number, y: number): Highlight | null {

    if (this.mData == null) {
      LogUtil.error(ChartModel.LOG_TAG, "Can't select by touch. No data set.");
      return null;
    } else {
      let highLighter: IHighlighter | null = this.getHighlighter();
      if (highLighter) {
        let h: Highlight | null = highLighter.getHighlight(x, y);
        if (h == null || !this.isHighlightFullBarEnabled()) {
          return h;
        }

        // For isHighlightFullBarEnabled, remove stackIndex
        return new Highlight(h.getX(), h.getY(), h.getDataSetIndex(), 0, -1,
          h.getXPx(), h.getYPx(), h.getAxis());
      } else {
        return null;
      }
    }
  }

  /**
   * Returns the bounding box of the specified Entry in the specified DataSet. Returns null if the Entry could not be
   * found in the charts data.  Performance-intensive code should use void getBarBounds(BarEntry, RectF) instead.
   *
   * @param e
   * @return
   */
  public getBarBoundsByEntry(e: BarEntry): MyRect {

    let bounds: MyRect = new MyRect();
    this.getBarBounds(e, bounds);

    return bounds;
  }

  /**
   * The passed outputRect will be assigned the values of the bounding box of the specified Entry in the specified DataSet.
   * The rect will be assigned Float.MIN_VALUE in all locations if the Entry could not be found in the charts data.
   *
   * @param e
   * @return
   */
  public getBarBounds(e: BarEntry, outputRect: MyRect): void {
    if (!this.mData) {
      return;
    }
    let bounds: MyRect = outputRect;

    let set: IBarDataSet | null = this.mData.getDataSetForEntry(e);

    if (!set) {
      bounds.set(Number.MIN_VALUE, Number.MIN_VALUE, Number.MIN_VALUE, Number.MIN_VALUE);
      return;
    }

    let y: number = e.getY();
    let x: number = e.getX();

    let barWidth: number = this.mData.getBarWidth();

    let left: number = x - barWidth / 2;
    let right: number = x + barWidth / 2;
    let top: number = y >= 0 ? y : 0;
    let bottom: number = y <= 0 ? y : 0;

    bounds.set(left, top, right, bottom);

    let transformer: Transformer | null = this.getTransformer(set.getAxisDependency());
    if (transformer) {
      transformer.rectValueToPixel(outputRect);
    }
  }

  /**
   * If set to true, all values are drawn above their bars, instead of below their top.
   *
   * @param enabled
   */
  public setDrawValueAboveBar(enabled: boolean): void {
    this.mDrawValueAboveBar = enabled;
  }

  /**
   * returns true if drawing values above bars is enabled, false if not
   *
   * @return
   */
  public isDrawValueAboveBarEnabled(): boolean {
    return this.mDrawValueAboveBar;
  }

  /**
   * If set to true, a grey area is drawn behind each bar that indicates the maximum value. Enabling his will reduce
   * performance by about 50%.
   *
   * @param enabled
   */
  public setDrawBarShadow(enabled: boolean): void {
    this.mDrawBarShadow = enabled;
  }

  /**
   * returns true if drawing shadows (maxvalue) for each bar is enabled, false if not
   *
   * @return
   */
  public isDrawBarShadowEnabled(): boolean {
    return this.mDrawBarShadow;
  }

  /**
   * Set this to true to make the highlight operation full-bar oriented, false to make it highlight single values (relevant
   * only for stacked). If enabled, highlighting operations will highlight the whole bar, even if only a single stack entry
   * was tapped.
   * Default: false
   *
   * @param enabled
   */
  public setHighlightFullBarEnabled(enabled: boolean): void {
    this.mHighlightFullBarEnabled = enabled;
  }

  /**
   * @return true the highlight operation is be full-bar oriented, false if single-value
   */
  // @Override
  public isHighlightFullBarEnabled(): boolean {
    return this.mHighlightFullBarEnabled;
  }

  /**
   * Highlights the value at the given x-value in the given DataSet. Provide
   * -1 as the dataSetIndex to undo all highlighting.
   *
   * @param x
   * @param dataSetIndex
   * @param stackIndex   the index inside the stack - only relevant for stacked entries
   */
  public highlightValue(x: number, dataSetIndex: number, stackIndex: number): void {
    this.highlightValueForObject(new Highlight(x, 0, dataSetIndex, 0, stackIndex, 0, 0, null), false);
  }

  // @Override
  public getBarData(): BarData | null {
    return this.mData;
  }

  /**
   * Adds half of the bar width to each side of the x-axis range in order to allow the bars of the barchart to be
   * fully displayed.
   * Default: false
   *
   * @param enabled
   */
  public setFitBars(enabled: boolean): void {
    this.mFitBars = enabled;
  }

  /**
   * Groups all BarDataSet objects this data object holds together by modifying the x-value of their entries.
   * Previously set x-values of entries will be overwritten. Leaves space between bars and groups as specified
   * by the parameters.
   * Calls notifyDataSetChanged() afterwards.
   *
   * @param fromX      the starting point on the x-axis where the grouping should begin
   * @param groupSpace the space between groups of bars in values (not pixels) e.g. 0.8f for bar width 1f
   * @param barSpace   the space between individual bars in values (not pixels) e.g. 0.1f for bar width 1f
   */
  public groupBars(fromX: number, groupSpace: number, barSpace: number): void {

    if (this.getBarData() == null) {
      throw new Error("You need to set data for the chart before grouping bars.");
    } else {
      let barData: BarData | null = this.getBarData();
      if (barData) {
        barData.groupBars(fromX, groupSpace, barSpace);
      }
      this.notifyDataSetChanged();
    }
  }
}
