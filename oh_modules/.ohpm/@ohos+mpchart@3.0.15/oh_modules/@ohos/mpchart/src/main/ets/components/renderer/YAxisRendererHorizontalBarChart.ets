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

import LimitLine, { LimitLabelPosition } from '../components/LimitLine';
import { JArrayList } from '../utils/JArrayList';
import MyRect from '../data/Rect';
import MPPointD from '../utils/MPPointD';
import Transformer from '../utils/Transformer';
import YAxis from '../components/YAxis';
import ViewPortHandler from '../utils/ViewPortHandler';
import YAxisRenderer from './YAxisRenderer';
import Utils from '../utils/Utils'
import { AxisDependency, YAxisLabelPosition } from '../components/YAxis'
import Paint, { Style } from '../data/Paint';
import HashMap from '@ohos.util.HashMap';

export default class YAxisRendererHorizontalBarChart extends YAxisRenderer {
  textSizeCache = new HashMap<string, TextMetrics>();

  constructor(viewPortHandler: ViewPortHandler, yAxis: YAxis,
              trans: Transformer) {
    super(viewPortHandler, yAxis, trans);

    this.mLimitLinePaint.setTextAlign("left");
  }

  /**
   * Computes the axis values.
   *
   * @param yMin - the minimum y-value in the data object for this axis
   * @param yMax - the maximum y-value in the data object for this axis
   */
  public computeAxis(yMin: number, yMax: number, inverted: boolean) {
    if (!this.mTrans || !this.mViewPortHandler) {
      return;
    }

    // calculate the starting and entry point of the y-labels (depending on
    // zoom / contentrect bounds)
    if (this.mViewPortHandler.contentHeight() > 10 && !this.mViewPortHandler.isFullyZoomedOutX()) {

      let p1: MPPointD = this.mTrans.getValuesByTouchPoint(this.mViewPortHandler.contentLeft(),
        this.mViewPortHandler.contentTop());
      let p2: MPPointD = this.mTrans.getValuesByTouchPoint(this.mViewPortHandler.contentRight(),
        this.mViewPortHandler.contentTop());

      if (!inverted) {
        yMin = p1.x;
        yMax = p2.x;
      } else {
        yMin = p2.x;
        yMax = p1.x;
      }

      MPPointD.recycleInstance(p1);
      MPPointD.recycleInstance(p2);
    }

    this.computeAxisValues(yMin, yMax);
  }

  /**
   * draws the y-axis labels to the screen
   */
  public renderAxisLabels(c: CanvasRenderingContext2D): void {

    if (!this.mYAxis || !this.mYAxis.isEnabled() || !this.mYAxis.isDrawLabelsEnabled() || !this.mViewPortHandler) {
      return;
    }

    let positions: number[] = this.getTransformedPositions();

    this.mAxisLabelPaint.setFontFamily(this.mYAxis.getTypeface());
    this.mAxisLabelPaint.setTextSize(this.mYAxis.getTextSize());
    this.mAxisLabelPaint.setColor(this.mYAxis.getTextColor());
    this.mAxisLabelPaint.setTextAlign("center");

    let baseYOffset = Utils.handleDataValues(2.5);
    let textHeight = Utils.getLabelTextSize(this.mAxisLabelPaint, "Q", this.textSizeCache).height;

    let dependency: AxisDependency = this.mYAxis.getAxisDependency();
    let labelPosition: YAxisLabelPosition = this.mYAxis.getLabelPosition();

    let yPos: number = 0;

    if (dependency == AxisDependency.LEFT) {

      if (labelPosition == YAxisLabelPosition.OUTSIDE_CHART) {
        yPos = this.mViewPortHandler.contentTop() - baseYOffset;
      } else {
        yPos = this.mViewPortHandler.contentTop() - baseYOffset;
      }

    } else {

      if (labelPosition == YAxisLabelPosition.OUTSIDE_CHART) {
        yPos = this.mViewPortHandler.contentBottom() + textHeight + baseYOffset;
      } else {
        yPos = this.mViewPortHandler.contentBottom() + textHeight + baseYOffset;
      }
    }

    this.drawYLabels(c, yPos, positions, this.mYAxis.getYOffset());
  }

