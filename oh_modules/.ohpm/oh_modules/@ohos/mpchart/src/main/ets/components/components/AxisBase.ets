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

import { DashPathEffect } from '../data/Paint';
import Utils from '../utils/Utils';
import { JArrayList } from '../utils/JArrayList';
import DefaultAxisValueFormatter from '../formatter/DefaultAxisValueFormatter';
import IAxisValueFormatter from '../formatter/IAxisValueFormatter';
import ComponentBase from './ComponentBase';
import LimitLine from './LimitLine';
import { GridLineConfig } from '../interfaces/LineConfig/CustomGridLineConfig';
import { LogUtil } from '../utils/LogUtil';
import HashMap from '@ohos.util.HashMap';

/**
 * Base-class of all axes (previously called labels).
 */
export default abstract class AxisBase extends ComponentBase {
  /**
   * custom formatter that is used instead of the auto-formatter if set
   */
  protected mAxisValueFormatter: IAxisValueFormatter | null = null;
  private mGridColor: number = Color.Gray;
  private mGridAlpha: number = 90;
  private mGridLineWidth: number = 1;
  private mAxisLineColor: number = Color.Gray;
  private mAxisLineWidth: number = 1;
  /**
   * the actual array of entries
   */
  public mEntries: number[] = [];
  /**
   * axis label entries only used for centered labels
   */
  public mCenteredEntries: number[] = [];
  /**
   * the number of entries the legend contains
   */
  public mEntryCount: number = 0;
  /**
   * the number of decimal digits to use
   */
  public mDecimals: number = 0;
  /**
   * the number of label entries the axis should have, default 6
   */
  private mLabelCount: number = 6;
  /**
   * the minimum interval between axis values
   */
  protected mGranularity: number = 1.0;
  /**
   * When true, axis labels are controlled by the `granularity` property.
   * When false, axis values could possibly be repeated.
   * This could happen if two adjacent axis values are rounded to same value.
   * If using granularity this could be avoided by having fewer axis values visible.
   */
  protected mGranularityEnabled: boolean = false;
  /**
   * if true, the set number of y-labels will be forced
   */
  protected mForceLabels: boolean = false;
  /**
   * flag indicating if the grid lines for this axis should be drawn
   */
  protected mDrawGridLines: boolean = true;
  /**
   * flag that indicates if the line alongside the axis is drawn or not
   */
  protected mDrawAxisLine: boolean = true;
  /**
   * flag that indicates of the labels of this axis should be drawn or not
   */
  protected mDrawLabels: boolean = true;
  protected mCenterAxisLabels: boolean = false;
  /**
   * the path effect of the axis line that makes dashed lines possible
   */
  private mAxisLineDashPathEffect: DashPathEffect | null
    = null;
  /**
   * the path effect of the grid lines that makes dashed lines possible
   */
  private mGridDashPathEffect: DashPathEffect | null
    = null;
  /**
   * array of limit lines that can be set for the axis
   */
  protected mLimitLines: JArrayList<LimitLine>;
  /**
   * array of custom grid lines that can be set for the axis
   */
  protected mGridLines: JArrayList<LimitLine>;
  /**
   * flag indicating the limit lines layer depth
   */
  protected mDrawLimitLineBehindData: boolean = false;
  /**
   * flag indicating the grid lines layer depth
   */
  protected mDrawGridLinesBehindData: boolean = true;
  /**
   * Extra spacing for `axisMinimum` to be added to automatically calculated `axisMinimum`
   */
  protected mSpaceMin: number = 0;
  /**
   * Extra spacing for `axisMaximum` to be added to automatically calculated `axisMaximum`
   */
  protected mSpaceMax: number = 0;
  /**
   * flag indicating that the axis-min value has been customized
   */
  protected mCustomAxisMin: boolean = false;
  /**
   * flag indicating that the axis-max value has been customized
   */
  protected mCustomAxisMax: boolean = false;
  /**
   * don't touch this directly, use setter
   */
  public mAxisMaximum: number = 0;
  /**
   * don't touch this directly, use setter
   */
  public mAxisMinimum: number = 0;
  /**
   * the total range of values this axis covers
   */
  public mAxisRange: number = 0;
  private mAxisMinLabels: number = 2;
  private mAxisMaxLabels: number = 25;

  textSizeCache: HashMap<string, TextMetrics> = new HashMap();

  /**
   * The minimum number of labels on the axis
   */
  public getAxisMinLabels(): number {
    return this.mAxisMinLabels;
  }

