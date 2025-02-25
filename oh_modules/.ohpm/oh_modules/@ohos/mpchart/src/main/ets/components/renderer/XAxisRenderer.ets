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

import AxisRenderer from './AxisRenderer'
import { XAxis, XAxisPosition } from '../components/XAxis'
import ViewPortHandler from '../utils/ViewPortHandler'
import Transformer from '../utils/Transformer'
import Utils from '../utils/Utils'
import FSize from '../utils/FSize'
import MPPointF from '../utils/MPPointF'
import MPPointD from '../utils/MPPointD'
import LimitLine, { LimitLabelPosition } from '../components/LimitLine'
import { JArrayList } from '../utils/JArrayList'
import MyRect from '../data/Rect'
import Paint, { Style } from '../data/Paint'
import { XAxisLabelPosition } from '../components/XAxisLabelPosition'
import HashMap from '@ohos.util.HashMap'

export default class XAxisRenderer extends AxisRenderer {
  protected mXAxis: XAxis | null = null;
  protected textSizeCache = new HashMap<string, TextMetrics>();

  constructor(viewPortHandler: ViewPortHandler, xAxis: XAxis, trans?: Transformer) {
    super(viewPortHandler, xAxis, trans);
    this.mXAxis = xAxis;
    if (this.mAxisLabelPaint) {

      this.mAxisLabelPaint.setColor(Color.Black);
      this.mAxisLabelPaint.setTextAlign('center');
      this.mAxisLabelPaint.setTextSize(10);
    }
  }

  protected setupGridPaint() {
    if (this.mGridPaint && this.mAxis && this.mXAxis) {
      this.mGridPaint.setGlobalAlpha(this.mXAxis.getGridAlpha() / 255);
      this.mGridPaint.setColor(this.mXAxis.getGridColor());
      this.mGridPaint.setStrokeWidth(this.mXAxis.getGridLineWidth());
      let dashPathEffect = this.mAxis.getGridDashPathEffect();
      this.mGridPaint.setDashPathEffect(dashPathEffect);
    }
  }

  public computeAxis(min: number, max: number, inverted: boolean) {

    // calculate the starting and entry point of the y-labels (depending on
    // zoom / contentrect bounds)
    if (!this.mViewPortHandler || !this.mTrans) {
      return;
    }
    if (this.mViewPortHandler.contentWidth() > 10 && !this.mViewPortHandler.isFullyZoomedOutX()) {

      let p1: MPPointD | undefined = this.mTrans?.getValuesByTouchPoint(this.mViewPortHandler.contentLeft(), this.mViewPortHandler.contentTop());
      let p2: MPPointD | undefined = this.mTrans?.getValuesByTouchPoint(this.mViewPortHandler.contentRight(), this.mViewPortHandler.contentTop());

      if (!!p1 && !!p2) {
        if (inverted) {

          min = p2.x;
          max = p1.x;
        } else {

          min = p1.x;
          max = p2.x;
        }

        MPPointD.recycleInstance(p1);
        MPPointD.recycleInstance(p2);
      }
    }

    this.computeAxisValues(min, max);
  }

  //     @Override
  protected computeAxisValues(min: number, max: number) {
    if (this.mXAxis?.isDrawCustomLabels()) {
      let labels = (this.mXAxis as XAxis)?.getCustomLabels();
      this.mXAxis.mEntries = labels;
      this.mXAxis.mCenteredEntries = labels;
      this.mXAxis.mEntryCount = labels.length;
    } else {
      super.computeAxisValues(min, max);
    }
    this.computeSize();
  }

