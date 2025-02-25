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

import { DashPathEffect, FontFamily } from './Paint';
import EntryOhos from './EntryOhos';
import IDataSet from '../interfaces/datasets/IDataSet';
import { JArrayList } from '../utils/JArrayList';
import { AxisDependency } from '../components/YAxis';
import IValueFormatter from '../formatter/IValueFormatter';
import { LegendForm } from '../components/Legend';
import MPPointF from '../utils/MPPointF';
import ColorTemplate from '../utils/ColorTemplate';
import Utils from '../utils/Utils';
import { Rounding } from './DataSet';

/**
 * This is the base dataset of all DataSets. It's purpose is to implement critical methods
 * provided by the IDataSet interface.
 */
export default abstract class BaseDataSet<T extends EntryOhos> implements IDataSet<T> {
  /**
   * List representing all colors that are used for this DataSet
   */
  protected mColors: JArrayList<Number> = new JArrayList<Number>();
  /**
   * List representing all colors that are used for drawing the actual values for this DataSet
   */
  protected mValueColors: JArrayList<Number> = new JArrayList<Number>();
  /**
   * label that describes the DataSet or the data the DataSet represents
   */
  private mLabel: string = "DataSet";
  /**
   * this specifies which axis this DataSet should be plotted against
   */
  protected mAxisDependency: AxisDependency = AxisDependency.LEFT;
  /**
   * if true, value highlighting is enabled
   */
  protected mHighlightEnabled: boolean = true;
  /**
   * custom formatter that is used instead of the auto-formatter if set
   */
  protected mValueFormatter: IValueFormatter | null = null;
  /**
   * the typeface used for the value text
   */
  protected mValueTypeface: FontFamily /*Typeface*/
    = ''
  private mForm: LegendForm = LegendForm.DEFAULT;
  private mFormSize: number = Number.NaN;
  private mFormLineWidth: number = Number.NaN;
  private mFormLineDashEffect: DashPathEffect | null = null;
  /**
   * if true, y-values are drawn on the chart
   */
  protected mDrawValues: boolean = true;
  /**
   * if true, y-icons are drawn on the chart
   */
  protected mDrawIcons: boolean = true;
  /**
   * the offset for drawing icons (in vp)
   */
  protected mIconsOffset: MPPointF = new MPPointF();
  /**
   * the size of the value-text labels
   */
  protected mValueTextSize: number = 8.0;
  /**
   * flag that indicates if the DataSet is visible or not
   */
  protected mVisible: boolean = true;

  /**
   * Default constructor.
   */
  // constructor();

  // constructor(label: string);

  constructor(label?: string) {
    this.mColors = new JArrayList<number>();
    this.mValueColors = new JArrayList<number>();
    // default color
    this.mColors.add(0x8ceaff);
    this.mValueColors.add(0x000000);
    if (label != undefined) {
      this.mLabel = label;
    } else {
      this.mLabel = 'DataSet';
    }
  }

  /**
   * Use this method to tell the data set that the underlying data has changed.
   */
  public notifyDataSetChanged(): void {
    this.calcMinMax();
  }


  /**
   * ###### ###### COLOR GETTING RELATED METHODS ##### ######
   */
  public getColors(): JArrayList<Number> {
    return this.mColors;
  }

  public getValueColors(): JArrayList<Number> {
    return this.mValueColors;
  }

  public getColor(index?: number): number {
    if (index === undefined) {
      return this.mColors.get(0).valueOf();
    }
    return this.mColors.get(Math.floor(index) % this.mColors.size()).valueOf();
  }


  /**
   * ###### ###### COLOR SETTING RELATED METHODS ##### ######
   */

  /**
   * Sets the colors that should be used fore this DataSet. Colors are reused
   * as soon as the number of Entries the DataSet represents is higher than
   * the size of the colors array. If you are using colors from the resources,
   * make sure that the colors are already prepared (by calling
   * getResources().getColor(...)) before adding them to the DataSet.
   *
   * @param colors
   */
  public setColorsByList(colors: JArrayList<Number>): void {
    this.mColors = colors;
  }

  /**
   * Sets the colors that should be used fore this DataSet. Colors are reused
   * as soon as the number of Entries the DataSet represents is higher than
   * the size of the colors array. If you are using colors from the resources,
   * make sure that the colors are already prepared (by calling
   * getResources().getColor(...)) before adding them to the DataSet.
   *
   * @param colors
   */
  public setColorsByVariable(colors: number[]): void {
    this.mColors = ColorTemplate.createColors(colors);
  }

