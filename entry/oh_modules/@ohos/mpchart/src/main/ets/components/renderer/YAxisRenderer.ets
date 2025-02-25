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

import MyRect from '../data/Rect';
import YAxis, { AxisDependency, YAxisLabelPosition } from '../components/YAxis';
import Paint, { Style } from '../data/Paint';
import Utils from '../utils/Utils';
import AxisRenderer from '../renderer/AxisRenderer';
import LimitLine, { LimitLabelPosition } from '../components/LimitLine';
import { JArrayList } from '../utils/JArrayList';
import ViewPortHandler from '../utils/ViewPortHandler';
import Transformer from '../utils/Transformer';
import MPPointD from '../utils/MPPointD';
import HashMap from '@ohos.util.HashMap';

export default class YAxisRenderer extends AxisRenderer {
  protected mYAxis: YAxis | null = null;
  protected mZeroLinePaint: Paint = new Paint();
  textSizeCache = new HashMap<string, TextMetrics>();

  constructor(viewPortHandler: ViewPortHandler, yAxis: YAxis, trans?: Transformer) {
    super(viewPortHandler, yAxis, trans)
    this.mYAxis = yAxis;

    if (viewPortHandler != null) {
      if (this.mAxisLabelPaint) {
        this.mAxisLabelPaint.setColor(Color.Black);
        this.mAxisLabelPaint.setTextSize(10);
      }

      this.mZeroLinePaint = new Paint();
      this.mZeroLinePaint.setColor(Color.Gray);
      this.mZeroLinePaint.setStrokeWidth(1);
      this.mZeroLinePaint.setStyle(Style.STROKE);
    }
  }

  /**
   * draws the y-axis labels to the screen
   */
  public renderAxisLabels(c: CanvasRenderingContext2D, isHorizontalFlip: boolean, isLeftAxis: boolean): void {
    if (!this.mYAxis) {
      return
    }
    if (!this.mYAxis.isEnabled() || !this.mYAxis.isDrawLabelsEnabled())
      return;

    let positions: number[] = this.getTransformedPositions();

    if (this.mAxisLabelPaint) {
      this.mAxisLabelPaint.setFontFamily(this.mYAxis.getTypeface());
      this.mAxisLabelPaint.setTextSize(this.mYAxis.getTextSize());
      this.mAxisLabelPaint.setColor(this.mYAxis.getTextColor());

      let xOffset = this.mYAxis.getXOffset();
      let yOffset = Utils.getLabelTextSize(this.mAxisLabelPaint, "A", this.textSizeCache)
        .height + this.mYAxis.getYOffset();
      let dependency: AxisDependency = this.mYAxis.getAxisDependency();
      let labelPosition: YAxisLabelPosition = this.mYAxis.getLabelPosition();

      let xPos: number = 0;

      if (dependency == AxisDependency.LEFT) {

        if (labelPosition == YAxisLabelPosition.OUTSIDE_CHART) {
          if (this.mAxisLabelPaint) {
            this.mAxisLabelPaint.setTextAlign('right');
          }

          xPos = (this.mViewPortHandler ? this.mViewPortHandler.offsetLeft() : 0) - xOffset;
        } else {
          if (this.mAxisLabelPaint) {
            this.mAxisLabelPaint.setTextAlign('left');
          }
          if (this.mViewPortHandler) {
            xPos = (this.mViewPortHandler ? this.mViewPortHandler.offsetLeft() : 0) + xOffset;
          }
        }
      } else {

        if (labelPosition == YAxisLabelPosition.OUTSIDE_CHART) {
          if (this.mAxisLabelPaint) {
            this.mAxisLabelPaint.setTextAlign('left');
          }
          if (this.mViewPortHandler) {
            xPos = this.mViewPortHandler.contentRight() + xOffset;
          }

        } else {
          if (this.mAxisLabelPaint) {
            this.mAxisLabelPaint.setTextAlign('right');
          }
          if (this.mViewPortHandler) {
            xPos = this.mViewPortHandler.contentRight() - xOffset;
          }
        }
      }

      this.drawYLabels(c, xPos, positions, yOffset, isHorizontalFlip, isLeftAxis);
    }
    // return [];
  }