  protected computeSize() {
    if (!this.mAxis || !this.mXAxis) {
      return;
    }
    let longest: string = this.mXAxis.getLongestLabel();

    if (this.mAxisLabelPaint) {
      this.mAxisLabelPaint.setFontFamily(this.mXAxis.getTypeface());
      this.mAxisLabelPaint.setTextSize(this.mXAxis.getTextSize());

      let labelWidth = Utils.getLabelTextSize(this.mAxisLabelPaint, longest, this.textSizeCache).width;
      let labelHeight = Utils.getLabelTextSize(this.mAxisLabelPaint, longest, this.textSizeCache).height;

      let labelRotatedSize: FSize = Utils.getSizeOfRotatedRectangleByDegrees(
        labelWidth,
        labelHeight,
        this.mXAxis.getLabelRotationAngle());


      this.mXAxis.mLabelWidth = Math.round(labelWidth);
      this.mXAxis.mLabelHeight = Math.round(labelHeight);
      this.mXAxis.mLabelRotatedWidth = Math.round(labelRotatedSize.width);
      this.mXAxis.mLabelRotatedHeight = Math.round(labelRotatedSize.height);

      FSize.recycleInstance(labelRotatedSize);
    }
  }

  public renderAxisLabels(c: CanvasRenderingContext2D, isHorizontalFlip: boolean): void {
    if (!this.mXAxis || !this.mViewPortHandler) {
      return;
    }
    if (!this.mXAxis.isEnabled() || !this.mXAxis.isDrawLabelsEnabled())
      return;

    let yoffset = this.mXAxis.getYOffset();

    if (this.mAxisLabelPaint) {
      this.mAxisLabelPaint.setFontFamily(this.mXAxis.getTypeface());
      this.mAxisLabelPaint.setTextSize(this.mXAxis.getTextSize());
      this.mAxisLabelPaint.setColor(this.mXAxis.getTextColor());
    }
    let pointF: MPPointF = MPPointF.getInstance(0, 0);
    if (this.mXAxis.getPosition() == XAxisPosition.TOP) {
      pointF.x = 0.5;
      pointF.y = 1.0;
      this.drawLabels(c, this.mViewPortHandler.contentTop() - yoffset, pointF, isHorizontalFlip);

    } else if (this.mXAxis.getPosition() == XAxisPosition.TOP_INSIDE) {
      pointF.x = 0.5;
      pointF.y = 1.0;
      this.drawLabels(c, this.mViewPortHandler.contentTop() + yoffset + this.mXAxis.mLabelRotatedHeight, pointF, isHorizontalFlip);

    } else if (this.mXAxis.getPosition() == XAxisPosition.BOTTOM) {
      pointF.x = 0.5;
      pointF.y = 0.0;
      this.drawLabels(c, this.mViewPortHandler.contentBottom() + yoffset, pointF, isHorizontalFlip);

    } else if (this.mXAxis.getPosition() == XAxisPosition.BOTTOM_INSIDE) {
      pointF.x = 0.5;
      pointF.y = 0.0;
      this.drawLabels(c, this.mViewPortHandler.contentBottom() - yoffset - this.mXAxis.mLabelRotatedHeight, pointF, isHorizontalFlip);

    } else { // BOTH SIDED

      pointF.x = 0.5;
      pointF.y = 1.0;
      this.drawLabels(c, this.mViewPortHandler.contentTop() - yoffset, pointF, isHorizontalFlip);
      pointF.x = 0.5;
      pointF.y = 0.0;
      this.drawLabels(c, this.mViewPortHandler.contentBottom() + yoffset, pointF, isHorizontalFlip);
    }
    MPPointF.recycleInstance(pointF);
  }

