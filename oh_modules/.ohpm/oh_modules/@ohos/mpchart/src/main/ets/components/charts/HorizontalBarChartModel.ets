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

import { LegendOrientation, LegendHorizontalAlignment, LegendVerticalAlignment } from '../components/Legend';
import { XAxisPosition } from '../components/XAxis';
import { AxisDependency } from '../components/YAxis';
import BarEntry from '../data/BarEntry';
import EntryOhos from '../data/EntryOhos';
import MyRect from '../data/Rect';
import Highlight from '../highlight/Highlight';
import HorizontalBarHighlighter from '../highlight/HorizontalBarHighlighter';
import IBarDataSet from '../interfaces/datasets/IBarDataSet';
import HorizontalBarChartRenderer from '../renderer/HorizontalBarChartRenderer';
import XAxisRendererHorizontalBarChart from '../renderer/XAxisRendererHorizontalBarChart';
import YAxisRendererHorizontalBarChart from '../renderer/YAxisRendererHorizontalBarChart';

import HorizontalViewPortHandler from '../utils/HorizontalViewPortHandler';
import { LogUtil } from '../utils/LogUtil';
import MPPointF from '../utils/MPPointF';
import TransformerHorizontalBarChart from '../utils/TransformerHorizontalBarChart';
import Utils from '../utils/Utils';

import BarChartModel from './BarChartModel';
import ChartModel from './ChartModel';

export default class HorizontalBarChartModel extends BarChartModel {
  constructor() {
    super();
    this.init();
  }

  protected init() {
    this.mViewPortHandler = new HorizontalViewPortHandler();
    super.init();

    this.mLeftAxisTransformer = new TransformerHorizontalBarChart(this.mViewPortHandler);
    this.mRightAxisTransformer = new TransformerHorizontalBarChart(this.mViewPortHandler);

    if (this.mAnimator) {
      this.mRenderer = new HorizontalBarChartRenderer(this, this.mAnimator, this.mViewPortHandler);
    }

    this.setHighlighter(new HorizontalBarHighlighter(this));

    if (this.mAxisLeft) {
      this.mAxisRendererLeft = new YAxisRendererHorizontalBarChart(this.mViewPortHandler, this.mAxisLeft, this.mLeftAxisTransformer);
    }
    if (this.mAxisRight) {
      this.mAxisRendererRight = new YAxisRendererHorizontalBarChart(this.mViewPortHandler, this.mAxisRight, this.mRightAxisTransformer);
    }
    if (this.mXAxis) {
      this.mXAxisRenderer = new XAxisRendererHorizontalBarChart(this.mViewPortHandler, this.mXAxis, this.mLeftAxisTransformer, this);
    }
  }

  protected calculateLegendOffsets(offsets: MyRect): void {
    offsets.left = 0;
    offsets.right = 0;
    offsets.top = 0;
    offsets.bottom = 0;

    if (this.mLegend == null || !this.mLegend.isEnabled() || this.mLegend.isDrawInsideEnabled())
      return;

    switch (this.mLegend.getOrientation()) {
      case LegendOrientation.VERTICAL:
        switch (this.mLegend.getHorizontalAlignment()) {
          case LegendHorizontalAlignment.LEFT:
            offsets.left += Math.min(this.mLegend.mNeededWidth,
              this.mViewPortHandler.getChartWidth() * this.mLegend.getMaxSizePercent())
            + this.mLegend.getXOffset();
            break;
          case LegendHorizontalAlignment.RIGHT:
            offsets.right += Math.min(this.mLegend.mNeededWidth,
              this.mViewPortHandler.getChartWidth() * this.mLegend.getMaxSizePercent())
            + this.mLegend.getXOffset();
            break;
          case LegendHorizontalAlignment.CENTER:
            switch (this.mLegend.getVerticalAlignment()) {
              case LegendVerticalAlignment.TOP:
                offsets.top += Math.min(this.mLegend.mNeededHeight,
                  this.mViewPortHandler.getChartHeight() * this.mLegend.getMaxSizePercent())
                + this.mLegend.getYOffset();
                break;

              case LegendVerticalAlignment.BOTTOM:
                offsets.bottom += Math.min(this.mLegend.mNeededHeight,
                  this.mViewPortHandler.getChartHeight() * this.mLegend.getMaxSizePercent())
                + this.mLegend.getYOffset();
                break;

              default:
                break;
            }
        }
        break;
      case LegendOrientation.HORIZONTAL:

        switch (this.mLegend.getVerticalAlignment()) {
          case LegendVerticalAlignment.TOP:
            offsets.top += Math.min(this.mLegend.mNeededHeight,
              this.mViewPortHandler.getChartHeight() * this.mLegend.getMaxSizePercent())
            + this.mLegend.getYOffset();

            if (this.mAxisLeft && this.mAxisLeft.isEnabled() && this.mAxisLeft.isDrawLabelsEnabled() && this.mAxisRendererLeft)
              offsets.top += this.mAxisLeft.getRequiredHeightSpace(
                this.mAxisRendererLeft.getPaintAxisLabels());
            break;

          case LegendVerticalAlignment.BOTTOM:
            offsets.bottom += Math.min(this.mLegend.mNeededHeight,
              this.mViewPortHandler.getChartHeight() * this.mLegend.getMaxSizePercent())
            + this.mLegend.getYOffset();


            if (this.mAxisRight && this.mAxisRight.isEnabled() && this.mAxisRight.isDrawLabelsEnabled() && this.mAxisRendererRight)
              offsets.bottom += this.mAxisRight.getRequiredHeightSpace(
                this.mAxisRendererRight.getPaintAxisLabels());
            break;

          default:
            break;
        }
        break;
    }
  }

