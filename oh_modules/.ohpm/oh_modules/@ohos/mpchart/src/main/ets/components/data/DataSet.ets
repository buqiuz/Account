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

import { JArrayList } from '../utils/JArrayList';
import EntryOhos from './EntryOhos';
import BaseDataSet from './BaseDataSet';
import Utils from '../utils/Utils';
import { LogUtil } from '../utils/LogUtil';

/**
 * The DataSet class represents one group or type of entries (Entry) in the
 * Chart that belong together. It is designed to logically separate different
 * groups of values inside the Chart (e.g. the values for a specific line in the
 * LineChart, or the values of a specific group of bars in the BarChart).
 *
 */
export abstract class DataSet<T extends EntryOhos> extends BaseDataSet<T> {
  /**
   * the entries that this DataSet represents / holds together
   */
  protected mEntries: JArrayList<T> | null = new JArrayList<T>();
  /**
   * maximum y-value in the value array
   */
  protected mYMax: number = -Number.MAX_VALUE;
  /**
   * minimum y-value in the value array
   */
  protected mYMin: number = Number.MAX_VALUE;
  /**
   * maximum x-value in the value array
   */
  protected mXMax: number = -Number.MAX_VALUE;
  /**
   * minimum x-value in the value array
   */
  protected mXMin: number = Number.MAX_VALUE;

  /**
   * Creates a new DataSet object with the given values (entries) it represents. Also, a
   * label that describes the DataSet can be specified. The label can also be
   * used to retrieve the DataSet from a ChartData object.
   *
   * @param entries
   * @param label
   */
  constructor(entries: JArrayList<T> | null, label: string) {
    super(label);
    this.mEntries = entries;

    if (!this.mEntries || this.mEntries == null)
      this.mEntries = new JArrayList<T>();

    this.calcMinMax();
  }


  public calcMinMax(): void {
    this.mYMax = -Number.MAX_VALUE;
    this.mYMin = Number.MAX_VALUE;
    this.mXMax = -Number.MAX_VALUE;
    this.mXMin = Number.MAX_VALUE;
    if (!this.mEntries || this.mEntries == null || this.mEntries.isEmpty())
      return;
    for (let e of this.mEntries.dataSource) {
      this.myCalcMinMax(e);
    }
  }

  public myCalcMinMax(e ?: T): void {
    if (!e)
      return;
    this.calcMinMaxX(e);
    this.myCalcMinMaxY(e);
  }

  public calcMinMaxY(fromX: number, toX: number): void {
    this.mYMax = -Number.MAX_VALUE;
    this.mYMin = Number.MAX_VALUE;

    if (!this.mEntries || this.mEntries == null || this.mEntries.isEmpty()) {
      return;
    }
    let indexFrom: number = this.getEntryIndex(fromX, Number.NaN, Rounding.DOWN);
    let indexTo: number = this.getEntryIndex(toX, Number.NaN, Rounding.UP);

    if (indexTo < indexFrom) return;

    for (let i: number = indexFrom; i <= indexTo; i++) {
      // only recalculate y
      this.myCalcMinMaxY(this.mEntries.get(i));
    }
  }


  protected calcMinMaxX(e: T): void {

    if (e.getX() < this.mXMin)
      this.mXMin = e.getX();

    if (e.getX() > this.mXMax)
      this.mXMax = e.getX();
  }

  protected myCalcMinMaxY(e: T): void {
    if (e.getY() < this.mYMin)
      this.mYMin = e.getY();

    if (e.getY() > this.mYMax)
      this.mYMax = e.getY();
  }

  public getEntryCount(): number {
    if (this.mEntries == null) {
      return 0;
    }
    return this.mEntries.size();
  }

  //    /**
  //     * This method is deprecated.
  //     * Use getEntries() instead.
  //     *
  //     * @return
  //     */
  //    @Deprecated
  public getValues(): JArrayList<T> | null {
    return this.mEntries;
  }