  public renderAxisLine(c: CanvasRenderingContext2D): void {

    if (!this.mAxisLinePaint || !this.mViewPortHandler || !this.mXAxis || !this.mXAxis.isDrawAxisLineEnabled() || !this.mXAxis.isEnabled())
      return;
    this.mAxisLinePaint.setColor(this.mXAxis.getAxisLineColor());
    this.mAxisLinePaint.setStrokeWidth(this.mXAxis.getAxisLineWidth());
    this.mAxisLinePaint.setDashPathEffect(this.mXAxis.getAxisLineDashPathEffect());

    // 重置更新Context上下文样式
    Utils.resetContext2DWithoutFont(c, this.mAxisLinePaint);
    let left = this.mViewPortHandler.contentLeft();
    let top = this.mViewPortHandler.contentTop();
    let right = this.mViewPortHandler.contentRight();
    let bottom = this.mViewPortHandler.contentBottom();

    if (this.mXAxis.getPosition() == XAxisPosition.TOP
    || this.mXAxis.getPosition() == XAxisPosition.TOP_INSIDE
    || this.mXAxis.getPosition() == XAxisPosition.BOTH_SIDED) {
      c.beginPath();
      c.moveTo(left, top);
      c.lineTo(right, top);
      c.stroke();
      c.closePath();
    }

    if (this.mXAxis.getPosition() == XAxisPosition.BOTTOM
    || this.mXAxis.getPosition() == XAxisPosition.BOTTOM_INSIDE
    || this.mXAxis.getPosition() == XAxisPosition.BOTH_SIDED) {
      c.beginPath();
      c.moveTo(left, bottom)
      c.lineTo(right, bottom);
      c.stroke();
      c.closePath();
    }
  }

  /**
   * draws the x-labels on the specified y-position
   *
   * @param pos
   */
  protected drawLabels(c: CanvasRenderingContext2D, pos: number, anchor: MPPointF, isHorizontalFlip: boolean): void {
    if (!this.mXAxis) {
      return;
    }
    let labelRotationAngleDegrees = this.mXAxis.getLabelRotationAngle();
    let centeringEnabled = this.mXAxis.isCenterAxisLabelsEnabled();

    let positions: number[] = new Array<number>(this.mXAxis.mEntryCount * 2);

    let labelPosition = this.mXAxis.getXAxisLabelPosition();
    for (let i = 0; i < positions.length; i += 2) {

      // only fill x values
      if (centeringEnabled) {
        positions[i] = this.mXAxis.mCenteredEntries[i / 2];
      } else {
        positions[i] = this.mXAxis.mEntries[i / 2];
      }
    }
    if (this.mTrans) {
      this.mTrans.pointValuesToPixel(positions);
    }

    let xOffset = this.mXAxis.getLabelXOffset();
    for (let i = 0; i < positions.length; i += 2) {

      let x = positions[i] + xOffset;

      // if (this.mViewPortHandler && this.mViewPortHandler.isInBoundsX(this.getXRelativeValue(x)/this.getAxisPercent())) {
      if (this.mViewPortHandler && this.mViewPortHandler.isInBoundsX(x)) {

        let label = this.mXAxis.getValueFormatter().getFormattedValue(this.mXAxis.mEntries[i / 2], this.mXAxis);

        if (this.mXAxis.isAvoidFirstLastClippingEnabled()) {

          const width = Utils.getLabelTextSize(this.mAxisLabelPaint, label, this.textSizeCache).width;
          // avoid clipping of the last
          if (i / 2 == this.mXAxis.mEntryCount - 1 && this.mXAxis.mEntryCount > 1) {

            if (width > this.mViewPortHandler.offsetRight() * 2
            && x + width > this.mViewPortHandler.getChartWidth())
              x -= width / 2;

            // avoid clipping of the first
          } else if (i == 0) {

            x += width / 2;
          }
        }

        this.drawLabel(c, label, x, pos, anchor, labelRotationAngleDegrees, labelPosition, isHorizontalFlip);
      }
    }
  }

  protected drawLabel(c: CanvasRenderingContext2D, formattedLabel: string, x: number, y: number, anchor: MPPointF, angleDegrees: number, labelPosition: XAxisLabelPosition = XAxisLabelPosition.Center, isHorizontalFlip: boolean = false): void {
    this.drawXAxisValue(c, formattedLabel, x, y, this.mAxisLabelPaint, anchor, angleDegrees, labelPosition, isHorizontalFlip);
  }

