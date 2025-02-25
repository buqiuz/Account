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

import LineDataProvider from '../interfaces/dataprovider/LineDataProvider';
import ILineDataSet from '../interfaces/datasets/ILineDataSet';
import { XBounds } from './BarLineScatterCandleBubbleRenderer';
import { Mode } from '../data/LineDataSet';
import Transformer from '../utils/Transformer';
import Paint, { Style } from '../data/Paint';
import MPPointF from '../utils/MPPointF';
import Utils from '../utils/Utils';
import ChartPixelMap from '../data/ChartPixelMap';
import ColorTemplate from '../utils/ColorTemplate';
import LineData from '../data/LineData';
import { LineRadarRenderer } from './LineRadarRenderer';
import EntryOhos from '../data/EntryOhos';
import Highlight from '../highlight/Highlight';
import MPPointD from '../utils/MPPointD';
import { JArrayList } from '../utils/JArrayList';
import ChartAnimator from '../animation/ChartAnimator';
import ViewPortHandler from '../utils/ViewPortHandler';
import IValueFormatter from '../formatter/IValueFormatter';
import { ChartColor } from '../utils/ColorTemplate';
import HashMap from '@ohos.util.HashMap';
import IDataSet from '../interfaces/datasets/IDataSet';

export default class LineChartRenderer extends LineRadarRenderer {
  public mChart: LineDataProvider | null = null;
  public mDrawBitmap: ChartPixelMap | null = null;
  public mBitmapCanvas: CanvasRenderingContext2D | null = null;
  public mCirclePaintInner: Paint = new Paint();
  protected cubicPath: Path2D = new Path2D();
  protected cubicFillPath: Path2D = new Path2D();

  constructor(chart: LineDataProvider, animator: ChartAnimator, viewPortHandler: ViewPortHandler) {
    super(animator, viewPortHandler);
    this.mChart = chart;

    this.mCirclePaintInner.setStyle(Style.FILL);
    this.mCirclePaintInner.setColor(ChartColor.rgb(255, 255, 255));
  }

  public initBuffers() {
  }

  public drawData(c: CanvasRenderingContext2D) {
    const width: number = Math.floor(this.mViewPortHandler ? this.mViewPortHandler.getChartWidth() : 0);
    const height: number = Math.floor(this.mViewPortHandler ? this.mViewPortHandler.getChartHeight() : 0);

    if (width > 0 && height > 0) {
      this.mBitmapCanvas = c;
    } else {
      return;
    }

    if (!this.mChart) {
      return;
    }
    const lineData: LineData | null = this.mChart.getLineData();
    if (!lineData) return;
    let dataSets = lineData.getDataSets();

    for (let i = 0; i < dataSets.size(); i++) {
      let set = dataSets.get(i);
      if (set.isVisible()) {
        this.drawDataSet(c, set);
      }
    }
  }

  public drawDataSet(c: CanvasRenderingContext2D, dataSet: ILineDataSet) {
    if (dataSet.getEntryCount() < 1) {
      return;
    }

    this.mRenderPaint.setStrokeWidth(dataSet.getLineWidth());
    this.mRenderPaint.setDashPathEffect(dataSet.getDashPathEffect());

    switch (dataSet.getMode()) {

      case Mode.LINEAR:
      case Mode.STEPPED:
        this.drawLinear(c, dataSet);
        break;
      case Mode.CUBIC_BEZIER:
        this.drawCubicBezier(c, dataSet);
        break;
      case Mode.HORIZONTAL_BEZIER:
        this.drawHorizontalBezier(c, dataSet);
        break;
      default:
        this.drawLinear(c, dataSet);
    }
    this.mRenderPaint.setDashPathEffect(null);
  }