  public renderAxisLine(c: CanvasRenderingContext2D, extraLength: number): void {

    if (!this.mYAxis || !this.mViewPortHandler || !this.mYAxis.isEnabled() || !this.mYAxis.isDrawAxisLineEnabled()) {
      return;
    }

    if (this.mAxisLinePaint) {
      this.mAxisLinePaint.setColor(this.mYAxis.getAxisLineColor());
      this.mAxisLinePaint.setStrokeWidth(this.mYAxis.getAxisLineWidth());

      Utils.resetContext2DWithoutFont(c, this.mAxisLinePaint);
      if (this.mYAxis.getAxisDependency() == AxisDependency.LEFT) {
        c.beginPath()
        c.moveTo(this.mViewPortHandler.contentLeft(), this.mViewPortHandler.contentTop());
        c.lineTo(this.mViewPortHandler.contentLeft(), this.mViewPortHandler.contentBottom() + extraLength)
        c.stroke();
        c.closePath();
      } else {
        c.beginPath()
        c.moveTo(this.mViewPortHandler.contentRight(), this.mViewPortHandler.contentTop());
        c.lineTo(this.mViewPortHandler.contentRight(), this.mViewPortHandler.contentBottom() + extraLength)
        c.stroke();
        c.closePath();
      }
    }
  }


  /**
   * draws the y-labels on the specified x-position
   *
   * @param fixedPosition
   * @param positions
   */
  protected drawYLabels(c: CanvasRenderingContext2D, fixedPosition: number, positions: number[], offset: number, isHorizontalFlip: boolean, isLeftAxis: boolean): void {
    // let paints:Paint[] = [];
    if (!this.mYAxis) {
      return;
    }
    const fromIndex = this.mYAxis.isDrawBottomYLabelEntryEnabled() ? 0 : 1;
    const to = this.mYAxis.isDrawTopYLabelEntryEnabled()
      ? this.mYAxis.mEntryCount
      : (this.mYAxis.mEntryCount - 1);

    let xOffset: number = this.mYAxis.getLabelXOffset();

    // draw
    if (isHorizontalFlip) {
      c.save();
      c.scale(-1, 1);
    }
    for (let i = fromIndex; i < to; i++) {
      let text: string = this.mYAxis.getFormattedLabel(i);
      let originTextBaseLine: CanvasTextBaseline = this.mAxisLabelPaint.getTextBaseline();
      this.mAxisLabelPaint.setTextBaseline('middle');
      Utils.resetContext2DWithoutLine(c, this.mAxisLabelPaint);
      const xPosition = fixedPosition + xOffset;
      const textSize = Utils.getLabelTextSize(this.mAxisLabelPaint, text, this.textSizeCache);
      const textWidth = textSize.width;
      const textHeight = textSize.height;
      switch (this.mAxisLabelPaint.getStyle()) {
        case Style.STROKE:
          c.beginPath();
          if (isHorizontalFlip) {
            if (isLeftAxis) {
              c.strokeText(text, -xPosition + textWidth, positions[i * 2+1] + offset - textHeight);
            } else {
              c.strokeText(text, -xPosition - textWidth, positions[i * 2+1] + offset - textHeight);
            }
          } else {
            c.strokeText(text, xPosition, positions[i * 2+1] + offset - textHeight);
          }
          c.closePath();
          break;
        case Style.FILL_AND_STROKE:
        case Style.FILL:
        default:
          c.beginPath();
          if (isHorizontalFlip) {
            if (isLeftAxis) {
              c.fillText(text, -xPosition + textWidth, positions[i * 2+1] + offset - textHeight);
            } else {
              c.fillText(text, -xPosition - textWidth, positions[i * 2+1] + offset - textHeight);
            }
          } else {
            c.fillText(text, xPosition, positions[i * 2+1] + offset - textHeight);
          }
          c.closePath();
          break;
      }
      this.mAxisLabelPaint.setTextBaseline(originTextBaseLine);
    }
    if (isHorizontalFlip) {
      c.restore();
    }
    // return paints;
  }

