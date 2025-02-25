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
import PieData from '../data/PieData';
import MyRect from '../data/Rect';
import MPPointF from '../utils/MPPointF';
import Utils from '../utils/Utils';
import PieRadarChartBase from './PieRadarChartBaseModel';
import PieChartRenderer from '../renderer/PieChartRenderer'
import PieHighlighter from '../highlight/PieHighlighter';
import Highlight from '../highlight/Highlight';
import MyMath from '../utils/MyMath';
import IPieDataSet from '../interfaces/datasets/IPieDataSet';
import { JArrayList } from '../utils/JArrayList';
import Paint, { FontFamily } from '../data/Paint';

/**
 * View that represents a pie chart. Draws cake like slices.
 *
 *
 */
export default class PieChartModel extends PieRadarChartBase<PieData> {
  /**
   * rect object that represents the bounds of the piechart, needed for
   * drawing the circle
   */
  private mCircleBox: MyRect = new MyRect();
  /**
   * flag indicating if entry labels should be drawn or not
   */
  private mDrawEntryLabels: boolean = true;
  /**
   * array that holds the width of each pie-slice in degrees
   */
  private mDrawAngles: number[] = new Array<number>(1);
  /**
   * array that holds the absolute angle in degrees of each slice
   */
  private mAbsoluteAngles: number[] = new Array<number>(1);
  /**
   * if true, the white hole inside the chart will be drawn
   */
  private mDrawHole: boolean = true;
  /**
   * if true, the hole will see-through to the inner tips of the slices
   */
  private mDrawSlicesUnderHole: boolean = false;
  /**
   * if true, the values inside the piechart are drawn as percent values
   */
  private mUsePercentValues: boolean = false;
  /**
   * if true, the slices of the piechart are rounded
   */
  private mDrawRoundedSlices: boolean = false;
  /**
   * variable for the text that is drawn in the center of the pie-chart
   */
  private mCenterText: string /*CharSequence*/
    = "";
  private mCenterTextOffset: MPPointF = MPPointF.getInstance(0, 0);
  /**
   * indicates the size of the hole in the center of the piechart, default:
   * radius / 2
   */
  private mHoleRadiusPercent: number = 50;
  /**
   * the radius of the transparent circle next to the chart-hole in the center
   */
  protected mTransparentCircleRadiusPercent: number = 55;
  /**
   * if enabled, centertext is drawn
   */
  private mDrawCenterText: boolean = true;
  private mCenterTextRadiusPercent: number = 100.0;
  protected mMaxAngle: number = 360;
  /**
   * Minimum angle to draw slices, this only works if there is enough room for all slices to have
   * the minimum angle, default 0f.
   */
  private mMinAngleForSlices: number = 0;
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

  // @Override
  protected init(): void {
    super.init();

    if (this.mAnimator) {
      this.mRenderer = new PieChartRenderer(this, this.mAnimator, this.mViewPortHandler);
    }
    this.mXAxis = null;

    this.mHighlighter = new PieHighlighter(this);
  }

  // @Override
  public onDraw(canvas: CanvasRenderingContext2D): void {
    super.onDraw(canvas);

    if (this.mData == null)
      return;
    this.mRenderer?.drawData(canvas);

    if (this.valuesToHighlight() && this.mIndicesToHighlight) {
      this.mRenderer?.drawHighlighted(canvas, this.mIndicesToHighlight);
    }

    this.mRenderer?.drawExtras(canvas);

    this.mRenderer?.drawValues(canvas);

    this.mLegendRenderer?.renderLegend(canvas);

    this.drawDescription(canvas);

    this.drawMarkers(canvas);
  }

  public calculateOffsets(): void {
    super.calculateOffsets();

    // prevent nullpointer when no data set
    if (this.mData == null)
      return;

    let diameter: number = this.getDiameter();
    let radius: number = diameter / 2;

    let c: MPPointF | null = this.getCenterOffsets();
    if (!c) {
      return;
    }

    let shift: number = this.mData.getDataSet().getSelectionShift();

    // create the circle box that will contain the pie-chart (the bounds of
    // the pie-chart)
    this.mCircleBox.set(c.x - radius + shift,
      c.y - radius + shift,
      c.x + radius - shift,
      c.y + radius - shift);

    MPPointF.recycleInstance(c);
  }

  // @Override
  protected calcMinMax(): void {
    this.calcAngles();
  }

