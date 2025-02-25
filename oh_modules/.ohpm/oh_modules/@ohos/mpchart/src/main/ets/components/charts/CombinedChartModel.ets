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

import BarData from '../data/BarData';
import BubbleData from '../data/BubbleData';
import CandleData from '../data/CandleData';
import CombinedData from '../data/CombinedData';
import EntryOhos from '../data/EntryOhos';
import LineData from '../data/LineData';
import { ScatterData } from '../data/ScatterData';
import CombinedHighlighter from '../highlight/CombinedHighlighter';
import Highlight from '../highlight/Highlight';
import CombinedDataProvider from '../interfaces/dataprovider/CombinedDataProvider';
import IBarLineScatterCandleBubbleDataSet from '../interfaces/datasets/IBarLineScatterCandleBubbleDataSet';
import CombinedChartRenderer from '../renderer/CombinedChartRenderer';
import { LogUtil } from '../utils/LogUtil';
import BarLineChartBaseModel from './BarLineChartBaseModel';

export default class CombinedChartModel extends BarLineChartBaseModel<CombinedData> implements CombinedDataProvider {
  public context2d: CanvasRenderingContext2D | null = null;

  public invalidate(): void {
    if (this.context2d) {
      super.onDraw(this.context2d);
    }
  }

  public invalidateHighlight() {
    this.invalidate();
  }

  public setContext2D(context2d: CanvasRenderingContext2D) {
    this.context2d = context2d;
  }

  public onChartSizeChanged(newWidth: number, newHeight: number, oldWidth: number, oldHeight: number) {
    super.onSizeChanged(newWidth, newHeight, oldWidth, oldHeight);
  }

  /**
   * if set to true, all values are drawn above their bars, instead of below
   * their top
   */
  private mDrawValueAboveBar: boolean = true;
  /**
   * flag that indicates whether the highlight should be full-bar oriented, or single-value?
   */
  protected mHighlightFullBarEnabled: boolean = false;
  /**
   * if set to true, a grey area is drawn behind each bar that indicates the
   * maximum value
   */
  private mDrawBarShadow: boolean = false;
  protected mDrawOrder: DrawOrder[] = [];

  constructor() {
    super();
    this.init();
  }

  protected init(): void {
    super.init();

    // Default values are not ready here yet
    this.mDrawOrder = [DrawOrder.WATERFALL, DrawOrder.BAR, DrawOrder.BUBBLE, DrawOrder.LINE, DrawOrder.CANDLE, DrawOrder.SCATTER];

    this.setHighlighter(new CombinedHighlighter(this, this, this));

    // Old default behaviour
    this.setHighlightFullBarEnabled(true);

    if (this.mAnimator) {
      this.mRenderer = new CombinedChartRenderer(this, this.mAnimator, this.mViewPortHandler);
    }
  }

  // @Override
  public getCombinedData(): CombinedData | null {
    return this.mData;
  }

  // @Override
  public setData(data: CombinedData): void {
    super.setData(data);
    this.setHighlighter(new CombinedHighlighter(this as CombinedDataProvider, this, this));
    (this.mRenderer as CombinedChartRenderer).createRenderers();
    this.mRenderer?.initBuffers();
  }

  /**
   * Returns the Highlight object (contains x-index and DataSet index) of the selected value at the given touch
   * point
   * inside the CombinedChart.
   *
   * @param x
   * @param y
   * @return
   */
  // @Override
  public getHighlightByTouchPoint(x: number, y: number): Highlight | null {

    if (this.mData == null) {
      LogUtil.log("Can't select by touch. No data set.");
      return null;
    } else {
      let highlighter = this.getHighlighter();
      if (!highlighter) {
        return null
      }
      let h: Highlight | null = highlighter.getHighlight(x, y);
      if (h == null || !this.isHighlightFullBarEnabled()) return h;

      // For isHighlightFullBarEnabled, remove stackIndex
      return new Highlight(h.getX(), h.getY(),
        h.getDataSetIndex(), h.getDataIndex(), -1, h.getXPx(), h.getYPx(), h.getAxis());
    }
  }