  public calculateOffsets(): void {

    let offsetLeft = 0, offsetRight = 0, offsetTop = 0, offsetBottom = 0;

    this.calculateLegendOffsets(this.mOffsetsBuffer);

    offsetLeft += this.mOffsetsBuffer.left;
    offsetTop += this.mOffsetsBuffer.top;
    offsetRight += this.mOffsetsBuffer.right;
    offsetBottom += this.mOffsetsBuffer.bottom;

    // offsets for y-labels
    if (this.mAxisLeft && this.mAxisLeft.needsOffset() && this.mAxisRendererLeft) {
      offsetTop += this.mAxisLeft.getRequiredHeightSpace(this.mAxisRendererLeft.getPaintAxisLabels());
    }

    if (this.mAxisRight && this.mAxisRight.needsOffset() && this.mAxisRendererRight) {
      offsetBottom += this.mAxisRight.getRequiredHeightSpace(this.mAxisRendererRight.getPaintAxisLabels());
    }

    if (!this.mXAxis) {
      return;
    }

    let xlabelwidth = this.mXAxis.mLabelRotatedWidth;

    if (this.mXAxis && this.mXAxis.isEnabled()) {

      // offsets for x-labels
      if (this.mXAxis.getPosition() == XAxisPosition.BOTTOM) {

        offsetLeft += xlabelwidth;

      } else if (this.mXAxis.getPosition() == XAxisPosition.TOP) {

        offsetRight += xlabelwidth;

      } else if (this.mXAxis.getPosition() == XAxisPosition.BOTH_SIDED) {

        offsetLeft += xlabelwidth;
        offsetRight += xlabelwidth;
      }
    }

    offsetTop += this.getExtraTopOffset();
    offsetRight += this.getExtraRightOffset();
    offsetBottom += this.getExtraBottomOffset();
    offsetLeft += this.getExtraLeftOffset();

    let minOffset = Utils.handleDataValues(this.mMinOffset);

    this.mViewPortHandler.restrainViewPort(
      Math.max(minOffset, offsetLeft),
      Math.max(minOffset, offsetTop),
      Math.max(minOffset, offsetRight),
      Math.max(minOffset, offsetBottom));

    if (this.mLogEnabled) {
      LogUtil.log(ChartModel.LOG_TAG, "offsetLeft: " + offsetLeft + ", offsetTop: " + offsetTop + ", offsetRight: " +
      offsetRight + ", offsetBottom: "
      + offsetBottom);
      LogUtil.log(ChartModel.LOG_TAG, "Content: " + this.mViewPortHandler.getContentRect().toString());
    }

    this.prepareOffsetMatrix();
    this.prepareValuePxMatrix();
  }

  prepareValuePxMatrix(): void {
    if (this.mRightAxisTransformer && this.mAxisRight && this.mXAxis) {
      this.mRightAxisTransformer.prepareMatrixValuePx(this.mAxisRight.mAxisMinimum, this.mAxisRight.mAxisRange, this.mXAxis.mAxisRange,
        this.mXAxis.mAxisMinimum);
    }
    if (this.mLeftAxisTransformer && this.mAxisLeft && this.mXAxis) {
      this.mLeftAxisTransformer.prepareMatrixValuePx(this.mAxisLeft.mAxisMinimum, this.mAxisLeft.mAxisRange, this.mXAxis.mAxisRange,
        this.mXAxis.mAxisMinimum);
    }
  }