  protected drawHorizontalBezier(c: CanvasRenderingContext2D, dataSet: ILineDataSet) {
    if (!this.mChart || !this.mXBounds) {
      return;
    }
    let phaseY: number = this.mAnimator ? this.mAnimator.getPhaseY() : 1;
    let trans: Transformer | null = this.mChart.getTransformer(dataSet.getAxisDependency());
    this.mXBounds?.set(this.mChart, dataSet);

    let cubicPath: Path2D = new Path2D();
    // cubicPath.reset();

    if (this.mXBounds.range >= 1) {
      let prev = dataSet.getEntryForIndex(this.mXBounds.min);
      let cur = prev;

      Utils.resetContext2DWithoutFont(c, this.mRenderPaint);
      // let the spline start
      cubicPath.moveTo(cur.getX(), cur.getY() * phaseY);

      for (let j: number = this.mXBounds.min + 1; j <= this.mXBounds.range + this.mXBounds.min; j++) {
        prev = cur;
        cur = dataSet.getEntryForIndex(j);

        const cpx: number = (prev.getX())
        + (cur.getX() - prev.getX()) / 2.0;

        cubicPath.bezierCurveTo(
          cpx, prev.getY() * phaseY,
          cpx, cur.getY() * phaseY,
          cur.getX(), cur.getY() * phaseY
        );
      }
    }

    // if filled is enabled, close the path
    if (dataSet.isDrawFilledEnabled() && trans) {
      let cubicFillPath = new Path2D();
      cubicFillPath.addPath(cubicPath);
      // create a new path, this is bad for performance
      this.drawCubicFill(c, dataSet, cubicFillPath, trans, this.mXBounds);
    }

    this.mRenderPaint.setColor(dataSet.getColor());
    this.mRenderPaint.setStyle(Style.STROKE);

    if (trans) {
      cubicPath = trans.pathValueToPixel(cubicPath);
    }

    Utils.resetContext2DWithoutFont(c, this.mRenderPaint);
    c.beginPath();
    c.stroke(cubicPath);
    c.closePath();

    this.mRenderPaint.setDashPathEffect(null);
  }

  protected drawCubicBezier(c: CanvasRenderingContext2D, dataSet: ILineDataSet) {
    if (!this.mChart || !this.mXBounds) {
      return;
    }
    const phaseY: number = this.mAnimator ? this.mAnimator.getPhaseY() : 1;
    const trans: Transformer | null = this.mChart.getTransformer(dataSet.getAxisDependency());

    this.mXBounds.set(this.mChart, dataSet);

    const intensity: number = dataSet.getCubicIntensity();

    let cubicPath = new Path2D();
    // cubicPath.reset();
    if (this.mXBounds.range >= 1) {
      let prevDx: number = 0;
      let prevDy: number = 0;
      let curDx: number = 0;
      let curDy: number = 0;

      // Take an extra point from the left, and an extra from the right.
      // That's because we need 4 points for a cubic bezier (cubic=4), otherwise we get lines moving and doing weird stuff on the edges of the chart.
      // So in the starting `prev` and `cur`, go -2, -1
      // And in the `lastIndex`, add +1

      const firstIndex: number = this.mXBounds.min + 1;
      const lastIndex: number = this.mXBounds.min + this.mXBounds.range;

      let prevPrev: EntryOhos | null;
      let prev: EntryOhos | null = dataSet.getEntryForIndex(Math.max(firstIndex - 2, 0));
      let cur: EntryOhos | null = dataSet.getEntryForIndex(Math.max(firstIndex - 1, 0));
      let next: EntryOhos | null = cur;
      let nextIndex: number = -1;

      if (cur === null) return;

      Utils.resetContext2DWithoutFont(c, this.mRenderPaint);
      // let the spline start
      cubicPath.moveTo(cur.getX(), cur.getY() * phaseY);

      for (let j: number = this.mXBounds.min + 1; j <= this.mXBounds.range + this.mXBounds.min; j++) {
        prevPrev = prev;
        prev = cur;
        cur = nextIndex === j ? next : dataSet.getEntryForIndex(j);

        nextIndex = j + 1 < dataSet.getEntryCount() ? j + 1 : j;
        next = dataSet.getEntryForIndex(nextIndex);

        prevDx = (cur.getX() - prevPrev.getX()) * intensity;
        prevDy = (cur.getY() - prevPrev.getY()) * intensity;
        curDx = (next.getX() - prev.getX()) * intensity;
        curDy = (next.getY() - prev.getY()) * intensity;

        cubicPath.bezierCurveTo(
          prev.getX() + prevDx,
          (prev.getY() + prevDy) * phaseY,
          cur.getX() - curDx,
          (cur.getY() - curDy) * phaseY,
          cur.getX(),
          cur.getY() * phaseY
        );
      }
    }

    // if filled is enabled, close the path
    if (dataSet.isDrawFilledEnabled()) {
      let cubicFillPath: Path2D = new Path2D();
      // cubicFillPath.reset();
      cubicFillPath.addPath(cubicPath);

      if (c && trans) {
        this.drawCubicFill(c, dataSet, cubicFillPath, trans, this.mXBounds);
      }
    }

    this.mRenderPaint.setColor(dataSet.getColor());
    this.mRenderPaint.setStyle(Style.STROKE);

    if (trans) {
      cubicPath = trans.pathValueToPixel(cubicPath);
    }

    Utils.resetContext2DWithoutFont(c, this.mRenderPaint);
    c.beginPath();
    c.stroke(cubicPath);
    c.closePath();
    this.mRenderPaint.setDashPathEffect(null);
  }