  // protected mRenderGridLinesPath: Path2D = new Path2D();

  public renderGridLines(c: CanvasRenderingContext2D): void {

    // let paints:Paint[] = []
    // const fromIndex = this.mYAxis.isDrawBottomYLabelEntryEnabled() ? 0 : 1;
    // const to = this.mYAxis.isDrawTopYLabelEntryEnabled()
    //   ? this.mYAxis.mEntryCount
    //   : (this.mYAxis.mEntryCount - 1);

    if (!this.mYAxis) {
      return;
    }
    if (!this.mYAxis.isEnabled())
      return;

    if (this.mYAxis.isDrawGridLinesEnabled()) {
      c.save();
      c.beginPath();
      let contentRect = this.getGridClippingRect();
      c.rect(contentRect.left, contentRect.top, contentRect.right - contentRect.left, contentRect.bottom - contentRect.top);
      c.closePath();
      c.clip();

      let positions: number[] = this.getTransformedPositions();

      if (this.mGridPaint) {
        this.mGridPaint.setGlobalAlpha(this.mYAxis.getGridAlpha() / 255);
        this.mGridPaint.setColor(this.mYAxis.getGridColor());
        this.mGridPaint.setStrokeWidth(this.mYAxis.getGridLineWidth());
        let dashEffect = this.mYAxis.getGridDashPathEffect();
        this.mGridPaint.setDashPathEffect(dashEffect);
      }

      // let gridLinePath: Path2D = this.mRenderGridLinesPath;
      // gridLinePath = new Path2D();

      //      let yOffset = Utils.calcTextHeight(this.mAxisLabelPaint, "A") / 2.5 + this.mYAxis.getYOffset()
      // draw the grid
      if (positions) {
        for (let i = 0; i < positions.length; i += 2) {
          Utils.resetContext2DWithoutFont(c, this.mGridPaint);
          c.beginPath();
          this.linePath(c, i, positions);
          c.closePath();
          // gridLinePath = new Path2D();
        }
      }
      c.restore();
    }

    if (this.mYAxis && this.mYAxis.isDrawZeroLineEnabled()) {
      this.drawZeroLine(c);
      // if (paint) {
      //   paints.push(paint);
      // }
    }

    // return paints;

  }

  protected mGridClippingRect: MyRect = new MyRect();

  public getGridClippingRect(): MyRect {
    if (this.mViewPortHandler) {
      this.mGridClippingRect.set(this.mViewPortHandler.getContentRect().left, this.mViewPortHandler.getContentRect().top
        , this.mViewPortHandler.getContentRect().right, this.mViewPortHandler.getContentRect().bottom);
    }
    if (this.mAxis) {
      this.mGridClippingRect.inset(0, -this.mAxis.getGridLineWidth(), 0, -this.mAxis.getGridLineWidth());
    }
    return this.mGridClippingRect;
  }

  /**
   * Calculates the path for a grid line.
   *
   * @param p
   * @param i
   * @param positions
   * @return
   */
  protected linePath(c: CanvasRenderingContext2D, i: number, positions: number[]): void {
    c.beginPath()
    c.moveTo(this.mViewPortHandler ? this.mViewPortHandler.offsetLeft() : 0, positions[i+1]);
    c.lineTo(this.mViewPortHandler ? this.mViewPortHandler.contentRight() : 0, positions[i+1]);
    c.stroke();
    c.closePath();
    // if (this.mAxisLinePaint && this.mViewPortHandler) {
    //   p = "M" + Utils.convertDpToPixel((this.mAxisLinePaint as LinePaint).startPoint[0]) + " " + Utils.convertDpToPixel(positions[i + 1]) + " L" + Utils.convertDpToPixel(this.mViewPortHandler.contentRight()) + " " + Utils.convertDpToPixel(positions[i + 1]) + " Z";
    // }
    // return p;
  }

