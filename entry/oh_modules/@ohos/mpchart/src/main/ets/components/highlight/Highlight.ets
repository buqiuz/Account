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

import { AxisDependency } from '../components/YAxis';

/**
 * Contains information needed to determine the highlighted value.
 */
export default class Highlight {
  /**
   * the x-value of the highlighted value
   */
  private mX: number = Number.NaN;
  /**
   * the y-value of the highlighted value
   */
  private mY: number = Number.NaN;
  /**
   * the x-pixel of the highlight
   */
  private mXPx: number = 0;
  /**
   * the y-pixel of the highlight
   */
  private mYPx: number = 0;
  /**
   * the index of the data object - in case it refers to more than one
   */
  private mDataIndex: number = -1;
  /**
   * the index of the dataset the highlighted value is in
   */
  private mDataSetIndex: number = 0;
  /**
   * index which value of a stacked bar entry is highlighted, default -1
   */
  private mStackIndex: number = -1;
  /**
   * the axis the highlighted value belongs to
   */
  private axis: AxisDependency | null = null;
  /**
   * the x-position (pixels) on which this highlight object was last drawn
   */
  private mDrawX: number = 0;
  /**
   * the y-position (pixels) on which this highlight object was last drawn
   */
  private mDrawY: number = 0;

  constructor(x: number, y: number, dataSetIndex: number, dataIndex: number, stackIndex: number, xPx: number, yPx: number, axis: AxisDependency | null) {
    this.mX = x;
    if (y == null || y == undefined) {
      this.mY = Number.NaN
    } else {
      this.mY = y;
    }
    this.mDataSetIndex = dataSetIndex ? dataSetIndex : 0;
    this.mStackIndex = stackIndex ? stackIndex : 0;
    if (dataIndex == null || dataIndex == undefined) {
      this.mDataIndex = -1;
    } else {
      this.mDataIndex = dataIndex;
    }
    this.mXPx = xPx ? xPx : 0;
    this.mYPx = yPx ? yPx : 0;
    this.axis = axis == undefined ? null : axis;
  }


  /**
   * returns the x-value of the highlighted value
   *
   * @return
   */
  public getX(): number {
    return this.mX;
  }

  /**
   * returns the y-value of the highlighted value
   *
   * @return
   */
  public getY(): number {
    return this.mY;
  }

  /**
   * returns the x-position of the highlight in pixels
   */
  public getXPx(): number {
    return this.mXPx;
  }

  /**
   * returns the y-position of the highlight in pixels
   */
  public getYPx(): number {
    return this.mYPx;
  }

  /**
   * the index of the data object - in case it refers to more than one
   *
   * @return
   */
  public getDataIndex(): number {
    return this.mDataIndex;
  }

  public setDataIndex(mDataIndex: number): void {
    this.mDataIndex = mDataIndex;
  }

  /**
   * returns the index of the DataSet the highlighted value is in
   *
   * @return
   */
  public getDataSetIndex(): number {
    return this.mDataSetIndex;
  }

  /**
   * Only needed if a stacked-barchart entry was highlighted. References the
   * selected value within the stacked-entry.
   *
   * @return
   */
  public getStackIndex(): number {
    return this.mStackIndex;
  }

  public isStacked(): boolean {
    return this.mStackIndex >= 0;
  }

  /**
   * Returns the axis the highlighted value belongs to.
   *
   * @return
   */
  public getAxis(): AxisDependency | null {
    return this.axis;
  }

  /**
   * Sets the x- and y-position (pixels) where this highlight was last drawn.
   *
   * @param x
   * @param y
   */
  public setDraw(x: number, y: number): void {
    this.mDrawX = x;
    this.mDrawY = y;
  }

  /**
   * Returns the x-position in pixels where this highlight object was last drawn.
   *
   * @return
   */
  public getDrawX(): number {
    return this.mDrawX;
  }

  /**
   * Returns the y-position in pixels where this highlight object was last drawn.
   *
   * @return
   */
  public getDrawY(): number {
    return this.mDrawY;
  }

  /**
   * Returns true if this highlight object is equal to the other (compares
   * xIndex and dataSetIndex)
   *
   * @param h
   * @return
   */
  public equalTo(h: Highlight | null): boolean {

    if (h == null)
      return false;
    else {
      if (this.mDataSetIndex == h.mDataSetIndex && this.mX == h.mX
      && this.mStackIndex == h.mStackIndex && this.mDataIndex == h.mDataIndex)
        return true;
      else
        return false;
    }
  }

  public toString(): String {
    return "Highlight, x: " + this.mX + ", y: " + this.mY + ", dataSetIndex: " + this.mDataSetIndex
    + ", stackIndex (only stacked barentry): " + this.mStackIndex;
  }
}