  /**
   * Returns the array of entries that this DataSet represents.
   *
   * @return
   */
  public getEntries(): JArrayList<T> | null {
    return this.mEntries;
  }

  //    /**
  //     * This method is deprecated.
  //     * Use setEntries(...) instead.
  //     *
  //     * @param values
  //     */
  //    @Deprecated
  public setValues(values: JArrayList<T>): void {
    this.setEntries(values);
  }

  /**
   * Sets the array of entries that this DataSet represents, and calls notifyDataSetChanged()
   *
   * @return
   */
  public setEntries(entries: JArrayList<T>): void {
    this.mEntries = entries;
    this.notifyDataSetChanged();
  }

  /**
   *
   * @param dataSet
   */
  abstract copy(): DataSet<T>;

  protected copyTo(dataSet: DataSet<T>): void {
    super.copyTo(dataSet as BaseDataSet<T>);
  }

  public toString(): string {
    let str: string = this.toSimpleString();
    if (this.mEntries != null) {
      for (let i: number = 0; i < this.mEntries.size(); i++) {
        str += this.mEntries.get(i).toString() + " "
      }
    }
    return str;
  }

  /**
   * Returns a simple string representation of the DataSet with the type and
   * the number of Entries.
   *
   * @return
   */
  public toSimpleString(): string {
    let size = 0;
    if (this.mEntries != null) {
      size = this.mEntries.size();
    }
    let str: string = "DataSet, label: " + (!this.getLabel() ? "" : this.getLabel()) + ", entries: " + size + "\n";
    return str
  }

  public getYMin(): number {
    return this.mYMin;
  }

  public getYMax(): number {
    return this.mYMax;
  }

  public getXMin(): number {
    return this.mXMin;
  }

  public getXMax(): number {
    return this.mXMax;
  }

  public addEntryOrdered(e: T): void {

    if (!e)
      return;

    if (!this.mEntries) {
      this.mEntries = new JArrayList<T>();
    }

    this.myCalcMinMax(e);

    if (this.mEntries.size() > 0 && this.mEntries.get(this.mEntries.size() - 1).getX() > e.getX()) {
      let closestIndex: number = this.getEntryIndex(e.getX(), e.getY(), Rounding.UP);
      //              this.mEntries.add(closestIndex, e);
    } else {
      this.mEntries.add(e);
    }
  }

  public clear(): void {
    this.mEntries?.clear();
    this.notifyDataSetChanged();
  }

  public addEntry(e: T): boolean {

    if (!e)
      return false;

    let values: JArrayList<T> | null = this.getEntries();
    if (!values) {
      values = new JArrayList<T>();
    }

    this.myCalcMinMax(e);

    // add the entry
    values.add(e);
    return true;
  }

  public removeEntry(e: T): boolean {
    if (!e)
      return false;

    if (!this.mEntries)
      return false;

    // remove the entry
    let removed: boolean = this.mEntries.remove(e);

    if (removed) {
      this.calcMinMax();
    }

    return removed;
  }

  public getEntryIndexByEntry(e: T): number {
    if (this.mEntries == null) {
      return -1;
    }
    return this.mEntries.indexOf(e);
  }

  public getEntryForXValue(xValue: number, closestToY: number, rounding?: Rounding): T | null {
    let myRounding: Rounding
    if (rounding == null) {
      myRounding = Rounding.CLOSEST;
    } else {
      myRounding = rounding;
    }
    // if(closestToY){
    let index: number = this.getEntryIndex(xValue, closestToY, myRounding);
    if (index > -1)
      if (this.mEntries) {
        return this.mEntries.get(index);
      }
    // }
    return null;
  }

  public getEntryForIndex(index: number): T {
    return this.mEntries!.get(index);
  }

