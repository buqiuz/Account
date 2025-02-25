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

import MyRect from '../data/Rect'
import Matrix from '../utils/Matrix'
import MPPointF from './MPPointF'
import Utils from './Utils'
import Chart from '../charts/ChartModel'
import EntryOhos from '../data/EntryOhos'
import IDataSet from '../interfaces/datasets/IDataSet'
import ChartData from '../data/ChartData'

/**
 * Class that contains information about the charts current viewport settings, including offsets, scale & translation
 * levels, ...
 *
 *
 */
export default class ViewPortHandler {
  /**
   * matrix used for touch events
   */
  public mMatrixTouch: Matrix = new Matrix();
  /**
   * this rectangle defines the area in which graph values can be drawn
   */
  protected mContentRect = new MyRect();
  protected mChartWidth: number = 0.0;
  protected mChartHeight: number = 0.0;
  /**
   * minimum scale value on the y-axis
   */
  private mMinScaleY: number = 1.0;
  /**
   * maximum scale value on the y-axis
   */
  private mMaxScaleY: number = Number.MAX_VALUE;
  /**
   * minimum scale value on the x-axis
   */
  private mMinScaleX: number = 1.0;
  /**
   * maximum scale value on the x-axis
   */
  private mMaxScaleX: number = Number.MAX_VALUE;
  /**
   * contains the current scale factor of the x-axis
   */
  private mScaleX: number = 1.0;
  /**
   * contains the current scale factor of the y-axis
   */
  private mScaleY: number = 1.0;
  /**
   * current translation (drag distance) on the x-axis
   */
  private mTransX: number = 0.0;
  /**
   * current translation (drag distance) on the y-axis
   */
  private mTransY: number = 0.0;
  /**
   * offset that allows the chart to be dragged over its bounds on the x-axis
   */
  private mTransOffsetX: number = 0.0;
  /**
   * offset that allows the chart to be dragged over its bounds on the x-axis
   */
  private mTransOffsetY: number = 0.0;

  /**
   * Sets the width and height of the chart.
   *
   * @param width
   * @param height
   */
  public setChartDimens(width: number, height: number) {

    let offsetLeft = this.offsetLeft();
    let offsetTop = this.offsetTop();
    let offsetRight = this.offsetRight();
    let offsetBottom = this.offsetBottom();

    this.mChartHeight = height;
    this.mChartWidth = width;

    this.restrainViewPort(offsetLeft, offsetTop, offsetRight, offsetBottom);
  }

  public hasChartDimens(): boolean {
    if (this.mChartHeight > 0 && this.mChartWidth > 0) {
      return true;
    } else {
      return false;
    }
  }

  public restrainViewPort(offsetLeft: number, offsetTop: number, offsetRight: number,
                          offsetBottom: number) {
    this.mContentRect.set(offsetLeft, offsetTop, this.mChartWidth - offsetRight, this.mChartHeight
    - offsetBottom);
  }

  public offsetLeft(): number {
    return this.mContentRect.left;
  }

  public offsetRight(): number {
    return this.mChartWidth - this.mContentRect.right;
  }

  public offsetTop(): number {
    return this.mContentRect.top;
  }

  public offsetBottom(): number {
    return this.mChartHeight - this.mContentRect.bottom;
  }

  public contentTop(): number {
    return this.mContentRect.top;
  }

  public contentLeft(): number {
    return this.mContentRect.left;
  }

  public contentRight(): number {
    return this.mContentRect.right;
  }

  public contentBottom(): number {
    return this.mContentRect.bottom;
  }

  public contentWidth(): number {
    return this.mContentRect.width();
  }

  public contentHeight(): number {
    return this.mContentRect.height();
  }

  public getContentRect(): MyRect {
    return this.mContentRect;
  }

  public getContentCenter(): MPPointF {
    return MPPointF.getInstance(this.mContentRect.centerX(), this.mContentRect.centerY());
  }

  public getChartHeight(): number {
    return this.mChartHeight;
  }

  public getChartWidth(): number {
    return this.mChartWidth;
  }

  /**
   * Returns the smallest extension of the content rect (width or height).
   *
   * @return
   */
  public getSmallestContentExtension(): number {
    return Math.min(this.mContentRect.width(), this.mContentRect.height());
  }

  /**
   * ################ ################ ################ ################
   */
  /** CODE BELOW THIS RELATED TO SCALING AND GESTURES */

