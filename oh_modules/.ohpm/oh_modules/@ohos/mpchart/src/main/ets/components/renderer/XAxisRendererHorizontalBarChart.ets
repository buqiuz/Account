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

import Paint, { Style } from '../data/Paint';
import { XAxis, XAxisPosition } from '../components/XAxis';
import LimitLine, { LimitLabelPosition } from '../components/LimitLine';
import MyRect from '../data/Rect';
import FSize from '../utils/FSize';
import MPPointF from '../utils/MPPointF';
import MPPointD from '../utils/MPPointD';
import Transformer from '../utils/Transformer';
import Utils from '../utils/Utils';
import ViewPortHandler from '../utils/ViewPortHandler';
import { JArrayList } from '../utils/JArrayList';
import XAxisRenderer from './XAxisRenderer';
import BarChartModel from '../charts/BarChartModel';
import HashMap from '@ohos.util.HashMap';

export default class XAxisRendererHorizontalBarChart extends XAxisRenderer {
  protected mChart: BarChartModel;
  textSizeCache = new HashMap<string, TextMetrics>();

  constructor(viewPortHandler: ViewPortHandler, xAxis: XAxis, trans: Transformer, chart: BarChartModel) {
    super(viewPortHandler, xAxis, trans);
    this.mChart = chart;
  }

  public computeAxis(min: number, max: number, inverted: boolean): void {
    if (!this.mTrans || !this.mViewPortHandler) {
      return;
    }

    // calculate the starting and entry point of the y-labels (depending on
    // zoom / contentrect bounds)
    if (this.mViewPortHandler.contentWidth() > 10 && !this.mViewPortHandler.isFullyZoomedOutY()) {

      let p1: MPPointD = this.mTrans.getValuesByTouchPoint(this.mViewPortHandler.contentLeft(), this.mViewPortHandler.contentBottom());
      let p2: MPPointD = this.mTrans.getValuesByTouchPoint(this.mViewPortHandler.contentLeft(), this.mViewPortHandler.contentTop());

      if (inverted) {

        min = p2.y;
        max = p1.y;
      } else {

        min = p1.y;
        max = p2.y;
      }

      MPPointD.recycleInstance(p1);
      MPPointD.recycleInstance(p2);
    }

    this.computeAxisValues(min, max);
  }

  protected computeSize(): void {
    if (!this.mXAxis) {
      return;
    }

    this.mAxisLabelPaint.setFontFamily(this.mXAxis.getTypeface());
    this.mAxisLabelPaint.setTextSize(this.mXAxis.getTextSize());

    let longest: string = this.mXAxis.getLongestLabel();

    const labelSize = Utils.getLabelTextSize(this.mAxisLabelPaint, longest, this.textSizeCache);

    const labelWidth: number = Math.round(labelSize.width + this.mXAxis.getXOffset() * 3.5);
    const labelHeight: number = labelSize.height;

    let labelRotatedSize: FSize = Utils.getSizeOfRotatedRectangleByDegrees(
      labelSize.width,
      labelHeight,
      this.mXAxis.getLabelRotationAngle());

    this.mXAxis.mLabelWidth = Math.round(labelWidth);
    this.mXAxis.mLabelHeight = Math.round(labelHeight);
    this.mXAxis.mLabelRotatedWidth = Math.round(labelRotatedSize.width + this.mXAxis.getXOffset() * 3.5);
    this.mXAxis.mLabelRotatedHeight = Math.round(labelRotatedSize.height);

    FSize.recycleInstance(labelRotatedSize);
  }

  public renderAxisLabels(c: CanvasRenderingContext2D) {

    if (!this.mXAxis || !this.mXAxis.isEnabled() || !this.mXAxis.isDrawLabelsEnabled() || !this.mViewPortHandler)
      return;

    let xoffset: number = this.mXAxis.getXOffset();

    this.mAxisLabelPaint.setFontFamily(this.mXAxis.getTypeface());
    this.mAxisLabelPaint.setTextSize(this.mXAxis.getTextSize());
    this.mAxisLabelPaint.setColor(this.mXAxis.getTextColor());

    let pointF: MPPointF = MPPointF.getInstance(0, 0);

    if (this.mXAxis.getPosition() == XAxisPosition.TOP) {
      pointF.x = 0.0;
      pointF.y = 0.5;
      this.drawLabels(c, this.mViewPortHandler.contentRight() + xoffset, pointF);

    } else if (this.mXAxis.getPosition() == XAxisPosition.TOP_INSIDE) {
      pointF.x = 1.0;
      pointF.y = 0.5;
      this.drawLabels(c, this.mViewPortHandler.contentRight() - xoffset, pointF);

    } else if (this.mXAxis.getPosition() == XAxisPosition.BOTTOM) {
      pointF.x = 1.0;
      pointF.y = 0.5;
      this.drawLabels(c, this.mViewPortHandler.contentLeft() - xoffset, pointF);

    } else if (this.mXAxis.getPosition() == XAxisPosition.BOTTOM_INSIDE) {
      pointF.x = 1.0;
      pointF.y = 0.5;
      this.drawLabels(c, this.mViewPortHandler.contentLeft() + xoffset, pointF);

    } else { // BOTH SIDED
      pointF.x = 0.0;
      pointF.y = 0.5;
      this.drawLabels(c, this.mViewPortHandler.contentRight() + xoffset, pointF);
      pointF.x = 1.0;
      pointF.y = 0.5;
      this.drawLabels(c, this.mViewPortHandler.contentLeft() - xoffset, pointF);
    }

    MPPointF.recycleInstance(pointF);
  }