  /**
   * The minimum number of labels on the axis
   */
  public setAxisMinLabels(labels: number): void {
    if (labels > 0)
      this.mAxisMinLabels = labels;
  }

  /**
   * The maximum number of labels on the axis
   */
  public getAxisMaxLabels(): number {
    return this.mAxisMaxLabels;
  }

  /**
   * The maximum number of labels on the axis
   */
  public setAxisMaxLabels(labels: number): void {
    if (labels > 0)
      this.mAxisMaxLabels = labels;
  }

  /**
   * default constructor
   */
  constructor() {
    super();
    this.mTextSize = Utils.handleDataValues(10);
    this.mXOffset = Utils.handleDataValues(5);
    this.mYOffset = Utils.handleDataValues(5);
    this.mLimitLines = new JArrayList<LimitLine>();
    this.mGridLines = new JArrayList<LimitLine>();
  }

  /**
   * Set this to true to enable drawing the grid lines for this axis.
   *
   * @param enabled
   */
  public setDrawGridLines(enabled: boolean): void {
    this.mDrawGridLines = enabled;
  }

  /**
   * Returns true if drawing grid lines is enabled for this axis.
   *
   * @return
   */
  public isDrawGridLinesEnabled(): boolean {
    return this.mDrawGridLines;
  }

  /**
   * Set this to true if the line alongside the axis should be drawn or not.
   *
   * @param enabled
   */
  public setDrawAxisLine(enabled: boolean): void {
    this.mDrawAxisLine = enabled;
  }

  /**
   * Returns true if the line alongside the axis should be drawn.
   *
   * @return
   */
  public isDrawAxisLineEnabled(): boolean {
    return this.mDrawAxisLine;
  }

  /**
   * Centers the axis labels instead of drawing them at their original position.
   * This is useful especially for grouped BarChart.
   *
   * @param enabled
   */
  public setCenterAxisLabels(enabled: boolean): void {
    this.mCenterAxisLabels = enabled;
  }

  public isCenterAxisLabelsEnabled(): boolean {
    return this.mCenterAxisLabels && this.mEntryCount > 0;
  }

  /**
   * Sets the color of the grid lines for this axis (the horizontal lines
   * coming from each label).
   *
   * @param color
   */
  public setGridColor(color: number): void {
    this.mGridColor = color;
  }

  /**
   * 设置GridLine的不透明度
   * @param alpha 不透明度，取值0到255之间，0是完全透明，255是完全不透明
   */
  public setGridAlpha(alpha: number): void {
    if (alpha < 0) {
      alpha = 0;
    } else if (alpha > 255) {
      alpha = 255;
    }
    this.mGridAlpha = alpha;
  }

  /**
   * 返回GridLine的不透明度
   * @returns
   */
  public getGridAlpha(): number {
    return this.mGridAlpha;
  }

  /**
   * Returns the color of the grid lines for this axis (the horizontal lines
   * coming from each label).
   *
   * @return
   */
  public getGridColor(): number {
    return this.mGridColor;
  }

  /**
   * Sets the width of the border surrounding the chart in vp.
   *
   * @param width
   */
  public setAxisLineWidth(width: number): void {
    this.mAxisLineWidth = Utils.handleDataValues(width);
  }

  /**
   * Returns the width of the axis line (line alongside the axis).
   *
   * @return
   */
  public getAxisLineWidth(): number {
    return this.mAxisLineWidth;
  }

  /**
   * Sets the width of the grid lines that are drawn away from each axis
   * label.
   *
   * @param width
   */
  public setGridLineWidth(width: number): void {
    this.mGridLineWidth = Utils.handleDataValues(width);
  }

  /**
   * Returns the width of the grid lines that are drawn away from each axis
   * label.
   *
   * @return
   */
  public getGridLineWidth(): number {
    return this.mGridLineWidth;
  }

  /**
   * Sets the color of the border surrounding the chart.
   *
   * @param color
   */
  public setAxisLineColor(color: number): void {
    this.mAxisLineColor = color;
  }

  /**
   * Returns the color of the axis line (line alongside the axis).
   *
   * @return
   */
  public getAxisLineColor(): number {
    return this.mAxisLineColor;
  }

  /**
   * Set this to true to enable drawing the labels of this axis (this will not
   * affect drawing the grid lines or axis lines).
   *
   * @param enabled
   */
  public setDrawLabels(enabled: boolean): void {
    this.mDrawLabels = enabled;
  }

  /**
   * Returns true if drawing the labels is enabled for this axis.
   *
   * @return
   */
  public isDrawLabelsEnabled(): boolean {
    return this.mDrawLabels;
  }