  /**
   * Zooms in by 1.4f, x and y are the coordinates (in pixels) of the zoom
   * center.
   *
   * @param x
   * @param y
   */
  public zoomIn(x: number, y: number, outputMatrix?: Matrix): Matrix {
    let save: Matrix = (outputMatrix == null || outputMatrix == undefined) ? new Matrix() : outputMatrix;
    save.reset();
    save.set(this.mMatrixTouch);
    save.postScale(1.4, 1.4, x, y);
    return save;
  }

  public zoomOut(x: number, y: number, outputMatrix?: Matrix): Matrix | void {
    if (!outputMatrix) {
      outputMatrix = new Matrix();
    }
    outputMatrix.reset();
    outputMatrix.set(this.mMatrixTouch);
    outputMatrix.postScale(0.7, 0.7, x, y);
    if (!outputMatrix) {
      return outputMatrix;
    }
  }

  /**
   * Zooms out to original size.
   * @param outputMatrix
   */
  public resetZoom(outputMatrix: Matrix): void {
    outputMatrix.reset();
    outputMatrix.set(this.mMatrixTouch);
    outputMatrix.postScale(1.0, 1.0, 0.0, 0.0);
  }

  /**
   * Post-scales by the specified scale factors.
   *
   * @param scaleX
   * @param scaleY
   * @return
   */
  public zoom(scaleX: number, scaleY: number, x?: number, y?: number, outputMatrix?: Matrix): Matrix | void {

    let save: Matrix = (outputMatrix != null && outputMatrix != undefined) ? outputMatrix : new Matrix();
    save.reset();
    save.set(this.mMatrixTouch);
    if (x != undefined && x != null && y != undefined && y != null) {
      save.postScale(scaleX, scaleY, x, y);
    } else {
      save.postScale(scaleX, scaleY);
    }
    if (!outputMatrix) {
      return save;
    }
  }


  /**
   * Sets the scale factor to the specified values.
   *
   * @param scaleX
   * @param scaleY
   * @return
   */
  public setZoom(scaleX: number, scaleY: number, x?: number, y?: number): Matrix {

    let save: Matrix = new Matrix();
    save.reset();
    save.set(this.mMatrixTouch);
    if (x != undefined && y != undefined) {
      save.setScale(scaleX, scaleY, x, y);
    } else {
      save.setScale(scaleX, scaleY);
    }
    return save;
  }

  protected valsBufferForFitScreen: number[] = new Array<number>(9);

  /**
   * Resets all zooming and dragging and makes the chart fit exactly it's
   * bounds.  Output Matrix is available for those who wish to cache the object.
   */
  public fitScreen(outputMatrix?: Matrix): Matrix {

    let save: Matrix = (outputMatrix == null || outputMatrix == undefined) ? new Matrix() : outputMatrix;
    this.mMinScaleX = 1;
    this.mMinScaleY = 1;

    save.set(this.mMatrixTouch);

    let vals: number[] = save.getValues();

    // reset all translations and scaling
    vals[Matrix.MTRANS_X] = 0;
    vals[Matrix.MTRANS_Y] = 0;
    vals[Matrix.MSCALE_X] = 1;
    vals[Matrix.MSCALE_Y] = 1;

    save.setValues(vals);

    return save;
  }

  /**
   * Post-translates to the specified points.  Less Performant.
   *
   * @param transformedPts
   * @return
   */
  public translate(transformedPts: number[], outputMatrix?: Matrix): Matrix {

    let save: Matrix = (outputMatrix != null && outputMatrix != undefined) ? outputMatrix : new Matrix();
    save.reset();
    save.set(this.mMatrixTouch);
    const x: number = transformedPts[0] - this.offsetLeft();
    const y: number = transformedPts[1] - this.offsetTop();
    save.postTranslate(-x, -y);
    return save;
  }

  protected mCenterViewPortMatrixBuffer: Matrix = new Matrix();

  /**
   * Centers the viewport around the specified position (x-index and y-value)
   * in the chart. Centering the viewport outside the bounds of the chart is
   * not possible. Makes most sense in combination with the
   * setScaleMinima(...) method.
   *
   * @param transformedPts the position to center view viewport to
   * @param view
   * @return save
   */
  public centerViewPort(transformedPts: number[], view: Chart<ChartData<IDataSet<EntryOhos>>>) {

    let save: Matrix = this.mCenterViewPortMatrixBuffer;
    save.reset();
    save.set(this.mMatrixTouch);

    const x: number = transformedPts[0] - this.offsetLeft();
    const y: number = transformedPts[1] - this.offsetTop();

    save.postTranslate(-x, -y);

    this.refresh(save, view, true);
  }

  /**
   * buffer for storing the 9 matrix values of a 3x3 matrix
   */
  protected matrixBuffer: number[] = new Array<number>(9);