  /**
   * Sets the colors that should be used fore this DataSet. Colors are reused
   * as soon as the number of Entries the DataSet represents is higher than
   * the size of the colors array. You can use
   * "new int[] { R.color.red, R.color.green, ... }" to provide colors for
   * this method. Internally, the colors are resolved using
   * getResources().getColor(...)
   *
   * @param colors
   */
  public setColorsByArr(colors: number[]): void {

    if (this.mColors == null) {
      this.mColors = new JArrayList <Number>();
    }
    this.mColors.clear();
    for (let color of colors) {
      this.mColors.add(color);
    }
  }

  /**
   * Adds a new color to the colors array of the DataSet.
   *
   * @param color
   */
  public addColor(color: number): void {
    if (this.mColors == null) {
      this.mColors = new JArrayList<Number>();
    }
    this.mColors.add(color);
  }

  /**
   * Sets the one and ONLY color that should be used for this DataSet.
   * Internally, this recreates the colors array and adds the specified color.
   *
   * @param color
   */
  public setColorByColor(color: Number): void {
    this.resetColors();
    this.mColors.add(color);
  }

  /**
   * Sets a color with a specific alpha value.
   *
   * @param color
   * @param alpha from 0-255
   */
  public setColorByAlpha(color: number, alpha: number): void {
    let mColor: number = ColorTemplate.argb(alpha, ColorTemplate.red(color), ColorTemplate.green(color), ColorTemplate.blue(color));
    this.setColorsByVariable([mColor])
  }

  /**
   * Sets colors with a specific alpha value.
   *
   * @param colors
   * @param alpha
   */
  public setColorsByArrAndAlpha(colors: number[], alpha: number): void {
    this.resetColors();
    for (let color of colors) {
      this.addColor(ColorTemplate.argb(alpha, ColorTemplate.red(color), ColorTemplate.green(color), ColorTemplate.blue(color)));
    }
  }

  /**
   * Resets all colors of this DataSet and recreates the colors array.
   */
  public resetColors(): void {
    if (this.mColors == null) {
      this.mColors = new JArrayList<Number>();
    }
    this.mColors.clear();
  }


  /**
   * ###### ###### OTHER STYLING RELATED METHODS ##### ######
   */
  public setLabel(label: string): void {
    this.mLabel = label;
  }

  public getLabel(): string {
    return this.mLabel;
  }

  public setHighlightEnabled(enabled: boolean): void {
    this.mHighlightEnabled = enabled;
  }

  public isHighlightEnabled(): boolean {
    return this.mHighlightEnabled;
  }

  public setValueFormatter(f: IValueFormatter): void {

    if (f == null)
      return;
    else
      this.mValueFormatter = f;
  }

  public getValueFormatter(): IValueFormatter | null {
    if (this.needsFormatter()) {
      return Utils.getDefaultValueFormatter();
    }
    return this.mValueFormatter;
  }

  public needsFormatter(): boolean {
    return this.mValueFormatter == null;
  }

  public setValueTextColor(color: number): void {
    if (this.mValueColors) {
      this.mValueColors.clear();
      this.mValueColors.add(color);
    }
  }

  public setValueTextColors(colors: JArrayList<Number>): void {
    if (this.mValueColors) {
      this.mValueColors = colors;
    }
  }

  public setValueTypeface(tf: FontFamily /*Typeface*/
  ): void {
    this.mValueTypeface = tf;
  }

  public setValueTextSize(size: number): void {
    this.mValueTextSize = size;
  }

  public getValueTextColor(index?: number): number {
    if (!index) {
      index = 0
    }
    if (this.mValueColors) {
      return this.mValueColors.get(index % this.mValueColors.size()).valueOf();
    }
    return 0;
  }

  public getValueTypeface(): FontFamily {
    return this.mValueTypeface;
  }

  public getValueTextSize(): number {
    return this.mValueTextSize;
  }

  public setForm(form: LegendForm): void {
    this.mForm = form;
  }

  public getForm(): LegendForm {
    return this.mForm;
  }

  public setFormSize(formSize: number): void {
    this.mFormSize = formSize;
  }

  public getFormSize(): number {
    return this.mFormSize;
  }

  public setFormLineWidth(formLineWidth: number): void {
    this.mFormLineWidth = formLineWidth;
  }

  public getFormLineWidth(): number {
    return this.mFormLineWidth;
  }

  public setFormLineDashEffect(dashPathEffect: DashPathEffect | null
  ): void {
    this.mFormLineDashEffect = dashPathEffect;
  }