  protected drawLabels(c: CanvasRenderingContext2D, pos: number, anchor: MPPointF): void {
    if (!this.mXAxis || !this.mTrans || !this.mViewPortHandler) {
      return;
    }
    const labelRotationAngleDegrees: number = this.mXAxis.getLabelRotationAngle();
    let centeringEnabled: boolean = this.mXAxis.isCenterAxisLabelsEnabled();

    let positions: number[] = new Array(this.mXAxis.mEntryCount * 2);

    for (let i = 0; i < positions.length; i += 2) {

      // only fill x values
      if (centeringEnabled) {
        positions[i + 1] = this.mXAxis.mCenteredEntries[i / 2];
      } else {
        positions[i + 1] = this.mXAxis.mEntries[i / 2];
      }
    }

    this.mTrans.pointValuesToPixel(positions);

    for (let i = 0; i < positions.length; i += 2) {

      let y: number = positions[i + 1];

      if (this.mViewPortHandler.isInBoundsY(y)) {

        let label: string = this.mXAxis.getValueFormatter().getFormattedValue(this.mXAxis.mEntries[i / 2], this.mXAxis);
        this.drawLabel(c, label, pos, y, anchor, labelRotationAngleDegrees);
      }
    }
  }

  public getGridClippingRect(): MyRect {
    if (!this.mAxis || !this.mViewPortHandler) {
      return new MyRect();
    }
    this.mGridClippingRect.set(this.mViewPortHandler.getContentRect().left, this.mViewPortHandler.getContentRect().top
      , this.mViewPortHandler.getContentRect().right, this.mViewPortHandler.getContentRect().bottom);
    this.mGridClippingRect.inset(0, -this.mAxis.getGridLineWidth(), 0, -this.mAxis.getGridLineWidth());
    return this.mGridClippingRect;
  }

  protected drawGridLine(c: CanvasRenderingContext2D, x: number, y: number): void {
    // draw a path because lines don't support dashing on lower ohos versions
    Utils.resetContext2DWithoutFont(c, this.mGridPaint);
    c.beginPath();
    c.moveTo(this.mViewPortHandler ? this.mViewPortHandler.contentRight() : 0, y);
    c.lineTo(this.mViewPortHandler ? this.mViewPortHandler.contentLeft() : 0, y);
    c.stroke();
    c.closePath();
  }

  public renderAxisLine(c: CanvasRenderingContext2D) {

    if (!this.mXAxis || !this.mXAxis.isDrawAxisLineEnabled() || !this.mXAxis.isEnabled() || !this.mViewPortHandler) {
      return;
    }

    this.mAxisLinePaint.setColor(this.mXAxis.getAxisLineColor());
    this.mAxisLinePaint.setStrokeWidth(this.mXAxis.getAxisLineWidth());
    Utils.resetContext2DWithoutFont(c, this.mAxisLinePaint);

    const left = this.mViewPortHandler.contentLeft();
    const top = this.mViewPortHandler.contentTop();
    const right = this.mViewPortHandler.contentRight();
    const bottom = this.mViewPortHandler.contentBottom();

    if (this.mXAxis.getPosition() == XAxisPosition.TOP
      || this.mXAxis.getPosition() == XAxisPosition.TOP_INSIDE
      || this.mXAxis.getPosition() == XAxisPosition.BOTH_SIDED) {
      this.renderLine(c, right, top, right, bottom)
    }

    if (this.mXAxis.getPosition() == XAxisPosition.BOTTOM
      || this.mXAxis.getPosition() == XAxisPosition.BOTTOM_INSIDE
      || this.mXAxis.getPosition() == XAxisPosition.BOTH_SIDED) {
      this.renderLine(c, left, top, left, bottom)
    }
  }

  protected renderLine(c: CanvasRenderingContext2D, fromX: number, fromY: number, toX: number, toY: number) {
    c.beginPath();
    c.moveTo(fromX, fromY);
    c.lineTo(toX, toY);
    c.closePath();
    c.stroke();
  }

  protected mRenderLimitLinesPathBuffer: Path2D = new Path2D();