  // @Override
  protected getMarkerPosition(highlight: Highlight): number[] {

    let center: MPPointF = this.getCenterCircleBox();
    let r: number = this.getRadius();

    let off: number = r / 10 * 3.6;

    if (this.isDrawHoleEnabled()) {
      off = (r - (r / 100 * this.getHoleRadius())) / 2;
    }

    r -= off; // offset to keep things inside the chart

    let rotationAngle: number = this.getRotationAngle();

    let entryIndex: number = /*(int)*/
    Math.round(highlight.getX());

    // offset needed to center the drawn text in the slice
    let offset: number = this.mDrawAngles[entryIndex] / 2;

    if (!this.mAnimator) {
      return [];
    }
    // calculate the text position
    let x: number = /*(float)*/
      (r
      * Math.cos(MyMath.toRadians((rotationAngle + this.mAbsoluteAngles[entryIndex] - offset)
      * this.mAnimator.getPhaseY())) + center.x);
    let y: number = /* (float)*/
      (r
      * Math.sin(MyMath.toRadians((rotationAngle + this.mAbsoluteAngles[entryIndex] - offset)
      * this.mAnimator.getPhaseY())) + center.y);

    MPPointF.recycleInstance(center);
    return [x, y] /*new float[]{x, y}*/
    ;
  }

  /**
   * calculates the needed angles for the chart slices
   */
  private calcAngles(): void {
    if (!this.mData) {
      return;
    }

    let entryCount: number = this.mData.getEntryCount();

    if (this.mDrawAngles.length != entryCount) {
      this.mDrawAngles = new Array<number>(entryCount) //new float[entryCount];
    } else {
      for (let i: number = 0; i < entryCount; i++) {
        this.mDrawAngles[i] = 0;
      }
    }
    if (this.mAbsoluteAngles.length != entryCount) {
      this.mAbsoluteAngles = new Array<number>(entryCount) //new float[entryCount];
    } else {
      for (let i: number = 0; i < entryCount; i++) {
        this.mAbsoluteAngles[i] = 0;
      }
    }

    let yValueSum: number = this.mData.getYValueSum();

    let dataSets: JArrayList<IPieDataSet> = this.mData.getDataSets();

    let hasMinAngle: boolean = this.mMinAngleForSlices != 0 && entryCount * this.mMinAngleForSlices <= this.mMaxAngle;
    let minAngles: number[] = new Array<number>(entryCount) //new float[entryCount];

    let cnt: number = 0;
    let offset: number = 0;
    let diff: number = 0;

    for (let i: number = 0; i < this.mData.getDataSetCount(); i++) {

      let set: IPieDataSet = dataSets.get(i);

      for (let j: number = 0; j < set.getEntryCount(); j++) {

        let drawAngle: number = this.calcAngle(Math.abs(set.getEntryForIndex(j).getY()), yValueSum);

        if (hasMinAngle) {
          let temp: number = drawAngle - this.mMinAngleForSlices;
          if (temp <= 0) {
            minAngles[cnt] = this.mMinAngleForSlices;
            offset += -temp;
          } else {
            minAngles[cnt] = drawAngle;
            diff += temp;
          }
        }

        this.mDrawAngles[cnt] = drawAngle;

        if (cnt == 0) {
          this.mAbsoluteAngles[cnt] = this.mDrawAngles[cnt];
        } else {
          this.mAbsoluteAngles[cnt] = this.mAbsoluteAngles[cnt - 1] + this.mDrawAngles[cnt];
        }

        cnt++;
      }
    }

    if (hasMinAngle) {
      // Correct bigger slices by relatively reducing their angles based on the total angle needed to subtract
      // This requires that `entryCount * mMinAngleForSlices <= mMaxAngle` be true to properly work!
      for (let i: number = 0; i < entryCount; i++) {
        minAngles[i] -= (minAngles[i] - this.mMinAngleForSlices) / diff * offset;
        if (i == 0) {
          this.mAbsoluteAngles[0] = minAngles[0];
        } else {
          this.mAbsoluteAngles[i] = this.mAbsoluteAngles[i - 1] + minAngles[i];
        }
      }

      this.mDrawAngles = minAngles;
    }
  }

  /**
   * Checks if the given index is set to be highlighted.
   *
   * @param index
   * @return
   */
  public needsHighlight(index: number): boolean {

    // no highlight
    if (!this.valuesToHighlight())
      return false;

    if (this.mIndicesToHighlight) {
      for (let i: number = 0; i < this.mIndicesToHighlight.length; i++) {
        // check if the xvalue for the given dataset needs highlight
        if ( /*(int)*/
          Math.round(this.mIndicesToHighlight[i].getX()) == index)
          return true;
      }
    }

    return false;
  }