  // @Override
  public getLineData(): LineData | null {
    if (this.mData == null)
      return null;
    return this.mData.getLineData();
  }

  // @Override
  public getBarData(): BarData | null {
    if (this.mData == null)
      return null;
    return this.mData.getBarData();
  }

  // @Override
  public getScatterData(): ScatterData | null {
    if (this.mData == null)
      return null;
    return this.mData.getScatterData();
  }

  // @Override
  public getCandleData(): CandleData | null {
    if (this.mData == null)
      return null;
    return this.mData.getCandleData();
  }

  // @Override
  public getBubbleData(): BubbleData | null {
    if (this.mData == null)
      return null;
    return this.mData.getBubbleData();
  }

  public getWaterfallData(): BarData | null {
    if (this.mData == null)
      return null;
    return this.mData.getWaterfallData();
  }

  // @Override
  public isDrawBarShadowEnabled(): boolean {
    return this.mDrawBarShadow;
  }

  // @Override
  public isDrawValueAboveBarEnabled(): boolean {
    return this.mDrawValueAboveBar;
  }

  /**
   * If set to true, all values are drawn above their bars, instead of below
   * their top.
   *
   * @param enabled
   */
  public setDrawValueAboveBar(enabled: boolean): void {
    this.mDrawValueAboveBar = enabled;
  }


  /**
   * If set to true, a grey area is drawn behind each bar that indicates the
   * maximum value. Enabling his will reduce performance by about 50%.
   *
   * @param enabled
   */
  public setDrawBarShadow(enabled: boolean): void {
    this.mDrawBarShadow = enabled;
  }

  /**
   * Set this to true to make the highlight operation full-bar oriented,
   * false to make it highlight single values (relevant only for stacked).
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
   * Returns the currently set draw order.
   *
   * @return
   */
  public getDrawOrder(): DrawOrder[] {
    return this.mDrawOrder;
  }

  /**
   * Sets the order in which the provided data objects should be drawn. The
   * earlier you place them in the provided array, the further they will be in
   * the background. e.g. if you provide new DrawOrer[] { DrawOrder.BAR,
   * DrawOrder.LINE }, the bars will be drawn behind the lines.
   *
   * @param order
   */
  public setDrawOrder(order: DrawOrder[]): void {
    if (order == null || order.length <= 0)
      return;
    this.mDrawOrder = order;
  }

  /**
   * draws all MarkerViews on the highlighted positions
   */
  protected drawMarkers(canvas: CanvasRenderingContext2D): void {

    // if there is no marker view or drawing marker is disabled
    if (this.mMarker == null || !this.isDrawMarkersEnabled() || !this.valuesToHighlight() || !this.mIndicesToHighlight)
      return;

    for (let i: number = 0; i < this.mIndicesToHighlight.length; i++) {

      let highlight: Highlight = this.mIndicesToHighlight[i];

      if (!this.mData) {
        continue;
      }
      let set: IBarLineScatterCandleBubbleDataSet<EntryOhos> | null = this.mData.getDataSetByHighlight(highlight);
      if (!set) {
        continue;
      }

      let e: EntryOhos | null = this.mData.getEntryForHighlight(highlight);
      if (e == null)
        continue;

      let entryIndex: number = set.getEntryIndexByEntry(e);

      if (!this.mAnimator) {
        continue;
      }
      // make sure entry not null
      if (entryIndex > set.getEntryCount() * this.mAnimator.getPhaseX())
        continue;

      let pos: number[] = this.getMarkerPosition(highlight);

      // check bounds
      if (!this.mViewPortHandler.isInBounds(pos[0], pos[1]))
        continue;

      // callbacks to update the content
      // this.mMarker.refreshContent(e, highlight);

      // draw the marker
      this.mMarker.draw(canvas, pos[0], pos[1], e, highlight);
    }
  }
}

enum DrawOrder {
  WATERFALL, BAR, BUBBLE, LINE, CANDLE, SCATTER
}