  protected drawCubicFill(c: CanvasRenderingContext2D, dataSet: ILineDataSet, spline: Path2D, trans: Transformer, bounds: XBounds) {
    if (!this.mChart) {
      return;
    }
    const fillMin: number = dataSet.getFillFormatter().getFillLinePosition(dataSet, this.mChart);

    spline.lineTo(dataSet.getEntryForIndex(bounds.min + bounds.range).getX(), fillMin);
    spline.lineTo(dataSet.getEntryForIndex(bounds.min).getX(), fillMin);
    spline.closePath();

    spline = trans.pathValueToPixel(spline);

    const drawable: ChartPixelMap | null = dataSet.getFillDrawable();
    const gradientFillColor = dataSet.getGradientFillColor();
    if (drawable !== null) {
      this.drawFilledPath(c, spline, drawable);
    } else if (gradientFillColor) {
      let isInverted: boolean = this.mChart.isInverted(dataSet.getAxisDependency());
      let topValue = 0;
      if (isInverted) {
        topValue = dataSet.getYMin();
      } else {
        topValue = dataSet.getYMax();
      }
      let topBottomValueNumber = [0, topValue, 0, fillMin];
      trans.pointValuesToPixel(topBottomValueNumber);
      this.drawGradientFill(c, spline, gradientFillColor, topBottomValueNumber[1], topBottomValueNumber[3]);
    } else {
      this.drawFilledPathWithAlpha(c, spline, dataSet.getFillColor(), dataSet.getFillAlpha());
    }
  }

  private mLineBuffer: number[] = new Array<number>(4);