  public getEntryIndex(xValue: number, closestToY: number, rounding: Rounding): number {

    if (!this.mEntries || this.mEntries.isEmpty())
      return -1;

    let low: number = 0;
    let high: number = this.mEntries.size() - 1;
    let closest: number = high;

    while (low < high) {
      let m: number = Math.floor((low + high) / 2);

      let xVal1: number = this.mEntries.get(m).getX();
      let xVal2: number = this.mEntries.get(m + 1).getX();

      let d1: number = xVal1 - xValue;
      let d2: number = xVal2 - xValue;

      if (typeof d1 !== 'number' || typeof d2 !== 'number' || isNaN(d1) || isNaN(d2)) {
        LogUtil.error(`Invalid values detected: d1 = ${d1}, d2 = ${d2}, xVal1 = ${xVal1}, xVal2 = ${xVal2}, xValue = ${xValue}, Indices: m = ${m}, low = ${low}, high = ${high}`);
        break;
      }
      let ad1: number = Math.abs(d1), ad2 = Math.abs(d2);

      if (ad2 < ad1) {
        // [m + 1] is closer to xValue
        // Search in an higher place
        low = m + 1;
      } else if (ad1 < ad2) {
        // [m] is closer to xValue
        // Search in a lower place
        high = m;
      } else {
        // We have multiple sequential x-value with same distance
        if (d1 >= 0.0) {
          // Search in a lower place
          high = m;
        } else if (d1 < 0.0) {
          // Search in an higher place
          low = m + 1;
        }
      }
      closest = high;
    }

    if (closest != -1) {
      let closestXValue: number = this.mEntries.get(closest).getX();
      if (rounding == Rounding.UP) {
        // If rounding up, and found x-value is lower than specified x, and we can go upper...
        if (closestXValue < xValue && closest < this.mEntries.size() - 1) {
          ++closest;
        }
      } else if (rounding == Rounding.DOWN) {
        // If rounding down, and found x-value is upper than specified x, and we can go lower...
        if (closestXValue > xValue && closest > 0) {
          --closest;
        }
      }
      // Search by closest to y-value
      if (!Number.isNaN(closestToY)) {
        while (closest > 0 && this.mEntries.get(closest - 1).getX() == closestXValue)
          closest -= 1;

        let closestYValue: number = this.mEntries.get(closest).getY();
        let closestYIndex: number = closest;

        while (true) {
          closest += 1;
          if (closest >= this.mEntries.size())
            break;

          let value: EntryOhos = this.mEntries.get(closest);

          if (value.getX() != closestXValue)
            break;

          if (Math.abs(value.getY() - closestToY) <= Math.abs(closestYValue - closestToY)) {
            closestYValue = closestToY;
            closestYIndex = closest;
          }
        }
        closest = closestYIndex;
      }
    }
    return closest;
  }

  public getEntriesForXValue(xValue: number): JArrayList<T> {

    let entries: JArrayList<T> = new JArrayList<T>();
    if (this.mEntries == null) {
      return entries;
    }
    let low: number = 0;
    let high: number = this.mEntries.size() - 1;

    while (low <= high) {
      let m: number = (high + low) / 2;
      m = Utils.parseInt(m);
      let entry: T = this.mEntries.get(m);
      // if we have a match
      if (entry && xValue == entry.getX()) {
        while (m > 0 && this.mEntries.get(m - 1).getX() == xValue)
          m--;

        high = this.mEntries.size();

        // loop over all "equal" entries
        for (; m < high; m++) {
          if (this.mEntries != null) {
            entry = this.mEntries.get(m);
            if (entry.getX() == xValue) {
              entries.add(entry);
            } else {
              break;
            }
          }
        }

        break;
      } else {
        if (entry && xValue > entry.getX())
          low = m + 1;
        else
          high = m - 1;
      }
    }

    return entries;
  }
}

/**
 * Determines how to round DataSet index values for
 * {@link DataSet#getEntryIndex(float, float, Rounding)} DataSet.getEntryIndex()}
 * when an exact x-index is not found.
 */
export enum Rounding {
  UP,
  DOWN,
  CLOSEST,
}