  /**
   * sets the number of label entries for the y-axis max = 25, min = 2, default: 6, be aware
   * that this number is not
   * fixed (if force == false) and can only be approximated.
   *
   * @param count the number of y-axis labels that should be displayed
   * @param force if enabled, the set label count will be forced, meaning that the exact
   *              specified count of labels will
   *              be drawn and evenly distributed alongside the axis - this might cause labels
   *              to have uneven values
   */
  public setLabelCount(count: number, force?: boolean): void {
    if (count > this.getAxisMaxLabels())
      count = this.getAxisMaxLabels();
    if (count < this.getAxisMinLabels())
      count = this.getAxisMinLabels();
    this.mLabelCount = count;
    this.mForceLabels = false;
    if (force != null || force != undefined) {
      this.mForceLabels = force;
    }
  }

  /**
   * Returns true if focing the y-label count is enabled. Default: false
   *
   * @return
   */
  public isForceLabelsEnabled(): boolean {
    return this.mForceLabels;
  }

  /**
   * Returns the number of label entries the y-axis should have
   *
   * @return
   */
  public getLabelCount(): number {
    return this.mLabelCount;
  }

  /**
   * @return true if granularity is enabled
   */
  public isGranularityEnabled(): boolean {
    return this.mGranularityEnabled;
  }

  /**
   * Enabled/disable granularity control on axis value intervals. If enabled, the axis
   * interval is not allowed to go below a certain granularity. Default: false
   *
   * @param enabled
   */
  public setGranularityEnabled(enabled: boolean): void {
    this.mGranularityEnabled = enabled;
  }

  /**
   * @return the minimum interval between axis values
   */
  public getGranularity(): number {
    return this.mGranularity;
  }

  /**
   * Set a minimum interval for the axis when zooming in. The axis is not allowed to go below
   * that limit. This can be used to avoid label duplicating when zooming in.
   *
   * @param granularity
   */
  public setGranularity(granularity: number): void {
    this.mGranularity = granularity;
    // set this to true if it was disabled, as it makes no sense to call this method with granularity disabled
    this.mGranularityEnabled = true;
  }

  /**
   * Adds a new LimitLine to this axis.
   *
   * @param l
   */
  public addLimitLine(l: LimitLine): void {
    this.mLimitLines.add(l);

    if (this.mLimitLines.size() > 6) {
      LogUtil.log("MPChart",
        "Warning! You have more than 6 LimitLines on your axis, do you really want " +
        "that?");
    }
  }

  public addGridLine(customLine: GridLineConfig) {
    const line = new LimitLine(customLine.position);
    customLine.lineWidth && line.setLineWidth(customLine.lineWidth);
    customLine.lineColor && line.setLineColor(customLine.lineColor);
    customLine.dashPathEffect && line.enableDashedLine(
      customLine.dashPathEffect.lineLength,
      customLine.dashPathEffect.spaceLength,
      customLine.dashPathEffect.phase
    );
    this.mGridLines.add(line);
  }

  public getGridLines(): JArrayList<LimitLine> {
    return this.mGridLines;
  }


  /**
   * Removes the specified LimitLine from the axis.
   *
   * @param l
   */
  public removeLimitLine(l: LimitLine): void {
    this.mLimitLines.remove(l);
  }

  /**
   * Removes all LimitLines from the axis.
   */
  public removeAllLimitLines(): void {
    this.mLimitLines.clear();
  }

  /**
   * Returns the LimitLines of this axis.
   *
   * @return
   */
  public getLimitLines(): JArrayList<LimitLine> {
    return this.mLimitLines;
  }

  /**
   * If this is set to true, the LimitLines are drawn behind the actual data,
   * otherwise on top. Default: false
   *
   * @param enabled
   */
  public setDrawLimitLinesBehindData(enabled: boolean): void {
    this.mDrawLimitLineBehindData = enabled;
  }

  public isDrawLimitLinesBehindDataEnabled(): boolean {
    return this.mDrawLimitLineBehindData;
  }

  /**
   * If this is set to false, the grid lines are draw on top of the actual data,
   * otherwise behind. Default: true
   *
   * @param enabled
   */
  public setDrawGridLinesBehindData(enabled: boolean): void {
    this.mDrawGridLinesBehindData = enabled;
  }

  public isDrawGridLinesBehindDataEnabled(): boolean {
    return this.mDrawGridLinesBehindData;
  }