  public renderAxisLine(c: CanvasRenderingContext2D) {

    if (!this.mYAxis || !this.mYAxis.isEnabled() || !this.mYAxis.isDrawAxisLineEnabled() || !this.mViewPortHandler) {
      return;
    }

    this.mAxisLinePaint.setColor(this.mYAxis.getAxisLineColor());
    this.mAxisLinePaint.setStrokeWidth(this.mYAxis.getAxisLineWidth());

    if (this.mYAxis.getAxisDependency() == AxisDependency.LEFT) {
      // c.drawLine(mViewPortHandler.contentLeft(),
      //   mViewPortHandler.contentTop(), mViewPortHandler.contentRight(),
      //   mViewPortHandler.contentTop(), mAxisLinePaint);
      Utils.resetContext2DWithoutFont(c, this.mAxisLinePaint);
      c.beginPath();
      c.moveTo(this.mViewPortHandler.contentLeft(), this.mViewPortHandler.contentTop());
      c.lineTo(this.mViewPortHandler.contentRight(), this.mViewPortHandler.contentTop());
      c.stroke();
      c.closePath();
    } else {
      // c.drawLine(mViewPortHandler.contentLeft(),
      //   mViewPortHandler.contentBottom(), mViewPortHandler.contentRight(),
      //   mViewPortHandler.contentBottom(), mAxisLinePaint);
      Utils.resetContext2DWithoutFont(c, this.mAxisLinePaint);
      c.beginPath();
      c.moveTo(this.mViewPortHandler.contentLeft(), this.mViewPortHandler.contentBottom());
      c.lineTo(this.mViewPortHandler.contentRight(), this.mViewPortHandler.contentBottom());
      c.stroke();
      c.closePath();
    }
  }

  /**
   * draws the y-labels on the specified x-position
   *
   * @param fixedPosition
   * @param positions
   */
  protected drawYLabels(c: CanvasRenderingContext2D, fixedPosition: number, positions: number[], offset: number): void {
    if (!this.mYAxis) {
      return;
    }
    this.mAxisLabelPaint.setFontFamily(this.mYAxis.getTypeface());
    this.mAxisLabelPaint.setTextSize(this.mYAxis.getTextSize());
    this.mAxisLabelPaint.setColor(this.mYAxis.getTextColor());

    const fromIndex = this.mYAxis.isDrawBottomYLabelEntryEnabled() ? 0 : 1;
    const to = this.mYAxis.isDrawTopYLabelEntryEnabled()
      ? this.mYAxis.mEntryCount
      : (this.mYAxis.mEntryCount - 1);

    let xOffset: number = this.mYAxis.getLabelXOffset();

    for (let i = fromIndex; i < to; i++) {

      let text: string = this.mYAxis.getFormattedLabel(i);

      Utils.resetContext2DWithoutLine(c, this.mAxisLabelPaint);
      c.beginPath();
      c.fillText(text, positions[i * 2], fixedPosition - offset + xOffset);
      c.closePath();
    }
  }

  protected getTransformedPositions(): number[] {
    if (!this.mYAxis) {
      return [];
    }
    if (this.mGetTransformedPositionsBuffer.length != this.mYAxis.mEntryCount * 2) {
      this.mGetTransformedPositionsBuffer = new Array<number>(this.mYAxis.mEntryCount * 2);
    }
    let positions: number[] = this.mGetTransformedPositionsBuffer;

    for (let i = 0; i < positions.length; i += 2) {
      // only fill x values, y values are not needed for x-labels
      positions[i] = this.mYAxis.mEntries[i / 2];
    }

    this.mTrans?.pointValuesToPixel(positions);
    return positions;
  }