  protected getMarkerPosition(high: Highlight): number[] {
    return [high.getDrawY(), high.getDrawX()];
  }

  public getBarBounds(e: BarEntry, outputRect: MyRect): void {
    if (!this.mData) {
      return;
    }
    let bounds: MyRect = outputRect;
    let set: IBarDataSet | null = this.mData.getDataSetForEntry(e);

    if (set == null) {
      outputRect.set(Number.MIN_VALUE, Number.MIN_VALUE, Number.MIN_VALUE, Number.MIN_VALUE);
      return;
    }
    let y = e.getY();
    let x = e.getX();

    let barWidth = this.mData.getBarWidth();

    let top = x - barWidth / 2;
    let bottom = x + barWidth / 2;
    let left = y >= 0 ? y : 0;
    let right = y <= 0 ? y : 0;

    bounds.set(left, top, right, bottom);

    this.getTransformer(set.getAxisDependency())?.rectValueToPixel(bounds);

  }

  protected mGetPositionBuffer: number[] = new Array<number>(2);

  /**
   * Returns a recyclable MPPointF instance.
   *
   * @param e
   * @param axis
   * @return
   */
  getPosition(e: EntryOhos, axis: AxisDependency): MPPointF {
    let vals: number[] = this.mGetPositionBuffer;
    vals[0] = e.getY();
    vals[1] = e.getX();

    this.getTransformer(axis)?.pointValuesToPixel(vals);

    return MPPointF.getInstance(vals[0], vals[1]);
  }

  /**
   * Returns the Highlight object (contains x-index and DataSet index) of the selected value at the given touch point
   * inside the BarChart.
   *
   * @param x
   * @param y
   * @return
   */

  public getHighlightByTouchPoint(x: number, y: number): Highlight | null {

    if (this.mData == null) {
      if (this.mLogEnabled) {
        LogUtil.log(ChartModel.LOG_TAG, "Can't select by touch. No data set.");
      }
      return null;
    } else {
      let highLighter = this.getHighlighter();
      if (highLighter) {
        return highLighter.getHighlight(y, x); // switch x and y
      } else {
        return null;
      }
    }
  }

  public getLowestVisibleX(): number {
    this.getTransformer(AxisDependency.LEFT)?.getValuesByTouchPoint(this.mViewPortHandler.contentLeft(),
      this.mViewPortHandler.contentBottom(), this.posForGetLowestVisibleX);

    let xAxis = this.mXAxis;
    if (xAxis) {
      return Math.max(xAxis.mAxisMinimum, this.posForGetLowestVisibleX.y);
    } else {
      return -1;
    }
  }

  public getHighestVisibleX(): number {
    this.getTransformer(AxisDependency.LEFT)?.getValuesByTouchPoint(this.mViewPortHandler.contentLeft(),
      this.mViewPortHandler.contentTop(), this.posForGetHighestVisibleX);
    let xAxis = this.mXAxis;
    if (xAxis) {
      return Math.min(xAxis.mAxisMaximum, this.posForGetHighestVisibleX.y);
    } else {
      return -1;
    }
  }

  /**
   * ###### VIEWPORT METHODS BELOW THIS ######
   */

  public setVisibleXRangeMaximum(maxXRange: number): void {
    if (this.mXAxis) {
      let xScale = this.mXAxis.mAxisRange / (maxXRange);
      this.mViewPortHandler.setMinimumScaleY(xScale);
    }
  }

  // @Override
  public setVisibleXRange(minXRange: number, maxXRange: number): void {
    if (this.mXAxis) {
      let minScale = this.mXAxis.mAxisRange / minXRange;
      let maxScale = this.mXAxis.mAxisRange / maxXRange;
      this.mViewPortHandler.setMinMaxScaleY(minScale, maxScale);
    }
  }

  // @Override
  public setVisibleYRangeMaximum(maxYRange: number, axis: AxisDependency) {
    let yScale = this.getAxisRange(axis) / maxYRange;
    this.mViewPortHandler.setMinimumScaleX(yScale);
  }

  // @Override
  public setVisibleYRangeMinimum(minYRange: number, axis: AxisDependency) {
    let yScale = this.getAxisRange(axis) / minYRange;
    this.mViewPortHandler.setMaximumScaleX(yScale);
  }

  // @Override
  public setVisibleYRange(minYRange: number, maxYRange: number, axis: AxisDependency) {
    let minScale = this.getAxisRange(axis) / minYRange;
    let maxScale = this.getAxisRange(axis) / maxYRange;
    this.mViewPortHandler.setMinMaxScaleX(minScale, maxScale);
  }
}