  public getFormLineDashEffect(): DashPathEffect | null {
    return this.mFormLineDashEffect;
  }

  public setDrawValues(enabled: boolean): void {
    this.mDrawValues = enabled;
  }

  public isDrawValuesEnabled(): boolean {
    return this.mDrawValues;
  }

  public setDrawIcons(enabled: boolean): void {
    this.mDrawIcons = enabled;
  }

  public isDrawIconsEnabled(): boolean {
    return this.mDrawIcons;
  }

  public setIconsOffset(offsetDp: MPPointF): void {

    this.mIconsOffset.x = offsetDp.x;
    this.mIconsOffset.y = offsetDp.y;
  }

  public getIconsOffset(): MPPointF {
    return this.mIconsOffset;
  }

  public setVisible(visible: boolean): void {
    this.mVisible = visible;
  }

  public isVisible(): boolean {
    return this.mVisible;
  }

  public getAxisDependency(): AxisDependency {
    return this.mAxisDependency;
  }

  public setAxisDependency(dependency: AxisDependency): void {
    this.mAxisDependency = dependency;
  }


  /**
   * ###### ###### DATA RELATED METHODS ###### ######
   */
  public getIndexInEntries(xIndex: number): number {
    for (let i = 0; i < this.getEntryCount(); i++) {
      let dataArray: T | null = this.getEntryForIndex(i);
      if (dataArray) {
        if (xIndex == dataArray.getX()) {
          return i;
        } else {
          return -1;
        }
      }

    }
    return -1;
  }

  public removeFirst(): boolean {
    if (this.getEntryCount() > 0) {
      let entry: T | null = this.getEntryForIndex(0);
      if (entry) {
        return this.removeEntry(entry);
      }
      return true;
    } else {
      return false;
    }
  }

  public removeLast(): boolean {
    if (this.getEntryCount() > 0) {
      let e: T | null = this.getEntryForIndex(this.getEntryCount() - 1);
      if (e) {
        return this.removeEntry(e);
      }
      return true;
    } else
      return false;
  }

  public removeEntryByXValue(xValue: number): boolean {
    let e: T | null = this.getEntryForXValue(xValue, Number.NaN);
    if (e) {
      return this.removeEntry(e);
    }
    return true;
  }

  public removeEntryByIndex(index: number): boolean {
    let e: T | null = this.getEntryForIndex(index);
    if (e) {
      return this.removeEntry(e);
    }
    return true;
  }

  public contains(e: T): boolean {
    for (let i = 0; i < this.getEntryCount(); i++) {
      if (this.getEntryForIndex(i) == e)
        return true;
    }
    return false;
  }

  protected copyTo(baseDataSet: BaseDataSet<T>): void {
    baseDataSet.mAxisDependency = this.mAxisDependency;
    baseDataSet.mColors = this.mColors;
    baseDataSet.mDrawIcons = this.mDrawIcons;
    baseDataSet.mDrawValues = this.mDrawValues;
    baseDataSet.mForm = this.mForm;
    baseDataSet.mFormLineDashEffect = this.mFormLineDashEffect;
    baseDataSet.mFormLineWidth = this.mFormLineWidth;
    baseDataSet.mFormSize = this.mFormSize;
    baseDataSet.mHighlightEnabled = this.mHighlightEnabled;
    baseDataSet.mIconsOffset = this.mIconsOffset;
    baseDataSet.mValueColors = this.mValueColors;
    baseDataSet.mValueFormatter = this.mValueFormatter;
    baseDataSet.mValueColors = this.mValueColors;
    baseDataSet.mValueTextSize = this.mValueTextSize;
    baseDataSet.mVisible = this.mVisible;
  }

  abstract getYMin(): number;

  abstract getYMax(): number;

  abstract getXMin(): number;

  abstract getXMax(): number;

  abstract getEntryCount(): number;

  abstract calcMinMax();

  abstract calcMinMaxY(fromX: number, toX: number);

  abstract getEntryForXValue(xValue: number, closestToY: number, rounding?: Rounding): T | null;

  abstract getEntriesForXValue(xValue: number): JArrayList<T>;

  abstract getEntryForIndex(index: number): T;

  abstract getEntryIndex(xValue: number, closestToY: number, rounding: Rounding): number;

  abstract getEntryIndexByEntry(e: T): number;

  abstract addEntry(e: T): boolean;

  abstract addEntryOrdered(e: T);

  abstract removeEntry(e: T): boolean;

  abstract clear();
}