  protected mGetTransformedPositionsBuffer: number[] = new Array<number>(2);

  /**
   * Transforms the values contained in the axis entries to screen pixels and returns them in form of a float array
   * of x- and y-coordinates.
   *
   * @return
   */
  protected getTransformedPositions(): number[] {
    if (!this.mYAxis) {
      return [];
    }
    if (this.mGetTransformedPositionsBuffer.length != this.mYAxis.mEntryCount * 2) {
      this.mGetTransformedPositionsBuffer = new Array<number>(this.mYAxis.mEntryCount * 2);
    }
    let positions: number[] = this.mGetTransformedPositionsBuffer;

    for (let i = 0; i < positions.length; i += 2) {
      // only fill y values, x values are not needed for y-labels
      positions[i + 1] = this.mYAxis.mEntries[i / 2];
    }

    if (this.mTrans) {
      this.mTrans.pointValuesToPixel(positions);
    }
    return positions;
  }

  // protected mDrawZeroLinePath: Path2D = new Path2D();
  protected mZeroLineClippingRect: MyRect = new MyRect();

  /**
   * Draws the zero line.
   */
  protected drawZeroLine(c: CanvasRenderingContext2D): void {
    c.save();

    if (this.mYAxis && this.mViewPortHandler && this.mTrans) {
      this.mZeroLineClippingRect.set(this.mViewPortHandler.getContentRect().left, this.mViewPortHandler.getContentRect()
        .top
        , this.mViewPortHandler.getContentRect().right, this.mViewPortHandler.getContentRect().bottom);
      this.mZeroLineClippingRect.inset(0, -this.mYAxis.getZeroLineWidth(), 0, -this.mYAxis.getZeroLineWidth());

      c.rect(this.mZeroLineClippingRect.left, this.mZeroLineClippingRect.top, this.mZeroLineClippingRect.right - this.mZeroLineClippingRect.left, this.mZeroLineClippingRect.bottom - this.mZeroLineClippingRect.top);
      c.clip();

      // draw zero line
      let pos: MPPointD = this.mTrans.getPixelForValues(0, 0);

      if (this.mZeroLinePaint) {
        this.mZeroLinePaint.setColor(this.mYAxis.getZeroLineColor());
        this.mZeroLinePaint.setStrokeWidth(this.mYAxis.getZeroLineWidth());
      }

      // let zeroLinePath = this.mDrawZeroLinePath;
      // zeroLinePath = new Path2D();
      c.beginPath();
      c.moveTo(this.mViewPortHandler ? this.mViewPortHandler.contentLeft() : 0, pos.y);
      c.lineTo(this.mViewPortHandler ? this.mViewPortHandler.contentRight() : 0, pos.y);

      c.stroke();
      c.closePath();
      c.restore();
    }
  }

  // protected mRenderLimitLines: Path2D = new Path2D();
  protected mRenderLimitLinesBuffer: number[] = new Array<number>(2);
  protected mLimitLineClippingRect: MyRect = new MyRect();

  public renderLine(c: CanvasRenderingContext2D, l: LimitLine) {
    if (this.mViewPortHandler) {
      this.mLimitLineClippingRect.set(this.mViewPortHandler.getContentRect()
        .left, this.mViewPortHandler.getContentRect().top,
        this.mViewPortHandler.getContentRect().right, this.mViewPortHandler.getContentRect().bottom);
    }

    this.mLimitLineClippingRect.inset(0, -l.getLineWidth(), 0, -l.getLineWidth());
    c.beginPath();
    c.rect(this.mLimitLineClippingRect.left, this.mLimitLineClippingRect.top, this.mLimitLineClippingRect.width(), this.mLimitLineClippingRect.height());
    c.closePath();
    c.clip();

    this.mLimitLinePaint.setStyle(Style.STROKE);
    this.mLimitLinePaint.setColor(l.getLineColor());
    this.mLimitLinePaint.setStrokeWidth(l.getLineWidth());
    let dashEffect = l.getDashPathEffect();
    this.mLimitLinePaint.setDashPathEffect(dashEffect)

    this.mRenderLimitLinesBuffer[1] = l.getLimit();

    if (this.mTrans) {
      this.mTrans.pointValuesToPixel(this.mRenderLimitLinesBuffer);
    }
    Utils.resetContext2DWithoutFont(c, this.mLimitLinePaint);
    c.beginPath();
    c.moveTo(this.mViewPortHandler ? this.mViewPortHandler.contentLeft() : 0, this.mRenderLimitLinesBuffer[1]);
    c.lineTo(this.mViewPortHandler ? this.mViewPortHandler.contentRight() : 0, this.mRenderLimitLinesBuffer[1]);
    c.stroke();
    c.closePath();
  }

