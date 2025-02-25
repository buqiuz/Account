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

import YAxis, { AxisDependency } from '../components/YAxis';
import RadarData from '../data/RadarData';
import MyRect from '../data/Rect';
import RadarHighlighter from '../highlight/RadarHighlighter';
import RadarChartRenderer from '../renderer/RadarChartRenderer';
import XAxisRendererRadarChart from '../renderer/XAxisRendererRadarChart';
import YAxisRendererRadarChart from '../renderer/YAxisRendererRadarChart';
import Utils from '../utils/Utils';
import PieRadarChartBase from './PieRadarChartBaseModel';
import { ChartColor } from '../utils/ColorTemplate';
import CanvasUtil from '../utils/CanvasUtil';

export default class RadarChartModel extends PieRadarChartBase<RadarData> {
  public context2d: CanvasRenderingContext2D | null = null;

  constructor() {
    super();
    this.init();
  }

  public invalidate() {
    if (this.context2d) {
      this.onDraw(this.context2d);
    }
  }

  public invalidateHighlight() {
    this.invalidate();
  }

  public setContext2D(context2d: CanvasRenderingContext2D) {
    this.context2d = context2d
  }

  public onChartSizeChanged(newWidth: number, newHeight: number, oldWidth: number, oldHeight: number) {
    super.onSizeChanged(newWidth, newHeight, oldWidth, oldHeight);
  }

  /**
   * width of the main web lines
   */
  private mWebLineWidth: number = 2.5;
  /**
   * width of the inner web lines
   */
  private mInnerWebLineWidth: number = 1.5;
  /**
   * color for the main web lines
   */
  private mWebColor: number = ChartColor.rgb(122, 122, 122);
  /**
   * color for the inner web
   */
  private mWebColorInner: number = ChartColor.rgb(122, 122, 122);
  /**
   * transparency the grid is drawn with (0-255)
   */
  private mWebAlpha: number = 150;
  /**
   * flag indicating if the web lines should be drawn or not
   */
  private mDrawWeb: boolean = true;
  /**
   * modulus that determines how many labels and web-lines are skipped before the next is drawn
   */
  private mSkipWebLineCount: number = 0;
  /**
   * the object representing the y-axis labels
   */
  private mYAxis: YAxis = new YAxis(AxisDependency.LEFT);
  protected mYAxisRenderer: YAxisRendererRadarChart = new YAxisRendererRadarChart(this.mViewPortHandler, this.mYAxis, this);
  protected mXAxisRenderer: XAxisRendererRadarChart | null = null;

  protected init() {
    super.init();

    this.mYAxis = new YAxis(AxisDependency.LEFT);
    this.mYAxis.setLabelXOffset(10);

    this.mWebLineWidth = Utils.handleDataValues(1.5);
    this.mInnerWebLineWidth = Utils.handleDataValues(0.75);

    if (this.mAnimator) {
      this.mRenderer = new RadarChartRenderer(this, this.mAnimator, this.mViewPortHandler);
    }
    this.mYAxisRenderer = new YAxisRendererRadarChart(this.mViewPortHandler, this.mYAxis, this, undefined);
    if (this.mXAxis) {
      this.mXAxisRenderer = new XAxisRendererRadarChart(this.mViewPortHandler, this.mXAxis, this, undefined);
    }

    this.mHighlighter = new RadarHighlighter(this);
  }

  public calcMinMax(): void {
    super.calcMinMax();
    if (!this.mData || !this.mData.getMaxEntryCountSet()) {
      return;
    }
    this.mYAxis.calculate(this.mData.getYMin(AxisDependency.LEFT), this.mData.getYMax(AxisDependency.LEFT));
    this.mYAxis.calculate(0, this.mData.getMaxEntryCountSet()!.getEntryCount());
  }

  public notifyDataSetChanged(): void {
    if (this.mData == null)
      return;

    this.calcMinMax();

    if (this.mYAxis) {
      this.mYAxisRenderer?.computeAxis(this.mYAxis.mAxisMinimum, this.mYAxis.mAxisMaximum, this.mYAxis.isInverted());
    }
    if (this.mXAxis) {
      this.mXAxisRenderer?.computeAxis(this.mXAxis.mAxisMinimum, this.mXAxis.mAxisMaximum, false);
    }

    if (this.mLegend != null && !this.mLegend.isLegendCustom())
      this.mLegendRenderer?.computeLegend(this.mData);

    this.calculateOffsets();
  }

  public onDraw(canvas: CanvasRenderingContext2D) {
    super.onDraw(canvas);

    if (this.mData == null) {
      return;
    }
    // if (this.mYAxis.isEnabled())
    //    this.mYAxisRenderer.computeAxis(this.mYAxis.mAxisMinimum, this.mYAxis.mAxisMaximum, this.mYAxis.isInverted());
    CanvasUtil.clearCanvas(canvas);
    if (this.mXAxis && this.mXAxis.isEnabled() && this.mXAxisRenderer)
      this.mXAxisRenderer.computeAxis(this.mXAxis.mAxisMinimum, this.mXAxis.mAxisMaximum, false);

    this.mXAxisRenderer?.renderAxisLabels(canvas);

    if (this.mDrawWeb)
      this.mRenderer?.drawExtras(canvas);

    if (this.mYAxis.isEnabled() && this.mYAxis.isDrawLimitLinesBehindDataEnabled())
      this.mYAxisRenderer.renderLimitLines(canvas);

    this.mRenderer?.drawData(canvas);

    if (this.valuesToHighlight() && this.mIndicesToHighlight)
      this.mRenderer?.drawHighlighted(canvas, this.mIndicesToHighlight);

    if (this.mYAxis.isEnabled() && !this.mYAxis.isDrawLimitLinesBehindDataEnabled())
      this.mYAxisRenderer.renderLimitLines(canvas);

    this.mYAxisRenderer.renderAxisLabels(canvas);

    this.mRenderer?.drawValues(canvas);

    this.mLegendRenderer?.renderLegend(canvas);

    this.drawDescription(canvas);

    this.drawMarkers(canvas);
  }