  protected drawLinear(c: CanvasRenderingContext2D, dataSet: ILineDataSet): void {
    if (!this.mChart || !this.mXBounds) {
      return;
    }
    let entryCount = dataSet.getEntryCount();
    const isDrawSteppedEnabled = dataSet.isDrawSteppedEnabled();
    const pointsPerEntryPair = isDrawSteppedEnabled ? 4 : 2;
    let trans: Transformer | null = this.mChart.getTransformer(dataSet.getAxisDependency());
    let phaseY = this.mAnimator ? this.mAnimator.getPhaseY() : 1;
    this.mRenderPaint.setStyle(Style.STROKE);
    let canvas: CanvasRenderingContext2D = c;

    // if the data-set is dashed, draw on bitmap-canvas
    if (dataSet.isDashedLineEnabled() && this.mBitmapCanvas) {
      canvas = this.mBitmapCanvas;
    } else {
      canvas = c;
    }

    this.mXBounds.set(this.mChart, dataSet);

    // if drawing filled is enabled
    if (dataSet.isDrawFilledEnabled() && entryCount > 0 && trans) {
      this.drawLinearFill(c, dataSet, trans, this.mXBounds);
    }

    // more than 1 color
    if (dataSet.getColors().size() > 1) {
      let numberOfFloats = pointsPerEntryPair * 2;
      if (this.mLineBuffer.length <= numberOfFloats) {
        this.mLineBuffer = new Array<number>(numberOfFloats * 2);

      }
      let max = this.mXBounds.min + this.mXBounds.range;
      for (let j = this.mXBounds.min; j < max; j++) {

        let e = dataSet.getEntryForIndex(j);
        if (e == null) continue;

        this.mLineBuffer[0] = e.getX();
        this.mLineBuffer[1] = e.getY() * phaseY;

        if (j < this.mXBounds.max) {

          e = dataSet.getEntryForIndex(j + 1);

          if (e == null) break;

          if (isDrawSteppedEnabled) {
            this.mLineBuffer[2] = e.getX();
            this.mLineBuffer[3] = this.mLineBuffer[1];
            this.mLineBuffer[4] = this.mLineBuffer[2];
            this.mLineBuffer[5] = this.mLineBuffer[3];
            this.mLineBuffer[6] = e.getX();
            this.mLineBuffer[7] = e.getY() * phaseY;
          } else {
            this.mLineBuffer[2] = e.getX();
            this.mLineBuffer[3] = e.getY() * phaseY;
          }

        } else {
          this.mLineBuffer[2] = this.mLineBuffer[0];
          this.mLineBuffer[3] = this.mLineBuffer[1];
        }

        trans?.pointValuesToPixel(this.mLineBuffer);
        // Determine the start and end coordinates of the line, and make sure they differ.
        let firstCoordinateX = this.mLineBuffer[0];
        let firstCoordinateY = this.mLineBuffer[1];
        let lastCoordinateX = this.mLineBuffer[numberOfFloats - 2];
        let lastCoordinateY = this.mLineBuffer[numberOfFloats - 1];

        if (firstCoordinateX == lastCoordinateX &&
        firstCoordinateY == lastCoordinateY)
          continue;


        if (!this.mViewPortHandler || !this.mViewPortHandler.isInBoundsRight(firstCoordinateX))
          break;

        // make sure the lines don't do shitty things outside
        // bounds
        if (!this.mViewPortHandler || !this.mViewPortHandler.isInBoundsLeft(lastCoordinateX) ||
        !this.mViewPortHandler.isInBoundsTop(Math.max(firstCoordinateY, lastCoordinateY)) ||
        !this.mViewPortHandler.isInBoundsBottom(Math.min(firstCoordinateY, lastCoordinateY)))
          continue;

        // get the color that is set for this line-segment
        this.mRenderPaint.setColor(dataSet.getColor(j));
        // canvas.drawLines(this.mLineBuffer, 0, pointsPerEntryPair * 2, this.mRenderPaint);

        Utils.resetContext2DWithoutFont(canvas, this.mRenderPaint);
        canvas.beginPath();

        canvas.moveTo(this.mLineBuffer[0], this.mLineBuffer[1]);
        for (let i = 0; i < pointsPerEntryPair * 2; i += 2) {
          canvas.lineTo(this.mLineBuffer[i], this.mLineBuffer[i + 1]);
        }
        canvas.stroke();
        canvas.closePath();
      }

    } else { // only one color per dataset

      if (this.mLineBuffer.length < Math.max((entryCount) * pointsPerEntryPair, pointsPerEntryPair) * 2)
        this.mLineBuffer = new Array<number>(Math.max((entryCount) * pointsPerEntryPair, pointsPerEntryPair) * 4);

      let e1: EntryOhos, e2: EntryOhos;

      e1 = dataSet.getEntryForIndex(this.mXBounds.min);

      if (e1 != null) {

        let j = 0;
        for (let x = this.mXBounds.min; x <= this.mXBounds.range + this.mXBounds.min; x++) {

          e1 = dataSet.getEntryForIndex(x == 0 ? 0 : (x - 1));
          e2 = dataSet.getEntryForIndex(x);

          if (e1 == null || e2 == null) continue;

          this.mLineBuffer[j++] = e1.getX();
          this.mLineBuffer[j++] = e1.getY() * phaseY;

          if (isDrawSteppedEnabled) {
            this.mLineBuffer[j++] = e2.getX();
            this.mLineBuffer[j++] = e1.getY() * phaseY;
            this.mLineBuffer[j++] = e2.getX();
            this.mLineBuffer[j++] = e1.getY() * phaseY;
          }

          this.mLineBuffer[j++] = e2.getX();
          this.mLineBuffer[j++] = e2.getY() * phaseY;
        }

        if (j > 0) {
          if (trans) {
            trans.pointValuesToPixel(this.mLineBuffer);
          }

          let size = Math.max((this.mXBounds.range + 1) * pointsPerEntryPair, pointsPerEntryPair) * 2;
          size = Math.floor(size);

          this.mRenderPaint.setColor(dataSet.getColor());

          // canvas.drawLines(this.mLineBuffer, 0, size, this.mRenderPaint);

          Utils.resetContext2DWithoutFont(canvas, this.mRenderPaint);
          canvas.beginPath();

          canvas.moveTo(this.mLineBuffer[0], this.mLineBuffer[1]);
          for (let i = 0; i < size; i += 2) {
            canvas.lineTo(this.mLineBuffer[i], this.mLineBuffer[i + 1]);
          }
          canvas.stroke();
          canvas.closePath();
        }
      }
    }
    this.mRenderPaint.setDashPathEffect(null);
  }

  public mGenerateFilledPathBuffer: Path2D = new Path2D();