  private drawXAxisValue(c: CanvasRenderingContext2D, text: string, x: number, y: number,
                         paint: Paint, anchor: MPPointF, angleDegrees: number, labelPosition: XAxisLabelPosition = XAxisLabelPosition.Center, isHorizontalFlip: boolean = false): void {
    let drawOffsetX: number = 0.0;
    let drawOffsetY: number = 0.0;

    // 防止计算出来的宽度，高度等数据不准确
    const textSize = Utils.getLabelTextSize(paint, text, this.textSizeCache);
    let lineHeight = textSize.height;

    // To have a consistent point of reference, we always draw left-aligned
    let originalTextAlign: CanvasTextAlign = paint.getTextAlign();
    let originalTextBaseLine: CanvasTextBaseline = paint.getTextBaseline();

    paint.setTextAlign('left');
    paint.setTextBaseline('top');
    Utils.resetContext2DWithoutLine(c, paint);
    if (angleDegrees != 0.0) {

      // Move the text drawing rect in a way that it always rotates around its center
      drawOffsetX -= textSize.width * 0.5;
      drawOffsetY -= lineHeight * 0.5;

      let translateX: number = x;
      let translateY: number = y;

      // Move the "outer" rect relative to the anchor, assuming its centered
      if (anchor.x != 0.5 || anchor.y != 0.5) {
        const rotatedSize: FSize = Utils.getSizeOfRotatedRectangleByDegrees(
          textSize.width,
          lineHeight,
          angleDegrees);

        translateX -= rotatedSize.width * (anchor.x - 0.5);
        if (labelPosition == XAxisLabelPosition.Right) {
          translateX += rotatedSize.width * 0.5;
        } else if (labelPosition == XAxisLabelPosition.Left) {
          translateX -= rotatedSize.width * 0.5;
        }
        translateY -= rotatedSize.height * (anchor.y - 0.5);
        FSize.recycleInstance(rotatedSize);
      }

      c.save();
      c.translate(translateX, translateY);
      c.rotate(angleDegrees * Math.PI / 180);
      switch (paint.getStyle()) {
        case Style.STROKE:
          c.beginPath();
          c.strokeText(text, drawOffsetX, drawOffsetY);
          c.closePath();
          break
        case Style.FILL_AND_STROKE:
        case Style.FILL:
        default:
          c.beginPath();
          c.fillText(text, drawOffsetX, drawOffsetY);
          c.closePath();
          break
      }
      c.restore();
    } else {
      if (anchor.x != 0.0 || anchor.y != 0.0) {

        drawOffsetX -= textSize.width * anchor.x;
        drawOffsetY -= lineHeight * anchor.y;
      }

      drawOffsetX += x;
      if (labelPosition == XAxisLabelPosition.Right) {
        drawOffsetX += textSize.width * 0.5;
      } else if (labelPosition == XAxisLabelPosition.Left) {
        drawOffsetX -= textSize.width * 0.5;
      }
      drawOffsetY += y;

      if (isHorizontalFlip) {
        c.save();
        c.scale(-1, 1);
      }
      const horizontalFlipWidth = -drawOffsetX - Utils.getLabelTextSize(paint, text, this.textSizeCache).width;
      switch (paint.getStyle()) {
        case Style.STROKE:
          c.beginPath();
          if (isHorizontalFlip) {

            c.strokeText(text, horizontalFlipWidth, drawOffsetY);
          } else {
            c.strokeText(text, drawOffsetX, drawOffsetY);
          }
          c.closePath();
          break
        case Style.FILL_AND_STROKE:
        case Style.FILL:
        default:
          c.beginPath();
          if (isHorizontalFlip) {
            c.fillText(text, horizontalFlipWidth, drawOffsetY);
          } else {
            c.fillText(text, drawOffsetX, drawOffsetY);
          }
          c.closePath();
          break
      }
      if (isHorizontalFlip) {
        c.restore();
      }
    }
    paint.setTextAlign(originalTextAlign);
    paint.setTextBaseline(originalTextBaseLine);
  }

  protected mRenderGridLinesBuffer: number[] = new Array(2);