  /**
   * calculates the needed angle for a given value
   *
   * @param value
   * @return
   */
  private calcAngleSum(value: number): number {
    if (!this.mData) {
      return -1;
    }
    return this.calcAngle(value, this.mData.getYValueSum());
  }

  /**
   * calculates the needed angle for a given value
   *
   * @param value
   * @param yValueSum
   * @return
   */
  private calcAngle(value: number, yValueSum: number): number {
    return value / yValueSum * this.mMaxAngle;
  }

  /**
   * This will throw an exception, PieChart has no XAxis object.
   *
   * @return
   */
  // @Deprecated
  // @Override
  public getXAxis(): XAxis {
    throw new Error("PieChart has no XAxis");
  }

  // @Override
  public getIndexForAngle(angle: number): number {

    // take the current angle of the chart into consideration
    let a: number = Utils.getNormalizedAngle(angle - this.getRotationAngle());

    for (let i: number = 0; i < this.mAbsoluteAngles.length; i++) {
      if (this.mAbsoluteAngles[i] > a)
        return i;
    }

    return -1; // return -1 if no index found
  }

  /**
   * Returns the index of the DataSet this x-index belongs to.
   *
   * @param xIndex
   * @return
   */
  public getDataSetIndexForIndex(xIndex: number): number {
    if (!this.mData) {
      return -1;
    }

    let dataSets: JArrayList<IPieDataSet> = this.mData.getDataSets();

    for (let i: number = 0; i < dataSets.size(); i++) {
      if (dataSets.get(i).getEntryForXValue(xIndex, Number.NaN) != null)
        return i;
    }

    return -1;
  }

  /**
   * returns an integer array of all the different angles the chart slices
   * have the angles in the returned array determine how much space (of 360°)
   * each slice takes
   *
   * @return
   */
  public getDrawAngles(): number[] {
    return this.mDrawAngles;
  }

  /**
   * returns the absolute angles of the different chart slices (where the
   * slices end)
   *
   * @return
   */
  public getAbsoluteAngles(): number[] {
    return this.mAbsoluteAngles;
  }

  /**
   * Sets the color for the hole that is drawn in the center of the PieChart
   * (if enabled).
   *
   * @param color
   */
  public setHoleColor(color: number): void {
    ( /*(PieChartRenderer)*/
      this.mRenderer as PieChartRenderer)?.getPaintHole().setColor(color);
  }

  /**
   * Enable or disable the visibility of the inner tips of the slices behind the hole
   */
  public setDrawSlicesUnderHole(enable: boolean): void {
    this.mDrawSlicesUnderHole = enable;
  }

  /**
   * Returns true if the inner tips of the slices are visible behind the hole,
   * false if not.
   *
   * @return true if slices are visible behind the hole.
   */
  public isDrawSlicesUnderHoleEnabled(): boolean {
    return this.mDrawSlicesUnderHole;
  }

  /**
   * set this to true to draw the pie center empty
   *
   * @param enabled
   */
  public setDrawHoleEnabled(enabled: boolean): void {
    this.mDrawHole = enabled;
  }

  /**
   * returns true if the hole in the center of the pie-chart is set to be
   * visible, false if not
   *
   * @return
   */
  public isDrawHoleEnabled(): boolean {
    return this.mDrawHole;
  }

  /**
   * Sets the text String that is displayed in the center of the PieChart.
   *
   * @param text
   */
  public setCenterText(text: string /*CharSequence*/
  ): void {
    if (text == null)
      this.mCenterText = "";
    else {
      this.mCenterText = text;
    }
  }

  /**
   * returns the text that is drawn in the center of the pie-chart
   *
   * @return
   */
  public getCenterText(): string /*CharSequence*/
  {
    return this.mCenterText;
  }

  /**
   * set this to true to draw the text that is displayed in the center of the
   * pie chart
   *
   * @param enabled
   */
  public setDrawCenterText(enabled: boolean): void {
    this.mDrawCenterText = enabled;
  }

  /**
   * returns true if drawing the center text is enabled
   *
   * @return
   */
  public isDrawCenterTextEnabled(): boolean {
    return this.mDrawCenterText;
  }

  // @Override
  protected getRequiredLegendOffset(): number {
    if (this.mLegendRenderer) {
      return this.mLegendRenderer.getLabelPaint().getTextSize() * 2.;
    }
    return 0;
  }

  // @Override
  protected getRequiredBaseOffset(): number {
    return 0;
  }

  // @Override
  public getRadius(): number {
    if (this.mCircleBox == null)
      return 0;
    else {
      return Math.min(this.mCircleBox.width() / 2, this.mCircleBox.height() / 2);
    }
  }