  public renderCustomGridLines(c: CanvasRenderingContext2D) {
    if (!this.mYAxis) {
      return;
    }
    let gridLines = this.mYAxis.getGridLines();
    if (!gridLines || gridLines.size() <= 0)
      return;

    for (let i = 0; i < gridLines.size(); i++) {
      c.save();

      let l: LimitLine = gridLines.get(i);

      if (!l.isEnabled())
        continue;
      this.renderLine(c, l)

      c.restore();
    }
  }

  /**
   * Draws the LimitLines associated with this axis to the screen.
   *
   * @param c
   */
  public renderLimitLines(c: CanvasRenderingContext2D, isHorizontalFlip: boolean): void {
    if (!this.mYAxis) {
      return;
    }
    let limitLines: JArrayList<LimitLine> = this.mYAxis.getLimitLines();

    if (!limitLines || limitLines.size() <= 0)
      return;

    let pts: number[] = this.mRenderLimitLinesBuffer;
    pts[0] = 0;
    pts[1] = 0;

    for (let i = 0; i < limitLines.size(); i++) {

      let l: LimitLine = limitLines.get(i);

      if (!l.isEnabled())
        continue;

      c.save();

      this.renderLine(c, l)

      let label: string = l.getLabel();
      if (label) {
        this.mLimitLinePaint.setStyle(l.getTextStyle());
        this.mLimitLinePaint.setDashPathEffect(null);
        this.mLimitLinePaint.setColor(l.getTextColor());
        this.mLimitLinePaint.setFontFamily(l.getTypeface());
        this.mLimitLinePaint.setStrokeWidth(0.5);
        this.mLimitLinePaint.setTextSize(l.getTextSize());

        const labelLineHeight = Utils.getLabelTextSize(this.mLimitLinePaint, label, this.textSizeCache).height;
        let xOffset = 4 + l.getXOffset();
        let yOffset = l.getLineWidth() + labelLineHeight + l.getYOffset();

        const position: LimitLabelPosition = l.getLabelPosition();
        let paintStyle = this.mLimitLinePaint.getStyle();

        if (isHorizontalFlip) {
          c.scale(-1, 1);
        }
        if (position == LimitLabelPosition.RIGHT_TOP) {
          this.mLimitLinePaint.setTextAlign('right');
          Utils.resetContext2DWithoutLine(c, this.mLimitLinePaint);
          switch (paintStyle) {
            case Style.STROKE:
              c.beginPath();
              this.strokeText(c, label, (this.mViewPortHandler ? this.mViewPortHandler.contentRight() : 0) - xOffset, pts[1] - yOffset + labelLineHeight, isHorizontalFlip, false);
              c.closePath();
              break
            case Style.FILL:
            case Style.FILL_AND_STROKE:
            default:
              c.beginPath();
              c.fillText(label, (this.mViewPortHandler ? this.mViewPortHandler.contentRight() : 0) - xOffset, pts[1] - yOffset + labelLineHeight)
              this.fillText(c, label, (this.mViewPortHandler ? this.mViewPortHandler.contentRight() : 0) - xOffset, pts[1] - yOffset + labelLineHeight, isHorizontalFlip, false);
              c.closePath();
              break;
          }
        } else if (position == LimitLabelPosition.RIGHT_BOTTOM) {
          this.mLimitLinePaint.setTextAlign('right');
          Utils.resetContext2DWithoutLine(c, this.mLimitLinePaint);
          switch (paintStyle) {
            case Style.STROKE:
              c.beginPath();
              this.strokeText(c, label, (this.mViewPortHandler ? this.mViewPortHandler.contentRight() : 0) - xOffset, pts[1] + yOffset -
                Utils.getLabelTextSize(this.mLimitLinePaint, label, this.textSizeCache)
                  .height / 2, isHorizontalFlip, false);
              c.closePath();
              break
            case Style.FILL:
            case Style.FILL_AND_STROKE:
            default:
              c.beginPath();
              this.fillText(c, label, (this.mViewPortHandler ? this.mViewPortHandler.contentRight() : 0) - xOffset, pts[1] + yOffset -
                Utils.getLabelTextSize(this.mLimitLinePaint, label, this.textSizeCache)
                  .height / 2, isHorizontalFlip, false);
              c.closePath();
              break;
          }

        } else if (position == LimitLabelPosition.LEFT_TOP) {
          this.mLimitLinePaint.setTextAlign('left');
          Utils.resetContext2DWithoutLine(c, this.mLimitLinePaint);
          switch (paintStyle) {
            case Style.STROKE:
              c.beginPath();
              this.strokeText(c, label, (this.mViewPortHandler ? this.mViewPortHandler.contentLeft() : 0) + xOffset, pts[1] - yOffset + labelLineHeight, isHorizontalFlip, true);
              c.closePath();
              break
            case Style.FILL:
            case Style.FILL_AND_STROKE:
            default:
              c.beginPath();
              this.fillText(c, label, (this.mViewPortHandler ? this.mViewPortHandler.contentLeft() : 0) + xOffset, pts[1] - yOffset + labelLineHeight, isHorizontalFlip, true);
              c.closePath();
              break;
          }

        } else {
          this.mLimitLinePaint.setTextAlign('left');
          Utils.resetContext2DWithoutLine(c, this.mLimitLinePaint);
          switch (paintStyle) {
            case Style.STROKE:
              c.beginPath();
              this.strokeText(c, label, (this.mViewPortHandler ? this.mViewPortHandler.contentLeft() : 0) + xOffset, pts[1] + yOffset -
                Utils.getLabelTextSize(this.mLimitLinePaint, label, this.textSizeCache)
                  .height / 2, isHorizontalFlip, true);
              c.closePath();
              break
            case Style.FILL:
            case Style.FILL_AND_STROKE:
            default:
              c.beginPath();
              this.fillText(c, label, (this.mViewPortHandler ? this.mViewPortHandler.contentLeft() : 0) + xOffset, pts[1] + yOffset -
                Utils.getLabelTextSize(this.mLimitLinePaint, label, this.textSizeCache)
                  .height / 2, isHorizontalFlip, true);
              c.closePath();
              break;
          }
        }
        if (isHorizontalFlip) {
          c.scale(-1, 1);
        }
      }
      c.restore();
    }
  }

  private strokeText(c: CanvasRenderingContext2D, text: string, x: number, y: number, isHorizontalFlip: boolean, isLeft: boolean) {
    if (isHorizontalFlip) {
      let textWidth = Utils.getLabelTextSize(this.mLimitLinePaint, text, this.textSizeCache).width;
      if (isLeft) {
        c.strokeText(text, -x - textWidth, y);
      } else {
        c.strokeText(text, -x + textWidth, y);
      }
    } else {
      c.strokeText(text, x, y);
    }
  }

  private fillText(c: CanvasRenderingContext2D, text: string, x: number, y: number, isHorizontalFlip: boolean, isLeft: boolean) {
    if (isHorizontalFlip) {
      let textWidth = Utils.getLabelTextSize(this.mLimitLinePaint, text, this.textSizeCache).width;
      if (isLeft) {
        c.fillText(text, -x - textWidth, y);
      } else {
        c.fillText(text, -x + textWidth, y);
      }
    } else {
      c.fillText(text, x, y);
    }
  }
}