  public renderGridLines(c: CanvasRenderingContext2D): void {

    if (!this.mAxis || !this.mXAxis || !this.mXAxis.isDrawGridLinesEnabled() || !this.mXAxis.isEnabled()) {
      return;
    }
    c.save();
    c.beginPath();
    let clippingRect = this.getGridClippingRect();
    c.rect(clippingRect.left, clippingRect.top, clippingRect.width(), clippingRect.height());
    c.closePath();
    c.clip();

    if (this.mRenderGridLinesBuffer.length != this.mAxis.mEntryCount * 2) {
      this.mRenderGridLinesBuffer = new Array<number>(this.mXAxis.mEntryCount * 2);
    }
    let positions: number[] = this.mRenderGridLinesBuffer;

    for (let i = 0; i < positions.length; i += 2) {
      positions[i] = this.mXAxis.mEntries[i / 2];
      positions[i + 1] = this.mXAxis.mEntries[i / 2];
    }
    if (this.mTrans) {
      this.mTrans.pointValuesToPixel(positions);
    }

    this.setupGridPaint();

    for (let i = 0; i < positions.length; i += 2) {
      this.drawGridLine(c, positions[i], positions[i+1]);
    }
    c.restore();
  }

  protected mGridClippingRect: MyRect = new MyRect();

  public getGridClippingRect(): MyRect {
    if (this.mViewPortHandler) {
      this.mGridClippingRect.set(this.mViewPortHandler.getContentRect().left, this.mViewPortHandler.getContentRect().top
        , this.mViewPortHandler.getContentRect().right, this.mViewPortHandler.getContentRect().bottom);
    }
    if (this.mAxis) {
      this.mGridClippingRect.inset(-this.mAxis.getGridLineWidth(), 0, -this.mAxis.getGridLineWidth(), 0,);
    }
    return this.mGridClippingRect;
  }

  /**
   * Draws the grid line at the specified position using the provided path.
   *
   * @param c
   * @param x
   * @param y
   * @param gridLinePath
   */
  protected drawGridLine(c: CanvasRenderingContext2D, x: number, y: number): void {
    Utils.resetContext2DWithoutFont(c, this.mGridPaint);
    c.beginPath();
    c.moveTo(x, (this.mViewPortHandler ? this.mViewPortHandler.contentBottom() : 0));
    c.lineTo(x, (this.mViewPortHandler ? this.mViewPortHandler.contentTop() : 0));
    c.stroke();
    c.closePath();
  }

  protected mRenderLimitLinesBuffer = new Array<number>(2);
  protected mLimitLineClippingRect = new MyRect();

  private renderLinesInner(c: CanvasRenderingContext2D, lines: JArrayList<LimitLine>) {
    if (!this.mXAxis || !this.mAxis) {
      return;
    }

    if (!lines || lines.size() <= 0)
      return;

    let position = this.mRenderLimitLinesBuffer;
    position[0] = 0;
    position[1] = 0;

    for (let i = 0; i < lines.size(); i++) {

      let l: LimitLine = lines.get(i);
      if (!l.isEnabled()) {
        continue;
      }
      c.save();
      if (this.mViewPortHandler) {
        this.mLimitLineClippingRect.set(this.mViewPortHandler.getContentRect()
          .left, this.mViewPortHandler.getContentRect().top
          , this.mViewPortHandler.getContentRect().right, this.mViewPortHandler.getContentRect().bottom);
      }

      c.beginPath();
      c.rect(this.mLimitLineClippingRect.left, this.mLimitLineClippingRect.top, this.mLimitLineClippingRect.width(), this.mLimitLineClippingRect.height());
      c.closePath();
      c.clip();

      if (this.mAxis) {
        this.mGridClippingRect.inset(-this.mAxis.getGridLineWidth(), 0, -this.mAxis.getGridLineWidth(), 0,);
      }

      position[0] = l.getLimit();
      position[1] = 0;
      if (this.mTrans) {
        this.mTrans.pointValuesToPixel(position);
      }
      this.renderLimitLineLine(c, l, position)
      this.renderLimitLineLabel(c, l, position, 2 + l.getYOffset());
      c.restore();
    }
  }