  /**
   * call this method to refresh the graph with a given matrix
   *
   * @param newMatrix
   * @return
   */
  public refresh(newMatrix: Matrix, chart: Chart<ChartData<IDataSet<EntryOhos>>>, invalidate: boolean): Matrix {

    this.mMatrixTouch.set(newMatrix);

    // make sure scale and translation are within their bounds
    this.limitTransAndScale(this.mMatrixTouch, this.mContentRect);

    if (invalidate)
      chart.invalidate();

    newMatrix.set(this.mMatrixTouch);
    return newMatrix;
  }

  /**
   * limits the maximum scale and X translation of the given matrix
   *
   * @param matrix
   */
  public limitTransAndScale(matrix: Matrix, content: MyRect) {

    this.matrixBuffer = matrix.getValues();

    let curTransX: number = this.matrixBuffer[Matrix.MTRANS_X];
    let curScaleX: number = this.matrixBuffer[Matrix.MSCALE_X];

    let curTransY: number = this.matrixBuffer[Matrix.MTRANS_Y];
    let curScaleY: number = this.matrixBuffer[Matrix.MSCALE_Y];

    // min scale-x is 1f
    this.mScaleX = Math.min(Math.max(this.mMinScaleX, curScaleX), this.mMaxScaleX);

    // min scale-y is 1f
    this.mScaleY = Math.min(Math.max(this.mMinScaleY, curScaleY), this.mMaxScaleY);

    let width: number = 0;
    let height: number = 0;

    if (content != null) {
      width = content.width();
      height = content.height();
    }

    let maxTransX: number = -width * (this.mScaleX - 1);
    this.mTransX = Math.min(Math.max(curTransX, maxTransX - this.mTransOffsetX), this.mTransOffsetX);

    let maxTransY: number = height * (this.mScaleY - 1);
    this.mTransY = Math.max(Math.min(curTransY, maxTransY + this.mTransOffsetY), -this.mTransOffsetY);

    this.matrixBuffer[Matrix.MTRANS_X] = this.mTransX;
    this.matrixBuffer[Matrix.MSCALE_X] = this.mScaleX;

    this.matrixBuffer[Matrix.MTRANS_Y] = this.mTransY;
    this.matrixBuffer[Matrix.MSCALE_Y] = this.mScaleY;

    matrix.setValues(this.matrixBuffer);
  }

  /**
   * Sets the minimum scale factor for the x-axis
   *
   * @param xScale
   */
  public setMinimumScaleX(xScale: number) {

    if (xScale < 1)
      xScale = 1;

    this.mMinScaleX = xScale;

    this.limitTransAndScale(this.mMatrixTouch, this.mContentRect);
  }

  /**
   * Sets the maximum scale factor for the x-axis
   *
   * @param xScale
   */
  public setMaximumScaleX(xScale: number) {

    if (xScale == 0.0)
      xScale = Number.MAX_VALUE;

    this.mMaxScaleX = xScale;

    this.limitTransAndScale(this.mMatrixTouch, this.mContentRect);
  }

  /**
   * Sets the minimum and maximum scale factors for the x-axis
   *
   * @param minScaleX
   * @param maxScaleX
   */
  public setMinMaxScaleX(minScaleX: number, maxScaleX: number) {

    if (minScaleX < 1)
      minScaleX = 1;

    if (maxScaleX == 0.0)
      maxScaleX = Number.MAX_VALUE;

    this.mMinScaleX = minScaleX;
    this.mMaxScaleX = maxScaleX;

    this.limitTransAndScale(this.mMatrixTouch, this.mContentRect);
  }

  /**
   * Sets the minimum scale factor for the y-axis
   *
   * @param yScale
   */
  public setMinimumScaleY(yScale: number) {

    if (yScale < 1)
      yScale = 1;

    this.mMinScaleY = yScale;

    this.limitTransAndScale(this.mMatrixTouch, this.mContentRect);
  }

  /**
   * Sets the maximum scale factor for the y-axis
   *
   * @param yScale
   */
  public setMaximumScaleY(yScale: number) {

    if (yScale == 0.0)
      yScale = Number.MAX_VALUE;

    this.mMaxScaleY = yScale;

    this.limitTransAndScale(this.mMatrixTouch, this.mContentRect);
  }

  public setMinMaxScaleY(minScaleY: number, maxScaleY: number) {

    if (minScaleY < 1)
      minScaleY = 1;

    if (maxScaleY == 0.0)
      maxScaleY = Number.MAX_VALUE;

    this.mMinScaleY = minScaleY;
    this.mMaxScaleY = maxScaleY;

    this.limitTransAndScale(this.mMatrixTouch, this.mContentRect);
  }

