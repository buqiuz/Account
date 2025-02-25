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

import MPPointD from '../utils/MPPointD'
import ViewPortHandler from './ViewPortHandler'
import Matrix from './Matrix'
import IScatterDataSet from '../interfaces/datasets/IScatterDataSet'
import Entry from '../data/EntryOhos'
import IBubbleDataSet from '../interfaces/datasets/IBubbleDataSet'
import ILineDataSet from '../interfaces/datasets/ILineDataSet'
import ICandleDataSet from '../interfaces/datasets/ICandleDataSet'
import CandleEntry from '../data/CandleEntry'
import MyRect from '../data/Rect'

/**
 * Transformer class that contains all matrices and is responsible for
 * transforming values into pixels on the screen and backwards.
 *
 *
 */
export default class Transformer {
  /**
   * matrix to map the values to the screen pixels
   */
  protected mMatrixValueToPx: Matrix = new Matrix();
  /**
   * matrix for handling the different offsets of the chart
   */
  protected mMatrixOffset: Matrix = new Matrix();
  protected mViewPortHandler: ViewPortHandler;
  protected matrix2D: Matrix2D = new Matrix2D();
  protected resultPath: Path2D = new Path2D();

  constructor(viewPortHandler: ViewPortHandler) {
    this.mViewPortHandler = viewPortHandler;
  }

  /**
   * Prepares the matrix that transforms values to pixels. Calculates the
   * scale factors from the charts size and offsets.
   *
   * @param xChartMin
   * @param deltaX
   * @param deltaY
   * @param yChartMin
   */
  public prepareMatrixValuePx(xChartMin: number, deltaX: number, deltaY: number, yChartMin: number) {

    let scaleX: number = this.mViewPortHandler.contentWidth() / deltaX;
    let scaleY: number = this.mViewPortHandler.contentHeight() / deltaY;

    if (scaleX == Number.MAX_VALUE) {
      scaleX = 0;
    }
    if (scaleY == Number.MAX_VALUE) {
      scaleY = 0;
    }

    // setup all matrices
    this.mMatrixValueToPx.reset();
    this.mMatrixValueToPx.postTranslate(-xChartMin, -yChartMin);
    this.mMatrixValueToPx.postScale(scaleX, -scaleY);
  }

  /**
   * Prepares the matrix that contains all offsets.
   *
   * @param inverted
   */
  public prepareMatrixOffset(inverted: boolean) {

    this.mMatrixOffset.reset();

    // offset.postTranslate(mOffsetLeft, getHeight() - mOffsetBottom);

    if (!inverted)
      this.mMatrixOffset.postTranslate(this.mViewPortHandler.offsetLeft(),
        this.mViewPortHandler.getChartHeight() - this.mViewPortHandler.offsetBottom());
    else {
      this.mMatrixOffset
        .setTranslate(this.mViewPortHandler.offsetLeft(), -this.mViewPortHandler.offsetTop());
      this.mMatrixOffset.postScale(1.0, -1.0);
    }
  }

  protected valuePointsForGenerateTransformedValuesScatter: number[] = new Array<number>(1);

  /**
   * Transforms an List of Entry into a float array containing the x and
   * y values transformed with all matrices for the SCATTERCHART.
   *
   * @param data
   * @return
   */
  public generateTransformedValuesScatter(data: IScatterDataSet, phaseX: number,
                                          phaseY: number, from: number, to: number): number[] {

    const count: number = Math.floor(((to - from) * phaseX + 1) * 2);

    if (this.valuePointsForGenerateTransformedValuesScatter.length != count) {
      this.valuePointsForGenerateTransformedValuesScatter = new Array<number>(count);
    }
    let valuePoints: number[] = this.valuePointsForGenerateTransformedValuesScatter;

    for (let j = 0; j < count; j += 2) {

      let e: Entry | null = data.getEntryForIndex(j / 2 + from);

      if (e != null) {
        valuePoints[j] = e.getX();
        valuePoints[j + 1] = e.getY() * phaseY;
      } else {
        valuePoints[j] = 0;
        valuePoints[j + 1] = 0;
      }
    }

    this.getValueToPixelMatrix().mapPoints(valuePoints);

    return valuePoints;
  }

  protected valuePointsForGenerateTransformedValuesBubble: number[] = new Array<number>(1);