  /**
   * Draws a filled linear path on the canvas.
   *
   * @param c
   * @param dataSet
   * @param trans
   * @param bounds
   */
  protected drawLinearFill(c: CanvasRenderingContext2D, dataSet: ILineDataSet, trans: Transformer, bounds: XBounds): void {
    if (!this.mChart) {
      return;
    }
    let filled: Path2D = this.mGenerateFilledPathBuffer;

    const startingIndex: number = bounds.min;
    const endingIndex: number = bounds.range + bounds.min;
    const indexInterval: number = 128;

    let currentStartIndex: number = 0;
    let currentEndIndex: number = indexInterval;
    let iterations: number = 0;

    // 迭代执行以避免大范围的 OutOfMemory 错误
    do {
      currentStartIndex = startingIndex + iterations * indexInterval;
      currentEndIndex = currentStartIndex + indexInterval;
      currentEndIndex = currentEndIndex > endingIndex ? endingIndex : currentEndIndex;

      if (currentStartIndex <= currentEndIndex) {
        filled = this.generateFilledPath(dataSet, currentStartIndex, currentEndIndex, filled);

        filled = trans.pathValueToPixel(filled);

        let isInverted: boolean = this.mChart.isInverted(dataSet.getAxisDependency());

        const drawable: ChartPixelMap | null = dataSet.getFillDrawable();
        const gradientFillColor = dataSet.getGradientFillColor();
        if (drawable !== null) {
          this.drawFilledPath(c, filled, drawable);
        } else if (gradientFillColor) {
          let topValue = 0;
          if (isInverted) {
            topValue = dataSet.getYMin();
          } else {
            topValue = dataSet.getYMax();
          }
          let fillMin = dataSet.getFillFormatter().getFillLinePosition(dataSet, this.mChart);
          let topBottomValueNumber = [0, topValue, 0, fillMin];
          trans.pointValuesToPixel(topBottomValueNumber);
          this.drawGradientFill(c, filled, gradientFillColor, topBottomValueNumber[1], topBottomValueNumber[3]);
        } else {
          this.drawFilledPathWithAlpha(c, filled, dataSet.getFillColor(), dataSet.getFillAlpha());
        }
      }

      iterations++;
    } while (currentStartIndex <= currentEndIndex);
  }


  /**
   * Generates a path that is used for filled drawing.
   *
   * @param dataSet    The dataset from which to read the entries.
   * @param startIndex The index from which to start reading the dataset
   * @param endIndex   The index from which to stop reading the dataset
   * @param outputPath The path object that will be assigned the chart data.
   * @return
   */
  private generateFilledPath(dataSet: ILineDataSet, startIndex: number, endIndex: number, outputPath: Path2D): Path2D {
    if (!this.mChart) {
      return new Path2D();
    }
    const fillMin: number = dataSet.getFillFormatter().getFillLinePosition(dataSet, this.mChart);
    const phaseY: number = this.mAnimator ? this.mAnimator.getPhaseY() : 1;
    const isDrawSteppedEnabled: boolean = dataSet.getMode() === Mode.STEPPED;

    let filled: Path2D = outputPath;
    // filled.reset();
    filled = new Path2D();

    const entry: EntryOhos = dataSet.getEntryForIndex(startIndex);

    filled.moveTo(entry.getX(), fillMin);
    filled.lineTo(entry.getX(), entry.getY() * phaseY);

    let currentEntry: EntryOhos | null = null;
    let previousEntry: EntryOhos = entry;
    for (let x: number = startIndex + 1; x <= endIndex; x++) {
      currentEntry = dataSet.getEntryForIndex(x);

      if (isDrawSteppedEnabled) {
        filled.lineTo(currentEntry.getX(), previousEntry.getY() * phaseY);
      }

      filled.lineTo(currentEntry.getX(), currentEntry.getY() * phaseY);

      previousEntry = currentEntry;
    }

    // close up
    if (currentEntry !== null) {
      filled.lineTo(currentEntry.getX(), fillMin);
    }

    filled.closePath();
    return filled;
  }

