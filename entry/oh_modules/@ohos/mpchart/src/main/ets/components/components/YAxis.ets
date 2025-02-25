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

import AxisBase from './AxisBase';
import Utils from '../utils/Utils';
import Paint from '../data/Paint';
import HashMap from '@ohos.util.HashMap';

/**
 * Class representing the y-axis labels settings and its entries. Only use the setter methods to
 * modify it. Do not
 * access public variables directly. Be aware that not all features the YLabels class provides
 * are suitable for the
 * RadarChart. Customizations that affect the value range of the axis need to be applied before
 * setting data for the
 * chart.
 *
 *
 */

export enum AxisDependency {
  LEFT, RIGHT
}

export enum YAxisLabelPosition {
  OUTSIDE_CHART, INSIDE_CHART
}

export default class YAxis extends AxisBase {
  /**
   * indicates if the bottom y-label entry is drawn or not
   */
  private mDrawBottomYLabelEntry: boolean = true;
  /**
   * indicates if the top y-label entry is drawn or not
   */
  private mDrawTopYLabelEntry: boolean = true;
  /**
   * flag that indicates if the axis is inverted or not
   */
  protected mInverted: boolean = false;
  /**
   * flag that indicates if the zero-line should be drawn regardless of other grid lines
   */
  protected mDrawZeroLine: boolean = false;
  /**
   * flag indicating that auto scale min restriction should be used
   */
  private mUseAutoScaleRestrictionMin: boolean = false;
  /**
   * flag indicating that auto scale max restriction should be used
   */
  private mUseAutoScaleRestrictionMax: boolean = false;
  /**
   * Color of the zero line
   */
  protected mZeroLineColor: number = Color.Gray;
  /**
   * Width of the zero line in pixels
   */
  protected mZeroLineWidth: number = 1;
  /**
   * axis space from the largest value to the top in percent of the total axis range
   */
  protected mSpacePercentTop: number = 10;
  /**
   * axis space from the smallest value to the bottom in percent of the total axis range
   */
  protected mSpacePercentBottom: number = 10;
  /**
   * the position of the y-labels relative to the chart
   */
  private mPosition: YAxisLabelPosition = YAxisLabelPosition.OUTSIDE_CHART;
  /**
   * the horizontal offset of the y-label
   */
  private mXLabelOffset: number = 0.0;
  /**
   * the side this axis object represents
   */
  private mAxisDependency: AxisDependency;
  /**
   * the minimum width that the axis should take (in vp).
   * <p/>
   * default: 0.0
   */
  protected mMinWidth: number = 0;
  /**
   * the maximum width that the axis can take (in vp).
   * use Inifinity for disabling the maximum
   * default: Float.POSITIVE_INFINITY (no maximum specified)
   */
  protected mMaxWidth: number = Number.POSITIVE_INFINITY;
  textSizeCache = new HashMap<string, TextMetrics>();

  constructor(position ?: AxisDependency) {
    super();

    // default left
    if (!position) {
      this.mAxisDependency = AxisDependency.LEFT;
    } else {
      this.mAxisDependency = position;
    }
    this.mYOffset = 0;
  }

  public getAxisDependency(): AxisDependency {
    return this.mAxisDependency;
  }

  /**
   * @return the minimum width that the axis should take (in vp).
   */
  public getMinWidth(): number {
    return this.mMinWidth;
  }

  /**
   * Sets the minimum width that the axis should take (in vp).
   *
   * @param minWidth
   */
  public setMinWidth(minWidth: number): void {
    this.mMinWidth = minWidth;
  }

  /**
   * @return the maximum width that the axis can take (in vp).
   */
  public getMaxWidth(): number {
    return this.mMaxWidth;
  }

  /**
   * Sets the maximum width that the axis can take (in vp).
   *
   * @param maxWidth
   */
  public setMaxWidth(maxWidth: number): void {
    this.mMaxWidth = maxWidth;
  }