  /**
   * Transforms an List of Entry into a float array containing the x and
   * y values transformed with all matrices for the BUBBLECHART.
   *
   * @param data
   * @return
   */
  public generateTransformedValuesBubble(data: IBubbleDataSet, phaseY: number, from: number, to: number): number[] {

    const count = (to - from + 1) * 2; // (int) Math.ceil((to - from) * phaseX) * 2;

    if (this.valuePointsForGenerateTransformedValuesBubble.length != count) {
      this.valuePointsForGenerateTransformedValuesBubble = new Array<number>(count);
    }
    let valuePoints: number[] = this.valuePointsForGenerateTransformedValuesBubble;

    for (let j = 0; j < count; j += 2) {

      let e: Entry | null = data.getEntryForIndex(j / 2 + from);

      if (e != null) {
        valuePoints[j] = e.getX();
        valuePoints[j + 1] = e.getY() * phaseY;
      } else {
        valuePoints[j] = 0;
        valuePoints[j + 1] = 0;
      }
    }

    this.getValueToPixelMatrix().mapPoints(valuePoints);

    return valuePoints;
  }

  protected valuePointsForGenerateTransformedValuesLine: number[] = new Array<number>(1);

  /**
   * Transforms an List of Entry into a float array containing the x and
   * y values transformed with all matrices for the LINECHART.
   *
   * @param data
   * @return
   */
  public generateTransformedValuesLine(data: ILineDataSet,
                                       phaseX: number, phaseY: number,
                                       min: number, max: number): number[] {

    const count: number = Math.floor((((max - min) * phaseX) + 1) * 2);

    if (this.valuePointsForGenerateTransformedValuesLine.length != count) {
      this.valuePointsForGenerateTransformedValuesLine = new Array<number>(count);
    }
    let valuePoints: number[] = this.valuePointsForGenerateTransformedValuesLine;

    for (let j = 0; j < count; j += 2) {

      let e: Entry | null = data.getEntryForIndex(j / 2 + min);

      if (e != null) {
        valuePoints[j] = e.getX();
        valuePoints[j + 1] = e.getY() * phaseY;
      } else {
        valuePoints[j] = 0;
        valuePoints[j + 1] = 0;
      }
    }

    this.getValueToPixelMatrix().mapPoints(valuePoints);

    return valuePoints;
  }

  protected valuePointsForGenerateTransformedValuesCandle: number[] = new Array<number>(1);

  /**
   * Transforms an List of Entry into a float array containing the x and
   * y values transformed with all matrices for the CANDLESTICKCHART.
   *
   * @param data
   * @return
   */
  public generateTransformedValuesCandle(data: ICandleDataSet,
                                         phaseX: number, phaseY: number, fromValue: number, toValue: number): number[] {

    const count: number = Math.floor(((toValue - fromValue) * phaseX + 1) * 2);

    if (this.valuePointsForGenerateTransformedValuesCandle.length != count) {
      this.valuePointsForGenerateTransformedValuesCandle = new Array<number>(count);
    }
    let valuePoints: number[] = this.valuePointsForGenerateTransformedValuesCandle;

    for (let j = 0; j < count; j += 2) {

      let e: CandleEntry | null = data.getEntryForIndex(j / 2 + fromValue);

      if (e != null) {
        valuePoints[j] = e.getX();
        valuePoints[j + 1] = e.getHigh() * phaseY;
      } else {
        valuePoints[j] = 0;
        valuePoints[j + 1] = 0;
      }
    }

    this.getValueToPixelMatrix().mapPoints(valuePoints);

    return valuePoints;
  }

  /**
   * transform a path with all the given matrices VERY IMPORTANT: keep order
   * to value-touch-offset
   *
   * @param path
   */
  public pathValueToPixel(path: Path2D): Path2D {
    path = this.pathTransform(path, this.mMatrixValueToPx);
    path = this.pathTransform(path, this.mViewPortHandler.getMatrixTouch());
    path = this.pathTransform(path, this.mMatrixOffset);
    return path;
  }

  public pathTransform(path: Path2D, matrix: Matrix): Path2D {
    let values = matrix.getValues();
    this.matrix2D.scaleX = values[Matrix.MSCALE_X];
    this.matrix2D.scaleY = values[Matrix.MSCALE_Y];
    this.matrix2D.translateX = values[Matrix.MTRANS_X];
    this.matrix2D.translateY = values[Matrix.MTRANS_Y];
    this.matrix2D.rotateX = values[Matrix.MSKEW_X];
    this.matrix2D.rotateY = values[Matrix.MSKEW_Y];
    this.resultPath = new Path2D();
    this.resultPath.addPath(path, this.matrix2D);
    return this.resultPath;
  }

  /**
   * Transform an array of points with all matrices. VERY IMPORTANT: Keep
   * matrix order "value-touch-offset" when transforming.
   *
   * @param pts
   */
  public pointValuesToPixel(pts: number[]) {
    this.mMatrixValueToPx.mapPoints(pts);
    this.mViewPortHandler.getMatrixTouch().mapPoints(pts);
    this.mMatrixOffset.mapPoints(pts);
  }

  /**
   * Transform a rectangle with all matrices.
   *
   * @param r
   */
  public rectValueToPixel(r: MyRect) {

    this.mMatrixValueToPx.mapRect(r);
    this.mViewPortHandler.getMatrixTouch().mapRect(r);
    this.mMatrixOffset.mapRect(r);
  }

