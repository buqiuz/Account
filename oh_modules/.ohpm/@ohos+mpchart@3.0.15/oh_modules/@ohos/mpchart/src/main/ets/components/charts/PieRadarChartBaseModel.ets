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

import { LegendHorizontalAlignment, LegendOrientation, LegendVerticalAlignment } from '../components/Legend';
import { XAxis } from '../components/XAxis';
import ChartData from '../data/ChartData';
import EntryOhos from '../data/EntryOhos';
import MyRect from '../data/Rect';
import IDataSet from '../interfaces/datasets/IDataSet';
import PieRadarChartTouchListener from '../listener/PieRadarChartTouchListener';
import { LogUtil } from '../utils/LogUtil';
import MPPointF from '../utils/MPPointF';
import Utils, { PanActionType, PinchActionType } from '../utils/Utils';
import Chart from './ChartModel';
import RadarChart from './RadarChartModel';

export default abstract class PieRadarChartBaseModel<T extends ChartData<IDataSet<EntryOhos>>> extends Chart<T> {
  // holds the normalized version of the current rotation angle of the chart
  private mRotationAngle: number = 270;
  // holds the raw version of the current rotation angle of the chart
  private mRawRotationAngle: number = 270;
  // flag that indicates if rotation is enabled or not
  protected mRotateEnabled: boolean = true;
  // Sets the minimum offset (padding) around the chart, defaults to 0
  protected mMinOffset: number = 0;

  constructor() {
    super();
    this.init();
  }

  protected init() {
    super.init();
    this.mChartTouchListener = new PieRadarChartTouchListener(this);
  }

  protected calcMinMax() {
    //this.mXAxis.mAxisRange = this.mData.getXVals().size() - 1;
  }

  public getMaxVisibleCount(): number {
    if (this.mData) {
      return this.mData.getEntryCount();
    } else {
      return 0;
    }
  }

  public onTouchEvent(event: TouchEvent): void {
    // check if touch gestures are enabled
    if (!this.mTouchEnabled) {
      return;
    }
    if (this.mChartTouchListener == null || this.mData == null)
      return;

    switch (event.type) {
      case TouchType.Down:
        this.mChartTouchListener.actionDown(true, event);
        break;
      case TouchType.Move:
        this.mChartTouchListener.actionMove(true, event);
        break;
      case TouchType.Up:
        this.mChartTouchListener.actionUp(true, event);
        break;
      default:
        break;
    }
  }

  public onSingleTapUp(isTouchEvent: boolean, event: TouchEvent | GestureEvent): void {
    if (!this.mTouchEnabled) {
      return;
    }
    if (this.mChartTouchListener) {
      this.mChartTouchListener.onSingleTapUp(isTouchEvent, event);
    }
  }

  public onDoubleTap(isTouchEvent: boolean, event: TouchEvent | GestureEvent): void {
    if (!this.mTouchEnabled) {
      return;
    }
    if (this.mChartTouchListener) {
      this.mChartTouchListener.onDoubleTap(isTouchEvent, event);
    }
  }

  public computeScroll(event: GestureEvent): void {

    if (this.mChartTouchListener instanceof PieRadarChartTouchListener)
      this.mChartTouchListener.computeScroll(event);
  }

  public notifyDataSetChanged() {
    if (this.mData == null)
      return;

    this.calcMinMax();

    if (this.mLegend != null)
      this.mLegendRenderer?.computeLegend(this.mData);

    this.calculateOffsets();
  }