  /**
   * Returns the longest formatted label (in terms of characters), this axis
   * contains.
   *
   * @return
   */
  public getLongestLabel(): string {
    let longest: string = "";
    let longestLength: number = 0;
    for (let i = 0; i < this.mEntries.length; i++) {
      let text: string = this.getFormattedLabel(i) || "";
      const textLength = Utils.getLabelTextSizeWithoutPaint(text, this.textSizeCache).width;
      if (textLength > longestLength) {
        longest = text;
        longestLength = textLength;
      }
    }
    return longest;
  }

  public getFormattedLabel(index: number): string {
    if (index < 0 || index >= this.mEntries.length)
      return "";
    else
      return this.getValueFormatter().getFormattedValue(this.mEntries[index], this);
  }

  /**
   * Sets the formatter to be used for formatting the axis labels. If no formatter is set, the
   * chart will
   * automatically determine a reasonable formatting (concerning decimals) for all the values
   * that are drawn inside
   * the chart. Use chart.getDefaultValueFormatter() to use the formatter calculated by the chart.
   *
   * @param f
   */
  public setValueFormatter(f: IAxisValueFormatter): void {

    if (!f || f == null)
      this.mAxisValueFormatter = new DefaultAxisValueFormatter(this.mDecimals);
    else
      this.mAxisValueFormatter = f;
  }

  /**
   * Returns the formatter used for formatting the axis labels.
   *
   * @return
   */
  public getValueFormatter(): IAxisValueFormatter {

    if (!this.mAxisValueFormatter ||
    (this.mAxisValueFormatter instanceof DefaultAxisValueFormatter &&
    (this.mAxisValueFormatter as DefaultAxisValueFormatter).getDecimalDigits() != this.mDecimals))
      this.mAxisValueFormatter = new DefaultAxisValueFormatter(this.mDecimals);

    return this.mAxisValueFormatter;
  }

  /**
   * Enables the grid line to be drawn in dashed mode, e.g. like this
   * "- - - - - -". THIS ONLY WORKS IF HARDWARE-ACCELERATION IS TURNED OFF.
   * Keep in mind that hardware acceleration boosts performance.
   *
   * @param lineLength  the length of the line pieces
   * @param spaceLength the length of space in between the pieces
   * @param phase       offset, in degrees (normally, use 0)
   */
  public enableGridDashedLine(lineLength: number, spaceLength: number, phase: number): void {
    this.mGridDashPathEffect = new DashPathEffect([lineLength, spaceLength], phase);
  }

  /**
   * Enables the grid line to be drawn in dashed mode, e.g. like this
   * "- - - - - -". THIS ONLY WORKS IF HARDWARE-ACCELERATION IS TURNED OFF.
   * Keep in mind that hardware acceleration boosts performance.
   *
   * @param effect the DashPathEffect
   */
  public setGridDashedLine(effect: DashPathEffect
  ): void {
    this.mGridDashPathEffect = effect;
  }

  /**
   * Disables the grid line to be drawn in dashed mode.
   */
  public disableGridDashedLine(): void {
    this.mGridDashPathEffect = null;
  }

  /**
   * Returns true if the grid dashed-line effect is enabled, false if not.
   *
   * @return
   */
  public isGridDashedLineEnabled(): boolean {
    return this.mGridDashPathEffect == null ? false : true;
  }

  /**
   * returns the DashPathEffect that is set for grid line
   *
   * @return
   */
  public getGridDashPathEffect(): DashPathEffect | null {
    return this.mGridDashPathEffect;
  }


  /**
   * Enables the axis line to be drawn in dashed mode, e.g. like this
   * "- - - - - -". THIS ONLY WORKS IF HARDWARE-ACCELERATION IS TURNED OFF.
   * Keep in mind that hardware acceleration boosts performance.
   *
   * @param lineLength  the length of the line pieces
   * @param spaceLength the length of space in between the pieces
   * @param phase       offset, in degrees (normally, use 0)
   */
  public enableAxisLineDashedLine(lineLength: number, spaceLength: number, phase: number): void {
    this.mAxisLineDashPathEffect = new DashPathEffect([lineLength, spaceLength], phase);
  }

  /**
   * Enables the axis line to be drawn in dashed mode, e.g. like this
   * "- - - - - -". THIS ONLY WORKS IF HARDWARE-ACCELERATION IS TURNED OFF.
   * Keep in mind that hardware acceleration boosts performance.
   *
   * @param effect the DashPathEffect
   */
  public setAxisLineDashedLine(effect: DashPathEffect): void {
    this.mAxisLineDashPathEffect = effect;
  }

  /**
   * Disables the axis line to be drawn in dashed mode.
   */
  public disableAxisLineDashedLine(): void {
    this.mAxisLineDashPathEffect = null;
  }