  /**
   * render custom grid lines.
   *
   * @param c
   */
  public renderCustomGridLines(c: CanvasRenderingContext2D) {
    let gridLines = this.mXAxis?.getGridLines();

    gridLines && this.renderLinesInner(c, gridLines);
  }

  /**
   * return the LimitLines draw data.
   *
   * @param c
   */
  public renderLimitLines(c: CanvasRenderingContext2D): void {
    let limitLines = this.mXAxis?.getLimitLines();

    limitLines && this.renderLinesInner(c, limitLines);
  }

  public mLimitLineSegmentsBuffer: number[] = new Array<number>(4);

  public renderLimitLineLine(c: CanvasRenderingContext2D, limitLine: LimitLine, position: number[]): void {
    this.mLimitLineSegmentsBuffer[0] = position[0];
    this.mLimitLineSegmentsBuffer[1] = this.mViewPortHandler ? this.mViewPortHandler.contentTop() : 0;
    this.mLimitLineSegmentsBuffer[2] = position[0];
    this.mLimitLineSegmentsBuffer[3] = this.mViewPortHandler ? this.mViewPortHandler.contentBottom() : 0;

    if (this.mLimitLinePaint) {
      this.mLimitLinePaint.setStyle(Style.STROKE);
      this.mLimitLinePaint.setColor(limitLine.getLineColor());
      this.mLimitLinePaint.setStrokeWidth(limitLine.getLineWidth());
      let dashPathEffect = limitLine.getDashPathEffect();
      if (dashPathEffect) {
        this.mLimitLinePaint.setDashPathEffect(dashPathEffect);
      }

      Utils.resetContext2DWithoutFont(c, this.mLimitLinePaint)
      c.beginPath();
      c.moveTo(this.mLimitLineSegmentsBuffer[0], this.mLimitLineSegmentsBuffer[1]);
      c.lineTo(this.mLimitLineSegmentsBuffer[2], this.mLimitLineSegmentsBuffer[3]);
      c.stroke();
      c.closePath();
    }
  }