  public calculateOffsets(): void {
    let legendLeft: number = 0;
    let legendRight: number = 0;
    let legendBottom: number = 0;
    let legendTop: number = 0;

    if (this.mLegend != null && this.mLegend.isEnabled() && !this.mLegend.isDrawInsideEnabled()) {
      let fullLegendWidth: number = Math.min(this.mLegend.mNeededWidth, this.mViewPortHandler.getChartWidth() * this.mLegend.getMaxSizePercent());

      switch (this.mLegend.getOrientation()) {
        case LegendOrientation.VERTICAL: {
          let xLegendOffset: number = 0;

          if (this.mLegend.getHorizontalAlignment() == LegendHorizontalAlignment.LEFT || this.mLegend.getHorizontalAlignment() == LegendHorizontalAlignment.RIGHT) {
            if (this.mLegend.getVerticalAlignment() == LegendVerticalAlignment.CENTER) {
              const spacing: number = Utils.handleDataValues(13);
              xLegendOffset = fullLegendWidth + spacing;
            } else {
              let spacing: number = Utils.handleDataValues(8);
              let legendWidth: number = fullLegendWidth + spacing;
              let legendHeight: number = this.mLegend.mNeededHeight + this.mLegend.mTextHeightMax;
              const center: MPPointF = this.getCenter();
              let bottomX: number = this.mLegend.getHorizontalAlignment() == LegendHorizontalAlignment.RIGHT ? this.getWidth() - legendWidth + 15 : legendWidth - 15;
              let bottomY: number = legendHeight + 15;
              let distLegend: number = this.distanceToCenter(bottomX, bottomY);
              const reference: MPPointF = this.getPosition(center, this.getRadius(), this.getAngleForPoint(bottomX, bottomY));
              let distReference: number = this.distanceToCenter(reference.x, reference.y);
              const minOffset: number = Utils.handleDataValues(5);

              if (bottomY >= center.y && this.getHeight() - legendWidth > this.getWidth()) {
                xLegendOffset = legendWidth;
              } else if (distLegend < distReference) {
                let diff: number = distReference - distLegend;
                xLegendOffset = minOffset + diff;
              }

              MPPointF.recycleInstance(center);
              MPPointF.recycleInstance(reference);
            }
          }

          switch (this.mLegend.getHorizontalAlignment()) {
            case LegendHorizontalAlignment.LEFT:
              legendLeft = xLegendOffset;
              break;
            case LegendHorizontalAlignment.RIGHT:
              legendRight = xLegendOffset;
              break;
            case LegendHorizontalAlignment.CENTER:
              switch (this.mLegend.getVerticalAlignment()) {
                case LegendVerticalAlignment.TOP:
                  legendTop = Math.min(this.mLegend.mNeededHeight, this.mViewPortHandler.getChartHeight() * this.mLegend.getMaxSizePercent());
                  break;
                case LegendVerticalAlignment.BOTTOM:
                  legendBottom = Math.min(this.mLegend.mNeededHeight, this.mViewPortHandler.getChartHeight() * this.mLegend.getMaxSizePercent());
                  break;
              }
              break;
          }
        }
          break;
        case LegendOrientation.HORIZONTAL:
          let yLegendOffset: number = 0;

          if (this.mLegend.getVerticalAlignment() == LegendVerticalAlignment.TOP || this.mLegend.getVerticalAlignment() == LegendVerticalAlignment.BOTTOM) {
            let yOffset: number = this.getRequiredLegendOffset();
            yLegendOffset = Math.min(this.mLegend.mNeededHeight + yOffset, this.mViewPortHandler.getChartHeight() * this.mLegend.getMaxSizePercent());
            switch (this.mLegend.getVerticalAlignment()) {
              case LegendVerticalAlignment.TOP:
                legendTop = yLegendOffset;
                break;
              case LegendVerticalAlignment.BOTTOM:
                legendBottom = yLegendOffset;
                break;
            }
          }
          break;
      }

      legendLeft += this.getRequiredBaseOffset();
      legendRight += this.getRequiredBaseOffset();
      legendTop += this.getRequiredBaseOffset();
      legendBottom += this.getRequiredBaseOffset();
    }

    let minOffset: number = Utils.handleDataValues(this.mMinOffset);

    if (this instanceof RadarChart) {
      const x: XAxis | null = this.getXAxis();
      if (x && x.isEnabled() && x.isDrawLabelsEnabled()) {
        minOffset = Math.max(minOffset, x.mLabelRotatedWidth);
      }
    }

    legendTop += this.getExtraTopOffset();
    legendRight += this.getExtraRightOffset();
    legendBottom += this.getExtraBottomOffset();
    legendLeft += this.getExtraLeftOffset();

    const offsetLeft: number = Math.max(minOffset, legendLeft);
    const offsetTop: number = Math.max(minOffset, legendTop);
    const offsetRight: number = Math.max(minOffset, legendRight);
    const offsetBottom: number = Math.max(minOffset, Math.max(this.getRequiredBaseOffset(), legendBottom));

    this.mViewPortHandler.restrainViewPort(offsetLeft, offsetTop, offsetRight, offsetBottom);

    if (this.mLogEnabled) {
      LogUtil.log(`offsetLeft: ${offsetLeft}, offsetTop: ${offsetTop}, offsetRight: ${offsetRight}, offsetBottom: ${offsetBottom}`);
    }
  }

  /**
   * returns the angle relative to the chart center for the given point on the
   * chart in degrees. The angle is always between 0 and 360°, 0° is NORTH,
   * 90° is EAST, ...
   *
   * @param x
   * @param y
   * @return
   */
  public getAngleForPoint(x: number, y: number): number {
    const c: MPPointF | null = this.getCenterOffsets();
    if (!c) {
      return 0;
    }

    const tx: number = x - c.x;
    const ty: number = y - c.y;
    const length: number = Math.sqrt(tx * tx + ty * ty);
    const r: number = Math.acos(ty / length);

    let angle: number = this.toDegrees(r);

    if (x > c.x) {
      angle = 360 - angle;
    }

    angle = angle + 90; // add 90° because chart starts EAST

    if (angle > 360) {
      angle = angle - 360; // neutralize overflow
    }

    MPPointF.recycleInstance(c);

    return angle;
  }

  public getPosition(center: MPPointF, dist: number, angle: number): MPPointF {
    const p: MPPointF = MPPointF.getInstance(0, 0);
    this.getPositionWithOutputPoint(center, dist, angle, p);
    return p;
  }