  /**
   * Returns the charts-touch matrix used for translation and scale on touch.
   *
   * @return
   */
  public getMatrixTouch(): Matrix {
    return this.mMatrixTouch;
  }

  /**
   * ################ ################ ################ ################
   */
  /**
   * BELOW METHODS FOR BOUNDS CHECK
   */
  public isInBoundsX(x: number): boolean {
    return this.isInBoundsLeft(x) && this.isInBoundsRight(x);
  }

  public isInBoundsY(y: number) {
    return this.isInBoundsTop(y) && this.isInBoundsBottom(y);
  }

  public isInBounds(x: number, y: number): boolean {
    return this.isInBoundsX(x) && this.isInBoundsY(y);
  }

  public isInBoundsLeft(x: number): boolean {
    return this.mContentRect.left <= x + 1;
  }

  public isInBoundsRight(x: number): boolean {
    return this.mContentRect.right >= x - 1;
  }

  public isInBoundsTop(y: number): boolean {
    return this.mContentRect.top <= y;
  }

  public isInBoundsBottom(y: number): boolean {
    return this.mContentRect.bottom >= y;
  }

  /**
   * returns the current x-scale factor
   */
  public getScaleX(): number {
    return this.mScaleX;
  }

  /**
   * returns the current y-scale factor
   */
  public getScaleY(): number {
    return this.mScaleY;
  }

  public getMinScaleX(): number {
    return this.mMinScaleX;
  }

  public getMaxScaleX(): number {
    return this.mMaxScaleX;
  }

  public getMinScaleY(): number {
    return this.mMinScaleY;
  }

  public getMaxScaleY(): number {
    return this.mMaxScaleY;
  }

  /**
   * Returns the translation (drag / pan) distance on the x-axis
   *
   * @return
   */
  public getTransX(): number {
    return this.mTransX;
  }

  /**
   * Returns the translation (drag / pan) distance on the y-axis
   *
   * @return
   */
  public getTransY(): number {
    return this.mTransY;
  }

  /**
   * if the chart is fully zoomed out, return true
   *
   * @return
   */
  public isFullyZoomedOut(): boolean {

    return this.isFullyZoomedOutX() && this.isFullyZoomedOutY();
  }

  /**
   * Returns true if the chart is fully zoomed out on it's y-axis (vertical).
   *
   * @return
   */
  public isFullyZoomedOutY(): boolean {
    return !(this.mScaleY > this.mMinScaleY || this.mMinScaleY > 1);
  }

  /**
   * Returns true if the chart is fully zoomed out on it's x-axis
   * (horizontal).
   *
   * @return
   */
  public isFullyZoomedOutX(): boolean {
    return !(this.mScaleX > this.mMinScaleX || this.mMinScaleX > 1);
  }

  /**
   * Set an offset in vp that allows the user to drag the chart over it's
   * bounds on the x-axis.
   *
   * @param offset
   */
  public setDragOffsetX(offset: number) {
    this.mTransOffsetX = Utils.handleDataValues(offset);
  }

  /**
   * Set an offset in vp that allows the user to drag the chart over it's
   * bounds on the y-axis.
   *
   * @param offset
   */
  public setDragOffsetY(offset: number) {
    this.mTransOffsetY = Utils.handleDataValues(offset);
  }

  /**
   * Returns true if both drag offsets (x and y) are zero or smaller.
   *
   * @return
   */
  public hasNoDragOffset(): boolean {
    return this.mTransOffsetX <= 0 && this.mTransOffsetY <= 0;
  }

  /**
   * Returns true if the chart is not yet fully zoomed out on the x-axis
   *
   * @return
   */
  public canZoomOutMoreX(): boolean {
    return this.mScaleX > this.mMinScaleX;
  }

  /**
   * Returns true if the chart is not yet fully zoomed in on the x-axis
   *
   * @return
   */
  public canZoomInMoreX(): boolean {
    return this.mScaleX < this.mMaxScaleX;
  }

  /**
   * Returns true if the chart is not yet fully zoomed out on the y-axis
   *
   * @return
   */
  public canZoomOutMoreY(): boolean {
    return this.mScaleY > this.mMinScaleY;
  }

  /**
   * Returns true if the chart is not yet fully zoomed in on the y-axis
   *
   * @return
   */
  public canZoomInMoreY(): boolean {
    return this.mScaleY < this.mMaxScaleY;
  }
}