  public drawValues(c: CanvasRenderingContext2D, isHorizontalFlip: boolean) {
    if (!this.mChart) {
      return;
    }
    if (this.isDrawingValuesAllowed(this.mChart)) {
      let lineData = this.mChart.getLineData();
      if (!lineData) {
        return;
      }
      let dataSets: JArrayList<ILineDataSet> = lineData.getDataSets();

      for (let i: number = 0; i < dataSets.size(); i++) {
        const dataSet: ILineDataSet = dataSets.get(i);

        if (!this.shouldDrawValues(dataSet) || dataSet.getEntryCount() < 1) {
          continue;
        }

        // apply the text-styling defined by the DataSet
        this.applyValueTextStyle(dataSet);

        let trans: Transformer | null = this.mChart.getTransformer(dataSet.getAxisDependency());

        // make sure the values do not interfere with the circles
        let valOffset: number = dataSet.getCircleRadius() * 1.75;

        if (!dataSet.isDrawCirclesEnabled()) {
          valOffset /= 2;
        }

        if (!this.mXBounds) {
          continue;
        }
        this.mXBounds.set(this.mChart, dataSet);

        let positions: number[] = new Array<number>();

        if (trans) {
          positions = trans.generateTransformedValuesLine(
            dataSet,
            this.mAnimator ? this.mAnimator.getPhaseX() : 1,
            this.mAnimator ? this.mAnimator.getPhaseY() : 1,
            this.mXBounds.min,
            this.mXBounds.max
          );
        }

        const iconsOffset: MPPointF = MPPointF.getInstance(undefined, undefined, dataSet.getIconsOffset());
        iconsOffset.x = Utils.handleDataValues(iconsOffset.x);
        iconsOffset.y = Utils.handleDataValues(iconsOffset.y);

        for (let j: number = 0; j < positions.length; j += 2) {
          const x: number = positions[j];
          const y: number = positions[j + 1];

          if (!this.mViewPortHandler || !this.mViewPortHandler.isInBoundsRight(x)) {
            break;
          }

          if (!this.mViewPortHandler || !this.mViewPortHandler.isInBoundsLeft(x) || !this.mViewPortHandler.isInBoundsY(y)) {
            continue;
          }

          const entry: EntryOhos = dataSet.getEntryForIndex(j / 2 + this.mXBounds.min);

          if (dataSet.isDrawValuesEnabled()) {
            let valueFormatter: IValueFormatter | null = dataSet.getValueFormatter();
            if (valueFormatter) {
              this.drawValue(
                c,
                valueFormatter,
                entry.getY(),
                entry,
                i,
                x,
                y - valOffset,
                dataSet.getValueTextColor(j / 2),
                isHorizontalFlip
              );
            }
          }

          if (entry.getIcon() != null && dataSet.isDrawIconsEnabled()) {
            let icon: ChartPixelMap | null = entry.getIcon();
            if (!icon) {
              return;
            }
            Utils.drawImage(
              c,
              icon,
              Math.floor(x + iconsOffset.x),
              Math.floor(y + iconsOffset.y),
              icon.getWidth(),
              icon.getHeight());
          }
        }

        MPPointF.recycleInstance(iconsOffset);
      }
    }
  }

  public drawExtras(c: CanvasRenderingContext2D) {
    this.drawCircles(c);
  }

  /**
   * cache for the circle bitmaps of all datasets
   */
  private mImageCaches = new HashMap<IDataSet<EntryOhos>, DataSetImageCache>();
  /**
   * buffer for drawing the circles
   */
  private mCirclesBuffer: number[] = new Array<number>(2);