  public getPositionWithOutputPoint(center: MPPointF, dist: number, angle: number, outputPoint: MPPointF): void {
    outputPoint.x = center.x + dist * Math.cos(this.toRadians(angle));
    outputPoint.y = center.y + dist * Math.sin(this.toRadians(angle));
  }

  /**
   * returns the angle relative to the chart center for the given point on the
   * chart in degrees. The angle is always between 0 and 360°, 0° is NORTH,
   * 90° is EAST, ...
   *
   * @param x
   * @param y
   * @return
   */
  public distanceToCenter(x: number, y: number): number {
    const c: MPPointF | null = this.getCenterOffsets();
    if (!c) {
      return 0;
    }
    let dist: number = 0;
    let xDist: number = 0;
    let yDist: number = 0;

    if (x > c.x) {
      xDist = x - c.x;
    } else {
      xDist = c.x - x;
    }

    if (y > c.y) {
      yDist = y - c.y;
    } else {
      yDist = c.y - y;
    }

    // pythagoras
    dist = Math.sqrt(Math.pow(xDist, 2.0) + Math.pow(yDist, 2.0));

    MPPointF.recycleInstance(c);

    return dist;
  }

  /**
   * Returns the xIndex for the given angle around the center of the chart.
   * Returns -1 if not found / outofbounds.
   *
   * @param angle
   * @return
   */
  public abstract getIndexForAngle(angle: number): number;

  /**
   * Set an offset for the rotation of the RadarChart in degrees. Default 270f
   * --> top (NORTH)
   *
   * @param angle
   */
  public setRotationAngle(angle: number): void {
    this.mRawRotationAngle = angle;
    this.mRotationAngle = Utils.getNormalizedAngle(this.mRawRotationAngle);
  }

  /**
   * gets the raw version of the current rotation angle of the pie chart the
   * returned value could be any value, negative or positive, outside of the
   * 360 degrees. this is used when working with rotation direction, mainly by
   * gestures and animations.
   *
   * @return
   */
  public getRawRotationAngle(): number {
    return this.mRawRotationAngle;
  }

  /**
   * gets a normalized version of the current rotation angle of the pie chart,
   * which will always be between 0.0 < 360.0
   *
   * @return
   */
  public getRotationAngle(): number {
    return this.mRotationAngle;
  }

  /**
   * Set this to true to enable the rotation / spinning of the chart by touch.
   * Set it to false to disable it. Default: true
   *
   * @param enabled
   */
  public setRotationEnabled(enabled: boolean): void {
    this.mRotateEnabled = enabled;
  }

  /**
   * Returns true if rotation of the chart by touch is enabled, false if not.
   *
   * @return
   */
  public isRotationEnabled(): boolean {
    return this.mRotateEnabled;
  }

  /**
   * Gets the minimum offset (padding) around the chart, defaults to 0.f
   */
  public getMinOffset(): number {
    return this.mMinOffset;
  }

  /**
   * Sets the minimum offset (padding) around the chart, defaults to 0.f
   */
  public setMinOffset(minOffset: number): void {
    this.mMinOffset = minOffset;
  }

  /**
   * returns the diameter of the pie- or radar-chart
   *
   * @return
   */
  public getDiameter(): number {
    let content: MyRect = this.mViewPortHandler.getContentRect();
    content.left += this.getExtraLeftOffset();
    content.top += this.getExtraTopOffset();
    content.right -= this.getExtraRightOffset();
    content.bottom -= this.getExtraBottomOffset();
    return Math.min(content.width(), content.height());
  }

  /**
   * Returns the radius of the chart in pixels.
   *
   * @return
   */
  public abstract getRadius(): number;

  /**
   * Returns the required offset for the chart legend.
   *
   * @return
   */
  protected abstract getRequiredLegendOffset(): number;

  /**
   * Returns the base offset needed for the chart without calculating the
   * legend size.
   *
   * @return
   */
  protected abstract getRequiredBaseOffset(): number;

  public getYChartMin(): number {
    return 0;
  }

  public getYChartMax(): number {
    return 0;
  }

  /**
   * ################ ################ ################ ################
   */
  /** CODE BELOW THIS RELATED TO ANIMATION */

  /**
   *
   * @param durationmillis
   * @param fromangle
   * @param toangle
   */
  // public spin(durationmillis: number, fromangle: number, toangle: number, easing: EasingFunction): void {
  //
  //   this.setRotationAngle(fromangle);
  //
  //   let spinAnimator: ObjectAnimator = ObjectAnimator.ofFloat(this, "rotationAngle", fromangle,
  //     toangle);
  //   spinAnimator.setDuration(durationmillis);
  //   spinAnimator.setInterpolator(easing);
  //
  //   spinAnimator.addUpdateListener(new AnimatorUpdateListener() {
  //
  //           @Override
  //           public void onAnimationUpdate(ValueAnimator animation) {
  //               postInvalidate();
  //           }
  //   }
  // );
  //   spinAnimator.start();
  // }

  private toDegrees(radians: number): number {
    return radians * (180 / Math.PI);
  }

  private toRadians(degrees: number): number {
    return degrees * (Math.PI / 180);
  }
}