  public getGridClippingRect(): MyRect {
    if (!this.mViewPortHandler) {
      this.mGridClippingRect.set(0, 0, 0, 0);
    } else {
      this.mGridClippingRect.set(this.mViewPortHandler.getContentRect().left, this.mViewPortHandler.getContentRect().top
        , this.mViewPortHandler.getContentRect().right, this.mViewPortHandler.getContentRect().bottom);
    }
    if (this.mAxis) {
      this.mGridClippingRect.inset(-this.mAxis.getGridLineWidth(), 0, -this.mAxis.getGridLineWidth(), 0);
    }
    return this.mGridClippingRect;
  }

  protected linePath(c: CanvasRenderingContext2D, i: number, positions: number[]): void {
    c.beginPath()
    c.moveTo(this.mViewPortHandler ? this.mViewPortHandler.offsetLeft() : 0, positions[i+1]);
    c.lineTo(this.mViewPortHandler ? this.mViewPortHandler.contentRight() : 0, positions[i+1]);
    c.stroke();
    c.closePath();
  }

  protected mDrawZeroLinePathBuffer: Path2D = new Path2D();

  protected drawZeroLine(c: CanvasRenderingContext2D): void {
    if (!this.mYAxis || !this.mTrans || !this.mViewPortHandler) {
      return;
    }
    c.save();
    this.mZeroLineClippingRect.set(this.mViewPortHandler.getContentRect().left, this.mViewPortHandler.getContentRect()
      .top,
      this.mViewPortHandler.getContentRect().right, this.mViewPortHandler.getContentRect().bottom);

    this.mZeroLineClippingRect.inset(-this.mYAxis.getZeroLineWidth(), 0, -this.mYAxis.getZeroLineWidth(), 0);

    // c.clipRect(mLimitLineClippingRect);
    c.rect(this.mLimitLineClippingRect.left, this.mLimitLineClippingRect.top, this.mLimitLineClippingRect.right - this.mLimitLineClippingRect.left, this.mLimitLineClippingRect.bottom - this.mLimitLineClippingRect.top);
    c.clip();

    // draw zero line
    let pos: MPPointD = this.mTrans.getPixelForValues(0, 0);

    this.mZeroLinePaint.setColor(this.mYAxis.getZeroLineColor());
    this.mZeroLinePaint.setStrokeWidth(this.mYAxis.getZeroLineWidth());

    let zeroLinePath: Path2D = this.mDrawZeroLinePathBuffer;


    // zeroLinePath.reset();
    zeroLinePath = new Path2D();

    zeroLinePath.moveTo(pos.x - 1, this.mViewPortHandler.contentTop());
    zeroLinePath.lineTo(pos.x - 1, this.mViewPortHandler.contentBottom());

    // draw a path because lines don't support dashing on lower ohos versions
    // c.drawPath(zeroLinePath, mZeroLinePaint);
    Utils.resetContext2DWithoutFont(c, this.mZeroLinePaint);
    c.beginPath();
    c.stroke(zeroLinePath);
    c.closePath();

    c.restore();

  }

  protected mRenderLimitLinesPathBuffer: Path2D = new Path2D();
  protected mRenderLimitLinesBuffer: Array<number> = new Array<number>(4);