  /**
   * returns the position of the y-labels
   */
  public getLabelPosition(): YAxisLabelPosition {
    return this.mPosition;
  }

  /**
   * sets the position of the y-labels
   *
   * @param pos
   */
  public setPosition(pos: YAxisLabelPosition): void {
    this.mPosition = pos;
  }

  /**
   * returns the horizontal offset of the y-label
   */
  public getLabelXOffset(): number {
    return this.mXLabelOffset;
  }

  /**
   * sets the horizontal offset of the y-label
   *
   * @param xOffset
   */
  public setLabelXOffset(xOffset: number): void {
    this.mXLabelOffset = xOffset;
  }

  /**
   * returns true if drawing the top y-axis label entry is enabled
   *
   * @return
   */
  public isDrawTopYLabelEntryEnabled(): boolean {
    return this.mDrawTopYLabelEntry;
  }

  /**
   * returns true if drawing the bottom y-axis label entry is enabled
   *
   * @return
   */
  public isDrawBottomYLabelEntryEnabled(): boolean {
    return this.mDrawBottomYLabelEntry;
  }

  /**
   * set this to true to enable drawing the bottom y-label entry. Disabling this can be helpful
   * when the bottom y-label and
   * left x-label interfere with each other. default: true
   *
   * @param enabled
   */
  public setDrawBottomYLabelEntry(enabled: boolean): void {
    this.mDrawBottomYLabelEntry = enabled;
  }

  /**
   * set this to true to enable drawing the top y-label entry. Disabling this can be helpful
   * when the top y-label and
   * left x-label interfere with each other. default: true
   *
   * @param enabled
   */
  public setDrawTopYLabelEntry(enabled: boolean): void {
    this.mDrawTopYLabelEntry = enabled;
  }

  /**
   * If this is set to true, the y-axis is inverted which means that low values are on top of
   * the chart, high values
   * on bottom.
   *
   * @param enabled
   */
  public setInverted(enabled: boolean): void {
    this.mInverted = enabled;
  }

  /**
   * If this returns true, the y-axis is inverted.
   *
   * @return
   */
  public isInverted(): boolean {
    return this.mInverted;
  }

  /**
   * This method is deprecated.
   * Use setAxisMinimum(...) / setAxisMaximum(...) instead.
   *
   * @param startAtZero
   */
  //    @Deprecated
  public setStartAtZero(startAtZero: boolean): void {
    if (startAtZero)
      super.setAxisMinimum(0);
    else
      super.resetAxisMinimum();
  }

  /**
   * Sets the top axis space in percent of the full range. Default 10f
   *
   * @param percent
   */
  public setSpaceTop(percent: number): void {
    this.mSpacePercentTop = percent;
  }

  /**
   * Returns the top axis space in percent of the full range. Default 10f
   *
   * @return
   */
  public getSpaceTop(): number {
    return this.mSpacePercentTop;
  }

  /**
   * Sets the bottom axis space in percent of the full range. Default 10f
   *
   * @param percent
   */
  public setSpaceBottom(percent: number): void {
    this.mSpacePercentBottom = percent;
  }

  /**
   * Returns the bottom axis space in percent of the full range. Default 10f
   *
   * @return
   */
  public getSpaceBottom(): number {
    return this.mSpacePercentBottom;
  }

  public isDrawZeroLineEnabled(): boolean {
    return this.mDrawZeroLine;
  }

  /**
   * Set this to true to draw the zero-line regardless of weather other
   * grid-lines are enabled or not. Default: false
   *
   * @param mDrawZeroLine
   */
  public setDrawZeroLine(mDrawZeroLine: boolean): void {
    this.mDrawZeroLine = mDrawZeroLine;
  }

  public getZeroLineColor(): number {
    return this.mZeroLineColor;
  }

  /**
   * Sets the color of the zero line
   *
   * @param color
   */
  public setZeroLineColor(color: number): void {
    this.mZeroLineColor = color;
  }

  public getZeroLineWidth(): number {
    return this.mZeroLineWidth;
  }