  /**
   * Transform a rectangle with all matrices with potential animation phases.
   *
   * @param r
   * @param phaseY
   */
  public rectToPixelPhase(r: MyRect, phaseY: number) {

    // multiply the height of the rect with the phase
    r.top *= phaseY;
    r.bottom *= phaseY;

    this.mMatrixValueToPx.mapRect(r);
    this.mViewPortHandler.getMatrixTouch().mapRect(r);
    this.mMatrixOffset.mapRect(r);
  }

  public rectToPixelPhaseHorizontal(r: MyRect, phaseY: number) {

    // multiply the height of the rect with the phase
    r.left *= phaseY;
    r.right *= phaseY;

    this.mMatrixValueToPx.mapRect(r);
    this.mViewPortHandler.getMatrixTouch().mapRect(r);
    this.mMatrixOffset.mapRect(r);
  }

  /**
   * Transform a rectangle with all matrices with potential animation phases.
   *
   * @param r
   */
  public rectValueToPixelHorizontal(r: MyRect, phaseY?: number) {
    if (phaseY != null && phaseY != undefined) {
      r.left *= phaseY;
      r.right *= phaseY;
    }
    this.mMatrixValueToPx.mapRect(r);
    this.mViewPortHandler.getMatrixTouch().mapRect(r);
    this.mMatrixOffset.mapRect(r);
  }

  /**
   * transforms multiple rects with all matrices
   *
   * @param rects
   */
  public rectValuesToPixel(rects: MyRect[]) {

    let m: Matrix = this.getValueToPixelMatrix();

    for (let i = 0; i < rects.length; i++) {
      m.mapRect(rects[i]);
    }
  }

  protected mPixelToValueMatrixBuffer: Matrix = new Matrix();

  /**
   * Transforms the given array of touch positions (pixels) (x, y, x, y, ...)
   * into values on the chart.
   *
   * @param pixels
   */
  public pixelsToValue(pixels: number[]) {

    let tmp: Matrix = this.mPixelToValueMatrixBuffer;
    tmp.reset();

    // invert all matrixes to convert back to the original value
    this.mMatrixOffset.invert(tmp);
    tmp.mapPoints(pixels);

    this.mViewPortHandler.getMatrixTouch().invert(tmp);
    tmp.mapPoints(pixels);

    this.mMatrixValueToPx.invert(tmp);
    tmp.mapPoints(pixels);
  }

  /**
   * buffer for performance
   */
  ptsBuffer: number[] = new Array<number>(2);

  /**
   * Returns a recyclable MPPointD instance.
   * returns the x and y values in the chart at the given touch point
   * (encapsulated in a MPPointD). This method transforms pixel coordinates to
   * coordinates / values in the chart. This is the opposite method to
   * getPixelForValues(...).
   *
   * @param x
   * @param y
   * @return
   */
  public getValuesByTouchPoint(x: number, y: number, outputPoint?: MPPointD): MPPointD {
    let result: MPPointD = (outputPoint != null && outputPoint != undefined) ? outputPoint : MPPointD.getInstance(0, 0);

    this.ptsBuffer[0] = x;
    this.ptsBuffer[1] = y;

    this.pixelsToValue(this.ptsBuffer);

    result.x = this.ptsBuffer[0];
    result.y = this.ptsBuffer[1];

    return result;
  }

  /**
   * Returns a recyclable MPPointD instance.
   * Returns the x and y coordinates (pixels) for a given x and y value in the chart.
   *
   * @param x
   * @param y
   * @return
   */
  public getPixelForValues(x: number, y: number): MPPointD {

    this.ptsBuffer[0] = x;
    this.ptsBuffer[1] = y;

    this.pointValuesToPixel(this.ptsBuffer);

    let xPx: number = this.ptsBuffer[0];
    let yPx: number = this.ptsBuffer[1];

    return MPPointD.getInstance(xPx, yPx);
  }

  public getValueMatrix(): Matrix {
    return this.mMatrixValueToPx;
  }

  public getOffsetMatrix(): Matrix {
    return this.mMatrixOffset;
  }

  private mMBuffer1: Matrix = new Matrix();

  public getValueToPixelMatrix(): Matrix {
    this.mMBuffer1.set(this.mMatrixValueToPx);
    this.mMBuffer1.postConcat(this.mViewPortHandler.mMatrixTouch);
    this.mMBuffer1.postConcat(this.mMatrixOffset);
    return this.mMBuffer1;
  }

  private mMBuffer2: Matrix = new Matrix();

  public getPixelToValueMatrix(): Matrix {
    this.getValueToPixelMatrix().invert(this.mMBuffer2);
    return this.mMBuffer2;
  }
}