  /**
   * Draws the LimitLines associated with this axis to the screen.
   * This is the standard XAxis renderer using the YAxis limit lines.
   *
   * @param c
   */
  public renderLimitLines(c: CanvasRenderingContext2D) {
    if (!this.mYAxis || !this.mViewPortHandler) {
      return;
    }

    let limitLines: JArrayList<LimitLine> = this.mYAxis.getLimitLines();

    if (limitLines == null || limitLines.size() <= 0) {
      return;
    }

    let pts: number[] = this.mRenderLimitLinesBuffer;
    pts[0] = 0;
    pts[1] = 0;
    pts[2] = 0;
    pts[3] = 0;
    let limitLinePath: Path2D = this.mRenderLimitLinesPathBuffer;
    limitLinePath = new Path2D();

    for (let i = 0; i < limitLines.size(); i++) {

      let l: LimitLine = limitLines.get(i);

      if (!l.isEnabled())
        continue;

      c.save();
      this.mLimitLineClippingRect.set(this.mViewPortHandler.getContentRect()
        .left, this.mViewPortHandler.getContentRect().top,
        this.mViewPortHandler.getContentRect().right, this.mViewPortHandler.getContentRect().bottom);
      this.mLimitLineClippingRect.inset(-l.getLineWidth(), 0, -l.getLineWidth(), 0);

      pts[0] = l.getLimit();
      pts[2] = l.getLimit();

      this.mTrans?.pointValuesToPixel(pts);

      pts[1] = this.mViewPortHandler.contentTop();
      pts[3] = this.mViewPortHandler.contentBottom();

      limitLinePath.moveTo(pts[0], pts[1]);
      limitLinePath.lineTo(pts[2], pts[3]);

      this.mLimitLinePaint.setStyle(Style.STROKE);
      this.mLimitLinePaint.setColor(l.getLineColor());
      this.mLimitLinePaint.setDashPathEffect(l.getDashPathEffect());
      this.mLimitLinePaint.setStrokeWidth(l.getLineWidth());

      Utils.resetContext2DWithoutFont(c, this.mLimitLinePaint);
      c.stroke(limitLinePath);
      let label: string = l.getLabel();

      // if drawing the limit-value label is enabled
      if (label != null && label != "") {

        this.mLimitLinePaint.setStyle(l.getTextStyle());
        this.mLimitLinePaint.setDashPathEffect(null);
        this.mLimitLinePaint.setColor(l.getTextColor());
        this.mLimitLinePaint.setFontFamily(l.getTypeface());
        this.mLimitLinePaint.setStrokeWidth(0.5);
        this.mLimitLinePaint.setTextSize(l.getTextSize());

        let xOffset: number = l.getLineWidth() + l.getXOffset();
        let yOffset: number = Utils.handleDataValues(2) + l.getYOffset();

        const position: LimitLabelPosition = l.getLabelPosition();

        c.beginPath();
        if (position == LimitLabelPosition.RIGHT_TOP) {

          const labelLineHeight: number = Utils.getLabelTextSize(this.mLimitLinePaint, label, this.textSizeCache)
            .height;
          this.mLimitLinePaint.setTextAlign("left");
          Utils.resetContext2DWithoutLine(c, this.mLimitLinePaint);
          c.fillText(label, pts[0] + xOffset, this.mViewPortHandler.contentTop() + yOffset + labelLineHeight);

        } else if (position == LimitLabelPosition.RIGHT_BOTTOM) {

          this.mLimitLinePaint.setTextAlign("left");
          Utils.resetContext2DWithoutLine(c, this.mLimitLinePaint);
          c.fillText(label, pts[0] + xOffset, this.mViewPortHandler.contentBottom() - yOffset);

        } else if (position == LimitLabelPosition.LEFT_TOP) {

          this.mLimitLinePaint.setTextAlign("right");
          const labelLineHeight: number = Utils.getLabelTextSize(this.mLimitLinePaint, label, this.textSizeCache)
            .height;
          Utils.resetContext2DWithoutLine(c, this.mLimitLinePaint);
          c.fillText(label, pts[0] - xOffset, this.mViewPortHandler.contentTop() + yOffset + labelLineHeight);

        } else {

          this.mLimitLinePaint.setTextAlign("right");
          Utils.resetContext2DWithoutLine(c, this.mLimitLinePaint);
          c.fillText(label, pts[0] - xOffset, this.mViewPortHandler.contentBottom() - yOffset);

        }
        c.closePath();
      }
      c.restore();
    }
  }
}