  /**
   * returns the circlebox, the boundingbox of the pie-chart slices
   *
   * @return
   */
  public getCircleBox(): MyRect {
    return this.mCircleBox;
  }

  /**
   * returns the center of the circlebox
   *
   * @return
   */
  public getCenterCircleBox(): MPPointF {
    return MPPointF.getInstance(this.mCircleBox.centerX(), this.mCircleBox.centerY());
  }

  /**
   * sets the typeface for the center-text paint
   *
   * @param t
   */
  public setCenterTextTypeface(t: FontFamily): void {
    ( /*(PieChartRenderer)*/
      this.mRenderer as PieChartRenderer).getPaintCenterText().setFontFamily(t);
  }

  /**
   * Sets the size of the center text of the PieChart in vp.
   *
   * @param sizeDp
   */
  public setCenterTextSize(sizeDp: number): void {
    ( /*(PieChartRenderer)*/
      this.mRenderer as PieChartRenderer).getPaintCenterText().setTextSize(
      Utils.handleDataValues(sizeDp));
  }

  /**
   * Sets the size of the center text of the PieChart in pixels.
   *
   * @param sizePixels
   */
  public setCenterTextSizePixels(sizePixels: number): void {
    ( /*(PieChartRenderer)*/
      this.mRenderer as PieChartRenderer).getPaintCenterText().setTextSize(sizePixels);
  }

  /**
   * Sets the offset the center text should have from it's original position in vp. Default x = 0, y = 0
   *
   * @param x
   * @param y
   */
  public setCenterTextOffset(x: number, y: number): void {
    this.mCenterTextOffset.x = Utils.handleDataValues(x);
    this.mCenterTextOffset.y = Utils.handleDataValues(y);
  }

  /**
   * Returns the offset on the x- and y-axis the center text has in vp.
   *
   * @return
   */
  public getCenterTextOffset(): MPPointF {
    return MPPointF.getInstance(this.mCenterTextOffset.x, this.mCenterTextOffset.y);
  }

  /**
   * Sets the color of the center text of the PieChart.
   *
   * @param color
   */
  public setCenterTextColor(color: number): void {
    ( /*(PieChartRenderer)*/
      this.mRenderer as PieChartRenderer).getPaintCenterText().setColor(color);
  }

  /**
   * sets the radius of the hole in the center of the piechart in percent of
   * the maximum radius (max = the radius of the whole chart), default 50%
   *
   * @param percent
   */
  public setHoleRadius(percent: number): void {
    this.mHoleRadiusPercent = percent;
  }

  /**
   * Returns the size of the hole radius in percent of the total radius.
   *
   * @return
   */
  public getHoleRadius(): number {
    return this.mHoleRadiusPercent;
  }

  /**
   * Sets the color the transparent-circle should have.
   *
   * @param color
   */
  public setTransparentCircleColor(color: number): void {
    if (!this.mRenderer) {
      return;
    }
    let p: Paint = ( /*(PieChartRenderer) */
      this.mRenderer as PieChartRenderer).getPaintTransparentCircle();
    let alpha: number | undefined = p.getGlobalAlpha();
    p.setColor(color);
    if (alpha) {
      p.setGlobalAlpha(alpha);
    }
  }

  /**
   * sets the radius of the transparent circle that is drawn next to the hole
   * in the piechart in percent of the maximum radius (max = the radius of the
   * whole chart), default 55% -> means 5% larger than the center-hole by
   * default
   *
   * @param percent
   */
  public setTransparentCircleRadius(percent: number): void {
    this.mTransparentCircleRadiusPercent = percent;
  }

  public getTransparentCircleRadius(): number {
    return this.mTransparentCircleRadiusPercent;
  }

  /**
   * Sets the amount of transparency the transparent circle should have 0 = fully transparent,
   * 255 = fully opaque.
   * Default value is 100.
   *
   * @param alpha 0-255
   */
  public setTransparentCircleAlpha(alpha: number): void {
    if (!this.mRenderer) {
      return;
    }
    ( /*(PieChartRenderer)*/
      this.mRenderer as PieChartRenderer).getPaintTransparentCircle().setGlobalAlpha(alpha / 255);
  }

  /**
   * Set this to true to draw the entry labels into the pie slices (Provided by the getLabel() method of the PieEntry class).
   * Deprecated -> use setDrawEntryLabels(...) instead.
   *
   * @param enabled
   */
  // @Deprecated
  public setDrawSliceText(enabled: boolean): void {
    this.mDrawEntryLabels = enabled;
  }