  /**
   * Returns the factor that is needed to transform values into pixels.
   *
   * @return
   */
  public getFactor(): number {
    let content: MyRect = this.mViewPortHandler.getContentRect();
    return Math.min(content.width() / 2, content.height() / 2) / this.mYAxis.mAxisRange * 0.7;
  }

  public getSliceAngle(): number {
    if (!this.mData || !this.mData.getMaxEntryCountSet()) {
      return 0;
    }
    return 360 / this.mData.getMaxEntryCountSet()!.getEntryCount();
  }

  public getIndexForAngle(angle: number): number {
    if (!this.mData || !this.mData.getMaxEntryCountSet()) {
      return 0;
    }
    // take the current angle of the chart into consideration
    let a: number = Utils.getNormalizedAngle(angle - this.getRotationAngle());

    let sliceangle: number = this.getSliceAngle();

    let max: number = this.mData.getMaxEntryCountSet()!.getEntryCount();

    let index = 0;

    for (let i = 0; i < max; i++) {

      let referenceAngle = sliceangle * (i + 1) - sliceangle / 2;

      if (referenceAngle > a) {
        index = i;
        break;
      }
    }
    return index;
  }

  /**
   * Returns the object that represents all y-labels of the RadarChart.
   *
   * @return
   */
  public getYAxis(): YAxis {
    return this.mYAxis;
  }

  /**
   * Sets the width of the web lines that come from the center.
   *
   * @param width
   */
  public setWebLineWidth(width: number): void {
    this.mWebLineWidth = Utils.handleDataValues(width);
  }

  public getWebLineWidth(): number {
    return this.mWebLineWidth;
  }

  /**
   * Sets the width of the web lines that are in between the lines coming from
   * the center.
   *
   * @param width
   */
  public setWebLineWidthInner(width: number): void {
    this.mInnerWebLineWidth = Utils.handleDataValues(width);
  }

  public getWebLineWidthInner(): number {
    return this.mInnerWebLineWidth;
  }

  /**
   * Sets the transparency (alpha) value for all web lines, default: 150, 255
   * = 100% opaque, 0 = 100% transparent
   *
   * @param alpha
   */
  public setWebAlpha(alpha: number): void {
    this.mWebAlpha = alpha;
  }

  /**
   * Returns the alpha value for all web lines.
   *
   * @return
   */
  public getWebAlpha(): number {
    return this.mWebAlpha;
  }

  /**
   * Sets the color for the web lines that come from the center. Don't forget
   * to use getResources().getColor(...) when loading a color from the
   * resources. Default: Color.rgb(122, 122, 122)
   *
   * @param color
   */
  public setWebColor(color: number) {
    this.mWebColor = color;
  }

  public getWebColor() {
    return this.mWebColor;
  }

  /**
   * Sets the color for the web lines in between the lines that come from the
   * center. Don't forget to use getResources().getColor(...) when loading a
   * color from the resources. Default: Color.rgb(122, 122, 122)
   *
   * @param color
   */
  public setWebColorInner(color: number) {
    this.mWebColorInner = color;
  }

  public getWebColorInner(): number {
    return this.mWebColorInner;
  }

  /**
   * If set to true, drawing the web is enabled, if set to false, drawing the
   * whole web is disabled. Default: true
   *
   * @param enabled
   */
  public setDrawWeb(enabled: boolean) {
    this.mDrawWeb = enabled;
  }

  /**
   * Sets the number of web-lines that should be skipped on chart web before the
   * next one is drawn. This targets the lines that come from the center of the RadarChart.
   *
   * @param count if count = 1 -> 1 line is skipped in between
   */

  public setSkipWebLineCount(count: number) {
    this.mSkipWebLineCount = Math.max(0, count);
  }

  /**
   * Returns the modulus that is used for skipping web-lines.
   *
   * @return
   */
  public getSkipWebLineCount() {
    return this.mSkipWebLineCount;
  }

  protected getRequiredLegendOffset(): number {
    if (this.mLegendRenderer) {
      return this.mLegendRenderer.getLabelPaint().getTextSize() * 4;
    }
    return 0;
  }

  protected getRequiredBaseOffset(): number {
    if (!this.mXAxis) {
      return Utils.handleDataValues(10);
    }
    return this.mXAxis.isEnabled() && this.mXAxis.isDrawLabelsEnabled() ?
    this.mXAxis.mLabelRotatedWidth :
    Utils.handleDataValues(10);
  }

  getRadius(): number {
    let content: MyRect = this.mViewPortHandler.getContentRect();
    return Math.min(content.width() / 2, content.height() / 2);
  }

  /**
   * Returns the maximum value this chart can display on it's y-axis.
   */
  public getYChartMax(): number {
    return this.mYAxis.mAxisMaximum;
  }

  /**
   * Returns the minimum value this chart can display on it's y-axis.
   */
  public getYChartMin(): number {
    return this.mYAxis.mAxisMinimum;
  }

  /**
   * Returns the range of y-values this chart can display.
   *
   * @return
   */
  public getYRange(): number {
    return this.mYAxis.mAxisRange;
  }
}