  public renderLimitLineLabel(c: CanvasRenderingContext2D, limitLine: LimitLine, position: number[], yOffset: number): void {

    let label: string = limitLine.getLabel();

    // if drawing the limit-value label is enabled
    if (label && label.length > 0) {
      if (this.mLimitLinePaint) {
        this.mLimitLinePaint.setStyle(limitLine.getTextStyle());
        this.mLimitLinePaint.setDashPathEffect(null);
        this.mLimitLinePaint.setColor(limitLine.getTextColor());
        this.mLimitLinePaint.setStrokeWidth(0.5);
        this.mLimitLinePaint.setTextSize(limitLine.getTextSize());
      }

      let xOffset = limitLine.getLineWidth() + limitLine.getXOffset();

      let labelPosition: LimitLabelPosition = limitLine.getLabelPosition();
      let paintStyle = this.mLimitLinePaint.getStyle();

      if (labelPosition == LimitLabelPosition.RIGHT_TOP) {
        const labelLineHeight = Utils.getLabelTextSize(this.mLimitLinePaint, label, this.textSizeCache).height;
        this.mLimitLinePaint.setTextAlign('left');

        Utils.resetContext2DWithoutLine(c, this.mLimitLinePaint);
        switch (paintStyle) {
          case Style.STROKE:
            c.beginPath();
            c.strokeText(label, position[0] + xOffset, (this.mViewPortHandler ? this.mViewPortHandler.contentTop() : 0) + yOffset + labelLineHeight);
            c.closePath();
            break
          case Style.FILL:
          case Style.FILL_AND_STROKE:
          default:
            c.beginPath();
            c.fillText(label, position[0] + xOffset, (this.mViewPortHandler ? this.mViewPortHandler.contentTop() : 0) + yOffset + labelLineHeight);
            c.closePath();
            break;
        }
      } else if (labelPosition == LimitLabelPosition.RIGHT_BOTTOM) {
        this.mLimitLinePaint.setTextAlign('left');

        Utils.resetContext2DWithoutLine(c, this.mLimitLinePaint);
        switch (paintStyle) {
          case Style.STROKE:
            c.beginPath();
            c.strokeText(label, position[0] + xOffset, (this.mViewPortHandler ? this.mViewPortHandler.contentBottom() : 0) - yOffset);
            c.closePath();
            break;
          case Style.FILL:
          case Style.FILL_AND_STROKE:
          default:
            c.beginPath();
            c.fillText(label, position[0] + xOffset, (this.mViewPortHandler ? this.mViewPortHandler.contentBottom() : 0) - yOffset);
            c.closePath();
            break;
        }
      } else if (labelPosition == LimitLabelPosition.LEFT_TOP) {
        this.mLimitLinePaint.setTextAlign('right');
        const labelLineHeight = Utils.getLabelTextSize(this.mLimitLinePaint, label, this.textSizeCache).height;

        Utils.resetContext2DWithoutLine(c, this.mLimitLinePaint);
        switch (paintStyle) {
          case Style.STROKE:
            c.beginPath();
            c.strokeText(label, position[0] - xOffset, this.mViewPortHandler ? this.mViewPortHandler.contentTop() : 0 + yOffset + labelLineHeight);
            c.closePath();
            break
          case Style.FILL:
          case Style.FILL_AND_STROKE:
          default:
            c.beginPath();
            c.fillText(label, position[0] - xOffset, this.mViewPortHandler ? this.mViewPortHandler.contentTop() : 0 + yOffset + labelLineHeight);
            c.closePath();
            break;
        }
      } else {
        this.mLimitLinePaint.setTextAlign('right');
        Utils.resetContext2DWithoutLine(c, this.mLimitLinePaint);
        switch (paintStyle) {
          case Style.STROKE:
            c.beginPath();
            c.strokeText(label, position[0] - xOffset, (this.mViewPortHandler ? this.mViewPortHandler.contentBottom() : 0) - yOffset);
            c.closePath();
            break
          case Style.FILL:
          case Style.FILL_AND_STROKE:
          default:
            c.beginPath();
            c.fillText(label, position[0] - xOffset, (this.mViewPortHandler ? this.mViewPortHandler.contentBottom() : 0) - yOffset);
            c.closePath();
            break;
        }
      }
    }
  }

  // public calcXLeftOffset(xVlaus:number):number{
  //   if (this.mAxis) {
  //     let xResult=(xVlaus-this.mAxis.getAxisMinimum())/this.getAxisPercent()+(this.mViewPortHandler?this.mViewPortHandler.contentLeft():0)+this.getLeftYTextWidth()
  //     return xResult;
  //   }
  //  return 0;
  // }
  // public getAxisPercent():number{
  //   if (this.mAxis) {
  //     return (this.mAxis.getAxisMaximum()-this.mAxis.getAxisMinimum())/this.getLineRange()
  //   }
  //   return 0;
  // }
  // public getLeftYTextWidth():number{
  //   if (this.mAxisLabelPaint) {
  //     return  Utils.calcTextWidth(this.mAxisLabelPaint,this.yLeftLongestLabel);
  //   }
  //  return 0;
  // }
  // public getRightYTextWidth():number{
  //   if (this.mAxisLabelPaint) {
  //     return Utils.calcTextWidth(this.mAxisLabelPaint, this.yRightLongestLabel);
  //   }
  //   return 0;
  // }
  // public getLineRange():number{
  //   if (this.mViewPortHandler) {
  //     return this.mViewPortHandler.contentRight()-this.mViewPortHandler.contentLeft()-this.getLeftYTextWidth()-this.getRightYTextWidth();
  //   }
  //   return 0;
  // }
  // public getXRelativeValue(x: number): number {
  //   if (this.mAxis) {
  //     return x - this.mAxis.getAxisMinimum();
  //   }
  //   return x;
  // }
}