  /**
   * Set this to true to draw the entry labels into the pie slices (Provided by the getLabel() method of the PieEntry class).
   *
   * @param enabled
   */
  public setDrawEntryLabels(enabled: boolean): void {
    this.mDrawEntryLabels = enabled;
  }

  /**
   * Returns true if drawing the entry labels is enabled, false if not.
   *
   * @return
   */
  public isDrawEntryLabelsEnabled(): boolean {
    return this.mDrawEntryLabels;
  }

  /**
   * Sets the color the entry labels are drawn with.
   *
   * @param color
   */
  public setEntryLabelColor(color: number): void {
    ( /*(PieChartRenderer) */
      this.mRenderer as PieChartRenderer).getPaintEntryLabels().setColor(color);
  }

  /**
   * Sets a custom Typeface for the drawing of the entry labels.
   *
   * @param tf
   */
  public setEntryLabelTypeface(tf: FontFamily): void {
    ( /*(PieChartRenderer)*/
      this.mRenderer as PieChartRenderer).getPaintEntryLabels().setFontFamily(tf);
  }

  /**
   * Sets the size of the entry labels in vp. Default: 14vp
   *
   * @param size
   */
  public setEntryLabelTextSize(size: number): void {
    ( /*(PieChartRenderer)*/
      this.mRenderer as PieChartRenderer).getPaintEntryLabels()
      .setTextSize(Utils.handleDataValues(size));
  }

  /**
   * Sets whether to draw slices in a curved fashion, only works if drawing the hole is enabled
   * and if the slices are not drawn under the hole.
   *
   * @param enabled draw curved ends of slices
   */
  public setDrawRoundedSlices(enabled: boolean): void {
    this.mDrawRoundedSlices = enabled;
  }

  /**
   * Returns true if the chart is set to draw each end of a pie-slice
   * "rounded".
   *
   * @return
   */
  public isDrawRoundedSlicesEnabled(): boolean {
    return this.mDrawRoundedSlices;
  }

  /**
   * If this is enabled, values inside the PieChart are drawn in percent and
   * not with their original value. Values provided for the IValueFormatter to
   * format are then provided in percent.
   *
   * @param enabled
   */
  public setUsePercentValues(enabled: boolean): void {
    this.mUsePercentValues = enabled;
  }

  /**
   * Returns true if using percentage values is enabled for the chart.
   *
   * @return
   */
  public isUsePercentValuesEnabled(): boolean {
    return this.mUsePercentValues;
  }

  /**
   * the rectangular radius of the bounding box for the center text, as a percentage of the pie
   * hole
   * default 1.f (100%)
   */
  public setCenterTextRadiusPercent(percent: number): void {
    this.mCenterTextRadiusPercent = percent;
  }

  /**
   * the rectangular radius of the bounding box for the center text, as a percentage of the pie
   * hole
   * default 1.f (100%)
   */
  public getCenterTextRadiusPercent(): number {
    return this.mCenterTextRadiusPercent;
  }

  public getMaxAngle(): number {
    return this.mMaxAngle;
  }

  /**
   * Sets the max angle that is used for calculating the pie-circle. 360f means
   * it's a full PieChart, 180f results in a half-pie-chart. Default: 360f
   *
   * @param maxangle min 90, max 360
   */
  public setMaxAngle(maxangle: number): void {

    if (maxangle > 360)
      maxangle = 360;

    if (maxangle < 90)
      maxangle = 90;

    this.mMaxAngle = maxangle;
  }

  /**
   * The minimum angle slices on the chart are rendered with, default is 0f.
   *
   * @return minimum angle for slices
   */
  public getMinAngleForSlices(): number {
    return this.mMinAngleForSlices;
  }

  /**
   * Set the angle to set minimum size for slices, you must call {@link #notifyDataSetChanged()}
   * and {@link #invalidate()} when changing this, only works if there is enough room for all
   * slices to have the minimum angle.
   *
   * @param minAngle minimum 0, maximum is half of {@link #setMaxAngle(float)}
   */
  public setMinAngleForSlices(minAngle: number): void {

    if (minAngle > (this.mMaxAngle / 2))
      minAngle = this.mMaxAngle / 2;
    else if (minAngle < 0)
      minAngle = 0;

    this.mMinAngleForSlices = minAngle;
  }

  // @Override
  protected onDetachedFromWindow(): void {
    // releases the bitmap in the renderer to avoid oom error
    if (this.mRenderer != null && this.mRenderer instanceof PieChartRenderer) {
      ( /*(PieChartRenderer)*/
        this.mRenderer as PieChartRenderer).releaseBitmap();
    }
    // super.onDetachedFromWindow();
  }
}