  /**
   * Returns true if the axis dashed-line effect is enabled, false if not.
   *
   * @return
   */
  public isAxisLineDashedLineEnabled(): boolean {
    return this.mAxisLineDashPathEffect == null ? false : true;
  }

  /**
   * returns the DashPathEffect that is set for axis line
   *
   * @return
   */
  public getAxisLineDashPathEffect(): DashPathEffect | null {
    return this.mAxisLineDashPathEffect;
  }

  /**
   * ###### BELOW CODE RELATED TO CUSTOM AXIS VALUES ######
   */

  public getAxisMaximum(): number {
    return this.mAxisMaximum;
  }

  public getAxisMinimum(): number {
    return this.mAxisMinimum;
  }

  /**
   * By calling this method, any custom maximum value that has been previously set is reset,
   * and the calculation is
   * done automatically.
   */
  public resetAxisMaximum(): void {
    this.mCustomAxisMax = false;
  }

  /**
   * Returns true if the axis max value has been customized (and is not calculated automatically)
   *
   * @return
   */
  public isAxisMaxCustom(): boolean {
    return this.mCustomAxisMax;
  }

  /**
   * By calling this method, any custom minimum value that has been previously set is reset,
   * and the calculation is
   * done automatically.
   */
  public resetAxisMinimum(): void {
    this.mCustomAxisMin = false;
  }

  /**
   * Returns true if the axis min value has been customized (and is not calculated automatically)
   *
   * @return
   */
  public isAxisMinCustom(): boolean {
    return this.mCustomAxisMin;
  }

  /**
   * Set a custom minimum value for this axis. If set, this value will not be calculated
   * automatically depending on
   * the provided data. Use resetAxisMinValue() to undo this. Do not forget to call
   * setStartAtZero(false) if you use
   * this method. Otherwise, the axis-minimum value will still be forced to 0.
   *
   * @param min
   */
  public setAxisMinimum(min: number): void {
    this.mCustomAxisMin = true;
    this.mAxisMinimum = min;
    this.mAxisRange = Math.abs(this.mAxisMaximum - min);
  }

  /**
   * Use setAxisMinimum(...) instead.
   *
   * @param min
   */
  public setAxisMinValue(min: number): void {
    this.setAxisMinimum(min);
  }

  /**
   * Set a custom maximum value for this axis. If set, this value will not be calculated
   * automatically depending on
   * the provided data. Use resetAxisMaxValue() to undo this.
   *
   * @param max
   */
  public setAxisMaximum(max: number): void {
    this.mCustomAxisMax = true;
    this.mAxisMaximum = max;
    this.mAxisRange = Math.abs(max - this.mAxisMinimum);
  }

  /**
   * Use setAxisMaximum(...) instead.
   *
   * @param max
   */
  public setAxisMaxValue(max: number): void {
    this.setAxisMaximum(max);
  }

  /**
   * Calculates the minimum / maximum  and range values of the axis with the given
   * minimum and maximum values from the chart data.
   *
   * @param dataMin the min value according to chart data
   * @param dataMax the max value according to chart data
   */
  public calculate(dataMin: number, dataMax: number): void {

    // if custom, use value as is, else use data value
    let min: number = this.mCustomAxisMin ? this.mAxisMinimum : (dataMin - this.mSpaceMin);
    let max: number = this.mCustomAxisMax ? this.mAxisMaximum : (dataMax + this.mSpaceMax);

    // temporary range (before calculations)
    let range: number = Math.abs(max - min);

    // in case all values are equal
    if (range == 0) {
      max = max + 1;
      min = min - 1;
    }

    this.mAxisMinimum = min;
    this.mAxisMaximum = max;

    // actual range
    this.mAxisRange = Math.abs(max - min);
  }

  /**
   * Gets extra spacing for `axisMinimum` to be added to automatically calculated `axisMinimum`
   */
  public getSpaceMin(): number {
    return this.mSpaceMin;
  }

  /**
   * Sets extra spacing for `axisMinimum` to be added to automatically calculated `axisMinimum`
   */
  public setSpaceMin(mSpaceMin: number): void {
    this.mSpaceMin = mSpaceMin;
  }

  /**
   * Gets extra spacing for `axisMaximum` to be added to automatically calculated `axisMaximum`
   */
  public getSpaceMax(): number {
    return this.mSpaceMax;
  }

  /**
   * Sets extra spacing for `axisMaximum` to be added to automatically calculated `axisMaximum`
   */
  public setSpaceMax(mSpaceMax: number): void {
    this.mSpaceMax = mSpaceMax;
  }
}