  /**
   * Sets the width of the zero line in vp
   *
   * @param width
   */
  public setZeroLineWidth(width: number): void {
    this.mZeroLineWidth = Utils.handleDataValues(width);
  }

  /**
   * This is for normal (not horizontal) charts horizontal spacing.
   *
   * @param p
   * @return
   */
  public getRequiredWidthSpace(p: Paint): number {

    p.setTextSize(this.mTextSize);

    let label: string = super.getLongestLabel();
    let width: number = Utils.getLabelTextSize(p, label, this.textSizeCache).width + super.getXOffset() * 2;

    let minWidth: number = this.getMinWidth();
    let maxWidth: number = this.getMaxWidth();

    if (minWidth > 0)
      minWidth = Utils.handleDataValues(minWidth);

    if (maxWidth > 0 && maxWidth != Number.POSITIVE_INFINITY)
      maxWidth = Utils.handleDataValues(maxWidth);

    width = Math.max(minWidth, Math.min(width, maxWidth > 0.0 ? maxWidth : width));

    return width;
  }

  /**
   * This is for HorizontalBarChart vertical spacing.
   *
   * @param p
   * @return
   */
  public getRequiredHeightSpace(p: Paint): number {

    p.setTextSize(this.mTextSize);

    let label: string = super.getLongestLabel();
    return Utils.getLabelTextSize(p, label, this.textSizeCache).height + super.getYOffset() * 2;
  }

  /**
   * Returns true if this axis needs horizontal offset, false if no offset is needed.
   *
   * @return
   */
  public needsOffset(): boolean {
    if (super.isEnabled() && super.isDrawLabelsEnabled() && this.getLabelPosition() == YAxisLabelPosition.OUTSIDE_CHART)
      return true;
    else
      return false;
  }

  /**
   * Returns true if autoscale restriction for axis min value is enabled
   */
  //    @Deprecated
  public isUseAutoScaleMinRestriction(): boolean {
    return this.mUseAutoScaleRestrictionMin;
  }

  /**
   * Sets autoscale restriction for axis min value as enabled/disabled
   */
  //    @Deprecated
  public setUseAutoScaleMinRestriction(isEnabled: boolean): void {
    this.mUseAutoScaleRestrictionMin = isEnabled;
  }

  /**
   * Returns true if autoscale restriction for axis max value is enabled
   */
  //    @Deprecated
  public isUseAutoScaleMaxRestriction(): boolean {
    return this.mUseAutoScaleRestrictionMax;
  }

  /**
   * Sets autoscale restriction for axis max value as enabled/disabled
   */
  //    @Deprecated
  public setUseAutoScaleMaxRestriction(isEnabled: boolean): void {
    this.mUseAutoScaleRestrictionMax = isEnabled;
  }


  //    @Override
  public calculate(dataMin: number, dataMax: number): void {

    let min: number = dataMin;
    let max: number = dataMax;

    // Make sure max is greater than min
    if (min > max) {
      if (this.mCustomAxisMax && this.mCustomAxisMin) {
        let t: number = min;
        min = max;
        max = t;
      }
      else if (this.mCustomAxisMax) {
        min = max < 0 ? max * 1.5 : max * 0.5;
      }
      else if (this.mCustomAxisMin) {
        max = min < 0 ? min * 0.5 : min * 1.5;
      }
    }

    let range: number = Math.abs(max - min);

    // in case all values are equal
    if (range == 0) {
      max = max + 1;
      min = min - 1;
    }

    // recalculate
    range = Math.abs(max - min);

    // calc extra spacing
    this.mAxisMinimum = this.mCustomAxisMin ? this.mAxisMinimum : min - (range / 100) * this.getSpaceBottom();
    this.mAxisMaximum = this.mCustomAxisMax ? this.mAxisMaximum : max + (range / 100) * this.getSpaceTop();

    this.mAxisRange = Math.abs(this.mAxisMinimum - this.mAxisMaximum);
  }
}