  protected drawCircles(c: CanvasRenderingContext2D) {
    if (!this.mChart || !this.mViewPortHandler || !this.mAnimator) {
      return;
    }
    this.mRenderPaint.setStyle(Style.FILL);

    const phaseY: number = this.mAnimator.getPhaseY();

    this.mCirclesBuffer[0] = 0;
    this.mCirclesBuffer[1] = 0;

    let lineData = this.mChart.getLineData();
    if (!lineData) {
      return;
    }

    let dataSets: JArrayList<ILineDataSet> = lineData.getDataSets();
    for (let i: number = 0; i < dataSets.size(); i++) {
      const dataSet: ILineDataSet = dataSets.get(i);

      if (!dataSet.isVisible() || !dataSet.isDrawCirclesEnabled() || dataSet.getEntryCount() === 0) {
        continue;
      }

      this.mCirclePaintInner?.setColor(dataSet.getCircleHoleColor());

      const trans: Transformer | null = this.mChart.getTransformer(dataSet.getAxisDependency());

      this.mXBounds?.set(this.mChart, dataSet);

      const circleRadius: number = dataSet.getCircleRadius();
      const circleHoleRadius: number = dataSet.getCircleHoleRadius();
      const drawCircleHole: boolean =
        dataSet.isDrawCircleHoleEnabled() &&
        circleHoleRadius < circleRadius &&
        circleHoleRadius > 0;
      const drawTransparentCircleHole: boolean =
        drawCircleHole &&
        dataSet.getCircleHoleColor() === ColorTemplate.COLOR_NONE;

      let imageCache: DataSetImageCache | undefined = undefined;

      if (Utils.getSDKInt() >= 12) {
        if (this.mImageCaches.hasKey(dataSet)) {
          imageCache = this.mImageCaches.get(dataSet);
        } else {
          imageCache = new DataSetImageCache();
          this.mImageCaches.set(dataSet, imageCache);
        }

        let changeRequired = imageCache.init(dataSet, this.mCirclePaintInner);

        if (changeRequired) {
          imageCache.fill(dataSet, drawCircleHole, drawTransparentCircleHole);
        }
      }

      if (!this.mXBounds) {
        return;
      }
      const boundsRangeCount: number = this.mXBounds.range + this.mXBounds.min;

      const colorCount: number = dataSet.getCircleColorCount();

      for (let j: number = this.mXBounds.min; j <= boundsRangeCount; j++) {
        const e: EntryOhos = dataSet.getEntryForIndex(j);

        if (e === null) {
          break;
        }

        this.mCirclesBuffer[0] = e.getX();
        this.mCirclesBuffer[1] = e.getY() * phaseY;

        trans?.pointValuesToPixel(this.mCirclesBuffer);

        if (!this.mViewPortHandler.isInBoundsRight(this.mCirclesBuffer[0])) {
          break;
        }

        if (
          !this.mViewPortHandler.isInBoundsLeft(this.mCirclesBuffer[0]) ||
          !this.mViewPortHandler.isInBoundsY(this.mCirclesBuffer[1])
        ) {
          continue;
        }
        if(Utils.getSDKInt() >= 12) {
          let circleBitmap: ImageBitmap | null = imageCache?.getBitmap(j)?? null;
          if(circleBitmap != null){
            c.globalAlpha = this.mRenderPaint.getGlobalAlpha() ?? 1.0;
            c.drawImage(circleBitmap, this.mCirclesBuffer[0] - circleRadius, this.mCirclesBuffer[1] - circleRadius);
          }
        } else {
          this.mRenderPaint.setColor(dataSet.getCircleColor(j % colorCount));
          this.fill(c, dataSet, drawCircleHole, drawTransparentCircleHole, this.mCirclesBuffer[0] - circleRadius, this.mCirclesBuffer[1] - circleRadius);
        }

      }
    }
  }

  public fill(c: CanvasRenderingContext2D, set: ILineDataSet, drawCircleHole: boolean, drawTransparentCircleHole: boolean, offsetX: number, offsetY: number): void {
    const circleRadius: number = set.getCircleRadius();
    const circleHoleRadius: number = set.getCircleHoleRadius();
    if (drawTransparentCircleHole) {
      // Begin path for circle with hole
      Utils.resetContext2DWithoutFont(c, this.mRenderPaint);
      c.beginPath();
      c.arc(
        circleRadius + offsetX,
        circleRadius + offsetY,
        circleRadius,
        0, Math.PI * 2, false)

      // Cut hole in path
      c.arc(
        circleRadius + offsetX,
        circleRadius + offsetY,
        circleHoleRadius,
        0, Math.PI * 2, true)

      // Fill in-between
      c.fill();
      c.closePath();

    } else {

      Utils.resetContext2DWithoutFont(c, this.mRenderPaint);
      c.beginPath();
      c.arc(
        circleRadius + offsetX,
        circleRadius + offsetY,
        circleRadius,
        0, Math.PI * 2);
      c.fill();
      c.closePath();

      if (drawCircleHole) {
        if (this.mCirclePaintInner) {
          Utils.resetContext2DWithoutFont(c, this.mCirclePaintInner);
        }
        c.beginPath();
        c.arc(
          circleRadius + offsetX,
          circleRadius + offsetY,
          circleHoleRadius,
          0, Math.PI * 2
        );
        c.fill();
        c.closePath();
      }
    }
  }

