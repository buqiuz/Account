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
import IValueFormatter from '../formatter/IValueFormatter';
import Highlight from '../highlight/Highlight';
import IDataSet from '../interfaces/datasets/IDataSet';
import { JArrayList } from '../utils/JArrayList';
import { LogUtil } from '../utils/LogUtil';
import EntryOhos from './EntryOhos';
import { FontFamily } from './Paint';

/**
 * Class that holds all relevant data that represents the chart. That involves
 * at least one (or more) DataSets, and an array of x-values.
 */
export default class ChartData<T extends IDataSet< /*T extends*/
EntryOhos>> {
  /**
   * maximum y-value in the value array across all axes
   */
  protected mYMax: number = -Number.MAX_VALUE;
  /**
   * the minimum y-value in the value array across all axes
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
  protected mLeftAxisMax: number = -Number.MAX_VALUE;
  protected mLeftAxisMin: number = Number.MAX_VALUE;
  protected mRightAxisMax = -Number.MAX_VALUE;
  protected mRightAxisMin: number = Number.MAX_VALUE;
  // public mDisplayRect: MyRect = new MyRect();

  /**
   * array that holds all DataSets the ChartData object represents
   */
  protected mDataSets: JArrayList<T> = new JArrayList<T>();

  /**
   * 是否仅通过X轴距离来判断是否高亮点
   */
  private mHighlightByXDistance: boolean = false;

  /**
   * Default constructor.
   */
  constructor();

  constructor(dataSets: JArrayList<T>);

  constructor(dataSets: T[]);

  constructor(dataSets ?: JArrayList<T> | T[]) {
    if (dataSets) {
      if (dataSets instanceof JArrayList) {
        this.mDataSets = dataSets;
      } else {
        this.mDataSets = this.arrayToList(dataSets);
      }
      this.notifyDataChanged();
    } else {
      this.mDataSets = new JArrayList<T>();
    }
  }

  /**
   * Created because Arrays.asList(...) does not support modification.
   *
   * @param array
   * @return
   */
  private arrayToList(array: T[]): JArrayList<T> {

    let list = new JArrayList<T>();

    for (let i = 0; i < array.length; i++) {
      let data: T = array[i];
      list.add(data);
    }

    return list;
  }

  /**
   * Call this method to let the ChartData know that the underlying data has
   * changed. Calling this performs all necessary recalculations needed when
   * the contained data has changed.
   */
  public notifyDataChanged(): void {
    this.calcMinMax();
  }

  /**
   * Calc minimum and maximum y-values over all DataSets.
   * Tell DataSets to recalculate their min and max y-values, this is only needed for autoScaleMinMax.
   *
   * @param fromX the x-value to start the calculation from
   * @param toX   the x-value to which the calculation should be performed
   */
  public calcMinMaxY(fromX: number, toX: number): void {
    if (this.mDataSets) {
      for (let i = 0; i < this.mDataSets.listSize; i++) {
        let data: T = this.mDataSets.at(i);
        data.calcMinMaxY(fromX, toX);
      }
      // apply the new data
      this.calcMinMax();
    }
  }

  /**
   * Calc minimum and maximum values (both x and y) over all DataSets.
   */
  public calcMinMax() {

    if (this.mDataSets == null)
      return;

    this.mYMax = -Number.MAX_VALUE;
    this.mYMin = Number.MAX_VALUE;
    this.mXMax = -Number.MAX_VALUE;
    this.mXMin = Number.MAX_VALUE;

    for (let dataSet of this.mDataSets.dataSource) {
      this.calcMinMax1(dataSet);
    }

    this.mLeftAxisMax = -Number.MAX_VALUE;
    this.mLeftAxisMin = Number.MAX_VALUE;
    this.mRightAxisMax = -Number.MAX_VALUE;
    this.mRightAxisMin = Number.MAX_VALUE;

    // left axis
    let firstLeft: T | null = this.getFirstLeft(this.mDataSets);

    if (firstLeft) {

      this.mLeftAxisMax = firstLeft.getYMax();
      this.mLeftAxisMin = firstLeft.getYMin();

      for (let dataSet of this.mDataSets.dataSource) {
        if (dataSet.getAxisDependency() == AxisDependency.LEFT) {
          if (dataSet.getYMin() < this.mLeftAxisMin)
            this.mLeftAxisMin = dataSet.getYMin();

          if (dataSet.getYMax() > this.mLeftAxisMax)
            this.mLeftAxisMax = dataSet.getYMax();
        }
      }
    }

    // right axis
    let firstRight: T | null = this.getFirstRight(this.mDataSets);

    if (firstRight) {

      this.mRightAxisMax = firstRight.getYMax();
      this.mRightAxisMin = firstRight.getYMin();

      for (let dataSet of this.mDataSets.dataSource) {
        if (dataSet.getAxisDependency() == AxisDependency.RIGHT) {
          if (dataSet.getYMin() < this.mRightAxisMin)
            this.mRightAxisMin = dataSet.getYMin();

          if (dataSet.getYMax() > this.mRightAxisMax)
            this.mRightAxisMax = dataSet.getYMax();
        }
      }
    }
  }

  /** ONLY GETTERS AND SETTERS BELOW THIS */

  /**
   * returns the number of LineDataSets this object contains
   *
   * @return
   */
  public getDataSetCount(): number {
    if (this.mDataSets == null) {
      return 0;
    }

    return this.mDataSets.listSize;
  }

  /**
   * Returns the smallest y-value the data object contains.
   *
   * @return
   */
  // public getYMin() : number {
  //     return this.mYMin;
  // }

  /**
   * Returns the minimum y-value for the specified axis.
   *
   * @param axis
   * @return
   */
  public getYMin(): number;

  public getYMin(axis: AxisDependency): number;

  public getYMin(axis ?: AxisDependency): number {
    if (axis == null) {
      return this.mYMin;
    }
    if (axis == AxisDependency.LEFT) {

      if (this.mLeftAxisMin == Number.MAX_VALUE) {
        return this.mRightAxisMin;
      } else
        return this.mLeftAxisMin;
    } else {
      if (this.mRightAxisMin == Number.MAX_VALUE) {
        return this.mLeftAxisMin;
      } else
        return this.mRightAxisMin;
    }
  }

  /**
   * Returns the greatest y-value the data object contains.
   *
   * @return
   */
  //    public getYMax() : number {
  //        return this.mYMax;
  //    }

  /**
   * Returns the maximum y-value for the specified axis.
   *
   * @param axis
   * @return
   */
  public getYMax(): number;

  public getYMax(axis: AxisDependency): number;

  public getYMax(axis ?: AxisDependency): number {
    if (axis == null) {
      return this.mYMax;
    }
    if (axis == AxisDependency.LEFT) {

      if (this.mLeftAxisMax == -Number.MAX_VALUE) {
        return this.mRightAxisMax;
      } else
        return this.mLeftAxisMax;
    } else {
      if (this.mRightAxisMax == -Number.MAX_VALUE) {
        return this.mLeftAxisMax;
      } else
        return this.mRightAxisMax;
    }
  }

  /**
   * Returns the minimum x-value this data object contains.
   *
   * @return
   */
  public getXMin(): number {
    return this.mXMin;
  }

  /**
   * Returns the maximum x-value this data object contains.
   *
   * @return
   */
  public getXMax(): number {
    return this.mXMax;
  }

  /**
   * Returns all DataSet objects this ChartData object holds.
   *
   * @return
   */
  public getDataSets(): JArrayList<T> {
    return this.mDataSets;
  }

  /**
   * Retrieve the index of a DataSet with a specific label from the ChartData.
   * Search can be case sensitive or not. IMPORTANT: This method does
   * calculations at runtime, do not over-use in performance critical
   * situations.
   *
   * @param dataSets   the DataSet array to search
   * @param label
   * @param ignorecase if true, the search is not case-sensitive
   * @return
   */
  protected getDataSetIndexByLabel(dataSets: JArrayList<T>, label: string,
                                   ignorecase: boolean): number {

    if (ignorecase) {
      for (let i: number = 0; i < dataSets.size(); i++)
        if (label.toLowerCase() == dataSets.get(i).getLabel().toLowerCase())
          return i;
    } else {
      for (let i: number = 0; i < dataSets.size(); i++)
        if (label == dataSets.get(i).getLabel())
          return i;
    }

    return -1;
  }

  /**
   * Returns the labels of all DataSets as a string array.
   *
   * @return
   */
  public getDataSetLabels(): string[] {
    let size: number = 0;
    if (this.mDataSets) {
      size = this.mDataSets.listSize;
    }
    let types: string[] = new Array(size);
    if (this.mDataSets) {
      for (let i: number = 0; i < this.mDataSets.listSize; i++) {
        types[i] = this.mDataSets.get(i).getLabel();
      }
    }

    return types;
  }

  /**
   * Get the Entry for a corresponding highlight object
   *
   * @param highlight
   * @return the entry that is highlighted
   */
  public getEntryForHighlight(highlight: Highlight): EntryOhos | null {
    if (!this.mDataSets) {
      return null;
    }
    if (highlight.getDataSetIndex() >= this.mDataSets.size())
      return null;
    else {
      return this.mDataSets.get(highlight.getDataSetIndex()).getEntryForXValue(highlight.getX(), highlight.getY());
    }
  }

  /**
   * Returns the DataSet object with the given label. Search can be case
   * sensitive or not. IMPORTANT: This method does calculations at runtime.
   * Use with care in performance critical situations.
   *
   * @param label
   * @param ignorecase
   * @return
   */
  public getDataSetByLabel(label: string, ignorecase: boolean): T | null {
    if (!this.mDataSets) {
      return null;
    }
    let index: number = this.getDataSetIndexByLabel(this.mDataSets, label, ignorecase);

    if (index < 0 || index >= this.mDataSets.size())
      return null;
    else
      return this.mDataSets.get(index);
  }

  public getDataSetByIndex(index: number): T | null {

    if (this.mDataSets == null || index < 0 || index >= this.mDataSets.size())
      return null;

    return this.mDataSets.get(index);
  }

  /**
   * Adds a DataSet dynamically.
   *
   * @param d
   */
  public addDataSet(d: T): void {

    if (d == null)
      return;

    this.calcMinMax1(d);
    if (this.mDataSets) {
      this.mDataSets.add(d);
    }
  }

  /**
   * Removes the given DataSet from this data object. Also recalculates all
   * minimum and maximum values. Returns true if a DataSet was removed, false
   * if no DataSet could be removed.
   *
   * @param d
   */
  public removeDataSet(d: T): boolean {

    if (d == null)
      return false;
    if (!this.mDataSets) {
      return true;
    }
    let removed: boolean = this.mDataSets.remove(d);

    // if a DataSet was removed
    if (removed) {
      this.notifyDataChanged();
    }

    return removed;
  }

  /**
   * Removes the DataSet at the given index in the DataSet array from the data
   * object. Also recalculates all minimum and maximum values. Returns true if
   * a DataSet was removed, false if no DataSet could be removed.
   *
   * @param index
   */
  public removeDataSetByIndex(index: number): boolean {
    if (!this.mDataSets) {
      return false;
    }
    if (index >= this.mDataSets.size() || index < 0)
      return false;

    let data: T = this.mDataSets.get(index);
    return this.removeDataSet(data);
  }

  /**
   * Adds an Entry to the DataSet at the specified index.
   * Entries are added to the end of the list.
   *
   * @param e
   * @param dataSetIndex
   */
  public addEntry(e: EntryOhos, dataSetIndex: number): void {

    if (this.mDataSets && this.mDataSets.size() > dataSetIndex && dataSetIndex >= 0) {

      let data: IDataSet<EntryOhos> = this.mDataSets.get(dataSetIndex);
      // add the entry to the dataset
      if (!data.addEntry(e))
        return;

      this.calcMinMax2(e, data.getAxisDependency());

    } else {
      LogUtil.log("addEntry", "Cannot add Entry because dataSetIndex too high or too low.");
    }
  }

  /**
   * Adjusts the current minimum and maximum values based on the provided Entry object.
   *
   * @param e
   * @param axis
   */
  protected calcMinMax2(e: EntryOhos, axis: AxisDependency): void {

    if (this.mYMax < e.getY())
      this.mYMax = e.getY();
    if (this.mYMin > e.getY())
      this.mYMin = e.getY();

    if (this.mXMax < e.getX())
      this.mXMax = e.getX();
    if (this.mXMin > e.getX())
      this.mXMin = e.getX();

    if (axis == AxisDependency.LEFT) {

      if (this.mLeftAxisMax < e.getY())
        this.mLeftAxisMax = e.getY();
      if (this.mLeftAxisMin > e.getY())
        this.mLeftAxisMin = e.getY();
    } else {
      if (this.mRightAxisMax < e.getY())
        this.mRightAxisMax = e.getY();
      if (this.mRightAxisMin > e.getY())
        this.mRightAxisMin = e.getY();
    }
  }

  /**
   * Adjusts the minimum and maximum values based on the given DataSet.
   *
   * @param d
   */
  protected calcMinMax1(d: T): void {

    if (this.mYMax < d.getYMax())
      this.mYMax = d.getYMax();
    if (this.mYMin > d.getYMin())
      this.mYMin = d.getYMin();

    if (this.mXMax < d.getXMax())
      this.mXMax = d.getXMax();
    if (this.mXMin > d.getXMin())
      this.mXMin = d.getXMin();

    if (d.getAxisDependency() == AxisDependency.LEFT) {

      if (this.mLeftAxisMax < d.getYMax())
        this.mLeftAxisMax = d.getYMax();
      if (this.mLeftAxisMin > d.getYMin())
        this.mLeftAxisMin = d.getYMin();
    } else {
      if (this.mRightAxisMax < d.getYMax())
        this.mRightAxisMax = d.getYMax();
      if (this.mRightAxisMin > d.getYMin())
        this.mRightAxisMin = d.getYMin();
    }
  }

  /**
   * Removes the given Entry object from the DataSet at the specified index.
   *
   * @param e
   * @param dataSetIndex
   */
  public removeEntry(e: EntryOhos, dataSetIndex: number): boolean {
    if (!this.mDataSets) {
      return true;
    }

    // entry null, outofbounds
    if (e == null || dataSetIndex >= this.mDataSets.listSize)
      return false;

    let data: IDataSet<EntryOhos> = this.mDataSets.get(dataSetIndex);

    if (data != null) {
      // remove the entry from the dataset
      let removed: boolean = data.removeEntry(e);
      if (removed) {
        this.notifyDataChanged();
      }

      return removed;
    } else
      return false;
  }

  /**
   * Removes the Entry object closest to the given DataSet at the
   * specified index. Returns true if an Entry was removed, false if no Entry
   * was found that meets the specified requirements.
   *
   * @param xValue
   * @param dataSetIndex
   * @return
   */
  public removeEntryByXValue(xValue: number, dataSetIndex: number): boolean {
    if (!this.mDataSets) {
      return false;
    }
    if (dataSetIndex >= this.mDataSets.size())
      return false;

    let dataSet: IDataSet<EntryOhos> = this.mDataSets.get(dataSetIndex);
    let e: EntryOhos | null = dataSet.getEntryForXValue(xValue, Number.NaN);

    if (e == null)
      return false;

    return this.removeEntry(e, dataSetIndex);
  }

  /**
   * Returns the DataSet that contains the provided Entry, or null, if no
   * DataSet contains this Entry.
   *
   * @param e
   * @return
   */
  public getDataSetForEntry(e: EntryOhos): T | null {

    if (e == null)
      return null;
    if (this.mDataSets) {
      for (let i = 0; i < this.mDataSets.size(); i++) {

        let dataSet: T = this.mDataSets.get(i);

        for (let j = 0; j < dataSet.getEntryCount(); j++) {
          if (dataSet.getEntryForXValue(e.getX(), e.getY())) {
            if (e.equalTo(dataSet.getEntryForXValue(e.getX(), e.getY()) !))
              return dataSet;
          }
        }
      }
    }


    return null;
  }

  /**
   * Returns all colors used across all DataSet objects this object
   * represents.
   *
   * @return
   */
  public getColors(): number[] | null {

    if (this.mDataSets == null)
      return null;

    let clrcnt: number = 0;

    for (let i = 0; i < this.mDataSets.listSize; i++) {
      clrcnt += this.mDataSets.get(i).getColors().size();
    }

    let colors: number[] = new Array(clrcnt);
    let cnt: number = 0

    for (let i = 0; i < this.mDataSets.size(); i++) {

      let clrs: JArrayList<Number> = this.mDataSets.get(i).getColors();

      for (let j = 0; j < clrs.size(); j++) {
        colors[cnt] = clrs.get(j).valueOf();
        cnt++;
      }
    }

    return colors;
  }

  /**
   * Returns the index of the provided DataSet in the DataSet array of this data object, or -1 if it does not exist.
   *
   * @param dataSet
   * @return
   */
  public getIndexOfDataSet(dataSet: T): number {
    if (this.mDataSets) {
      return this.mDataSets.indexOf(dataSet);
    }
    return -1;
  }

  /**
   * Returns the first DataSet from the datasets-array that has it's dependency on the left axis.
   * Returns null if no DataSet with left dependency could be found.
   *
   * @return
   */
  protected getFirstLeft(sets: JArrayList<T>): T | null {
    for (let dataSet of sets.dataSource) {
      if (dataSet.getAxisDependency() == AxisDependency.LEFT)
        return dataSet;
    }
    return null;
  }

  /**
   * Returns the first DataSet from the datasets-array that has it's dependency on the right axis.
   * Returns null if no DataSet with right dependency could be found.
   *
   * @return
   */
  public getFirstRight(sets: JArrayList<T>): T | null {
    for (let dataSet of sets.dataSource) {
      if (dataSet.getAxisDependency() == AxisDependency.RIGHT)
        return dataSet;
    }
    return null;
  }

  /**
   * Sets a custom IValueFormatter for all DataSets this data object contains.
   *
   * @param f
   */
  public setValueFormatter(f: IValueFormatter): void {
    if (f == null)
      return;
    else {
      if (this.mDataSets) {
        for (let data of this.mDataSets.dataSource) {
          data.setValueFormatter(f);
        }
      }
    }
  }

  /**
   * Sets the color of the value-text (color in which the value-labels are
   * drawn) for all DataSets this data object contains.
   *
   * @param color
   */
  public setValueTextColor(color: number): void {
    if (this.mDataSets) {
      for (let data of this.mDataSets.dataSource) {
        data.setValueTextColor(color);
      }
    }
  }

  /**
   * Sets the same list of value-colors for all DataSets this
   * data object contains.
   *
   * @param colors
   */
  public setValueTextColors(colors: JArrayList<Number>): void {
    if (this.mDataSets) {
      for (let data of this.mDataSets.dataSource) {
        data.setValueTextColors(colors);
      }
    }
  }

  /**
   * Sets the Typeface for all value-labels for all DataSets this data object
   * contains.
   *
   * @param tf
   */
  public setValueTypeface(tf: FontFamily): void {
    if (this.mDataSets) {
      for (let data of this.mDataSets.dataSource) {
        data.setValueTypeface(tf);
      }
    }
  }

  /**
   * Sets the size (in vp) of the value-text for all DataSets this data object
   * contains.
   *
   * @param size
   */
  public setValueTextSize(size: number): void {
    if (this.mDataSets) {
      for (let data of this.mDataSets.dataSource) {
        data.setValueTextSize(size);
      }
    }
  }

  /**
   * Enables / disables drawing values (value-text) for all DataSets this data
   * object contains.
   *
   * @param enabled
   */
  public setDrawValues(enabled: boolean): void {
    if (this.mDataSets) {
      for (let data of this.mDataSets.dataSource) {
        data.setDrawValues(enabled);
      }
    }
  }

  /**
   * Enables / disables highlighting values for all DataSets this data object
   * contains. If set to true, this means that values can
   * be highlighted programmatically or by touch gesture.
   */
  public setHighlightEnabled(enabled: boolean): void {
    if (this.mDataSets) {
      for (let data of this.mDataSets.dataSource) {
        data.setHighlightEnabled(enabled);
      }
    }
  }

  /**
   * Returns true if highlighting of all underlying values is enabled, false
   * if not.
   *
   * @return
   */
  public isHighlightEnabled(): boolean {
    if (this.mDataSets) {
      for (let data of this.mDataSets.dataSource) {
        if (!data.isHighlightEnabled())
          return false;
      }
    }

    return true;
  }

  /**
   * Clears this data object from all DataSets and removes all Entries. Don't
   * forget to invalidate the chart after this.
   */
  clearValues(): void {
    if (this.mDataSets != null) {
      this.mDataSets.clear();
    }
    this.notifyDataChanged();
  }

  /**
   * Checks if this data object contains the specified DataSet. Returns true
   * if so, false if not.
   *
   * @param dataSet
   * @return
   */
  public contains(dataSet: T): boolean {
    if (this.mDataSets) {
      for (let data of this.mDataSets.dataSource) {
        if (data == dataSet)
          return true;
      }
    }

    return false;
  }

  /**
   * Returns the total entry count across all DataSet objects this data object contains.
   *
   * @return
   */
  public getEntryCount(): number {

    let count: number = 0;
    if (this.mDataSets) {
      for (let data of this.mDataSets.dataSource) {
        count += data.getEntryCount();
      }
    }

    return count;
  }

  /**
   * Returns the DataSet object with the maximum number of entries or null if there are no DataSets.
   *
   * @return
   */
  public getMaxEntryCountSet(): T | null {

    if (this.mDataSets == null || this.mDataSets.isEmpty())
      return null;

    let max: T = this.mDataSets.get(0);

    for (let data of this.mDataSets.dataSource) {

      if (data.getEntryCount() > max.getEntryCount())
        max = data;
    }

    return max;
  }

  /**
   * 设置是否仅通过X轴距离来判断是否高亮点
   * @param value 是否仅通过X轴距离来判断是否高亮点
   */
  public setHighlightByXDistance(highlightByXDistance: boolean){
    this.mHighlightByXDistance = highlightByXDistance;
  }

  /**
   * 检查是否仅通过X轴距离来判断是否高亮点
   * @returns 是否仅通过X轴距离来判断是否高亮点的布尔值
   */
  public isHighlightByXDistance(): boolean{
    return this.mHighlightByXDistance;
  }
}