  /**
   * Draws the LimitLines associated with this axis to the screen.
   * This is the standard YAxis renderer using the XAxis limit lines.
   *
   * @param c
   */
  public renderLimitLines(c: CanvasRenderingContext2D) {
    if (!this.mXAxis || !this.mViewPortHandler) {
      return;
    }

    let limitLines: JArrayList<LimitLine> = this.mXAxis.getLimitLines();

    if (limitLines == null || limitLines.size() <= 0)
      return;

    let pts: number[] = this.mRenderLimitLinesBuffer;
    pts[0] = 0;
    pts[1] = 0;

    let limitLinePath: Path2D = this.mRenderLimitLinesPathBuffer;
    limitLinePath = new Path2D();

    for (let i = 0; i < limitLines.size(); i++) {

      let l: LimitLine = limitLines.get(i);

      if (!l.isEnabled())
        continue;

      c.save();
      this.mLimitLineClippingRect.set(this.mViewPortHandler.getContentRect()
        .left, this.mViewPortHandler.getContentRect().top
        , this.mViewPortHandler.getContentRect().right, this.mViewPortHandler.getContentRect().bottom);
      this.mLimitLineClippingRect.inset(0, -l.getLineWidth(), 0, -l.getLineWidth());

      this.mLimitLinePaint.setStyle(Style.STROKE);
      this.mLimitLinePaint.setColor(l.getLineColor());
      this.mLimitLinePaint.setStrokeWidth(l.getLineWidth());
      this.mLimitLinePaint.setDashPathEffect(l.getDashPathEffect());

      pts[1] = l.getLimit();

      this.mTrans?.pointValuesToPixel(pts);

      limitLinePath.moveTo(this.mViewPortHandler.contentLeft(), pts[1]);
      limitLinePath.lineTo(this.mViewPortHandler.contentRight(), pts[1]);

      // c.drawPath(limitLinePath, this.mLimitLinePaint);
      Utils.resetContext2DWithoutFont(c, this.mLimitLinePaint);
      c.beginPath();
      c.stroke(limitLinePath);
      c.closePath();
      limitLinePath = new Path2D();

      // c.drawLines(pts, mLimitLinePaint);

      let label: string = l.getLabel();

      // if drawing the limit-value label is enabled
      if (label != null && label != undefined && label.length > 0) {

        this.mLimitLinePaint.setStyle(l.getTextStyle());
        this.mLimitLinePaint.setDashPathEffect(null);
        this.mLimitLinePaint.setColor(l.getTextColor());
        this.mLimitLinePaint.setStrokeWidth(0.5);
        this.mLimitLinePaint.setTextSize(l.getTextSize());

        let labelLineHeight: number = Utils.getLabelTextSize(this.mLimitLinePaint, label, this.textSizeCache).height;
        let xOffset: number = Utils.handleDataValues(4) + l.getXOffset();
        let yOffset: number = l.getLineWidth() + labelLineHeight + l.getYOffset();

        let position: LimitLabelPosition = l.getLabelPosition();

        if (position == LimitLabelPosition.RIGHT_TOP) {

          this.mLimitLinePaint.setTextAlign("right");
          //					c.drawText(label,
          //                            mViewPortHandler.contentRight() - xOffset,
          //							pts[1] - yOffset + labelLineHeight, mLimitLinePaint);
          Utils.resetContext2DWithoutLine(c, this.mLimitLinePaint);
          c.beginPath();
          c.fillText(label, this.mViewPortHandler.contentRight() - xOffset,
            pts[1] - yOffset + labelLineHeight);
          c.closePath();

        } else if (position == LimitLabelPosition.RIGHT_BOTTOM) {

          this.mLimitLinePaint.setTextAlign("right");
          //                    c.drawText(label,
          //                            mViewPortHandler.contentRight() - xOffset,
          //                            pts[1] + yOffset, mLimitLinePaint);
          Utils.resetContext2DWithoutLine(c, this.mLimitLinePaint);
          c.beginPath();
          c.fillText(label, this.mViewPortHandler.contentRight() - xOffset,
            pts[1] + yOffset);
          c.closePath();

        } else if (position == LimitLabelPosition.LEFT_TOP) {

          this.mLimitLinePaint.setTextAlign("left");
          /* c.drawText(label,
                   mViewPortHandler.contentLeft() + xOffset,
                   pts[1] - yOffset + labelLineHeight, mLimitLinePaint);*/
          Utils.resetContext2DWithoutLine(c, this.mLimitLinePaint);
          c.beginPath();
          c.fillText(label, this.mViewPortHandler.contentLeft() + xOffset,
            pts[1] - yOffset + labelLineHeight);
          c.closePath();

        } else {

          this.mLimitLinePaint.setTextAlign("left");
          /*	c.drawText(label,
                              mViewPortHandler.offsetLeft() + xOffset,
                pts[1] + yOffset, mLimitLinePaint);*/
          Utils.resetContext2DWithoutLine(c, this.mLimitLinePaint);
          c.beginPath();
          c.fillText(label, this.mViewPortHandler.offsetLeft() + xOffset,
            pts[1] + yOffset);
          c.closePath();
        }
      }

      c.restore();
    }
  }
}