  public drawHighlighted(c: CanvasRenderingContext2D, indices: Highlight[], isDraw?: boolean) {
    if (!this.mChart || !isDraw) {
      return;
    }

    const lineData: LineData | null = this.mChart.getLineData();
    if (!lineData) {
      return;
    }

    for (const high of indices) {
      const set: ILineDataSet | null = lineData.getDataSetByIndex(high.getDataSetIndex());

      if (!set || !set.isHighlightEnabled()) {
        continue;
      }

      const e: EntryOhos | null = set.getEntryForXValue(high.getX(), high.getY());

      if (!e || !this.isInBoundsX(e, set)) {
        continue;
      }

      let trans: Transformer | null = this.mChart.getTransformer(set.getAxisDependency());
      if (!trans) {
        return;
      }
      const pix: MPPointD = trans.getPixelForValues(e.getX(), e.getY() * (this.mAnimator ? this.mAnimator.getPhaseY() : 1));

      high.setDraw(pix.x as number, pix.y as number);

      // draw the lines
      this.drawHighlightLines(c, pix.x as number, pix.y as number, set);
    }
  }

  /**
   * Releases the drawing bitmap. This should be called when {@link LineChart#onDetachedFromWindow()}.
   */
  public releaseBitmap(): void {
    if (this.mBitmapCanvas !== null) {
      // this.mBitmapCanvas.setBitmap(null);
      this.mBitmapCanvas = null;
    }

    if (this.mDrawBitmap !== null) {
      const drawBitmap: ChartPixelMap | null = this.mDrawBitmap;
      if (drawBitmap !== null) {
        // drawBitmap.recycle();
      }
      // this.mDrawBitmap.clear();
      this.mDrawBitmap = null;
    }
  }
}

class DataSetImageCache {
  mCirclePathBuffer = new Path2D();
  circleBitmaps: ImageBitmap[] | null = null;
  mCirclePaintInner: Paint = new Paint();

  init(set: ILineDataSet, circlePaintInner: Paint): boolean {
    this.mCirclePaintInner = circlePaintInner;
    const size: number = set.getCircleColorCount();
    let changeRequired: boolean = false;
    if (this.circleBitmaps == null) {
      this.circleBitmaps = new Array<ImageBitmap>(size);
      changeRequired = true;
    } else if (this.circleBitmaps.length != size) {
      this.circleBitmaps = new Array<ImageBitmap>(size);
      changeRequired = true;
    }
    return changeRequired;
  }

  public fill(set: ILineDataSet, drawCircleHole: boolean, drawTransparentCircleHole: boolean) {
    const colorCount = set.getCircleColorCount();
    const circleRadius = set.getCircleRadius();
    const circleHoleRadius = set.getCircleHoleRadius();

    for (let i = 0; i < colorCount; i++) {
      let offscreenCanvas: OffscreenCanvasRenderingContext2D =
        new OffscreenCanvasRenderingContext2D(Math.floor(circleRadius * 2.1), Math.floor(circleRadius * 2.1));

      offscreenCanvas.fillStyle = set.getCircleColor(i); //设置填充颜色

      if (drawTransparentCircleHole) {
        //绘制带孔的圆
        this.mCirclePathBuffer = new Path2D();

        this.mCirclePathBuffer.arc(
          circleRadius,
          circleRadius,
          circleRadius,
          0,
          Math.PI * 2,
          false
        );

        this.mCirclePathBuffer.arc(
          circleRadius,
          circleRadius,
          circleHoleRadius,
          0,
          Math.PI * 2,
          true
        );

        offscreenCanvas.fill(this.mCirclePathBuffer);
      } else {
        //绘制完整的圆
        offscreenCanvas.beginPath();
        offscreenCanvas.arc(
          circleRadius,
          circleRadius,
          circleRadius,
          0,
          Math.PI * 2,
          false
        );
        offscreenCanvas.fill();

        if (drawCircleHole) {
          offscreenCanvas.beginPath();
          offscreenCanvas.arc(
            circleRadius,
            circleRadius,
            circleHoleRadius,
            0,
            Math.PI * 2,
            false
          );
          offscreenCanvas.fillStyle = this.mCirclePaintInner.fillStyle;
          offscreenCanvas.fill();
        }
      }
      if (this.circleBitmaps && this.circleBitmaps.length > 0) {
        this.circleBitmaps[i] = offscreenCanvas.transferToImageBitmap();
      }
    }
  }

  public getBitmap(index: number): ImageBitmap | null {
    if (this.circleBitmaps && this.circleBitmaps.length > 0) {
      return this.circleBitmaps[index % this.circleBitmaps.length];
    } else {
      return null;
    }
  }
}